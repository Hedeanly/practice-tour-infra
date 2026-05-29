from fastapi import FastAPI
from datetime import datetime

app = FastAPI()

@app.get("/")
def root():
    raise Exception("Broken on purpose :3")


@app.get("/health")
def health():
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}
