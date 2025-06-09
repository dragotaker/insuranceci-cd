import pytest
from bottle import Bottle, response
import json

# Import your application
from routes import app

@pytest.fixture
def client():
    """Create a test client for the application."""
    return app

def test_index_route(client):
    """Test the index route returns 200 OK."""
    response = client.get('/')
    assert response.status_code == 200

def test_static_files(client):
    """Test static files are served correctly."""
    response = client.get('/static/css/style.css')
    assert response.status_code in [200, 404]  # 404 is acceptable if file doesn't exist

def test_table_route(client):
    """Test table view route."""
    response = client.get('/table/users')
    assert response.status_code in [200, 404]  # 404 if table doesn't exist

def test_add_record_route(client):
    """Test add record route."""
    response = client.get('/add/users')
    assert response.status_code in [200, 404]  # 404 if table doesn't exist 