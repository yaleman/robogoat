import math
from dataclasses import dataclass

from webapp.models import (
    CalculationRequest,
    CalculationResult,
    CalculationWarning,
    DcMotor,
    FeasibilityStatus,
    MechanicalPowerMotor,
    MechanicalTorqueMotor,
    TractionMode,
    ToothGearing,
    WarningCode,
    WarningSeverity,
)

GRAVITY_MPS2 = 9.80665
MARGINAL_THRESHOLD = 0.8


@dataclass(frozen=True)
class OperatingPoint:
    speed_mps: float
    theoretical_speed_mps: float
    required_force_n: float
    motor_force_limit_n: float
    traction_limit_n: float | None
    required_motor_torque_nm: float
    available_motor_torque_nm: float
    required_power_w: float
    available_power_w: float
    estimated_current_per_motor_a: float | None


def reduction_ratio(request: CalculationRequest) -> float:
    gearing = request.gearing
    if isinstance(gearing, ToothGearing):
        return gearing.driven_teeth / gearing.motor_teeth
    return gearing.reduction_ratio


def circumference_m(diameter_mm: float) -> float:
    return math.pi * diameter_mm / 1_000


def speed_from_rpm(rpm: float, ratio: float, diameter_mm: float) -> float:
    return rpm / ratio / 60 * circumference_m(diameter_mm)


def opposing_force_n(request: CalculationRequest, incline_deg: float) -> float:
    angle = math.radians(incline_deg)
    weight = request.robot_mass_kg * GRAVITY_MPS2
    return weight * (
        math.sin(angle) + request.rolling_resistance * math.cos(angle)
    )


def traction_limit_n(request: CalculationRequest, incline_deg: float) -> float | None:
    if request.traction_mode == TractionMode.POSITIVE_ENGAGEMENT:
        return None
    normal_force = request.robot_mass_kg * GRAVITY_MPS2 * math.cos(
        math.radians(incline_deg)
    )
    return request.traction_coefficient * normal_force


def available_force_n(point: OperatingPoint) -> float:
    if point.traction_limit_n is None:
        return point.motor_force_limit_n
    return min(point.motor_force_limit_n, point.traction_limit_n)


def traction_is_sufficient(point: OperatingPoint) -> bool:
    return (
        point.traction_limit_n is None
        or point.required_force_n <= point.traction_limit_n
    )


def torque_from_power(power_w: float, rpm: float) -> float:
    return power_w / (rpm * 2 * math.pi / 60)


def _mechanical_operating_point(
    request: CalculationRequest, incline_deg: float
) -> OperatingPoint:
    motor = request.motor
    if isinstance(motor, MechanicalPowerMotor):
        motor_power_w = motor.power_w
        motor_torque_nm = torque_from_power(motor.power_w, motor.loaded_rpm)
    elif isinstance(motor, MechanicalTorqueMotor):
        motor_torque_nm = motor.torque_nm
        motor_power_w = motor.torque_nm * motor.loaded_rpm * 2 * math.pi / 60
    else:
        raise TypeError("mechanical operating point requires a mechanical motor")

    ratio = reduction_ratio(request)
    radius_m = request.sprocket_diameter_mm / 2_000
    theoretical_speed = speed_from_rpm(motor.loaded_rpm, ratio, request.sprocket_diameter_mm)
    required_force = opposing_force_n(request, incline_deg)
    motor_force_limit = (
        motor_torque_nm
        * request.motor_count
        * ratio
        * request.drivetrain_efficiency
        / radius_m
    )
    traction = traction_limit_n(request, incline_deg)
    available_power = motor_power_w * request.motor_count * request.drivetrain_efficiency
    required_power = required_force * theoretical_speed
    sustainable_speed = (
        min(theoretical_speed, available_power / required_force)
        if required_force > 0
        and required_force <= motor_force_limit
        and (traction is None or required_force <= traction)
        else theoretical_speed if required_force == 0 else 0
    )
    return OperatingPoint(
        speed_mps=sustainable_speed,
        theoretical_speed_mps=theoretical_speed,
        required_force_n=required_force,
        motor_force_limit_n=motor_force_limit,
        traction_limit_n=traction,
        required_motor_torque_nm=required_force
        * radius_m
        / (ratio * request.drivetrain_efficiency * request.motor_count),
        available_motor_torque_nm=motor_torque_nm,
        required_power_w=required_power,
        available_power_w=available_power,
        estimated_current_per_motor_a=None,
    )


