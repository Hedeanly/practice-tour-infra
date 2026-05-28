from fastapi import FastAPI
from datetime import datetime

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Tour Guide API v3", "environment": "powered by CI/CD"}

@app.get("/health")
def health():
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}
