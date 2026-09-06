from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="student-ml-api")

VERSION = "1.1.0"
MODEL_VERSION = "model-1"


class PredictionInput(BaseModel):
    value: float


@app.get("/health")
def health():
    return {
        "status": "healthy",
        "application": "student-ml-api",
        "application_version": VERSION,
        "model_version": MODEL_VERSION
    }


@app.post("/predict")
def predict(data: PredictionInput):
    prediction = data.value * 2

    return {
        "input": data.value,
        "prediction": prediction
    }
