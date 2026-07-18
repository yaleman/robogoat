import math

import pytest

from webapp.calculator import (
    calculate,
    circumference_m,
    maximum_incline_deg,
    opposing_force_n,
    reduction_ratio,
    speed_from_rpm,
    torque_from_power,
)
from webapp.models import CalculationRequest, FeasibilityStatus


def mechanical_request(**overrides: object) -> CalculationRequest:
    data: dict[str, object] = {
        "sprocket_diameter_mm": 106.5,
        "robot_mass_kg": 18,
        "incline_deg": 20,
        "motor_count": 2,
        "drivetrain_efficiency": 0.7,
        "rolling_resistance": 0.08,
        "traction_coefficient": 0.8,
        "gearing": {"kind": "direct", "reduction_ratio": 96},
        "motor": {"kind": "mechanical_power", "loaded_rpm": 12_000, "power_w": 100},
    }
    data.update(overrides)
    return CalculationRequest.model_validate(data)


def dc_request(**overrides: object) -> CalculationRequest:
    data: dict[str, object] = {
        "sprocket_diameter_mm": 106.5,
        "robot_mass_kg": 18,
        "incline_deg": 20,
        "motor_count": 2,
        "drivetrain_efficiency": 0.7,
        "rolling_resistance": 0.08,
        "traction_coefficient": 0.8,
        "gearing": {"kind": "direct", "reduction_ratio": 96},
        "motor": {
            "kind": "dc_curve",
            "voltage_v": 12,
            "no_load_rpm": 16_000,
            "no_load_current_a": 1.2,
            "stall_torque_nm": 0.45,
            "stall_current_a": 35,
        },
    }
    data.update(overrides)
    return CalculationRequest.model_validate(data)


def test_geometry_and_speed() -> None:
    assert circumference_m(1000) == pytest.approx(math.pi)
    assert speed_from_rpm(60, 1, 1000) == pytest.approx(math.pi)


def test_tooth_ratio_uses_driven_over_motor() -> None:
    request = mechanical_request(
        gearing={"kind": "teeth", "motor_teeth": 20, "driven_teeth": 48}
    )
    assert reduction_ratio(request) == pytest.approx(2.4)


def test_power_to_torque_conversion() -> None:
    assert torque_from_power(2 * math.pi, 60) == pytest.approx(1)


def test_flat_ground_force_is_rolling_resistance() -> None:
    request = mechanical_request(incline_deg=0)
    assert opposing_force_n(request, 0) == pytest.approx(18 * 9.80665 * 0.08)


def test_vertical_force_excludes_rolling_resistance() -> None:
    request = mechanical_request(incline_deg=90)
    assert opposing_force_n(request, 90) == pytest.approx(18 * 9.80665)


def test_drivetrain_efficiency_reduces_available_force_and_power() -> None:
    efficient = calculate(mechanical_request(drivetrain_efficiency=1, traction_coefficient=5))
    lossy = calculate(mechanical_request(drivetrain_efficiency=0.5, traction_coefficient=5))
    assert efficient.available_power_w == pytest.approx(lossy.available_power_w * 2)
    assert efficient.available_force_n > lossy.available_force_n


def test_dc_curve_slows_and_draws_more_current_under_load() -> None:
    flat = calculate(dc_request(incline_deg=0))
    slope = calculate(dc_request(incline_deg=30))
    assert slope.sustainable_speed_mps < flat.sustainable_speed_mps
    assert slope.estimated_current_per_motor_a > flat.estimated_current_per_motor_a
    assert slope.sustainable_speed_mps > 0


def test_insufficient_torque_reports_typed_failure() -> None:
    result = calculate(mechanical_request(motor={"kind": "mechanical_torque", "loaded_rpm": 12_000, "torque_nm": 0.001}))
    assert result.status == FeasibilityStatus.INFEASIBLE
    assert result.limiting_factor == "torque"
    assert {warning.code for warning in result.warnings} >= {"torque_limited", "stalled"}


def test_insufficient_traction_reports_typed_failure() -> None:
    result = calculate(mechanical_request(traction_mode="friction_only", traction_coefficient=0.01))
    assert result.status == FeasibilityStatus.INFEASIBLE
    assert result.limiting_factor == "traction"


def test_dc_traction_failure_still_reports_motor_power_demand() -> None:
    result = calculate(dc_request(traction_mode="friction_only", traction_coefficient=0.01))
    assert result.sustainable_speed_mps == 0
    assert result.required_power_w > 0


def test_over_power_operation_is_infeasible() -> None:
    result = calculate(mechanical_request(robot_mass_kg=100, incline_deg=10))
    assert result.status == FeasibilityStatus.INFEASIBLE
    assert result.power_budget_percent > 100


def test_valid_configuration_has_incline_limit() -> None:
    request = dc_request(traction_mode="friction_only")
    result = calculate(request)
    assert result.status in {FeasibilityStatus.FEASIBLE, FeasibilityStatus.MARGINAL}
    assert request.incline_deg < result.maximum_incline_deg < 90
    assert maximum_incline_deg(request) == pytest.approx(result.maximum_incline_deg)


def test_positive_engagement_bypasses_friction_cap() -> None:
    friction = calculate(mechanical_request(incline_deg=35, traction_mode="friction_only", traction_coefficient=0.6))
    engaged = calculate(mechanical_request(incline_deg=35, traction_mode="positive_engagement", traction_coefficient=0.6))
    assert friction.limiting_factor == "traction"
    assert friction.status == FeasibilityStatus.INFEASIBLE
    assert engaged.status == FeasibilityStatus.FEASIBLE
    assert engaged.traction_limit_n is None
    assert engaged.power_budget_percent == pytest.approx(56.1, abs=0.1)


def test_dc_stall_returns_zero_speed() -> None:
    result = calculate(dc_request(robot_mass_kg=500, incline_deg=45, traction_coefficient=5))
    assert result.status == FeasibilityStatus.INFEASIBLE
    assert result.sustainable_speed_mps == 0
