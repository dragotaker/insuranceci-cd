from bottle import route, template, request, redirect, static_file
import psycopg2
from datetime import datetime
import re

from database import get_db_connection
from config import TABLES
from utils import hash_password # ensure_utf8 - если понадобится для данных из форм напрямую

# Статические файлы
@route('/static/<filename:path>')
def serve_static(filename):
    return static_file(filename, root='static')

# Главная страница
@route('/')
def index():
    return template('templates/layout.tpl', 
                    title='Главная',
                    current_page='home',
                    base=template('templates/index.tpl'))

# Просмотр таблицы
@route('/table/<table_name>')
def show_table(table_name):
    if table_name not in TABLES:
        return "Таблица не найдена"
    
    conn = get_db_connection()
    cur = conn.cursor()
    
    # Устанавливаем кодировку для соединения
    cur.execute("SET client_encoding TO 'UTF8'")
    
    # Получаем поисковый запрос
    search_query = request.query.get('search', '').strip()
    search_field = request.query.get('search_field', '')
    
    # Обработка кодировки для поискового запроса
    if search_query:
        try:
            # Принудительно декодируем как UTF-8
            search_query = search_query.encode('latin1').decode('utf-8')
        except Exception as e:
            print(f"Error decoding search query: {e}")
            search_query = ''

    base_query_fields = list(TABLES[table_name]['fields']) # Копия, чтобы не менять оригинал
    if 'password' in base_query_fields and table_name not in ['clients', 'employees']: # Не извлекаем пароль, если это не юзеры/клиенты
         base_query_fields.remove('password')
    
    select_fields_str = ", ".join([f"t.{f}" for f in base_query_fields])

    if table_name in ['clients', 'employees']:
        id_field_table = 'client_id' if table_name == 'clients' else 'employee_id'
        # Добавляем u.username к списку полей для SELECT, если его там нет
        if 'username' not in base_query_fields: # username берется из users
             query_fields_for_dict = base_query_fields + ['username']
        else: # username есть в основной таблице (например, если бы он был в clients/employees напрямую)
            query_fields_for_dict = base_query_fields
        
        # Удаляем 'password' из основного запроса к таблице t, если он там есть, так как он будет в users
        # Но для clients и employees, 'password' в TABLES['fields'] - это для формы ввода, а не для select напрямую.
        # Пароль пользователя хранится в users.password_hash
        fields_for_t = [f for f in TABLES[table_name]['fields'] if f not in ['username', 'password']]
        select_fields_str = ", ".join([f"t.{f}" for f in fields_for_t]) + ", u.username"

        query = f"""
            SELECT {select_fields_str}
            FROM insurance.{table_name} t 
            LEFT JOIN insurance.users u ON t.{id_field_table} = u.{id_field_table}
        """
    else:
        query_fields_for_dict = base_query_fields
        select_fields_str = ", ".join([f"t.{f}" for f in base_query_fields])
        query = f"SELECT {select_fields_str} FROM insurance.{table_name} t"
        
    params = []
    
    if search_query:
        conditions = []
        # Поля для поиска, исключая 'password' из TABLES[table_name]['fields']
        searchable_fields_config = [f for f in TABLES[table_name]['fields'] if f != 'password']

        if search_field:
            if table_name in ['clients', 'employees'] and search_field == 'username':
                query += f" WHERE u.username ILIKE %s"
            elif search_field in searchable_fields_config: # Проверяем, что поле существует в конфигурации
                query += f" WHERE t.{search_field}::text ILIKE %s"
            else: # Поиск по несуществующему полю, можно вернуть пустой результат или ошибку
                pass # Пока пропускаем, запрос не изменится
            if search_field and (search_field in searchable_fields_config or (table_name in ['clients', 'employees'] and search_field == 'username')):
                 params.append(f'%{search_query}%')
        else:
            for field in searchable_fields_config:
                if table_name in ['clients', 'employees'] and field == 'username':
                    conditions.append(f"u.username ILIKE %s")
                else: # username/password из clients/employees - это для формы, не для поиска в самой таблице
                    if field not in ['username', 'password']:
                         conditions.append(f"t.{field}::text ILIKE %s")
            if conditions:
                query += " WHERE " + " OR ".join(conditions)
                params.extend([f'%{search_query}%'] * len(conditions))
    
    order_by_field = TABLES[table_name]['fields'][0] # Первое поле из конфигурации
    query += f" ORDER BY t.{order_by_field}"
    
    cur.execute(query, params)
    db_rows = cur.fetchall()
    
    rows = [dict(zip(query_fields_for_dict, row)) for row in db_rows]
    
    # Используем display_fields из TABLES для определения, что показывать
    display_field_keys = list(TABLES[table_name]['display_fields'].keys())

    show_add_delete = table_name != 'users' 
    
    cur.close()
    conn.close()
    
    return template('templates/layout.tpl',
                    title=TABLES[table_name]['name'],
                    current_page=table_name,
                    base=template('templates/table.tpl',
                                  table_name=TABLES[table_name]['name'],
                                  fields=display_field_keys, # Ключи полей для отображения
                                  rows=rows,
                                  table_key=table_name,
                                  table_info=TABLES[table_name],
                                  search_query=search_query,
                                  search_field=search_field,
                                  show_add_delete=show_add_delete))

