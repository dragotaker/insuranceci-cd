-- Дополнительные клиенты разных возрастов
INSERT INTO insurance.clients (client_id, full_name, address, phone_number, email, birth_date, passport_data) VALUES
-- Молодые клиенты (до 30)
(6, 'Смирнов Артем Дмитриевич', 'ул. Молодежная, 10', '+7(999)111-11-11', 'smirnov@mail.ru', '2000-06-15', '1111 111111'),
(7, 'Ковалева Юлия Андреевна', 'ул. Студенческая, 5', '+7(999)222-22-22', 'kovaleva@mail.ru', '1998-03-20', '2222 222222'),
(8, 'Попов Максим Сергеевич', 'ул. Юности, 8', '+7(999)333-33-33', 'popov@mail.ru', '1995-12-10', '3333 333333'),
(9, 'Иванова Анна Петровна', 'ул. Молодежная, 12', '+7(999)123-45-67', 'ivanova@mail.ru', '1997-08-25', '1234 567891'),

-- Клиенты среднего возраста (30-49)
(10, 'Соколова Екатерина Петровна', 'ул. Центральная, 15', '+7(999)444-44-44', 'sokolova@mail.ru', '1985-07-25', '4444 444444'),
(11, 'Лебедев Игорь Николаевич', 'ул. Рабочая, 20', '+7(999)555-55-55', 'lebedev@mail.ru', '1980-09-30', '5555 555555'),
(12, 'Новикова Мария Ивановна', 'ул. Садовая, 25', '+7(999)666-66-66', 'novikova@mail.ru', '1990-11-15', '6666 666666'),
(13, 'Петров Александр Иванович', 'ул. Центральная, 18', '+7(999)234-56-78', 'petrov@mail.ru', '1988-04-12', '2345 678902'),

-- Пожилые клиенты (50+)
(14, 'Козлов Петр Васильевич', 'ул. Ветеранская, 30', '+7(999)777-77-77', 'kozlov@mail.ru', '1965-04-20', '7777 777777'),
(15, 'Морозова Галина Степановна', 'ул. Пенсионная, 35', '+7(999)888-88-88', 'morozova@mail.ru', '1958-08-10', '8888 888888'),
(16, 'Волков Николай Павлович', 'ул. Заречная, 40', '+7(999)999-99-99', 'volkov@mail.ru', '1970-02-28', '9999 999999'),
(17, 'Сидорова Людмила Ивановна', 'ул. Ветеранская, 33', '+7(999)345-67-89', 'sidorova@mail.ru', '1962-11-30', '3456 789013');

-- Добавление пользователей для новых клиентов
INSERT INTO insurance.users (username, password_hash, role_id, client_id, employee_id) VALUES
('smirnov', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 6, NULL),
('kovaleva', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 7, NULL),
('popov', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 8, NULL),
('ivanova', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 9, NULL),
('sokolova', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 10, NULL),
('lebedev', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 11, NULL),
('novikova', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 12, NULL),
('petrov', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 13, NULL),
('kozlov', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 14, NULL),
('morozova', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 15, NULL),
('volkov', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 16, NULL),
('sidorova', '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8', 1, 17, NULL);

-- Дополнительные страховые полисы для новых клиентов
INSERT INTO insurance.insurance_policies (policy_number, client_id, category_id, start_date, end_date, insurance_amount, monthly_payment, status) VALUES
-- Полисы для молодых клиентов
('POL-006', 6, 1, '2024-01-15', '2025-01-15', 800000.00, 4000.00, 'active'),
('POL-007', 7, 2, '2024-02-15', '2025-02-15', 400000.00, 2500.00, 'active'),
('POL-008', 8, 3, '2024-03-15', '2025-03-15', 600000.00, 1800.00, 'active'),
('POL-015', 9, 4, '2024-01-20', '2025-01-20', 1000000.00, 3000.00, 'active'),

-- Полисы для клиентов среднего возраста
('POL-009', 10, 4, '2024-04-15', '2025-04-15', 1500000.00, 3500.00, 'active'),
('POL-010', 11, 5, '2024-05-15', '2025-05-15', 250000.00, 1200.00, 'active'),
('POL-011', 12, 1, '2024-06-15', '2025-06-15', 900000.00, 4500.00, 'active'),
('POL-016', 13, 2, '2024-02-20', '2025-02-20', 500000.00, 2800.00, 'active'),

-- Полисы для пожилых клиентов
('POL-012', 14, 2, '2024-07-15', '2025-07-15', 600000.00, 2800.00, 'active'),
('POL-013', 15, 3, '2024-08-15', '2025-08-15', 800000.00, 2200.00, 'active'),
('POL-014', 16, 4, '2024-09-15', '2025-09-15', 1800000.00, 3800.00, 'active'),
('POL-017', 17, 5, '2024-03-20', '2025-03-20', 300000.00, 1500.00, 'active');

-- Дополнительные страховые события
INSERT INTO insurance.policy_events (policy_id, event_id, event_date, status, description) VALUES
-- События для молодых клиентов (высокий риск)
(6, 1, '2024-01-20', 'pending', 'Серьезное ДТП'),
(7, 3, '2024-02-25', 'pending', 'Экстренная госпитализация'),
(8, 4, '2024-03-30', 'pending', 'Крупный пожар'),
(15, 5, '2024-01-25', 'pending', 'Несчастный случай'),

