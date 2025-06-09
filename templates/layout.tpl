<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
    <link rel="stylesheet" href="/static/style.css">
</head>
<body>
    <div class="sidebar">
        <div class="logo">
            <h2>Страховая компания</h2>
        </div>
        <nav>
            <ul>
                <li><a href="/" class="{{'active' if current_page == 'home' else ''}}">Главная</a></li>
                <li class="nav-header">Основные данные</li>
                <li><a href="/table/clients" class="{{'active' if current_page == 'clients' else ''}}">Клиенты</a></li>
                <li><a href="/table/employees" class="{{'active' if current_page == 'employees' else ''}}">Сотрудники</a></li>
                <li><a href="/table/category_insurances" class="{{'active' if current_page == 'category_insurances' else ''}}">Категории страхования</a></li>
                <li class="nav-header">Страхование</li>
                <li><a href="/table/insurance_policies" class="{{'active' if current_page == 'insurance_policies' else ''}}">Страховые полисы</a></li>
                <li><a href="/table/insured_events" class="{{'active' if current_page == 'insured_events' else ''}}">Страховые случаи</a></li>
                <li><a href="/table/policy_events" class="{{'active' if current_page == 'policy_events' else ''}}">События по полисам</a></li>
                <li><a href="/table/insurance_claims" class="{{'active' if current_page == 'insurance_claims' else ''}}">Страховые претензии</a></li>
                <li><a href="/table/payments" class="{{'active' if current_page == 'payments' else ''}}">Платежи</a></li>
                <li class="nav-header">Отчеты</li>
                <li><a href="/reports" class="{{'active' if current_page == 'reports' else ''}}">Статистика</a></li>
                <li class="nav-header">Система</li>
                <li><a href="/table/roles" class="{{'active' if current_page == 'roles' else ''}}">Роли</a></li>
                <li><a href="/table/users" class="{{'active' if current_page == 'users' else ''}}">Пользователи</a></li>
            </ul>
        </nav>
    </div>
    <div class="main-content">
        {{!base}}
    </div>
</body>
</html> 