def _dc_operating_point(request: CalculationRequest, incline_deg: float) -> OperatingPoint:
    motor = request.motor
    if not isinstance(motor, DcMotor):
        raise TypeError("DC operating point requires a DC motor")

    ratio = reduction_ratio(request)
    radius_m = request.sprocket_diameter_mm / 2_000
    required_force = opposing_force_n(request, incline_deg)
    required_motor_torque = (
        required_force
        * radius_m
        / (ratio * request.drivetrain_efficiency * request.motor_count)
    )
    torque_fraction = required_motor_torque / motor.stall_torque_nm
    theoretical_speed = speed_from_rpm(
        motor.no_load_rpm, ratio, request.sprocket_diameter_mm
    )
    traction = traction_limit_n(request, incline_deg)
    motor_curve_speed = (
        theoretical_speed * max(0, 1 - torque_fraction) if torque_fraction < 1 else 0
    )
    speed = motor_curve_speed if traction is None or required_force <= traction else 0
    current = motor.no_load_current_a + (
        motor.stall_current_a - motor.no_load_current_a
    ) * min(1, max(0, torque_fraction))
    no_load_omega = motor.no_load_rpm * 2 * math.pi / 60
    maximum_power = (
        motor.stall_torque_nm
        * no_load_omega
        / 4
        * request.motor_count
        * request.drivetrain_efficiency
    )
    motor_force_limit = (
        motor.stall_torque_nm
        * request.motor_count
        * ratio
        * request.drivetrain_efficiency
        / radius_m
    )
    return OperatingPoint(
        speed_mps=speed,
        theoretical_speed_mps=theoretical_speed,
        required_force_n=required_force,
        motor_force_limit_n=motor_force_limit,
        traction_limit_n=traction,
        required_motor_torque_nm=required_motor_torque,
        available_motor_torque_nm=motor.stall_torque_nm,
        required_power_w=required_force * motor_curve_speed,
        available_power_w=maximum_power,
        estimated_current_per_motor_a=current,
    )


def operating_point(request: CalculationRequest, incline_deg: float) -> OperatingPoint:
    if isinstance(request.motor, DcMotor):
        return _dc_operating_point(request, incline_deg)
    return _mechanical_operating_point(request, incline_deg)


def _is_sustainable(point: OperatingPoint) -> bool:
    return (
        point.speed_mps > 0
        and point.required_force_n <= point.motor_force_limit_n
        and traction_is_sufficient(point)
        and point.required_power_w <= point.available_power_w + 1e-9
    )


def maximum_incline_deg(request: CalculationRequest) -> float:
    if not _is_sustainable(operating_point(request, 0)):
        return 0
    if _is_sustainable(operating_point(request, 90)):
        return 90
    low, high = 0.0, 90.0
    for _ in range(50):
        middle = (low + high) / 2
        if _is_sustainable(operating_point(request, middle)):
            low = middle
        else:
            high = middle
    return low


