--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

-- Started on 2025-06-06 02:20:27

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 42827)
-- Name: insurance; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA insurance;


ALTER SCHEMA insurance OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 50233)
-- Name: check_and_cleanup_before_delete(); Type: FUNCTION; Schema: insurance; Owner: postgres
--

CREATE FUNCTION insurance.check_and_cleanup_before_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Проверка для категорий страхования
    IF TG_TABLE_NAME = 'category_insurances' THEN
        IF EXISTS (SELECT 1 FROM insurance.insurance_policies WHERE category_id = OLD.category_id) THEN
            RAISE EXCEPTION 'Невозможно удалить категорию: есть связанные полисы';
        END IF;
        IF EXISTS (SELECT 1 FROM insurance.insured_events WHERE category_id = OLD.category_id) THEN
            RAISE EXCEPTION 'Невозможно удалить категорию: есть связанные страховые случаи';
        END IF;
    END IF;

    -- Проверка для клиентов
    IF TG_TABLE_NAME = 'clients' THEN
        IF EXISTS (SELECT 1 FROM insurance.insurance_policies WHERE client_id = OLD.client_id) THEN
            RAISE EXCEPTION 'Невозможно удалить клиента: есть связанные полисы';
        END IF;
        IF EXISTS (SELECT 1 FROM insurance.payments WHERE client_id = OLD.client_id) THEN
            RAISE EXCEPTION 'Невозможно удалить клиента: есть связанные платежи';
        END IF;
        -- Удаление связанного пользователя
        DELETE FROM insurance.users WHERE client_id = OLD.client_id;
    END IF;

    -- Проверка для сотрудников
    IF TG_TABLE_NAME = 'employees' THEN
        IF EXISTS (SELECT 1 FROM insurance.insurance_claims WHERE processed_by = OLD.employee_id) THEN
            RAISE EXCEPTION 'Невозможно удалить сотрудника: есть обработанные им претензии';
        END IF;
        -- Удаление связанного пользователя
        DELETE FROM insurance.users WHERE employee_id = OLD.employee_id;
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION insurance.check_and_cleanup_before_delete() OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 50231)
-- Name: check_policy_status(); Type: FUNCTION; Schema: insurance; Owner: postgres
--

CREATE FUNCTION insurance.check_policy_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.end_date < CURRENT_DATE AND NEW.status <> 'Истек' THEN
        NEW.status := 'Истек';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION insurance.check_policy_status() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 50229)
-- Name: create_initial_payment(); Type: FUNCTION; Schema: insurance; Owner: postgres
--

CREATE FUNCTION insurance.create_initial_payment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO insurance.payments (
        payment_number,
        client_id,
        policy_id,
        amount,
        payment_date,
        payment_type,
        status
    ) VALUES (
        'PAY-' || NEW.policy_id,
        NEW.client_id,
        NEW.policy_id,
        NEW.monthly_payment,
        CURRENT_DATE,
        'premium',
        'pending'
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION insurance.create_initial_payment() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 50225)
-- Name: delete_user_on_client_delete(); Type: FUNCTION; Schema: insurance; Owner: postgres
--

CREATE FUNCTION insurance.delete_user_on_client_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM insurance.users WHERE client_id = OLD.client_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION insurance.delete_user_on_client_delete() OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 50227)
-- Name: delete_user_on_employee_delete(); Type: FUNCTION; Schema: insurance; Owner: postgres
--

CREATE FUNCTION insurance.delete_user_on_employee_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM insurance.users WHERE employee_id = OLD.employee_id;
    RETURN OLD;
END;
$$;


ALTER FUNCTION insurance.delete_user_on_employee_delete() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 42828)
-- Name: category_insurances; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.category_insurances (
    category_id integer NOT NULL,
    category_name character varying(100) NOT NULL,
    description text,
    base_rate numeric(10,2)
);


ALTER TABLE insurance.category_insurances OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 42833)
-- Name: category_insurances_category_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.category_insurances ALTER COLUMN category_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.category_insurances_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 217 (class 1259 OID 42834)
-- Name: clients; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.clients (
    client_id integer NOT NULL,
    full_name character varying(100) NOT NULL,
    address character varying(200),
    phone_number character varying(20),
    email character varying(100),
    birth_date date NOT NULL,
    passport_data character varying(50)
);


ALTER TABLE insurance.clients OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 42837)
-- Name: clients_client_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.clients ALTER COLUMN client_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.clients_client_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 219 (class 1259 OID 42838)
-- Name: employees; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.employees (
    employee_id integer NOT NULL,
    full_name character varying(100) NOT NULL,
    "position" character varying(100),
    phone_number character varying(20),
    email character varying(100),
    hire_date date NOT NULL
);


