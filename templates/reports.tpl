% rebase('templates/layout.tpl', title='Статистические отчеты', current_page='reports')

<div class="reports-container">
    <!-- Анализ клиентской базы -->
    <div class="stats-section">
        <h2>Анализ клиентской базы по возрасту</h2>
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Всего клиентов</h3>
                <p class="stat-value">{{client_age_analysis['summary']['total_clients']}}</p>
            </div>
            <div class="stat-card">
                <h3>Молодые клиенты</h3>
                <p class="stat-value">{{client_age_analysis['summary']['young_clients']}} ({{client_age_analysis['summary']['young_clients_percentage']}}%)</p>
            </div>
            <div class="stat-card">
                <h3>Клиенты среднего возраста</h3>
                <p class="stat-value">{{client_age_analysis['summary']['middle_clients']}} ({{client_age_analysis['summary']['middle_clients_percentage']}}%)</p>
            </div>
            <div class="stat-card">
                <h3>Пожилые клиенты</h3>
                <p class="stat-value">{{client_age_analysis['summary']['senior_clients']}} ({{client_age_analysis['summary']['senior_clients_percentage']}}%)</p>
            </div>
            <div class="stat-card">
                <h3>Средний возраст</h3>
                <p class="stat-value">{{client_age_analysis['summary']['avg_client_age']}} лет</p>
            </div>
        </div>

        <div class="table-container">
            <h3>Детали по категориям</h3>
            <table>
                <thead>
                    <tr>
                        <th>Категория</th>
                        <th>Всего клиентов</th>
                        <th>Молодые</th>
                        <th>Средний возраст</th>
                        <th>Пожилые</th>
                        <th>Средний возраст</th>
                    </tr>
                </thead>
                <tbody>
                    % for client in client_age_analysis['details']:
                    <tr>
                        <td>{{client['category_name']}}</td>
                        <td>{{client['total_clients']}}</td>
                        <td>{{client['young_clients']}} ({{client['young_clients_percentage']}}%)</td>
                        <td>{{client['middle_clients']}} ({{client['middle_clients_percentage']}}%)</td>
                        <td>{{client['senior_clients']}} ({{client['senior_clients_percentage']}}%)</td>
                        <td>{{client['avg_client_age']}} лет</td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>
    </div>

    <!-- Анализ страховых случаев -->
    <div class="stats-section">
        <h2>Анализ страховых случаев и рекомендации по ставкам</h2>
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Всего категорий</h3>
                <p class="stat-value">{{insurance_cases_analysis['summary']['total_categories']}}</p>
            </div>
            <div class="stat-card">
                <h3>Общая корректировка</h3>
                <p class="stat-value">{{insurance_cases_analysis['summary']['total_adjustment']}} ₽</p>
            </div>
            <div class="stat-card">
                <h3>Категории высокого риска</h3>
                <p class="stat-value">{{insurance_cases_analysis['summary']['high_risk_categories']}}</p>
            </div>
        </div>

        <div class="risk-distribution">
            <h3>Распределение по уровню риска</h3>
            <div class="distribution-bars">
                <div class="distribution-bar">
                    <div class="bar-label">Высокий</div>
                    <div class="bar-container">
                        <div class="bar high-risk" style="width: {{(insurance_cases_analysis['summary']['risk_distribution']['high'] / insurance_cases_analysis['summary']['total_categories'] * 100) if insurance_cases_analysis['summary']['total_categories'] > 0 else 0}}%"></div>
                    </div>
                    <div class="bar-value">{{insurance_cases_analysis['summary']['risk_distribution']['high']}}</div>
                </div>
                <div class="distribution-bar">
                    <div class="bar-label">Средний</div>
                    <div class="bar-container">
                        <div class="bar medium-risk" style="width: {{(insurance_cases_analysis['summary']['risk_distribution']['medium'] / insurance_cases_analysis['summary']['total_categories'] * 100) if insurance_cases_analysis['summary']['total_categories'] > 0 else 0}}%"></div>
                    </div>
                    <div class="bar-value">{{insurance_cases_analysis['summary']['risk_distribution']['medium']}}</div>
                </div>
                <div class="distribution-bar">
                    <div class="bar-label">Низкий</div>
                    <div class="bar-container">
                        <div class="bar low-risk" style="width: {{(insurance_cases_analysis['summary']['risk_distribution']['low'] / insurance_cases_analysis['summary']['total_categories'] * 100) if insurance_cases_analysis['summary']['total_categories'] > 0 else 0}}%"></div>
                    </div>
                    <div class="bar-value">{{insurance_cases_analysis['summary']['risk_distribution']['low']}}</div>
                </div>
            </div>
        </div>

        <div class="table-container">
            <h3>Детали по категориям</h3>
            <table>
                <thead>
                    <tr>
                        <th>Категория</th>
                        <th>Текущая ставка</th>
                        <th>Рекомендуемая ставка</th>
                        <th>Корректировка</th>
                        <th>Уровень риска</th>
                        <th>Частота претензий</th>
                    </tr>
                </thead>
                <tbody>
                    % for case in insurance_cases_analysis['details']:
                    <tr>
                        <td>{{case['category_name']}}</td>
                        <td>{{case['base_rate']}} ₽</td>
                        <td>{{case['recommended_rate']}} ₽</td>
                        <td class="{{'positive' if case['rate_adjustment'] > 0 else 'negative'}}">
                            {{case['rate_adjustment']}} ₽
                        </td>
                        <td class="risk-level {{case['risk_level'].lower().replace(' ', '-')}}">
                            {{case['risk_level']}}
                        </td>
                        <td>{{case['avg_claim_rate']}}%</td>
                    </tr>
                    % end
                </tbody>
            </table>
        </div>
    </div>
