-- Очистка существующих данных (в обратном порядке от связей)
DELETE FROM insurance.payments;
DELETE FROM insurance.insurance_claims;
DELETE FROM insurance.policy_events;
DELETE FROM insurance.insurance_policies;
DELETE FROM insurance.insured_events;
DELETE FROM insurance.category_insurances;
DELETE FROM insurance.users;
DELETE FROM insurance.clients;
DELETE FROM insurance.employees;
DELETE FROM insurance.roles;

-- Сброс последовательностей
ALTER SEQUENCE insurance.category_insurances_category_id_seq RESTART WITH 1;
ALTER SEQUENCE insurance.clients_client_id_seq RESTART WITH 1;
ALTER SEQUENCE insurance.employees_employee_id_seq RESTART WITH 1;
ALTER SEQUENCE insurance.insurance_claims_claim_id_seq RESTART WITH 1;
ALTER SEQUENCE insurance.insurance_policies_policy_id_seq RESTART WITH 1;
ALTER SEQUENCE insurance.insured_events_event_id_seq RESTART WITH 1;
ALTER SEQUENCE insurance.payments_payment_id_seq RESTART WITH 1;
ALTER SEQUENCE insurance.policy_events_policy_event_id_seq RESTART WITH 1;
ALTER SEQUENCE insurance.roles_role_id_seq RESTART WITH 1;
ALTER SEQUENCE insurance.users_user_id_seq RESTART WITH 1;

-- Заполнение ролей
INSERT INTO insurance.roles (role_name, access_rights) VALUES
('Клиент', 'Смотрит свои полисы'),
('Администратор', 'Полный доступ'),
('Менеджер', 'Работает с клиентами');

-- Заполнение категорий страхования
INSERT INTO insurance.category_insurances (category_name, description, base_rate) VALUES
('Автострахование', 'Страхование автомобилей от ущерба и угона', 5000.00),
('Медицинское страхование', 'Страхование здоровья и медицинских расходов', 3000.00),
('Страхование имущества', 'Страхование жилья и имущества от повреждений', 2000.00),
('Страхование жизни', 'Страхование жизни и здоровья', 4000.00),
('Страхование путешествий', 'Страхование во время поездок', 1500.00);

-- Заполнение клиентов
INSERT INTO insurance.clients (full_name, address, phone_number, email, birth_date, passport_data) VALUES
('Иванов Иван Иванович', 'ул. Ленина, 1', '+7(999)111-22-33', 'ivanov@mail.ru', '1990-01-15', '1234 567890'),
('Петрова Анна Сергеевна', 'ул. Пушкина, 2', '+7(999)222-33-44', 'petrova@mail.ru', '1985-05-20', '2345 678901'),
('Сидоров Алексей Николаевич', 'ул. Гагарина, 3', '+7(999)333-44-55', 'sidorov@mail.ru', '1995-08-10', '3456 789012'),
('Козлова Елена Владимировна', 'ул. Королева, 4', '+7(999)444-55-66', 'kozlova@mail.ru', '1988-12-25', '4567 890123'),
('Морозов Дмитрий Петрович', 'ул. Циолковского, 5', '+7(999)555-66-77', 'morozov@mail.ru', '1992-03-30', '5678 901234');

-- Заполнение сотрудников
INSERT INTO insurance.employees (full_name, position, phone_number, email, hire_date) VALUES
('Кузнецова Мария Ивановна', 'Страховой агент', '+7(999)666-77-88', 'kuznetsova@mail.ru', '2021-02-15'),
('Новиков Дмитрий Сергеевич', 'Специалист по урегулированию', '+7(999)777-88-99', 'novikov@mail.ru', '2022-03-20'),
('Волкова Ольга Александровна', 'Страховой агент', '+7(999)888-99-00', 'volkova@mail.ru', '2023-04-25');

