def test_root():
    response = client.get("/", follow_redirects=False)
    assert response.status_code == 500

Actually wait — FastAPI's TestClient by default raises server exceptions instead of
returning 500. We need to disable that:

nano ~/practice-tour-infra/hello-service/test_main.py

Make the whole file look like this:

from fastapi.testclient import TestClient
from main import app

client = TestClient(app, raise_server_exceptions=False)

def test_root():
    response = client.get("/")
    assert response.status_code == 500

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    assert "timestamp" in response.json()