ALTER TABLE insurance.employees OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 42841)
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.employees ALTER COLUMN employee_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.employees_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 42842)
-- Name: insurance_claims; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.insurance_claims (
    claim_id integer NOT NULL,
    claim_number character varying(50) NOT NULL,
    policy_event_id integer NOT NULL,
    claim_date date NOT NULL,
    description text,
    requested_amount numeric(15,2) NOT NULL,
    approved_amount numeric(15,2),
    status character varying(50) DEFAULT 'pending'::character varying,
    processed_by integer,
    processed_at timestamp without time zone
);


ALTER TABLE insurance.insurance_claims OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 42848)
-- Name: insurance_claims_claim_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.insurance_claims ALTER COLUMN claim_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.insurance_claims_claim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 42849)
-- Name: insurance_policies; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.insurance_policies (
    policy_id integer NOT NULL,
    policy_number character varying(50) NOT NULL,
    client_id integer NOT NULL,
    category_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    insurance_amount numeric(15,2) NOT NULL,
    monthly_payment numeric(15,2) NOT NULL,
    status character varying(50) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE insurance.insurance_policies OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 42854)
-- Name: insurance_policies_policy_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.insurance_policies ALTER COLUMN policy_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.insurance_policies_policy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 42855)
-- Name: insured_events; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.insured_events (
    event_id integer NOT NULL,
    event_name character varying(100) NOT NULL,
    description text,
    status character varying(50) DEFAULT 'active'::character varying,
    category_id integer NOT NULL,
    coverage_percentage numeric(5,2) NOT NULL,
    probability numeric(5,2) NOT NULL
);


ALTER TABLE insurance.insured_events OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 42861)
-- Name: insured_events_event_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.insured_events ALTER COLUMN event_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.insured_events_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 227 (class 1259 OID 42862)
-- Name: payments; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.payments (
    payment_id integer NOT NULL,
    payment_number character varying(50) NOT NULL,
    client_id integer NOT NULL,
    policy_id integer,
    claim_id integer,
    amount numeric(15,2) NOT NULL,
    payment_date date NOT NULL,
    payment_type character varying(50) NOT NULL,
    status character varying(50) NOT NULL
);


ALTER TABLE insurance.payments OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 42865)
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.payments ALTER COLUMN payment_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 229 (class 1259 OID 42866)
-- Name: policy_events; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.policy_events (
    policy_event_id integer NOT NULL,
    policy_id integer NOT NULL,
    event_id integer NOT NULL,
    event_date date NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying,
    description text
);


ALTER TABLE insurance.policy_events OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 42872)
-- Name: policy_events_policy_event_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.policy_events ALTER COLUMN policy_event_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.policy_events_policy_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 231 (class 1259 OID 42873)
-- Name: roles; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.roles (
    role_id integer NOT NULL,
    role_name character varying(50) NOT NULL,
    access_rights character varying(255)
);


ALTER TABLE insurance.roles OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 42876)
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.roles ALTER COLUMN role_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.roles_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 233 (class 1259 OID 42877)
-- Name: users; Type: TABLE; Schema: insurance; Owner: postgres
--

CREATE TABLE insurance.users (
    user_id integer NOT NULL,
    username character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    role_id integer,
    client_id integer,
    employee_id integer
);


ALTER TABLE insurance.users OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 42880)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: insurance; Owner: postgres
--

ALTER TABLE insurance.users ALTER COLUMN user_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME insurance.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 4907 (class 0 OID 42828)
-- Dependencies: 215
-- Data for Name: category_insurances; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.category_insurances (category_id, category_name, description, base_rate) FROM stdin;
2	Медицинское страхование	Страхование здоровья и медицинских расходов	3000.00
3	Страхование имущества	Страхование жилья и имущества от повреждений	2000.00
4	Страхование жизни	Страхование жизни и здоровья	4000.00
5	Страхование путешествий	Страхование во время поездок	1500.00
1	Автострахование	Страхование автомобилей от ущерба и угона	9000.00
\.


