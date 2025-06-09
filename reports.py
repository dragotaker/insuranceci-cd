"""
SQL queries for reports generation
"""

from database import get_db_connection

# Анализ клиентской базы по возрасту
CLIENT_AGE_ANALYSIS_QUERY = """
    WITH client_age_stats AS (
        SELECT 
            c.category_id,
            c.category_name,
            COUNT(DISTINCT p.client_id) as total_clients,
            COUNT(DISTINCT CASE 
                WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, cl.birth_date)) < 30 
                THEN p.client_id 
            END) as young_clients,
            COUNT(DISTINCT CASE 
                WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, cl.birth_date)) >= 30 
                AND EXTRACT(YEAR FROM AGE(CURRENT_DATE, cl.birth_date)) < 50
                THEN p.client_id 
            END) as middle_clients,
            COUNT(DISTINCT CASE 
                WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, cl.birth_date)) >= 50 
                THEN p.client_id 
            END) as senior_clients,
            ROUND(COALESCE(AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, cl.birth_date))), 0)::numeric, 1) as avg_client_age
        FROM insurance.category_insurances c
        LEFT JOIN insurance.insurance_policies p ON c.category_id = p.category_id
        LEFT JOIN insurance.clients cl ON p.client_id = cl.client_id
        GROUP BY c.category_id, c.category_name
    )
    SELECT 
        *,
        ROUND(COALESCE((young_clients::numeric / NULLIF(total_clients, 0) * 100), 0)::numeric, 2) as young_clients_percentage,
        ROUND(COALESCE((middle_clients::numeric / NULLIF(total_clients, 0) * 100), 0)::numeric, 2) as middle_clients_percentage,
        ROUND(COALESCE((senior_clients::numeric / NULLIF(total_clients, 0) * 100), 0)::numeric, 2) as senior_clients_percentage
    FROM client_age_stats
    ORDER BY total_clients DESC
"""

# Анализ страховых случаев и рекомендации по ставкам
INSURANCE_CASES_ANALYSIS_QUERY = """
    WITH case_stats AS (
        SELECT 
            c.category_id,
            c.category_name,
            COALESCE(c.base_rate, 0) as base_rate,
            e.event_name,
            COUNT(DISTINCT pe.policy_event_id) as total_events,
            COUNT(DISTINCT CASE WHEN cl.status = 'approved' THEN cl.claim_id END) as approved_claims,
            ROUND(COALESCE(AVG(CASE WHEN cl.status = 'approved' THEN cl.approved_amount END), 0)::numeric, 2) as avg_claim_amount,
            ROUND(COALESCE((COUNT(DISTINCT CASE WHEN cl.status = 'approved' THEN cl.claim_id END)::numeric / 
                   NULLIF(COUNT(DISTINCT pe.policy_event_id), 0) * 100), 0)::numeric, 2) as claim_rate
        FROM insurance.category_insurances c
        LEFT JOIN insurance.insured_events e ON c.category_id = e.category_id
        LEFT JOIN insurance.policy_events pe ON e.event_id = pe.event_id
        LEFT JOIN insurance.insurance_claims cl ON pe.policy_event_id = cl.policy_event_id
        GROUP BY c.category_id, c.category_name, c.base_rate, e.event_name
    ),
    category_analysis AS (
        SELECT 
            category_id,
            category_name,
            base_rate,
            COALESCE(SUM(total_events), 0) as total_events,
            COALESCE(SUM(approved_claims), 0) as total_approved_claims,
            ROUND(COALESCE(AVG(avg_claim_amount), 0)::numeric, 2) as avg_claim_amount,
            ROUND(COALESCE(AVG(claim_rate), 0)::numeric, 2) as avg_claim_rate,
            CASE 
                WHEN COALESCE(AVG(claim_rate), 0) > 50 OR COALESCE(AVG(avg_claim_amount), 0) > 200000 THEN 1.4
                WHEN COALESCE(AVG(claim_rate), 0) > 30 OR COALESCE(AVG(avg_claim_amount), 0) > 100000 THEN 1.3
                WHEN COALESCE(AVG(claim_rate), 0) > 15 OR COALESCE(AVG(avg_claim_amount), 0) > 50000 THEN 1.2
                ELSE 1.1
            END as risk_factor
        FROM case_stats
        GROUP BY category_id, category_name, base_rate
    )
    SELECT 
        ca.*,
        ROUND((base_rate * risk_factor)::numeric, 2) as recommended_rate,
        ROUND(((base_rate * risk_factor) - base_rate)::numeric, 2) as rate_adjustment,
        CASE 
            WHEN risk_factor >= 1.4 THEN 'Высокий риск'
            WHEN risk_factor >= 1.2 THEN 'Средний риск'
            ELSE 'Низкий риск'
        END as risk_level,
        COALESCE(
            (
                SELECT json_agg(json_build_object(
                    'event_name', event_name,
                    'total_events', total_events,
                    'approved_claims', approved_claims,
                    'avg_claim_amount', avg_claim_amount,
                    'claim_rate', claim_rate
                ))
                FROM case_stats cs
                WHERE cs.category_id = ca.category_id
            ),
            '[]'::json
        ) as event_details
    FROM category_analysis ca
    ORDER BY risk_factor DESC
"""