# Добавление записи
@route('/add/<table_name>', method=['GET', 'POST'])
def add_record(table_name):
    if table_name not in TABLES:
        return "Таблица не найдена"
    
    table_config = TABLES[table_name]

    if request.method == 'POST':
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SET client_encoding TO 'UTF8'")
        
        form_fields = table_config['fields']
        values_to_insert = []
        db_field_names = []
        
        # Пропускаем первое поле (ID) и username/password для clients/employees
        # ID обычно SERIAL и генерируется БД
        # username/password для clients/employees обрабатываются отдельно для таблицы users
        
        for field in form_fields:
            if field == form_fields[0]: # Пропускаем ID поле
                continue
            if table_name in ['clients', 'employees'] and field in ['username', 'password']:
                continue
            
            # Для всех остальных полей берем значение из формы
            # request.forms.getunicode() для корректной обработки UTF-8 из форм
            value = request.forms.getunicode(field)
            
            # Обработка пустых строк для числовых и других типов, если нужно
            # Например, если поле должно быть NULL, а не пустой строкой
            if value == '' and field in ['base_rate', 'insurance_amount', 'monthly_payment', 'coverage_percentage', 'probability', 'requested_amount', 'approved_amount', 'amount', 'role_id', 'client_id', 'employee_id', 'category_id', 'policy_id', 'event_id', 'policy_event_id', 'claim_id', 'processed_by']: # Добавьте другие числовые/FK поля при необходимости
                value = None 

            values_to_insert.append(value)
            db_field_names.append(field)
        
        placeholders = ', '.join(['%s'] * len(values_to_insert))
        field_names_str = ', '.join(db_field_names)
        
        # RETURNING ID field
        returning_id_field = form_fields[0] 
        query = f"INSERT INTO insurance.{table_name} ({field_names_str}) VALUES ({placeholders}) RETURNING {returning_id_field}"
        
        try:
            cur.execute(query, values_to_insert)
            new_id = cur.fetchone()[0]
            
            # Создаем пользователя для клиента или сотрудника
            if table_name in ['clients', 'employees']:
                username = request.forms.getunicode('username')
                password = request.forms.getunicode('password')
                
                if username and password:
                    role_id = 1 if table_name == 'clients' else 2 # Пример: 1 для клиента, 2 для сотрудника (настройте ID ролей)
                    id_field_for_user_table = 'client_id' if table_name == 'clients' else 'employee_id'
                    
                    cur.execute(f"""
                        INSERT INTO insurance.users (username, password_hash, role_id, {id_field_for_user_table})
                        VALUES (%s, %s, %s, %s)
                    """, (username, hash_password(password), role_id, new_id))
            
            conn.commit()
        except psycopg2.Error as e:
            conn.rollback()
            cur.close()
            conn.close()
            # Передаем ошибку в шаблон
            return template('templates/layout.tpl',
                            title=table_config['add_form_title'],
                            current_page=table_name,
                            base=template('templates/add.tpl',
                                          table_name=table_config['name'],
                                          fields=table_config['fields'], # Используем все поля для формы
                                          table_key=table_name,
                                          TABLES=TABLES, # Передаем все TABLES для foreign_keys и т.д.
                                          foreign_data=get_foreign_data(table_name, table_config),
                                          error=str(e)))
        finally:
            cur.close()
            conn.close()
            
        redirect(f'/table/{table_name}')
    
    # GET request: отображаем форму
    foreign_data = get_foreign_data(table_name, table_config)
    
    return template('templates/layout.tpl',
                    title=table_config['add_form_title'],
                    current_page=table_name,
                    base=template('templates/add.tpl',
                                  table_name=table_config['name'],
                                  fields=table_config['fields'], # Используем все поля для формы
                                  table_key=table_name,
                                  TABLES=TABLES, # Передаем все TABLES для foreign_keys и т.д.
                                  foreign_data=foreign_data,
                                  error=None))

def get_foreign_data(table_name, table_config):
    """Вспомогательная функция для получения данных для выпадающих списков."""
    foreign_data = {}
    if 'foreign_keys' in table_config:
        conn_fk = get_db_connection()
        cur_fk = conn_fk.cursor()
        for field_fk, fk_info in table_config['foreign_keys'].items():
            # Используем правильное имя первичного ключа из связанной таблицы
            # (обычно это первое поле в 'fields' конфигурации связанной таблицы)
            fk_table_id_field = TABLES[fk_info['table']]['fields'][0]
            cur_fk.execute(f"SELECT {fk_table_id_field}, {fk_info['display_field']} FROM insurance.{fk_info['table']} ORDER BY {fk_info['display_field']}")
            foreign_data[field_fk] = cur_fk.fetchall()
        cur_fk.close()
        conn_fk.close()
    return foreign_data