--
-- TOC entry 4909 (class 0 OID 42834)
-- Dependencies: 217
-- Data for Name: clients; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.clients (client_id, full_name, address, phone_number, email, birth_date, passport_data) FROM stdin;
6	Смирнов Артем Дмитриевич	ул. Молодежная, 10	+7(999)111-11-11	smirnov@mail.ru	2000-06-15	1111 111111
7	Ковалева Юлия Андреевна	ул. Студенческая, 5	+7(999)222-22-22	kovaleva@mail.ru	1998-03-20	2222 222222
8	Попов Максим Сергеевич	ул. Юности, 8	+7(999)333-33-33	popov@mail.ru	1995-12-10	3333 333333
9	Иванова Анна Петровна	ул. Молодежная, 12	+7(999)123-45-67	ivanova@mail.ru	1997-08-25	1234 567891
10	Соколова Екатерина Петровна	ул. Центральная, 15	+7(999)444-44-44	sokolova@mail.ru	1985-07-25	4444 444444
11	Лебедев Игорь Николаевич	ул. Рабочая, 20	+7(999)555-55-55	lebedev@mail.ru	1980-09-30	5555 555555
12	Новикова Мария Ивановна	ул. Садовая, 25	+7(999)666-66-66	novikova@mail.ru	1990-11-15	6666 666666
13	Петров Александр Иванович	ул. Центральная, 18	+7(999)234-56-78	petrov@mail.ru	1988-04-12	2345 678902
14	Козлов Петр Васильевич	ул. Ветеранская, 30	+7(999)777-77-77	kozlov@mail.ru	1965-04-20	7777 777777
15	Морозова Галина Степановна	ул. Пенсионная, 35	+7(999)888-88-88	morozova@mail.ru	1958-08-10	8888 888888
16	Волков Николай Павлович	ул. Заречная, 40	+7(999)999-99-99	volkov@mail.ru	1970-02-28	9999 999999
17	Сидорова Людмила Ивановна	ул. Ветеранская, 33	+7(999)345-67-89	sidorova@mail.ru	1962-11-30	3456 789013
1	Иванов Иван Иванович	ул. Ленина, 1	+7(999)111-22-33	ivanov@mail.ru	1990-01-15	1234 567890
2	Петрова Анна Сергеевна	ул. Пушкина, 2	+7(999)222-33-44	petrova@mail.ru	1985-05-20	2345 678901
3	Сидоров Алексей Николаевич	ул. Гагарина, 3	+7(999)333-44-55	sidorov@mail.ru	1995-08-10	3456 789012
4	Козлова Елена Владимировна	ул. Королева, 4	+7(999)444-55-66	kozlova@mail.ru	1988-12-25	4567 890123
5	Морозов Дмитрий Петрович	ул. Циолковского, 5	+7(999)555-66-77	morozov@mail.ru	1992-03-30	5678 901234
\.


--
-- TOC entry 4911 (class 0 OID 42838)
-- Dependencies: 219
-- Data for Name: employees; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.employees (employee_id, full_name, "position", phone_number, email, hire_date) FROM stdin;
1	Кузнецова Мария Ивановна	Страховой агент	+7(999)666-77-88	kuznetsova@mail.ru	2021-02-15
2	Новиков Дмитрий Сергеевич	Специалист по урегулированию	+7(999)777-88-99	novikov@mail.ru	2022-03-20
3	Волкова Ольга Александровна	Страховой агент	+7(999)888-99-00	volkova@mail.ru	2023-04-25
\.


--
-- TOC entry 4913 (class 0 OID 42842)
-- Dependencies: 221
-- Data for Name: insurance_claims; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.insurance_claims (claim_id, claim_number, policy_event_id, claim_date, description, requested_amount, approved_amount, status, processed_by, processed_at) FROM stdin;
4	CLM-004	4	2024-05-01	Оплата больничного	15000.00	\N	pending	\N	\N
5	CLM-005	5	2024-05-16	Компенсация отмененной поездки	25000.00	\N	pending	\N	\N
6	CLM-006	6	2024-01-21	Ремонт после серьезного ДТП	150000.00	120000.00	approved	2	\N
7	CLM-007	7	2024-02-26	Оплата экстренного лечения	80000.00	72000.00	approved	2	\N
8	CLM-008	8	2024-03-31	Восстановление после пожара	300000.00	250000.00	approved	2	\N
9	CLM-015	15	2024-01-26	Оплата лечения	90000.00	80000.00	approved	2	\N
11	CLM-010	10	2024-05-26	Компенсация отмененной поездки	35000.00	30000.00	approved	2	\N
12	CLM-011	11	2024-07-01	Ремонт после ДТП	60000.00	50000.00	approved	2	\N
13	CLM-016	16	2024-03-01	Оплата лечения	30000.00	28000.00	approved	2	\N
15	CLM-013	13	2024-08-26	Восстановление имущества	40000.00	35000.00	approved	2	\N
16	CLM-014	14	2024-10-01	Оплата реабилитации	30000.00	28000.00	approved	2	\N
\.


