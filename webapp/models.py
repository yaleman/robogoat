from enum import StrEnum
from typing import Annotated, Literal

from pydantic import BaseModel, Field, model_validator


class DirectGearing(BaseModel):
    kind: Literal["direct"]
    reduction_ratio: float = Field(gt=0, le=100_000)


class ToothGearing(BaseModel):
    kind: Literal["teeth"]
    motor_teeth: int = Field(gt=0, le=10_000)
    driven_teeth: int = Field(gt=0, le=100_000)


Gearing = Annotated[DirectGearing | ToothGearing, Field(discriminator="kind")]


class MechanicalPowerMotor(BaseModel):
    kind: Literal["mechanical_power"]
    loaded_rpm: float = Field(gt=0, le=1_000_000)
    power_w: float = Field(gt=0, le=1_000_000)


class MechanicalTorqueMotor(BaseModel):
    kind: Literal["mechanical_torque"]
    loaded_rpm: float = Field(gt=0, le=1_000_000)
    torque_nm: float = Field(gt=0, le=100_000)


class DcMotor(BaseModel):
    kind: Literal["dc_curve"]
    voltage_v: float = Field(gt=0, le=1_000)
    no_load_rpm: float = Field(gt=0, le=1_000_000)
    no_load_current_a: float = Field(ge=0, le=100_000)
    stall_torque_nm: float = Field(gt=0, le=100_000)
    stall_current_a: float = Field(gt=0, le=100_000)

    @model_validator(mode="after")
    def current_order_is_physical(self) -> "DcMotor":
        if self.stall_current_a <= self.no_load_current_a:
            raise ValueError("stall current must be greater than no-load current")
        return self


Motor = Annotated[
    MechanicalPowerMotor | MechanicalTorqueMotor | DcMotor,
    Field(discriminator="kind"),
]


class TractionMode(StrEnum):
    POSITIVE_ENGAGEMENT = "positive_engagement"
    FRICTION_ONLY = "friction_only"


class CalculationRequest(BaseModel):
    sprocket_diameter_mm: float = Field(gt=0, le=10_000)
    robot_mass_kg: float = Field(gt=0, le=100_000)
    incline_deg: float = Field(ge=0, le=90)
    motor_count: int = Field(gt=0, le=100)
    drivetrain_efficiency: float = Field(gt=0, le=1)
    rolling_resistance: float = Field(ge=0, le=2)
    traction_coefficient: float = Field(gt=0, le=5)
    traction_mode: TractionMode = TractionMode.POSITIVE_ENGAGEMENT
    gearing: Gearing
    motor: Motor


class FeasibilityStatus(StrEnum):
    FEASIBLE = "feasible"
    MARGINAL = "marginal"
    INFEASIBLE = "infeasible"


class WarningSeverity(StrEnum):
    INFO = "info"
    CAUTION = "caution"
    CRITICAL = "critical"


class WarningCode(StrEnum):
    ASSUMPTIONS = "assumptions"
    MARGINAL = "marginal"
    POWER_LIMITED = "power_limited"
    TORQUE_LIMITED = "torque_limited"
    TRACTION_LIMITED = "traction_limited"
    STALLED = "stalled"
    ENGAGEMENT_ASSUMED = "engagement_assumed"


class CalculationWarning(BaseModel):
    code: WarningCode
    severity: WarningSeverity
    message: str


class CalculationResult(BaseModel):
    status: FeasibilityStatus
    limiting_factor: Literal["none", "power", "torque", "traction"]
    reduction_ratio: float
    circumference_m: float
    theoretical_speed_mps: float
    theoretical_speed_kmh: float
    sustainable_speed_mps: float
    sustainable_speed_kmh: float
    required_force_n: float
    available_force_n: float
    traction_limit_n: float | None
    required_wheel_torque_nm: float
    required_motor_torque_nm: float
    available_motor_torque_nm: float
    required_power_w: float
    available_power_w: float
    power_budget_percent: float
    power_margin_percent: float
    maximum_incline_deg: float
    estimated_current_per_motor_a: float | None
    estimated_total_current_a: float | None
    warnings: list[CalculationWarning]
