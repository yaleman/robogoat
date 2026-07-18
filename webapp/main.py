from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from webapp.calculator import calculate
from webapp.models import CalculationRequest, CalculationResult

STATIC_DIR = Path(__file__).parent / "static"

app = FastAPI(title="RoboGoat feasibility calculator", version="0.1.0")
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")


@app.get("/", include_in_schema=False)
def index() -> FileResponse:
    return FileResponse(STATIC_DIR / "index.html")


@app.post("/api/calculate", response_model=CalculationResult)
def calculate_feasibility(request: CalculationRequest) -> CalculationResult:
    return calculate(request)