--
-- TOC entry 4915 (class 0 OID 42849)
-- Dependencies: 223
-- Data for Name: insurance_policies; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.insurance_policies (policy_id, policy_number, client_id, category_id, start_date, end_date, insurance_amount, monthly_payment, status, created_at) FROM stdin;
1	POL-001	1	1	2024-01-01	2025-01-01	1000000.00	5000.00	active	2025-06-06 02:07:47.92696
2	POL-002	2	2	2024-02-01	2025-02-01	500000.00	3000.00	active	2025-06-06 02:07:47.92696
3	POL-003	3	3	2024-03-01	2025-03-01	750000.00	2000.00	active	2025-06-06 02:07:47.92696
4	POL-004	4	4	2024-04-01	2025-04-01	2000000.00	4000.00	active	2025-06-06 02:07:47.92696
5	POL-005	5	5	2024-05-01	2025-05-01	300000.00	1500.00	active	2025-06-06 02:07:47.92696
6	POL-006	6	1	2024-01-15	2025-01-15	800000.00	4000.00	active	2025-06-06 02:12:50.565032
7	POL-007	7	2	2024-02-15	2025-02-15	400000.00	2500.00	active	2025-06-06 02:12:50.565032
8	POL-008	8	3	2024-03-15	2025-03-15	600000.00	1800.00	active	2025-06-06 02:12:50.565032
9	POL-015	9	4	2024-01-20	2025-01-20	1000000.00	3000.00	active	2025-06-06 02:12:50.565032
10	POL-009	10	4	2024-04-15	2025-04-15	1500000.00	3500.00	active	2025-06-06 02:12:50.565032
11	POL-010	11	5	2024-05-15	2025-05-15	250000.00	1200.00	active	2025-06-06 02:12:50.565032
12	POL-011	12	1	2024-06-15	2025-06-15	900000.00	4500.00	active	2025-06-06 02:12:50.565032
13	POL-016	13	2	2024-02-20	2025-02-20	500000.00	2800.00	active	2025-06-06 02:12:50.565032
14	POL-012	14	2	2024-07-15	2025-07-15	600000.00	2800.00	active	2025-06-06 02:12:50.565032
15	POL-013	15	3	2024-08-15	2025-08-15	800000.00	2200.00	active	2025-06-06 02:12:50.565032
16	POL-014	16	4	2024-09-15	2025-09-15	1800000.00	3800.00	active	2025-06-06 02:12:50.565032
17	POL-017	17	5	2024-03-20	2025-03-20	300000.00	1500.00	active	2025-06-06 02:12:50.565032
\.


--
-- TOC entry 4917 (class 0 OID 42855)
-- Dependencies: 225
-- Data for Name: insured_events; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.insured_events (event_id, event_name, description, status, category_id, coverage_percentage, probability) FROM stdin;
1	ДТП	Дорожно-транспортное происшествие	active	1	80.00	5.00
2	Угон	Угон автомобиля	active	1	90.00	2.00
3	Госпитализация	Экстренная госпитализация	active	2	90.00	3.00
4	Пожар	Пожар в жилом помещении	active	3	85.00	2.00
5	Травма	Травма на производстве	active	4	95.00	4.00
6	Отмена поездки	Вынужденная отмена поездки	active	5	70.00	3.00
\.