-- События для клиентов среднего возраста (средний риск)
(9, 5, '2024-04-20', 'pending', 'Несчастный случай на работе'),
(10, 6, '2024-05-25', 'pending', 'Отмена деловой поездки'),
(11, 1, '2024-06-30', 'pending', 'Небольшое ДТП'),
(16, 3, '2024-02-28', 'pending', 'Плановая госпитализация'),

-- События для пожилых клиентов (низкий риск)
(12, 3, '2024-07-20', 'pending', 'Плановая госпитализация'),
(13, 4, '2024-08-25', 'pending', 'Небольшой пожар'),
(14, 5, '2024-09-30', 'pending', 'Легкая травма'),
(17, 6, '2024-03-25', 'pending', 'Отмена поездки');

-- Дополнительные страховые претензии
INSERT INTO insurance.insurance_claims (claim_number, policy_event_id, claim_date, description, requested_amount, approved_amount, status, processed_by) VALUES
-- Претензии для молодых клиентов (высокие суммы)
('CLM-006', 6, '2024-01-21', 'Ремонт после серьезного ДТП', 150000.00, 120000.00, 'approved', 2),
('CLM-007', 7, '2024-02-26', 'Оплата экстренного лечения', 80000.00, 72000.00, 'approved', 2),
('CLM-008', 8, '2024-03-31', 'Восстановление после пожара', 300000.00, 250000.00, 'approved', 2),
('CLM-015', 15, '2024-01-26', 'Оплата лечения', 90000.00, 80000.00, 'approved', 2),

-- Претензии для клиентов среднего возраста (средние суммы)
('CLM-009', 9, '2024-04-21', 'Оплата больничного', 45000.00, 40000.00, 'approved', 2),
('CLM-010', 10, '2024-05-26', 'Компенсация отмененной поездки', 35000.00, 30000.00, 'approved', 2),
('CLM-011', 11, '2024-07-01', 'Ремонт после ДТП', 60000.00, 50000.00, 'approved', 2),
('CLM-016', 16, '2024-03-01', 'Оплата лечения', 30000.00, 28000.00, 'approved', 2),

-- Претензии для пожилых клиентов (низкие суммы)
('CLM-012', 12, '2024-07-21', 'Оплата лечения', 25000.00, 22000.00, 'approved', 2),
('CLM-013', 13, '2024-08-26', 'Восстановление имущества', 40000.00, 35000.00, 'approved', 2),
('CLM-014', 14, '2024-10-01', 'Оплата реабилитации', 30000.00, 28000.00, 'approved', 2),
('CLM-017', 17, '2024-03-26', 'Компенсация отмененной поездки', 20000.00, 18000.00, 'approved', 2);

-- Дополнительные платежи
INSERT INTO insurance.payments (payment_number, client_id, policy_id, claim_id, amount, payment_date, payment_type, status) VALUES
-- Платежи по премиям
('PAY-008', 6, 6, NULL, 4000.00, '2024-01-15', 'premium', 'completed'),
('PAY-009', 7, 7, NULL, 2500.00, '2024-02-15', 'premium', 'completed'),
('PAY-010', 8, 8, NULL, 1800.00, '2024-03-15', 'premium', 'completed'),
('PAY-011', 9, 15, NULL, 3000.00, '2024-01-20', 'premium', 'completed'),
('PAY-012', 10, 9, NULL, 3500.00, '2024-04-15', 'premium', 'completed'),
('PAY-013', 11, 10, NULL, 1200.00, '2024-05-15', 'premium', 'completed'),
('PAY-014', 12, 11, NULL, 4500.00, '2024-06-15', 'premium', 'completed'),
('PAY-015', 13, 16, NULL, 2800.00, '2024-02-20', 'premium', 'completed'),
('PAY-016', 14, 12, NULL, 2800.00, '2024-07-15', 'premium', 'completed'),
('PAY-017', 15, 13, NULL, 2200.00, '2024-08-15', 'premium', 'completed'),
('PAY-018', 16, 14, NULL, 3800.00, '2024-09-15', 'premium', 'completed'),
('PAY-019', 17, 17, NULL, 1500.00, '2024-03-20', 'premium', 'completed'),

-- Платежи по претензиям
('PAY-020', 6, NULL, 6, 120000.00, '2024-01-22', 'claim', 'completed'),
('PAY-021', 7, NULL, 7, 72000.00, '2024-02-27', 'claim', 'completed'),
('PAY-022', 8, NULL, 8, 250000.00, '2024-04-01', 'claim', 'completed'),
('PAY-023', 9, NULL, 15, 80000.00, '2024-01-27', 'claim', 'completed'),
('PAY-024', 10, NULL, 9, 40000.00, '2024-04-22', 'claim', 'completed'),
('PAY-025', 11, NULL, 10, 30000.00, '2024-05-27', 'claim', 'completed'),
('PAY-026', 12, NULL, 11, 50000.00, '2024-07-02', 'claim', 'completed'),
('PAY-027', 13, NULL, 16, 28000.00, '2024-03-02', 'claim', 'completed'),
('PAY-028', 14, NULL, 12, 22000.00, '2024-07-22', 'claim', 'completed'),
('PAY-029', 15, NULL, 13, 35000.00, '2024-08-27', 'claim', 'completed'),
('PAY-030', 16, NULL, 14, 28000.00, '2024-10-02', 'claim', 'completed'),
('PAY-031', 17, NULL, 17, 18000.00, '2024-03-27', 'claim', 'completed'); 