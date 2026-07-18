from fastapi.testclient import TestClient

from webapp.main import app

client = TestClient(app)


BASE_REQUEST = {
    "sprocket_diameter_mm": 106.5,
    "robot_mass_kg": 18,
    "incline_deg": 20,
    "motor_count": 2,
    "drivetrain_efficiency": 0.7,
    "rolling_resistance": 0.08,
    "traction_coefficient": 0.8,
    "gearing": {"kind": "direct", "reduction_ratio": 96},
}


def test_page_and_static_assets_are_served() -> None:
    response = client.get("/")
    assert response.status_code == 200
    assert "Will this thing climb?" in response.text
    assert client.get("/static/app.js").status_code == 200


def test_mechanical_request() -> None:
    response = client.post(
        "/api/calculate",
        json=BASE_REQUEST
        | {"motor": {"kind": "mechanical_power", "loaded_rpm": 12_000, "power_w": 100}},
    )
    assert response.status_code == 200
    assert response.json()["reduction_ratio"] == 96
    assert response.json()["estimated_total_current_a"] is None
    assert response.json()["traction_limit_n"] is None


def test_dc_request() -> None:
    response = client.post(
        "/api/calculate",
        json=BASE_REQUEST
        | {"motor": {"kind": "dc_curve", "voltage_v": 12, "no_load_rpm": 16_000, "no_load_current_a": 1.2, "stall_torque_nm": 0.45, "stall_current_a": 35}},
    )
    assert response.status_code == 200
    assert response.json()["estimated_total_current_a"] > 0


def test_validation_errors_are_structured() -> None:
    response = client.post(
        "/api/calculate",
        json=BASE_REQUEST
        | {"incline_deg": 91, "motor": {"kind": "mechanical_power", "loaded_rpm": 0, "power_w": 100}},
    )
    assert response.status_code == 422
    assert isinstance(response.json()["detail"], list)
    locations = [item["loc"] for item in response.json()["detail"]]
    assert ["body", "incline_deg"] in locations
    assert ["body", "motor", "mechanical_power", "loaded_rpm"] in locations