</div>

<style>
.reports-container {
    padding: 20px;
}

.stats-section {
    margin-bottom: 30px;
    background: white;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.stats-section h2 {
    color: #2c3e50;
    margin-bottom: 20px;
    padding-bottom: 10px;
    border-bottom: 2px solid #eee;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
}

.stat-card {
    background: #f8f9fa;
    padding: 15px;
    border-radius: 6px;
    text-align: center;
}

.stat-card h3 {
    color: #6c757d;
    font-size: 0.9em;
    margin-bottom: 10px;
}

.stat-value {
    font-size: 1.5em;
    font-weight: bold;
    color: #2c3e50;
}

.table-container {
    overflow-x: auto;
    margin-top: 20px;
}

table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 10px;
}

th, td {
    padding: 12px;
    text-align: left;
    border-bottom: 1px solid #dee2e6;
}

th {
    background-color: #f8f9fa;
    font-weight: 600;
    color: #495057;
}

tr:hover {
    background-color: #f8f9fa;
}

.positive {
    color: #28a745;
}

.negative {
    color: #dc3545;
}

.risk-distribution {
    margin: 30px 0;
}

.distribution-bars {
    display: flex;
    flex-direction: column;
    gap: 15px;
}

.distribution-bar {
    display: flex;
    align-items: center;
    gap: 10px;
}

.bar-label {
    width: 80px;
    text-align: right;
    color: #6c757d;
}

.bar-container {
    flex-grow: 1;
    height: 20px;
    background: #e9ecef;
    border-radius: 10px;
    overflow: hidden;
}

.bar {
    height: 100%;
    transition: width 0.3s ease;
}

.bar.high-risk {
    background: #dc3545;
}

.bar.medium-risk {
    background: #ffc107;
}

.bar.low-risk {
    background: #28a745;
}

.bar-value {
    width: 40px;
    text-align: right;
    font-weight: bold;
}

.risk-level {
    font-weight: bold;
    padding: 4px 8px;
    border-radius: 4px;
}

.risk-level.высокий-риск {
    background: #f8d7da;
    color: #721c24;
}

.risk-level.средний-риск {
    background: #fff3cd;
    color: #856404;
}

.risk-level.низкий-риск {
    background: #d4edda;
    color: #155724;
}
</style> 