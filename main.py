from fastapi import FastAPI
from app.database import engine, Base
from app.models import medecin, patient, dossier, traitement, image, prediction, audit
from app.routers import auth, patients, dossiers, traitements

Base.metadata.create_all(bind=engine)

app = FastAPI(title="MedAssist AI", version="1.0.0")

app.include_router(auth.router)
app.include_router(patients.router)
app.include_router(dossiers.router)
app.include_router(traitements.router)

@app.get("/")
def root():
    return {"message": "MedAssist AI API is running"}