--
-- TOC entry 4919 (class 0 OID 42862)
-- Dependencies: 227
-- Data for Name: payments; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.payments (payment_id, payment_number, client_id, policy_id, claim_id, amount, payment_date, payment_type, status) FROM stdin;
1	PAY-1	1	1	\N	5000.00	2025-06-06	premium	pending
2	PAY-2	2	2	\N	3000.00	2025-06-06	premium	pending
3	PAY-3	3	3	\N	2000.00	2025-06-06	premium	pending
4	PAY-4	4	4	\N	4000.00	2025-06-06	premium	pending
5	PAY-5	5	5	\N	1500.00	2025-06-06	premium	pending
6	PAY-001	1	1	\N	5000.00	2024-01-01	premium	completed
7	PAY-002	2	2	\N	3000.00	2024-02-01	premium	completed
8	PAY-003	3	3	\N	2000.00	2024-03-01	premium	completed
9	PAY-004	4	4	\N	4000.00	2024-04-01	premium	completed
10	PAY-005	5	5	\N	1500.00	2024-05-01	premium	completed
13	PAY-6	6	6	\N	4000.00	2025-06-06	premium	pending
14	PAY-7	7	7	\N	2500.00	2025-06-06	premium	pending
15	PAY-8	8	8	\N	1800.00	2025-06-06	premium	pending
16	PAY-9	9	9	\N	3000.00	2025-06-06	premium	pending
17	PAY-10	10	10	\N	3500.00	2025-06-06	premium	pending
18	PAY-11	11	11	\N	1200.00	2025-06-06	premium	pending
19	PAY-12	12	12	\N	4500.00	2025-06-06	premium	pending
20	PAY-13	13	13	\N	2800.00	2025-06-06	premium	pending
21	PAY-14	14	14	\N	2800.00	2025-06-06	premium	pending
22	PAY-15	15	15	\N	2200.00	2025-06-06	premium	pending
23	PAY-16	16	16	\N	3800.00	2025-06-06	premium	pending
24	PAY-17	17	17	\N	1500.00	2025-06-06	premium	pending
25	PAY-008	6	6	\N	4000.00	2024-01-15	premium	completed
26	PAY-009	7	7	\N	2500.00	2024-02-15	premium	completed
27	PAY-010	8	8	\N	1800.00	2024-03-15	premium	completed
28	PAY-011	9	15	\N	3000.00	2024-01-20	premium	completed
29	PAY-012	10	9	\N	3500.00	2024-04-15	premium	completed
30	PAY-013	11	10	\N	1200.00	2024-05-15	premium	completed
31	PAY-014	12	11	\N	4500.00	2024-06-15	premium	completed
32	PAY-015	13	16	\N	2800.00	2024-02-20	premium	completed
33	PAY-016	14	12	\N	2800.00	2024-07-15	premium	completed
34	PAY-017	15	13	\N	2200.00	2024-08-15	premium	completed
35	PAY-018	16	14	\N	3800.00	2024-09-15	premium	completed
36	PAY-019	17	17	\N	1500.00	2024-03-20	premium	completed
37	PAY-020	6	\N	6	120000.00	2024-01-22	claim	completed
38	PAY-021	7	\N	7	72000.00	2024-02-27	claim	completed
39	PAY-022	8	\N	8	250000.00	2024-04-01	claim	completed
40	PAY-023	9	\N	15	80000.00	2024-01-27	claim	completed
41	PAY-024	10	\N	9	40000.00	2024-04-22	claim	completed
43	PAY-026	12	\N	11	50000.00	2024-07-02	claim	completed
44	PAY-027	13	\N	16	28000.00	2024-03-02	claim	completed
45	PAY-028	14	\N	12	22000.00	2024-07-22	claim	completed
46	PAY-029	15	\N	13	35000.00	2024-08-27	claim	completed
42	PAY-025	11	\N	\N	30000.00	2024-05-27	claim	completed
12	PAY-007	2	\N	\N	27000.00	2024-02-22	claim	completed
47	PAY-030	16	\N	\N	28000.00	2024-10-02	claim	completed
11	PAY-006	1	\N	\N	40000.00	2024-01-17	claim	completed
48	PAY-031	17	\N	\N	18000.00	2024-03-27	claim	completed
\.


--
-- TOC entry 4921 (class 0 OID 42866)
-- Dependencies: 229
-- Data for Name: policy_events; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.policy_events (policy_event_id, policy_id, event_id, event_date, status, description) FROM stdin;
1	1	1	2024-01-15	pending	Небольшое ДТП
2	2	3	2024-02-20	pending	Плановая госпитализация
3	3	4	2024-03-25	pending	Пожар в квартире
4	4	5	2024-04-30	pending	Травма на работе
5	5	6	2024-05-15	pending	Отмена командировки
6	6	1	2024-01-20	pending	Серьезное ДТП
7	7	3	2024-02-25	pending	Экстренная госпитализация
8	8	4	2024-03-30	pending	Крупный пожар
9	15	5	2024-01-25	pending	Несчастный случай
10	9	5	2024-04-20	pending	Несчастный случай на работе
11	10	6	2024-05-25	pending	Отмена деловой поездки
12	11	1	2024-06-30	pending	Небольшое ДТП
13	16	3	2024-02-28	pending	Плановая госпитализация
14	12	3	2024-07-20	pending	Плановая госпитализация
15	13	4	2024-08-25	pending	Небольшой пожар
16	14	5	2024-09-30	pending	Легкая травма
17	17	6	2024-03-25	pending	Отмена поездки
\.


--
-- TOC entry 4923 (class 0 OID 42873)
-- Dependencies: 231
-- Data for Name: roles; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.roles (role_id, role_name, access_rights) FROM stdin;
1	Клиент	Смотрит свои полисы
2	Администратор	Полный доступ
3	Менеджер	Работает с клиентами
\.


--
-- TOC entry 4925 (class 0 OID 42877)
-- Dependencies: 233
-- Data for Name: users; Type: TABLE DATA; Schema: insurance; Owner: postgres
--

