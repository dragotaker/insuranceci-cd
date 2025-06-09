import os
from dotenv import load_dotenv

# Загрузка переменных окружения
load_dotenv()

# Настройки подключения к базе данных
DB_CONFIG = {
    'database': os.getenv('DB_NAME', 'insurance_db'),
    'user': os.getenv('DB_USER', 'postgres'),
    'password': os.getenv('DB_PASSWORD', 'drago'),
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', '5432')),
    'client_encoding': 'UTF8', # Добавлено для psycopg2 v3+
}

# Таблицы
TABLES = {
    'clients': {
        'name': 'Клиенты',
        'add_form_title': 'Добавить клиента',
        'fields': ['client_id', 'full_name', 'address', 'phone_number', 'email', 'birth_date', 'passport_data', 'username', 'password'],
        'field_names': {
            'client_id': 'ID клиента',
            'full_name': 'ФИО',
            'address': 'Адрес',
            'phone_number': 'Телефон',
            'email': 'Email',
            'birth_date': 'Дата рождения',
            'passport_data': 'Паспортные данные',
            'username': 'Логин',
            'password': 'Пароль'
        },
        'display_fields': {
            'client_id': 'Номер',
            'full_name': 'ФИО',
            'address': 'Адрес',
            'phone_number': 'Телефон',
            'email': 'Email',
            'birth_date': 'Дата рождения',
            'passport_data': 'Паспортные данные',
            'username': 'Логин' # Пароль не отображаем
        }
    },
    'employees': {
        'name': 'Сотрудники',
        'add_form_title': 'Добавить сотрудника',
        'fields': ['employee_id', 'full_name', 'position', 'phone_number', 'email', 'hire_date', 'username', 'password'],
        'field_names': {
            'employee_id': 'ID сотрудника',
            'full_name': 'ФИО',
            'position': 'Должность',
            'phone_number': 'Телефон',
            'email': 'Email',
            'hire_date': 'Дата приема',
            'username': 'Логин',
            'password': 'Пароль'
        },
        'display_fields': {
            'employee_id': 'Номер',
            'full_name': 'ФИО',
            'position': 'Должность',
            'phone_number': 'Телефон',
            'email': 'Email',
            'hire_date': 'Дата приема',
            'username': 'Логин' # Пароль не отображаем
        }
    },
    'category_insurances': {
        'name': 'Категории страхования',
        'add_form_title': 'Добавить категорию страхования',
        'fields': ['category_id', 'category_name', 'description', 'base_rate'],
        'field_names': {
            'category_id': 'ID категории',
            'category_name': 'Название категории',
            'description': 'Описание',
            'base_rate': 'Базовая ставка'
        },
        'display_fields': {
            'category_id': 'Номер',
            'category_name': 'Название категории',
            'description': 'Описание',
            'base_rate': 'Базовая ставка'
        }
    },
    'insurance_policies': {
        'name': 'Страховые полисы',
        'add_form_title': 'Добавить страховой полис',
        'fields': ['policy_id', 'policy_number', 'client_id', 'category_id', 'start_date', 'end_date', 'insurance_amount', 'monthly_payment', 'status'],
        'field_names': {
            'policy_id': 'ID полиса',
            'policy_number': 'Номер полиса',
            'client_id': 'ID клиента',
            'category_id': 'ID категории',
            'start_date': 'Дата начала',
            'end_date': 'Дата окончания',
            'insurance_amount': 'Страховая сумма',
            'monthly_payment': 'Ежемесячный платеж',
            'status': 'Статус'
        },
        'display_fields': {
            'policy_id': 'Номер',
            'policy_number': 'Номер полиса',
            'client_id': 'Номер клиента',
            'category_id': 'Номер категории',
            'start_date': 'Дата начала',
            'end_date': 'Дата окончания',
            'insurance_amount': 'Страховая сумма',
            'monthly_payment': 'Ежемесячный платеж',
            'status': 'Статус'
        },
        'display_values': {
            'status': {
                'active': 'Активен',
                'expired': 'Истек',
                'cancelled': 'Аннулирован'
            }
        }
    },
    'insured_events': {
        'name': 'Страховые случаи',
        'add_form_title': 'Добавить страховой случай',
        'fields': ['event_id', 'event_name', 'description', 'status', 'category_id', 'coverage_percentage', 'probability'],
        'field_names': {
            'event_id': 'ID случая',
            'event_name': 'Название случая',
            'description': 'Описание',
            'status': 'Статус',
            'category_id': 'ID категории',
            'coverage_percentage': 'Процент покрытия',
            'probability': 'Вероятность'
        },
        'display_fields': {
            'event_id': 'Номер',
            'event_name': 'Название случая',
            'description': 'Описание',
            'status': 'Статус',
            'category_id': 'Номер категории',
            'coverage_percentage': 'Процент покрытия',
            'probability': 'Вероятность'
        }
    },
    'policy_events': {
        'name': 'События по полисам',
        'add_form_title': 'Добавить событие по полису',
        'fields': ['policy_event_id', 'policy_id', 'event_id', 'event_date', 'status', 'description'],
        'field_names': {
            'policy_event_id': 'ID события',
            'policy_id': 'ID полиса',
            'event_id': 'ID случая',
            'event_date': 'Дата события',
            'status': 'Статус',
            'description': 'Описание'
        },
        'display_fields': {
            'policy_event_id': 'Номер',
            'policy_id': 'Номер полиса',
            'event_id': 'Номер случая',
            'event_date': 'Дата события',
            'status': 'Статус',
            'description': 'Описание'
        }
    },
    'insurance_claims': {
        'name': 'Страховые претензии',
        'add_form_title': 'Добавить страховую претензию',
        'fields': ['claim_id', 'claim_number', 'policy_event_id', 'claim_date', 'description', 'requested_amount', 'approved_amount', 'status', 'processed_by', 'processed_at'],
        'field_names': {
            'claim_id': 'ID претензии',
            'claim_number': 'Номер претензии',
            'policy_event_id': 'ID события',
            'claim_date': 'Дата претензии',
            'description': 'Описание',
            'requested_amount': 'Запрошенная сумма',
            'approved_amount': 'Утвержденная сумма',
            'status': 'Статус',
            'processed_by': 'Обработано',
            'processed_at': 'Дата обработки'
        },
        'display_fields': {
            'claim_id': 'Номер',
            'claim_number': 'Номер претензии',
            'policy_event_id': 'Номер события',
            'claim_date': 'Дата претензии',
            'description': 'Описание',
            'requested_amount': 'Запрошенная сумма',
            'approved_amount': 'Утвержденная сумма',
            'status': 'Статус',
            'processed_by': 'Обработано',
            'processed_at': 'Дата обработки'
        }
    },
    'payments': {
        'name': 'Платежи',
        'add_form_title': 'Добавить платеж',
        'fields': ['payment_id', 'payment_number', 'client_id', 'policy_id', 'claim_id', 'amount', 'payment_date', 'payment_type', 'status'],
        'field_names': {
            'payment_id': 'ID платежа',
            'payment_number': 'Номер платежа',
            'client_id': 'ID клиента',
            'policy_id': 'ID полиса',
            'claim_id': 'ID претензии',
            'amount': 'Сумма',
            'payment_date': 'Дата платежа',
            'payment_type': 'Тип платежа',
            'status': 'Статус'
        },
        'display_fields': {
            'payment_id': 'Номер',
            'payment_number': 'Номер платежа',
            'client_id': 'Номер клиента',
            'policy_id': 'Номер полиса',
            'claim_id': 'Номер претензии',
            'amount': 'Сумма',
            'payment_date': 'Дата платежа',
            'payment_type': 'Тип платежа',
            'status': 'Статус'
        }
    },
    'roles': {
        'name': 'Роли',
        'add_form_title': 'Добавить роль',
        'fields': ['role_id', 'role_name', 'access_rights'],
        'field_names': {
            'role_id': 'ID роли',
            'role_name': 'Название роли',
            'access_rights': 'Права доступа'
        },
        'display_fields': {
            'role_id': 'Номер',
            'role_name': 'Название роли',
            'access_rights': 'Права доступа'
        }
    },
    'users': {
        'name': 'Пользователи',
        'add_form_title': 'Добавить пользователя',
        'fields': ['user_id', 'username', 'password_hash', 'role_id', 'client_id', 'employee_id'],
        'field_names': {
            'user_id': 'ID пользователя',
            'username': 'Логин',
            'password_hash': 'Пароль',
            'role_id': 'Роль',
            'client_id': 'Клиент',
            'employee_id': 'Сотрудник'
        },
        'display_fields': {
            'user_id': 'Номер',
            'username': 'Логин',
            # 'password_hash': 'Пароль', # Не отображаем хеш пароля
            'role_id': 'Роль',
            'client_id': 'Клиент',
            'employee_id': 'Сотрудник'
        },
        'foreign_keys': {
            'client_id': {
                'table': 'clients',
                'display_field': 'full_name'
            },
            'employee_id': {
                'table': 'employees',
                'display_field': 'full_name'
            },
            'role_id': {
                'table': 'roles',
                'display_field': 'role_name'
            }
        }
    }
}