# RoboGoat

Mechanical models and analysis tools for the RoboGoat tracked platform.

## Drivetrain feasibility calculator

The calculator compares the platform's estimated speed, torque, traction and
power against a requested incline. Its defaults reflect the current 106.5 mm
drive sprocket, two-motor layout and 96:1 total reduction, but every assumption
is editable.

Run it locally:

```console
uv run uvicorn webapp.main:app --reload
```

Then open `http://127.0.0.1:8000`.

Run its calculation and API tests with:

```console
uv run pytest
```

The results are estimates. Stair impacts, acceleration, track deformation,
cooling, battery sag and structural strength require physical validation.