COPY insurance.users (user_id, username, password_hash, role_id, client_id, employee_id) FROM stdin;
21	smirnov	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	6	\N
22	kovaleva	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	7	\N
23	popov	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	8	\N
24	ivanova	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	9	\N
25	sokolova	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	10	\N
26	lebedev	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	11	\N
27	novikova	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	12	\N
28	petrov	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	13	\N
29	kozlov	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	14	\N
30	morozova	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	15	\N
31	volkov	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	16	\N
32	sidorova	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	17	\N
1	ivanov	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	1	\N
2	petrova	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	2	\N
3	sidorov	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	3	\N
4	kozlova	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	4	\N
5	morozov	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	1	5	\N
6	kuznetsova	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	3	\N	1
7	novikov	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	3	\N	2
8	volkova	5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8	3	\N	3
\.


--
-- TOC entry 4932 (class 0 OID 0)
-- Dependencies: 216
-- Name: category_insurances_category_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.category_insurances_category_id_seq', 5, true);


--
-- TOC entry 4933 (class 0 OID 0)
-- Dependencies: 218
-- Name: clients_client_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.clients_client_id_seq', 21, true);


--
-- TOC entry 4934 (class 0 OID 0)
-- Dependencies: 220
-- Name: employees_employee_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.employees_employee_id_seq', 3, true);


--
-- TOC entry 4935 (class 0 OID 0)
-- Dependencies: 222
-- Name: insurance_claims_claim_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.insurance_claims_claim_id_seq', 17, true);


--
-- TOC entry 4936 (class 0 OID 0)
-- Dependencies: 224
-- Name: insurance_policies_policy_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.insurance_policies_policy_id_seq', 17, true);


--
-- TOC entry 4937 (class 0 OID 0)
-- Dependencies: 226
-- Name: insured_events_event_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.insured_events_event_id_seq', 6, true);


--
-- TOC entry 4938 (class 0 OID 0)
-- Dependencies: 228
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.payments_payment_id_seq', 48, true);


--
-- TOC entry 4939 (class 0 OID 0)
-- Dependencies: 230
-- Name: policy_events_policy_event_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.policy_events_policy_event_id_seq', 17, true);


--
-- TOC entry 4940 (class 0 OID 0)
-- Dependencies: 232
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.roles_role_id_seq', 3, true);


--
-- TOC entry 4941 (class 0 OID 0)
-- Dependencies: 234
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: insurance; Owner: postgres
--

SELECT pg_catalog.setval('insurance.users_user_id_seq', 32, true);


--
-- TOC entry 4690 (class 2606 OID 42882)
-- Name: category_insurances category_insurances_category_name_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.category_insurances
    ADD CONSTRAINT category_insurances_category_name_key UNIQUE (category_name);


--
-- TOC entry 4692 (class 2606 OID 42884)
-- Name: category_insurances category_insurances_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.category_insurances
    ADD CONSTRAINT category_insurances_pkey PRIMARY KEY (category_id);


--
-- TOC entry 4694 (class 2606 OID 42886)
-- Name: clients clients_email_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.clients
    ADD CONSTRAINT clients_email_key UNIQUE (email);


--
-- TOC entry 4696 (class 2606 OID 42888)
-- Name: clients clients_passport_data_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.clients
    ADD CONSTRAINT clients_passport_data_key UNIQUE (passport_data);


--
-- TOC entry 4698 (class 2606 OID 42890)
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (client_id);


--
-- TOC entry 4700 (class 2606 OID 42892)
-- Name: employees employees_email_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.employees
    ADD CONSTRAINT employees_email_key UNIQUE (email);


--
-- TOC entry 4702 (class 2606 OID 42894)
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 4706 (class 2606 OID 42896)
-- Name: insurance_claims insurance_claims_claim_number_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insurance_claims
    ADD CONSTRAINT insurance_claims_claim_number_key UNIQUE (claim_number);


--
-- TOC entry 4708 (class 2606 OID 42898)
-- Name: insurance_claims insurance_claims_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insurance_claims
    ADD CONSTRAINT insurance_claims_pkey PRIMARY KEY (claim_id);


--
-- TOC entry 4712 (class 2606 OID 42900)
-- Name: insurance_policies insurance_policies_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insurance_policies
    ADD CONSTRAINT insurance_policies_pkey PRIMARY KEY (policy_id);


--
-- TOC entry 4714 (class 2606 OID 42902)
-- Name: insurance_policies insurance_policies_policy_number_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insurance_policies
    ADD CONSTRAINT insurance_policies_policy_number_key UNIQUE (policy_number);


--
-- TOC entry 4717 (class 2606 OID 42904)
-- Name: insured_events insured_events_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insured_events
    ADD CONSTRAINT insured_events_pkey PRIMARY KEY (event_id);


--
-- TOC entry 4722 (class 2606 OID 42906)
-- Name: payments payments_payment_number_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.payments
    ADD CONSTRAINT payments_payment_number_key UNIQUE (payment_number);