def get_report_data(cur):
    """Get all report data"""
    # Execute client age analysis query
    cur.execute(CLIENT_AGE_ANALYSIS_QUERY)
    client_age_analysis = [dict(zip([
        'category_id', 'category_name', 'total_clients', 'young_clients',
        'middle_clients', 'senior_clients', 'avg_client_age', 'young_clients_percentage',
        'middle_clients_percentage', 'senior_clients_percentage'
    ], row)) for row in cur.fetchall()]

    # Execute insurance cases analysis query
    cur.execute(INSURANCE_CASES_ANALYSIS_QUERY)
    insurance_cases_analysis = [dict(zip([
        'category_id', 'category_name', 'base_rate', 'total_events',
        'total_approved_claims', 'avg_claim_amount', 'avg_claim_rate',
        'risk_factor', 'recommended_rate', 'rate_adjustment', 'risk_level',
        'event_details'
    ], row)) for row in cur.fetchall()]

    # Calculate summary statistics for client age analysis
    total_clients = sum(cat['total_clients'] for cat in client_age_analysis)
    total_young = sum(cat['young_clients'] for cat in client_age_analysis)
    total_middle = sum(cat['middle_clients'] for cat in client_age_analysis)
    total_senior = sum(cat['senior_clients'] for cat in client_age_analysis)
    avg_age = sum(cat['avg_client_age'] * cat['total_clients'] for cat in client_age_analysis) / total_clients if total_clients > 0 else 0

    # Calculate summary statistics for insurance cases analysis
    total_categories = len(insurance_cases_analysis)
    total_adjustment = sum(abs(cat['rate_adjustment']) for cat in insurance_cases_analysis)
    high_risk_categories = sum(1 for cat in insurance_cases_analysis if cat['risk_level'] == 'Высокий риск')

    # Return formatted data structure
    return {
        'client_age_analysis': {
            'details': client_age_analysis,
            'summary': {
                'total_clients': total_clients,
                'young_clients': total_young,
                'middle_clients': total_middle,
                'senior_clients': total_senior,
                'avg_client_age': round(avg_age, 1),
                'young_clients_percentage': round((total_young / total_clients * 100) if total_clients > 0 else 0, 2),
                'middle_clients_percentage': round((total_middle / total_clients * 100) if total_clients > 0 else 0, 2),
                'senior_clients_percentage': round((total_senior / total_clients * 100) if total_clients > 0 else 0, 2)
            }
        },
        'insurance_cases_analysis': {
            'details': insurance_cases_analysis,
            'summary': {
                'total_categories': total_categories,
                'total_adjustment': round(total_adjustment, 2),
                'high_risk_categories': high_risk_categories,
                'risk_distribution': {
                    'high': high_risk_categories,
                    'medium': sum(1 for cat in insurance_cases_analysis if cat['risk_level'] == 'Средний риск'),
                    'low': sum(1 for cat in insurance_cases_analysis if cat['risk_level'] == 'Низкий риск')
                }
            }
        }
    } 