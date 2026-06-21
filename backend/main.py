from fastapi import FastAPI
from app.database import engine, Base
from app.models import medecin, patient, dossier, traitement, image, prediction, audit

Base.metadata.create_all(bind=engine)

app = FastAPI(title="MedAssist AI", version="1.0.0")

@app.get("/")
def root():
    return {"message": "MedAssist AI API is running "}