--
-- TOC entry 4724 (class 2606 OID 42908)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- TOC entry 4728 (class 2606 OID 42910)
-- Name: policy_events policy_events_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.policy_events
    ADD CONSTRAINT policy_events_pkey PRIMARY KEY (policy_event_id);


--
-- TOC entry 4730 (class 2606 OID 42912)
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- TOC entry 4732 (class 2606 OID 42914)
-- Name: roles roles_role_name_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.roles
    ADD CONSTRAINT roles_role_name_key UNIQUE (role_name);


--
-- TOC entry 4737 (class 2606 OID 42916)
-- Name: users users_client_id_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.users
    ADD CONSTRAINT users_client_id_key UNIQUE (client_id);


--
-- TOC entry 4739 (class 2606 OID 42918)
-- Name: users users_employee_id_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.users
    ADD CONSTRAINT users_employee_id_key UNIQUE (employee_id);


--
-- TOC entry 4741 (class 2606 OID 42920)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 4743 (class 2606 OID 42922)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4703 (class 1259 OID 42923)
-- Name: idx_claims_policyevent_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_claims_policyevent_id ON insurance.insurance_claims USING btree (policy_event_id);


--
-- TOC entry 4704 (class 1259 OID 42924)
-- Name: idx_claims_processedby_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_claims_processedby_id ON insurance.insurance_claims USING btree (processed_by);


--
-- TOC entry 4715 (class 1259 OID 42925)
-- Name: idx_events_category_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_events_category_id ON insurance.insured_events USING btree (category_id);


--
-- TOC entry 4718 (class 1259 OID 42926)
-- Name: idx_payments_claim_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_payments_claim_id ON insurance.payments USING btree (claim_id);


--
-- TOC entry 4719 (class 1259 OID 42927)
-- Name: idx_payments_client_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_payments_client_id ON insurance.payments USING btree (client_id);


--
-- TOC entry 4720 (class 1259 OID 42928)
-- Name: idx_payments_policy_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_payments_policy_id ON insurance.payments USING btree (policy_id);


--
-- TOC entry 4709 (class 1259 OID 42929)
-- Name: idx_policies_category_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_policies_category_id ON insurance.insurance_policies USING btree (category_id);


--
-- TOC entry 4710 (class 1259 OID 42930)
-- Name: idx_policies_client_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_policies_client_id ON insurance.insurance_policies USING btree (client_id);


--
-- TOC entry 4725 (class 1259 OID 42931)
-- Name: idx_policyevents_event_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_policyevents_event_id ON insurance.policy_events USING btree (event_id);


--
-- TOC entry 4726 (class 1259 OID 42932)
-- Name: idx_policyevents_policy_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_policyevents_policy_id ON insurance.policy_events USING btree (policy_id);


--
-- TOC entry 4733 (class 1259 OID 42933)
-- Name: idx_users_client_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_users_client_id ON insurance.users USING btree (client_id);


--
-- TOC entry 4734 (class 1259 OID 42934)
-- Name: idx_users_employee_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_users_employee_id ON insurance.users USING btree (employee_id);


--
-- TOC entry 4735 (class 1259 OID 42935)
-- Name: idx_users_role_id; Type: INDEX; Schema: insurance; Owner: postgres
--

CREATE INDEX idx_users_role_id ON insurance.users USING btree (role_id);


--
-- TOC entry 4757 (class 2620 OID 50234)
-- Name: category_insurances trg_before_delete_category_insurances; Type: TRIGGER; Schema: insurance; Owner: postgres
--

CREATE TRIGGER trg_before_delete_category_insurances BEFORE DELETE ON insurance.category_insurances FOR EACH ROW EXECUTE FUNCTION insurance.check_and_cleanup_before_delete();


--
-- TOC entry 4758 (class 2620 OID 50236)
-- Name: clients trg_before_delete_clients; Type: TRIGGER; Schema: insurance; Owner: postgres
--

CREATE TRIGGER trg_before_delete_clients BEFORE DELETE ON insurance.clients FOR EACH ROW EXECUTE FUNCTION insurance.check_and_cleanup_before_delete();


--
-- TOC entry 4760 (class 2620 OID 50235)
-- Name: employees trg_before_delete_employees; Type: TRIGGER; Schema: insurance; Owner: postgres
--

CREATE TRIGGER trg_before_delete_employees BEFORE DELETE ON insurance.employees FOR EACH ROW EXECUTE FUNCTION insurance.check_and_cleanup_before_delete();


--
-- TOC entry 4762 (class 2620 OID 50232)
-- Name: insurance_policies trigger_check_policy_status; Type: TRIGGER; Schema: insurance; Owner: postgres
--