def calculate(request: CalculationRequest) -> CalculationResult:
    point = operating_point(request, request.incline_deg)
    available_force = available_force_n(point)
    power_fraction = (
        point.required_power_w / point.available_power_w
        if point.available_power_w > 0
        else math.inf
    )
    force_fraction = (
        point.required_force_n / available_force if available_force > 0 else math.inf
    )
    load_fraction = max(power_fraction, force_fraction)
    sustainable = _is_sustainable(point)
    status = (
        FeasibilityStatus.INFEASIBLE
        if not sustainable
        else FeasibilityStatus.MARGINAL
        if load_fraction >= MARGINAL_THRESHOLD
        else FeasibilityStatus.FEASIBLE
    )

    limiting_factor = "none"
    if point.traction_limit_n is not None and point.required_force_n > point.traction_limit_n:
        limiting_factor = "traction"
    elif point.required_force_n > point.motor_force_limit_n:
        limiting_factor = "torque"
    elif point.required_power_w > point.available_power_w:
        limiting_factor = "power"
    elif status == FeasibilityStatus.MARGINAL:
        constraints = {
            "torque": point.required_force_n / point.motor_force_limit_n,
            "power": power_fraction,
        }
        if point.traction_limit_n is not None:
            constraints["traction"] = point.required_force_n / point.traction_limit_n
        limiting_factor = max(constraints, key=constraints.get)  # type: ignore[arg-type]

    warnings = [
        CalculationWarning(
            code=WarningCode.ASSUMPTIONS,
            severity=WarningSeverity.INFO,
            message="Estimate excludes impacts, acceleration, track deformation, cooling, battery sag and structural limits.",
        )
    ]
    if request.traction_mode == TractionMode.POSITIVE_ENGAGEMENT:
        warnings.append(
            CalculationWarning(
                code=WarningCode.ENGAGEMENT_ASSUMED,
                severity=WarningSeverity.CAUTION,
                message="Assumes the tracks remain positively engaged with multiple stair edges and cannot slip.",
            )
        )
    if limiting_factor == "traction":
        warnings.append(CalculationWarning(code=WarningCode.TRACTION_LIMITED, severity=WarningSeverity.CRITICAL, message="Required force exceeds the configured track traction."))
    if limiting_factor == "torque":
        warnings.append(CalculationWarning(code=WarningCode.TORQUE_LIMITED, severity=WarningSeverity.CRITICAL, message="Required motor torque exceeds the available torque."))
    if limiting_factor == "power":
        warnings.append(CalculationWarning(code=WarningCode.POWER_LIMITED, severity=WarningSeverity.CRITICAL, message="Required mechanical power exceeds the available output."))
    if point.speed_mps <= 0:
        warnings.append(CalculationWarning(code=WarningCode.STALLED, severity=WarningSeverity.CRITICAL, message="The model predicts no sustainable forward speed."))
    elif status == FeasibilityStatus.MARGINAL:
        warnings.append(CalculationWarning(code=WarningCode.MARGINAL, severity=WarningSeverity.CAUTION, message="Less than 20% calculated margin remains; allow substantially more for real stairs."))

    radius_m = request.sprocket_diameter_mm / 2_000
    return CalculationResult(
        status=status,
        limiting_factor=limiting_factor,
        reduction_ratio=reduction_ratio(request),
        circumference_m=circumference_m(request.sprocket_diameter_mm),
        theoretical_speed_mps=point.theoretical_speed_mps,
        theoretical_speed_kmh=point.theoretical_speed_mps * 3.6,
        sustainable_speed_mps=point.speed_mps,
        sustainable_speed_kmh=point.speed_mps * 3.6,
        required_force_n=point.required_force_n,
        available_force_n=available_force,
        traction_limit_n=point.traction_limit_n,
        required_wheel_torque_nm=point.required_force_n * radius_m,
        required_motor_torque_nm=point.required_motor_torque_nm,
        available_motor_torque_nm=point.available_motor_torque_nm,
        required_power_w=point.required_power_w,
        available_power_w=point.available_power_w,
        power_budget_percent=power_fraction * 100,
        power_margin_percent=(1 - power_fraction) * 100,
        maximum_incline_deg=maximum_incline_deg(request),
        estimated_current_per_motor_a=point.estimated_current_per_motor_a,
        estimated_total_current_a=point.estimated_current_per_motor_a
        * request.motor_count
        if point.estimated_current_per_motor_a is not None
        else None,
        warnings=warnings,
    )
