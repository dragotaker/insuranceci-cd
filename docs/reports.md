# Документация по модулю отчетов (reports.py)

## Общее описание
Модуль `reports.py` содержит SQL-запросы и функции для генерации статистических отчетов. Все запросы оптимизированы для работы с PostgreSQL и используют специфические функции для форматирования данных.

## SQL-запросы

### 1. Общая статистика (TOTAL_STATS_QUERY)
```sql
SELECT 
    (SELECT COUNT(*) FROM insurance.clients) as total_clients,
    (SELECT COUNT(*) FROM insurance.insurance_policies) as total_policies,
    (SELECT COUNT(*) FROM insurance.insurance_claims) as total_claims
```
- Использует подзапросы для получения агрегированных данных
- `COALESCE` предотвращает NULL значения
- Приведение к `numeric` для корректной работы с числами

### 2. Топ категорий (TOP_CATEGORIES_QUERY)
```sql
SELECT 
    c.category_name,
    COUNT(p.policy_id) as count,
    ROUND(AVG(p.insurance_amount)::numeric, 2) as avg_amount
FROM insurance.category_insurances c
INNER JOIN insurance.insurance_policies p ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
HAVING COUNT(p.policy_id) > 0
ORDER BY count DESC
LIMIT 3
```
- `INNER JOIN` вместо `LEFT JOIN` для исключения категорий без полисов
- `HAVING` фильтрует категории с нулевым количеством полисов
- Округление средних значений до 2 знаков

### 3. Статистика по месяцам (MONTHLY_STATS_QUERY)
```sql
SELECT 
    TO_CHAR(start_date, 'YYYY') || ' ' || 
    CASE EXTRACT(MONTH FROM start_date)
        WHEN 1 THEN 'Январь'
        -- ... другие месяцы ...
    END as month,
    COUNT(*) as new_policies,
    SUM(insurance_amount)::numeric as total_amount
FROM insurance.insurance_policies
GROUP BY TO_CHAR(start_date, 'YYYY'), EXTRACT(MONTH FROM start_date)
ORDER BY TO_CHAR(start_date, 'YYYY') DESC, EXTRACT(MONTH FROM start_date) DESC
LIMIT 12
```
- Использование `CASE` для локализации названий месяцев
- Группировка по году и месяцу для корректной сортировки
- Ограничение последними 12 месяцами

### 4. Самый активный клиент (MOST_ACTIVE_CLIENT_QUERY)
```sql
SELECT 
    c.full_name as name,
    COUNT(p.policy_id) as policies
FROM insurance.clients c
LEFT JOIN insurance.insurance_policies p ON c.client_id = p.client_id
GROUP BY c.client_id, c.full_name
ORDER BY policies DESC
LIMIT 1
```
- `LEFT JOIN` для включения клиентов без полисов
- Подсчет количества полисов на клиента

### 5. Самая частая причина (MOST_COMMON_CLAIM_QUERY)
```sql
SELECT 
    e.description as reason,
    COUNT(c.claim_id) as count
FROM insurance.insured_events e
INNER JOIN insurance.policy_events pe ON e.event_id = pe.event_id
INNER JOIN insurance.insurance_claims c ON pe.policy_event_id = c.policy_event_id
GROUP BY e.event_id, e.description
ORDER BY count DESC
LIMIT 1
```
- Двойной `INNER JOIN` для связи событий с претензиями
- Подсчет количества претензий по каждому событию

### 6. Среднее время обработки (AVG_CLAIM_PROCESSING_TIME_QUERY)
```sql
SELECT 
    ROUND(AVG(EXTRACT(DAY FROM (processed_at - claim_date)))::numeric, 1) as avg_days
FROM insurance.insurance_claims
WHERE processed_at IS NOT NULL
```
- Использование `EXTRACT` для вычисления разницы в днях
- Округление до 1 знака после запятой

### 7. Процент одобренных претензий (APPROVED_CLAIMS_PERCENTAGE_QUERY)
```sql
SELECT 
    ROUND((100.0 * COUNT(CASE WHEN status = 'approved' THEN 1 END)::numeric / NULLIF(COUNT(*), 0))::numeric, 1) as approved_percentage
FROM insurance.insurance_claims
```
- Использование `CASE` для подсчета одобренных претензий
- `NULLIF` для предотвращения деления на ноль
- Округление процента до 1 знака

## Функция get_report_data

### Описание
Функция выполняет все SQL-запросы и форматирует результаты для отображения в шаблоне.

### Обработка данных
1. Выполнение всех запросов последовательно
2. Преобразование результатов в словари
3. Форматирование числовых значений

### Форматирование
- Все числовые значения приводятся к float
- Добавление символа валюты (₽) в шаблоне
- Округление процентов до 1 знака
- Обработка NULL значений через оператор `or 0`

## Анимации и стили
В шаблоне `reports.tpl` используются CSS-анимации и стили для улучшения визуального представления:

1. Карточки статистики:
   - Тени и скругленные углы
   - Hover-эффекты
   - Адаптивная сетка

2. Таблицы:
   - Горизонтальная прокрутка
   - Hover-эффекты для строк
   - Фиксированные заголовки

3. Цветовая индикация:
   - Зеленый для положительных значений
   - Красный для отрицательных значений

4. Адаптивный дизайн:
   - Использование CSS Grid
   - Медиа-запросы для мобильных устройств
   - Гибкие размеры элементов 