CREATE TRIGGER trigger_check_policy_status BEFORE UPDATE ON insurance.insurance_policies FOR EACH ROW EXECUTE FUNCTION insurance.check_policy_status();


--
-- TOC entry 4763 (class 2620 OID 50230)
-- Name: insurance_policies trigger_create_initial_payment; Type: TRIGGER; Schema: insurance; Owner: postgres
--

CREATE TRIGGER trigger_create_initial_payment AFTER INSERT ON insurance.insurance_policies FOR EACH ROW EXECUTE FUNCTION insurance.create_initial_payment();


--
-- TOC entry 4759 (class 2620 OID 50226)
-- Name: clients trigger_delete_user_on_client_delete; Type: TRIGGER; Schema: insurance; Owner: postgres
--

CREATE TRIGGER trigger_delete_user_on_client_delete AFTER DELETE ON insurance.clients FOR EACH ROW EXECUTE FUNCTION insurance.delete_user_on_client_delete();


--
-- TOC entry 4761 (class 2620 OID 50228)
-- Name: employees trigger_delete_user_on_employee_delete; Type: TRIGGER; Schema: insurance; Owner: postgres
--

CREATE TRIGGER trigger_delete_user_on_employee_delete AFTER DELETE ON insurance.employees FOR EACH ROW EXECUTE FUNCTION insurance.delete_user_on_employee_delete();


--
-- TOC entry 4744 (class 2606 OID 42936)
-- Name: insurance_claims fk_claims_employee; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insurance_claims
    ADD CONSTRAINT fk_claims_employee FOREIGN KEY (processed_by) REFERENCES insurance.employees(employee_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4745 (class 2606 OID 42941)
-- Name: insurance_claims fk_claims_policyevent; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insurance_claims
    ADD CONSTRAINT fk_claims_policyevent FOREIGN KEY (policy_event_id) REFERENCES insurance.policy_events(policy_event_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4748 (class 2606 OID 42946)
-- Name: insured_events fk_events_category; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insured_events
    ADD CONSTRAINT fk_events_category FOREIGN KEY (category_id) REFERENCES insurance.category_insurances(category_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4749 (class 2606 OID 42951)
-- Name: payments fk_payments_claim; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.payments
    ADD CONSTRAINT fk_payments_claim FOREIGN KEY (claim_id) REFERENCES insurance.insurance_claims(claim_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4750 (class 2606 OID 42956)
-- Name: payments fk_payments_client; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.payments
    ADD CONSTRAINT fk_payments_client FOREIGN KEY (client_id) REFERENCES insurance.clients(client_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4751 (class 2606 OID 42961)
-- Name: payments fk_payments_policy; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.payments
    ADD CONSTRAINT fk_payments_policy FOREIGN KEY (policy_id) REFERENCES insurance.insurance_policies(policy_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 4746 (class 2606 OID 42966)
-- Name: insurance_policies fk_policies_category; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insurance_policies
    ADD CONSTRAINT fk_policies_category FOREIGN KEY (category_id) REFERENCES insurance.category_insurances(category_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4747 (class 2606 OID 42971)
-- Name: insurance_policies fk_policies_client; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.insurance_policies
    ADD CONSTRAINT fk_policies_client FOREIGN KEY (client_id) REFERENCES insurance.clients(client_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4752 (class 2606 OID 42976)
-- Name: policy_events fk_policyevents_event; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.policy_events
    ADD CONSTRAINT fk_policyevents_event FOREIGN KEY (event_id) REFERENCES insurance.insured_events(event_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 4753 (class 2606 OID 42981)
-- Name: policy_events fk_policyevents_policy; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.policy_events
    ADD CONSTRAINT fk_policyevents_policy FOREIGN KEY (policy_id) REFERENCES insurance.insurance_policies(policy_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4754 (class 2606 OID 42986)
-- Name: users fk_users_client; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.users
    ADD CONSTRAINT fk_users_client FOREIGN KEY (client_id) REFERENCES insurance.clients(client_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4755 (class 2606 OID 42991)
-- Name: users fk_users_employee; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.users
    ADD CONSTRAINT fk_users_employee FOREIGN KEY (employee_id) REFERENCES insurance.employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4756 (class 2606 OID 42996)
-- Name: users fk_users_role; Type: FK CONSTRAINT; Schema: insurance; Owner: postgres
--

ALTER TABLE ONLY insurance.users
    ADD CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES insurance.roles(role_id) ON UPDATE CASCADE ON DELETE SET NULL;


-- Completed on 2025-06-06 02:20:27

--
-- PostgreSQL database dump complete
--

