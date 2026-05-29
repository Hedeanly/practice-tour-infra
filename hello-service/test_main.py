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