# Редактирование записи
@route('/edit/<table_name>/<id_value>', method=['GET', 'POST']) # id переименован в id_value во избежание конфликта с встроенной функцией id()
def edit_record(table_name, id_value):
    if table_name not in TABLES:
        return "Таблица не найдена"

    table_config = TABLES[table_name]
    id_field_name = table_config['fields'][0] # Имя поля ID

    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SET client_encoding TO 'UTF8'")

    if request.method == 'POST':
        updates = []
        values = []
        
        # Поля для обновления (все, кроме ID и username/password для clients/employees)
        fields_to_update = [f for f in table_config['fields'][1:] if not (table_name in ['clients', 'employees'] and f in ['username', 'password'])]

        for field in fields_to_update:
            value = request.forms.getunicode(field)
            # Обработка пустых строк для числовых и других типов
            if value == '' and field in ['base_rate', 'insurance_amount', 'monthly_payment', 'coverage_percentage', 'probability', 'requested_amount', 'approved_amount', 'amount', 'role_id', 'client_id', 'employee_id', 'category_id', 'policy_id', 'event_id', 'policy_event_id', 'claim_id', 'processed_by']:
                value = None
            
            if field == 'password' and table_name == 'users': # Хешируем пароль, если это таблица users и поле password_hash
                 # Убедитесь, что поле в users называется password_hash
                if value: # Обновляем пароль только если он был введен
                    updates.append(f"password_hash = %s") # Имя поля в БД users
                    values.append(hash_password(value))
            else:
                updates.append(f"{field} = %s")
                values.append(value)
        
        if not updates: # Если нет полей для обновления (например, только ID)
            redirect(f'/table/{table_name}')
            return

        values.append(id_value) 
        query = f"UPDATE insurance.{table_name} SET {', '.join(updates)} WHERE {id_field_name} = %s"
        
        try:
            cur.execute(query, values)
            conn.commit()
        except psycopg2.Error as e:
            conn.rollback()
            # Можно передать ошибку в шаблон редактирования
        finally:
            cur.close()
            conn.close()
        
        redirect(f'/table/{table_name}')
    
    # GET request: отображаем форму редактирования
    cur.execute(f"SELECT * FROM insurance.{table_name} WHERE {id_field_name} = %s", (id_value,))
    row_tuple = cur.fetchone()
    
    if not row_tuple:
        cur.close()
        conn.close()
        return "Запись не найдена"
    
    # Преобразуем кортеж в словарь для удобства в шаблоне
    row_dict = dict(zip(table_config['fields'], row_tuple))

    # Поля для отображения в форме (все, кроме username/password для clients/employees, т.к. они редактируются через users)
    form_fields_config = [f for f in table_config['fields'] if not (table_name in ['clients', 'employees'] and f in ['username', 'password'])]

    foreign_data = get_foreign_data(table_name, table_config)

    cur.close()
    conn.close()
    
    return template('templates/layout.tpl',
                    title=f"Редактировать {table_config['name'].lower()}",
                    current_page=table_name,
                    base=template('templates/edit.tpl',
                                  table_name=table_config['name'],
                                  fields_config=form_fields_config, # Передаем конфигурацию полей для формы
                                  row_data=row_dict, # Передаем данные записи как словарь
                                  table_key=table_name,
                                  TABLES=TABLES,
                                  foreign_data=foreign_data,
                                  id_field_name=id_field_name, # Имя поля ID
                                  error=None))


# Удаление записи
@route('/delete/<table_name>/<id_value>')
def delete_record(table_name, id_value):
    if table_name not in TABLES:
        return "Таблица не найдена"

    table_config = TABLES[table_name]
    id_field_name = table_config['fields'][0]

    conn = get_db_connection()
    cur = conn.cursor()
    
    try:
        # Пытаемся удалить запись
        cur.execute(f"DELETE FROM insurance.{table_name} WHERE {id_field_name} = %s", (id_value,))
        conn.commit()
        
    except psycopg2.Error as e:
        conn.rollback()
        # Получаем сообщение об ошибке из базы данных
        error_message = str(e)
        
        # Если это ошибка от триггера, показываем её пользователю
        if "RAISE EXCEPTION" in error_message:
            # Извлекаем сообщение об ошибке из текста исключения
            match = re.search(r'RAISE EXCEPTION \'([^\']+)\'', error_message)
            if match:
                error_message = match.group(1)
        
        return template('templates/layout.tpl',
                        title='Ошибка удаления', 
                        current_page=table_name,
                        base=template('templates/error.tpl', 
                                    message=error_message))
    finally:
        cur.close()
        conn.close()
        
    redirect(f'/table/{table_name}')

# Статистические отчеты
@route('/reports')
def show_reports():
    conn = get_db_connection()
    cur = conn.cursor()
    
    try:
        from reports import get_report_data
        report_data = get_report_data(cur)
        
        return template('templates/reports.tpl', **report_data)
    except Exception as e:
        print(f"Error in show_reports: {str(e)}")
        return template('templates/error.tpl',
                        message=f"Произошла ошибка при формировании отчетов: {str(e)}")
    finally:
        cur.close()
        conn.close()