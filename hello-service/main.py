from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message":"API v2 IS RUNNNING FROM CI/CD PIPELINE STREAM LANA DEL REY"}

# test