-- Заполнение пользователей
INSERT INTO insurance.users (username, password_hash, role_id, client_id, employee_id) VALUES
('ivanov', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 1, NULL),
('petrova', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 2, NULL),
('sidorov', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 3, NULL),
('kozlova', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 4, NULL),
('morozov', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 5, NULL),
('kuznetsova', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 3, NULL, 1),
('novikov', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 3, NULL, 2),
('volkova', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 3, NULL, 3);

-- Заполнение страховых событий
INSERT INTO insurance.insured_events (event_name, description, status, category_id, coverage_percentage, probability) VALUES
('ДТП', 'Дорожно-транспортное происшествие', 'active', 1, 80.00, 5.00),
('Угон', 'Угон автомобиля', 'active', 1, 90.00, 2.00),
('Госпитализация', 'Экстренная госпитализация', 'active', 2, 90.00, 3.00),
('Пожар', 'Пожар в жилом помещении', 'active', 3, 85.00, 2.00),
('Травма', 'Травма на производстве', 'active', 4, 95.00, 4.00),
('Отмена поездки', 'Вынужденная отмена поездки', 'active', 5, 70.00, 3.00);

-- Заполнение страховых полисов
INSERT INTO insurance.insurance_policies (policy_number, client_id, category_id, start_date, end_date, insurance_amount, monthly_payment, status) VALUES
('POL-001', 1, 1, '2024-01-01', '2025-01-01', 1000000.00, 5000.00, 'active'),
('POL-002', 2, 2, '2024-02-01', '2025-02-01', 500000.00, 3000.00, 'active'),
('POL-003', 3, 3, '2024-03-01', '2025-03-01', 750000.00, 2000.00, 'active'),
('POL-004', 4, 4, '2024-04-01', '2025-04-01', 2000000.00, 4000.00, 'active'),
('POL-005', 5, 5, '2024-05-01', '2025-05-01', 300000.00, 1500.00, 'active');

-- Заполнение событий полисов
INSERT INTO insurance.policy_events (policy_id, event_id, event_date, status, description) VALUES
(1, 1, '2024-01-15', 'pending', 'Небольшое ДТП'),
(2, 3, '2024-02-20', 'pending', 'Плановая госпитализация'),
(3, 4, '2024-03-25', 'pending', 'Пожар в квартире'),
(4, 5, '2024-04-30', 'pending', 'Травма на работе'),
(5, 6, '2024-05-15', 'pending', 'Отмена командировки');

-- Заполнение страховых претензий
INSERT INTO insurance.insurance_claims (claim_number, policy_event_id, claim_date, description, requested_amount, approved_amount, status, processed_by) VALUES
('CLM-001', 1, '2024-01-16', 'Ремонт автомобиля после ДТП', 50000.00, 40000.00, 'approved', 2),
('CLM-002', 2, '2024-02-21', 'Оплата лечения', 30000.00, 27000.00, 'approved', 2),
('CLM-003', 3, '2024-03-26', 'Восстановление имущества', 200000.00, 170000.00, 'pending', NULL),
('CLM-004', 4, '2024-05-01', 'Оплата больничного', 15000.00, NULL, 'pending', NULL),
('CLM-005', 5, '2024-05-16', 'Компенсация отмененной поездки', 25000.00, NULL, 'pending', NULL);

-- Заполнение платежей
INSERT INTO insurance.payments (payment_number, client_id, policy_id, claim_id, amount, payment_date, payment_type, status) VALUES
('PAY-001', 1, 1, NULL, 5000.00, '2024-01-01', 'premium', 'completed'),
('PAY-002', 2, 2, NULL, 3000.00, '2024-02-01', 'premium', 'completed'),
('PAY-003', 3, 3, NULL, 2000.00, '2024-03-01', 'premium', 'completed'),
('PAY-004', 4, 4, NULL, 4000.00, '2024-04-01', 'premium', 'completed'),
('PAY-005', 5, 5, NULL, 1500.00, '2024-05-01', 'premium', 'completed'),
('PAY-006', 1, NULL, 1, 40000.00, '2024-01-17', 'claim', 'completed'),
('PAY-007', 2, NULL, 2, 27000.00, '2024-02-22', 'claim', 'completed'); 