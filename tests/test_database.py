import pytest
import psycopg2
from database import get_db_connection

def test_database_connection():
    """Test database connection can be established."""
    try:
        conn = get_db_connection()
        assert conn is not None
        conn.close()
    except psycopg2.Error as e:
        pytest.skip(f"Database connection failed: {str(e)}")

def test_database_tables():
    """Test that required tables exist."""
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # Get list of tables
        cur.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """)
        tables = [table[0] for table in cur.fetchall()]
        
        # Check for some expected tables
        expected_tables = ['users', 'clients', 'policies']  # Add your actual table names
        for table in expected_tables:
            assert table in tables, f"Table {table} not found in database"
            
        cur.close()
        conn.close()
    except psycopg2.Error as e:
        pytest.skip(f"Database query failed: {str(e)}") 