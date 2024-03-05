--
-- PostgreSQL database dump
--

-- Dumped from database version 15.4
-- Dumped by pg_dump version 15.4

-- Started on 2023-12-05 19:44:07

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
-- TOC entry 875 (class 1247 OID 18559)
-- Name: cuisine_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.cuisine_type AS ENUM (
    'итальянская',
    'французская',
    'русская',
    'американская',
    'тайская'
);


ALTER TYPE public.cuisine_type OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 18688)
-- Name: calc_points(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calc_points() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
old_points int;
BEGIN
	SELECT points into old_points from clients where card_id = new.card_id;
	NEW.points = old_points + NEW.spend_money * 0.1;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.calc_points() OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 18692)
-- Name: calc_restaurant_earnings(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calc_restaurant_earnings() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	UPDATE restaurants 
    SET earnings = (SELECT SUM(spend_money) FROM 
					clients INNER JOIN ClientsRestaurants ON clients.card_id = ClientsRestaurants.card_id
        			WHERE ClientsRestaurants.restaurant_name = restaurants.restaurant_name);
    	
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calc_restaurant_earnings() OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 18669)
-- Name: calc_spend_money(character varying, numeric); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.calc_spend_money(IN client_card_id character varying, IN client_spend_money numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE clients
    SET spend_money = client_spend_money
    WHERE card_id = client_card_id;
	
    COMMIT;
END;
$$;


ALTER PROCEDURE public.calc_spend_money(IN client_card_id character varying, IN client_spend_money numeric) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 18697)
-- Name: calc_sum_earnings(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calc_sum_earnings() RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
	sum_earnings decimal;
BEGIN
	select SUM(earnings) into sum_earnings from restaurants;
	RETURN sum_earnings;  
END;
$$;


ALTER FUNCTION public.calc_sum_earnings() OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 18772)
-- Name: calculate_premium_workers(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calculate_premium_workers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF NEW.post = 'manager_mone' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 820;
	ELSIF NEW.post = 'manager_victor' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 750;
	ELSIF NEW.post = 'manager_arcobaleno' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 900;
		
	ELSIF NEW.post = 'cook_mone' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 500;
	ELSIF NEW.post = 'cook_victor' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 510;
	ELSIF NEW.post = 'cook_arcobaleno' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 490;
		
	ELSIF NEW.post = 'barmen_mone' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 450;
	ELSIF NEW.post = 'barmen_victor' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 400;
	ELSIF NEW.post = 'barmen_arcobaleno' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 440;
		
	ELSIF NEW.post = 'waiter_mone' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 400;
	ELSIF NEW.post = 'waiter_victor' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 350;
	ELSIF NEW.post = 'waiter_arcobaleno' THEN
    	NEW.premium = (NEW.waste_hours - 40) * 375;
    
	ELSE 
		NEW.premium = 0;
		
	END IF;
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.calculate_premium_workers() OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 18668)
-- Name: find_product_and_min_keep_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.find_product_and_min_keep_count() RETURNS TABLE(products_with_min_keep_count character varying, min_keep_count integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
	SELECT product_name AS products_with_min_keep_count, 
	MIN(keep_count) AS min_keep_count
    FROM products
	WHERE keep_count = (SELECT MIN(keep_count) FROM products)
    GROUP BY product_name;    
END;
$$;


ALTER FUNCTION public.find_product_and_min_keep_count() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 221 (class 1259 OID 18618)
-- Name: work_place; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_place (
    restaurant_name character varying NOT NULL,
    id_worker integer NOT NULL
);


ALTER TABLE public.work_place OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 18607)
-- Name: workers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workers (
    id_worker integer NOT NULL,
    name character varying NOT NULL,
    surname character varying NOT NULL,
    lastname character varying,
    sex character varying NOT NULL,
    birth_date date NOT NULL,
    phone_number character varying NOT NULL,
    waste_hours integer NOT NULL,
    premium integer,
    post character varying NOT NULL
);


ALTER TABLE public.workers OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 18714)
-- Name: barmens_arcobaleno; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.barmens_arcobaleno AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'бармен'::text) AND ((work_place.restaurant_name)::text = 'Аркобалено'::text));


ALTER TABLE public.barmens_arcobaleno OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 18706)
-- Name: barmens_klod_mone; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.barmens_klod_mone AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'бармен'::text) AND ((work_place.restaurant_name)::text = 'Клод Моне'::text));


ALTER TABLE public.barmens_klod_mone OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 18710)
-- Name: barmens_victor; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.barmens_victor AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'бармен'::text) AND ((work_place.restaurant_name)::text = 'Виктор'::text));


ALTER TABLE public.barmens_victor OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 18579)
-- Name: clients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clients (
    card_id character varying NOT NULL,
    name character varying NOT NULL,
    email character varying,
    phone_number character varying NOT NULL,
    spend_money numeric,
    points numeric
);


ALTER TABLE public.clients OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 18590)
-- Name: clientsrestaurants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientsrestaurants (
    restaurant_name character varying NOT NULL,
    card_id character varying NOT NULL
);


ALTER TABLE public.clientsrestaurants OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 18738)
-- Name: cooks_arcobaleno; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.cooks_arcobaleno AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'повар'::text) AND ((work_place.restaurant_name)::text = 'Аркобалено'::text));


ALTER TABLE public.cooks_arcobaleno OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 18730)
-- Name: cooks_klod_mone; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.cooks_klod_mone AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'повар'::text) AND ((work_place.restaurant_name)::text = 'Клод Моне'::text));


ALTER TABLE public.cooks_klod_mone OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 18734)
-- Name: cooks_victor; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.cooks_victor AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'повар'::text) AND ((work_place.restaurant_name)::text = 'Виктор'::text));


ALTER TABLE public.cooks_victor OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 18464)
-- Name: dishes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dishes (
    dish_name character varying NOT NULL,
    weight integer NOT NULL,
    composition character varying NOT NULL,
    callories integer NOT NULL,
    restaurant_name character varying NOT NULL,
    cuisine public.cuisine_type
);


ALTER TABLE public.dishes OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 18471)
-- Name: drinks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drinks (
    drink_name character varying NOT NULL,
    volume integer NOT NULL,
    composition character varying NOT NULL,
    alcohol_degree integer NOT NULL,
    restaurant_name character varying NOT NULL
);


ALTER TABLE public.drinks OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 18726)
-- Name: managers_arcobaleno; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.managers_arcobaleno AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'менеджер'::text) AND ((work_place.restaurant_name)::text = 'Аркобалено'::text));


ALTER TABLE public.managers_arcobaleno OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 18718)
-- Name: managers_klod_mone; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.managers_klod_mone AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'менеджер'::text) AND ((work_place.restaurant_name)::text = 'Клод Моне'::text));


ALTER TABLE public.managers_klod_mone OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 18722)
-- Name: managers_victor; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.managers_victor AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'менеджер'::text) AND ((work_place.restaurant_name)::text = 'Виктор'::text));


ALTER TABLE public.managers_victor OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 18785)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_name character varying NOT NULL,
    wieght double precision NOT NULL,
    create_data date NOT NULL,
    keep_count integer NOT NULL,
    restaurant_name character varying NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 18489)
-- Name: restaurants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.restaurants (
    restaurant_name character varying NOT NULL,
    seats_count integer NOT NULL,
    address character varying NOT NULL,
    worker_count integer NOT NULL,
    earnings numeric
);


ALTER TABLE public.restaurants OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 18496)
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    company_name character varying NOT NULL,
    delivery_type character varying NOT NULL,
    supplier_type character varying NOT NULL,
    restaurant_name character varying NOT NULL
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 18751)
-- Name: waiters_arcobaleno; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.waiters_arcobaleno AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'официант'::text) AND ((work_place.restaurant_name)::text = 'Аркобалено'::text));


ALTER TABLE public.waiters_arcobaleno OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 18742)
-- Name: waiters_klod_mone; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.waiters_klod_mone AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'официант'::text) AND ((work_place.restaurant_name)::text = 'Клод Моне'::text));


ALTER TABLE public.waiters_klod_mone OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 18747)
-- Name: waiters_victor; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.waiters_victor AS
 SELECT workers.id_worker,
    workers.name,
    workers.surname,
    workers.lastname,
    workers.post,
    work_place.restaurant_name
   FROM (public.workers
     JOIN public.work_place ON ((workers.id_worker = work_place.id_worker)))
  WHERE (((workers.post)::text = 'официант'::text) AND ((work_place.restaurant_name)::text = 'Виктор'::text));


ALTER TABLE public.waiters_victor OWNER TO postgres;

--
-- TOC entry 3466 (class 0 OID 18579)
-- Dependencies: 218
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.clients VALUES ('CL5000005', 'Марина', 'Марина5@mail.ru', '84950000004', 0, 0);
INSERT INTO public.clients VALUES ('CL6000006', 'Лев', 'Лев6@mail.ru', '84950000005', 0, 0);
INSERT INTO public.clients VALUES ('CL7000007', 'Юлия', 'Юлия7@mail.ru', '84950000006', 0, 0);
INSERT INTO public.clients VALUES ('CL8000008', 'Александр', 'Александр8@mail.ru', '84950000007', 0, 0);
INSERT INTO public.clients VALUES ('CL9000009', 'Лев', 'Лев9@mail.ru', '84950000008', 0, 0);
INSERT INTO public.clients VALUES ('CL120000012', 'Павел', 'Павел12@mail.ru', '84950000011', 0, 0);
INSERT INTO public.clients VALUES ('CL130000013', 'Павел', 'Павел13@mail.ru', '84950000012', 0, 0);
INSERT INTO public.clients VALUES ('CL140000014', 'Владимир', 'Владимир14@mail.ru', '84950000013', 0, 0);
INSERT INTO public.clients VALUES ('CL150000015', 'Татьяна', 'Татьяна15@mail.ru', '84950000014', 0, 0);
INSERT INTO public.clients VALUES ('CL160000016', 'Наталья', 'Наталья16@mail.ru', '84950000015', 0, 0);
INSERT INTO public.clients VALUES ('CL170000017', 'Михаил', 'Михаил17@mail.ru', '84950000016', 0, 0);
INSERT INTO public.clients VALUES ('CL180000018', 'Артем', 'Артем18@mail.ru', '84950000017', 0, 0);
INSERT INTO public.clients VALUES ('CL190000019', 'Наталья', 'Наталья19@mail.ru', '84950000018', 0, 0);
INSERT INTO public.clients VALUES ('CL200000020', 'Надежда', 'Надежда20@mail.ru', '84950000019', 0, 0);
INSERT INTO public.clients VALUES ('CL210000021', 'Любовь', 'Любовь21@mail.ru', '84950000020', 0, 0);
INSERT INTO public.clients VALUES ('CL220000022', 'Денис', 'Денис22@mail.ru', '84950000021', 0, 0);
INSERT INTO public.clients VALUES ('CL230000023', 'Милана', 'Милана23@mail.ru', '84950000022', 0, 0);
INSERT INTO public.clients VALUES ('CL240000024', 'Артем', 'Артем24@mail.ru', '84950000023', 0, 0);
INSERT INTO public.clients VALUES ('CL250000025', 'Надежда', 'Надежда25@mail.ru', '84950000024', 0, 0);
INSERT INTO public.clients VALUES ('CL260000026', 'Марина', 'Марина26@mail.ru', '84950000025', 0, 0);
INSERT INTO public.clients VALUES ('CL270000027', 'Никита', 'Никита27@mail.ru', '84950000026', 0, 0);
INSERT INTO public.clients VALUES ('CL280000028', 'Марина', 'Марина28@mail.ru', '84950000027', 0, 0);
INSERT INTO public.clients VALUES ('CL290000029', 'Лев', 'Лев29@mail.ru', '84950000028', 0, 0);
INSERT INTO public.clients VALUES ('CL300000030', 'Михаил', 'Михаил30@mail.ru', '84950000029', 0, 0);
INSERT INTO public.clients VALUES ('CL310000031', 'Ольга', 'Ольга31@mail.ru', '84950000030', 0, 0);
INSERT INTO public.clients VALUES ('CL320000032', 'Ринат', 'Ринат32@mail.ru', '84950000031', 0, 0);
INSERT INTO public.clients VALUES ('CL330000033', 'Алексей', 'Алексей33@mail.ru', '84950000032', 0, 0);
INSERT INTO public.clients VALUES ('CL340000034', 'Любовь', 'Любовь34@mail.ru', '84950000033', 0, 0);
INSERT INTO public.clients VALUES ('CL350000035', 'Татьяна', 'Татьяна35@mail.ru', '84950000034', 0, 0);
INSERT INTO public.clients VALUES ('CL360000036', 'Марина', 'Марина36@mail.ru', '84950000035', 0, 0);
INSERT INTO public.clients VALUES ('CL370000037', 'Иван', 'Иван37@mail.ru', '84950000036', 0, 0);
INSERT INTO public.clients VALUES ('CL380000038', 'Милана', 'Милана38@mail.ru', '84950000037', 0, 0);
INSERT INTO public.clients VALUES ('CL390000039', 'Павел', 'Павел39@mail.ru', '84950000038', 0, 0);
INSERT INTO public.clients VALUES ('CL400000040', 'Татьяна', 'Татьяна40@mail.ru', '84950000039', 0, 0);
INSERT INTO public.clients VALUES ('CL410000041', 'Ирина', 'Ирина41@mail.ru', '84950000040', 0, 0);
INSERT INTO public.clients VALUES ('CL420000042', 'Екатерина', 'Екатерина42@mail.ru', '84950000041', 0, 0);
INSERT INTO public.clients VALUES ('CL430000043', 'Мария', 'Мария43@mail.ru', '84950000042', 0, 0);
INSERT INTO public.clients VALUES ('CL440000044', 'Роман', 'Роман44@mail.ru', '84950000043', 0, 0);
INSERT INTO public.clients VALUES ('CL450000045', 'Егор', 'Егор45@mail.ru', '84950000044', 0, 0);
INSERT INTO public.clients VALUES ('CL460000046', 'Игорь', 'Игорь46@mail.ru', '84950000045', 0, 0);
INSERT INTO public.clients VALUES ('CL470000047', 'Константин', 'Константин47@mail.ru', '84950000046', 0, 0);
INSERT INTO public.clients VALUES ('CL480000048', 'Татьяна', 'Татьяна48@mail.ru', '84950000047', 0, 0);
INSERT INTO public.clients VALUES ('CL490000049', 'Павел', 'Павел49@mail.ru', '84950000048', 0, 0);
INSERT INTO public.clients VALUES ('CL500000050', 'Екатерина', 'Екатерина50@mail.ru', '84950000049', 0, 0);
INSERT INTO public.clients VALUES ('CL510000051', 'Никита', 'Никита51@mail.ru', '84950000050', 0, 0);
INSERT INTO public.clients VALUES ('CL520000052', 'Юлия', 'Юлия52@mail.ru', '84950000051', 0, 0);
INSERT INTO public.clients VALUES ('CL530000053', 'Амина', 'Амина53@mail.ru', '84950000052', 0, 0);
INSERT INTO public.clients VALUES ('CL540000054', 'Федор', 'Федор54@mail.ru', '84950000053', 0, 0);
INSERT INTO public.clients VALUES ('CL550000055', 'Евгений', 'Евгений55@mail.ru', '84950000054', 0, 0);
INSERT INTO public.clients VALUES ('CL560000056', 'Денис', 'Денис56@mail.ru', '84950000055', 0, 0);
INSERT INTO public.clients VALUES ('CL570000057', 'Денис', 'Денис57@mail.ru', '84950000056', 0, 0);
INSERT INTO public.clients VALUES ('CL580000058', 'Лев', 'Лев58@mail.ru', '84950000057', 0, 0);
INSERT INTO public.clients VALUES ('CL590000059', 'Екатерина', 'Екатерина59@mail.ru', '84950000058', 0, 0);
INSERT INTO public.clients VALUES ('CL600000060', 'Петр', 'Петр60@mail.ru', '84950000059', 0, 0);
INSERT INTO public.clients VALUES ('CL610000061', 'Даниил', 'Даниил61@mail.ru', '84950000060', 0, 0);
INSERT INTO public.clients VALUES ('CL620000062', 'Андрей', 'Андрей62@mail.ru', '84950000061', 0, 0);
INSERT INTO public.clients VALUES ('CL630000063', 'Игорь', 'Игорь63@mail.ru', '84950000062', 0, 0);
INSERT INTO public.clients VALUES ('CL640000064', 'Надежда', 'Надежда64@mail.ru', '84950000063', 0, 0);
INSERT INTO public.clients VALUES ('CL650000065', 'Виктория', 'Виктория65@mail.ru', '84950000064', 0, 0);
INSERT INTO public.clients VALUES ('CL660000066', 'Николай', 'Николай66@mail.ru', '84950000065', 0, 0);
INSERT INTO public.clients VALUES ('CL670000067', 'Дмитрий', 'Дмитрий67@mail.ru', '84950000066', 0, 0);
INSERT INTO public.clients VALUES ('CL680000068', 'Екатерина', 'Екатерина68@mail.ru', '84950000067', 0, 0);
INSERT INTO public.clients VALUES ('CL690000069', 'Юлия', 'Юлия69@mail.ru', '84950000068', 0, 0);
INSERT INTO public.clients VALUES ('CL700000070', 'Виктор', 'Виктор70@mail.ru', '84950000069', 0, 0);
INSERT INTO public.clients VALUES ('CL710000071', 'Владимир', 'Владимир71@mail.ru', '84950000070', 0, 0);
INSERT INTO public.clients VALUES ('CL720000072', 'Лев', 'Лев72@mail.ru', '84950000071', 0, 0);
INSERT INTO public.clients VALUES ('CL730000073', 'Екатерина', 'Екатерина73@mail.ru', '84950000072', 0, 0);
INSERT INTO public.clients VALUES ('CL740000074', 'Ольга', 'Ольга74@mail.ru', '84950000073', 0, 0);
INSERT INTO public.clients VALUES ('CL750000075', 'Николай', 'Николай75@mail.ru', '84950000074', 0, 0);
INSERT INTO public.clients VALUES ('CL760000076', 'Елена', 'Елена76@mail.ru', '84950000075', 0, 0);
INSERT INTO public.clients VALUES ('CL770000077', 'Михаил', 'Михаил77@mail.ru', '84950000076', 0, 0);
INSERT INTO public.clients VALUES ('CL780000078', 'Екатерина', 'Екатерина78@mail.ru', '84950000077', 0, 0);
INSERT INTO public.clients VALUES ('CL790000079', 'Александра', 'Александра79@mail.ru', '84950000078', 0, 0);
INSERT INTO public.clients VALUES ('CL800000080', 'Мария', 'Мария80@mail.ru', '84950000079', 0, 0);
INSERT INTO public.clients VALUES ('CL810000081', 'Светлана', 'Светлана81@mail.ru', '84950000080', 0, 0);
INSERT INTO public.clients VALUES ('CL820000082', 'Мария', 'Мария82@mail.ru', '84950000081', 0, 0);
INSERT INTO public.clients VALUES ('CL830000083', 'Иван', 'Иван83@mail.ru', '84950000082', 0, 0);
INSERT INTO public.clients VALUES ('CL840000084', 'Виктор', 'Виктор84@mail.ru', '84950000083', 0, 0);
INSERT INTO public.clients VALUES ('CL100000010', 'Любовь', 'Любовь10@mail.ru', '84950000009', 4670, 467.0);
INSERT INTO public.clients VALUES ('CL110000011', 'Даниил', 'Даниил11@mail.ru', '84950000010', 12220, 2234.0);
INSERT INTO public.clients VALUES ('CL3000003', 'Григорий', 'Григорий3@mail.ru', '84950000002', 970, 97.0);
INSERT INTO public.clients VALUES ('CL4000004', 'Никита', 'Никита4@mail.ru', '84950000003', 260, 26.0);
INSERT INTO public.clients VALUES ('CL850000085', 'Наталья', 'Наталья85@mail.ru', '84950000084', 0, 0);
INSERT INTO public.clients VALUES ('CL860000086', 'Артем', 'Артем86@mail.ru', '84950000085', 0, 0);
INSERT INTO public.clients VALUES ('CL870000087', 'Денис', 'Денис87@mail.ru', '84950000086', 0, 0);
INSERT INTO public.clients VALUES ('CL880000088', 'Александра', 'Александра88@mail.ru', '84950000087', 0, 0);
INSERT INTO public.clients VALUES ('CL890000089', 'Дмитрий', 'Дмитрий89@mail.ru', '84950000088', 0, 0);
INSERT INTO public.clients VALUES ('CL900000090', 'Владимир', 'Владимир90@mail.ru', '84950000089', 0, 0);
INSERT INTO public.clients VALUES ('CL910000091', 'Егор', 'Егор91@mail.ru', '84950000090', 0, 0);
INSERT INTO public.clients VALUES ('CL920000092', 'Иван', 'Иван92@mail.ru', '84950000091', 0, 0);
INSERT INTO public.clients VALUES ('CL930000093', 'Алексей', 'Алексей93@mail.ru', '84950000092', 0, 0);
INSERT INTO public.clients VALUES ('CL940000094', 'София', 'София94@mail.ru', '84950000093', 0, 0);
INSERT INTO public.clients VALUES ('CL950000095', 'Максим', 'Максим95@mail.ru', '84950000094', 0, 0);
INSERT INTO public.clients VALUES ('CL960000096', 'Мария', 'Мария96@mail.ru', '84950000095', 0, 0);
INSERT INTO public.clients VALUES ('CL970000097', 'Егор', 'Егор97@mail.ru', '84950000096', 0, 0);
INSERT INTO public.clients VALUES ('CL980000098', 'Марина', 'Марина98@mail.ru', '84950000097', 0, 0);
INSERT INTO public.clients VALUES ('CL990000099', 'Ирина', 'Ирина99@mail.ru', '84950000098', 0, 0);
INSERT INTO public.clients VALUES ('CL10000000100', 'Елизавета', 'Елизавета100@mail.ru', '84950000099', 0, 0);
INSERT INTO public.clients VALUES ('CL10100000101', 'Елена', 'Елена101@mail.ru', '84950000100', 0, 0);
INSERT INTO public.clients VALUES ('CL10200000102', 'Сергей', 'Сергей102@mail.ru', '84950000101', 0, 0);
INSERT INTO public.clients VALUES ('CL10300000103', 'Наталья', 'Наталья103@mail.ru', '84950000102', 0, 0);
INSERT INTO public.clients VALUES ('CL10400000104', 'Юлия', 'Юлия104@mail.ru', '84950000103', 0, 0);
INSERT INTO public.clients VALUES ('CL10500000105', 'Максим', 'Максим105@mail.ru', '84950000104', 0, 0);
INSERT INTO public.clients VALUES ('CL10600000106', 'Владимир', 'Владимир106@mail.ru', '84950000105', 0, 0);
INSERT INTO public.clients VALUES ('CL10700000107', 'Виктория', 'Виктория107@mail.ru', '84950000106', 0, 0);
INSERT INTO public.clients VALUES ('CL10800000108', 'Михаил', 'Михаил108@mail.ru', '84950000107', 0, 0);
INSERT INTO public.clients VALUES ('CL10900000109', 'Максим', 'Максим109@mail.ru', '84950000108', 0, 0);
INSERT INTO public.clients VALUES ('CL11000000110', 'Иван', 'Иван110@mail.ru', '84950000109', 0, 0);
INSERT INTO public.clients VALUES ('CL11100000111', 'Петр', 'Петр111@mail.ru', '84950000110', 0, 0);
INSERT INTO public.clients VALUES ('CL11200000112', 'Евгений', 'Евгений112@mail.ru', '84950000111', 0, 0);
INSERT INTO public.clients VALUES ('CL11300000113', 'Виктор', 'Виктор113@mail.ru', '84950000112', 0, 0);
INSERT INTO public.clients VALUES ('CL11400000114', 'Татьяна', 'Татьяна114@mail.ru', '84950000113', 0, 0);
INSERT INTO public.clients VALUES ('CL11500000115', 'Артем', 'Артем115@mail.ru', '84950000114', 0, 0);
INSERT INTO public.clients VALUES ('CL11600000116', 'Татьяна', 'Татьяна116@mail.ru', '84950000115', 0, 0);
INSERT INTO public.clients VALUES ('CL11700000117', 'Марина', 'Марина117@mail.ru', '84950000116', 0, 0);
INSERT INTO public.clients VALUES ('CL11800000118', 'Арсений', 'Арсений118@mail.ru', '84950000117', 0, 0);
INSERT INTO public.clients VALUES ('CL11900000119', 'Елена', 'Елена119@mail.ru', '84950000118', 0, 0);
INSERT INTO public.clients VALUES ('CL12000000120', 'Федор', 'Федор120@mail.ru', '84950000119', 0, 0);
INSERT INTO public.clients VALUES ('CL12100000121', 'Светлана', 'Светлана121@mail.ru', '84950000120', 0, 0);
INSERT INTO public.clients VALUES ('CL12200000122', 'Михаил', 'Михаил122@mail.ru', '84950000121', 0, 0);
INSERT INTO public.clients VALUES ('CL12300000123', 'Андрей', 'Андрей123@mail.ru', '84950000122', 0, 0);
INSERT INTO public.clients VALUES ('CL12400000124', 'Александр', 'Александр124@mail.ru', '84950000123', 0, 0);
INSERT INTO public.clients VALUES ('CL12500000125', 'Александра', 'Александра125@mail.ru', '84950000124', 0, 0);
INSERT INTO public.clients VALUES ('CL12600000126', 'Светлана', 'Светлана126@mail.ru', '84950000125', 0, 0);
INSERT INTO public.clients VALUES ('CL12700000127', 'Михаил', 'Михаил127@mail.ru', '84950000126', 0, 0);
INSERT INTO public.clients VALUES ('CL12800000128', 'Лев', 'Лев128@mail.ru', '84950000127', 0, 0);
INSERT INTO public.clients VALUES ('CL12900000129', 'Милана', 'Милана129@mail.ru', '84950000128', 0, 0);
INSERT INTO public.clients VALUES ('CL13000000130', 'Александр', 'Александр130@mail.ru', '84950000129', 0, 0);
INSERT INTO public.clients VALUES ('CL13100000131', 'Никита', 'Никита131@mail.ru', '84950000130', 0, 0);
INSERT INTO public.clients VALUES ('CL13200000132', 'Марина', 'Марина132@mail.ru', '84950000131', 0, 0);
INSERT INTO public.clients VALUES ('CL13300000133', 'Алексей', 'Алексей133@mail.ru', '84950000132', 0, 0);
INSERT INTO public.clients VALUES ('CL13400000134', 'Марьям', 'Марьям134@mail.ru', '84950000133', 0, 0);
INSERT INTO public.clients VALUES ('CL13500000135', 'Александра', 'Александра135@mail.ru', '84950000134', 0, 0);
INSERT INTO public.clients VALUES ('CL13600000136', 'Татьяна', 'Татьяна136@mail.ru', '84950000135', 0, 0);
INSERT INTO public.clients VALUES ('CL13700000137', 'Виктор', 'Виктор137@mail.ru', '84950000136', 0, 0);
INSERT INTO public.clients VALUES ('CL13800000138', 'Дмитрий', 'Дмитрий138@mail.ru', '84950000137', 0, 0);
INSERT INTO public.clients VALUES ('CL13900000139', 'Наталья', 'Наталья139@mail.ru', '84950000138', 0, 0);
INSERT INTO public.clients VALUES ('CL14000000140', 'София', 'София140@mail.ru', '84950000139', 0, 0);
INSERT INTO public.clients VALUES ('CL14100000141', 'Денис', 'Денис141@mail.ru', '84950000140', 0, 0);
INSERT INTO public.clients VALUES ('CL14200000142', 'Евгений', 'Евгений142@mail.ru', '84950000141', 0, 0);
INSERT INTO public.clients VALUES ('CL14300000143', 'Виктор', 'Виктор143@mail.ru', '84950000142', 0, 0);
INSERT INTO public.clients VALUES ('CL14400000144', 'Мария', 'Мария144@mail.ru', '84950000143', 0, 0);
INSERT INTO public.clients VALUES ('CL14500000145', 'Иван', 'Иван145@mail.ru', '84950000144', 0, 0);
INSERT INTO public.clients VALUES ('CL14600000146', 'Юлия', 'Юлия146@mail.ru', '84950000145', 0, 0);
INSERT INTO public.clients VALUES ('CL14700000147', 'София', 'София147@mail.ru', '84950000146', 0, 0);
INSERT INTO public.clients VALUES ('CL14800000148', 'Алексей', 'Алексей148@mail.ru', '84950000147', 0, 0);
INSERT INTO public.clients VALUES ('CL14900000149', 'Виктория', 'Виктория149@mail.ru', '84950000148', 0, 0);
INSERT INTO public.clients VALUES ('CL15000000150', 'Светлана', 'Светлана150@mail.ru', '84950000149', 0, 0);
INSERT INTO public.clients VALUES ('CL15100000151', 'Лев', 'Лев151@mail.ru', '84950000150', 0, 0);
INSERT INTO public.clients VALUES ('CL15200000152', 'Павел', 'Павел152@mail.ru', '84950000151', 0, 0);
INSERT INTO public.clients VALUES ('CL15300000153', 'Виктория', 'Виктория153@mail.ru', '84950000152', 0, 0);
INSERT INTO public.clients VALUES ('CL15400000154', 'Николай', 'Николай154@mail.ru', '84950000153', 0, 0);
INSERT INTO public.clients VALUES ('CL15500000155', 'Алексей', 'Алексей155@mail.ru', '84950000154', 0, 0);
INSERT INTO public.clients VALUES ('CL15600000156', 'Максим', 'Максим156@mail.ru', '84950000155', 0, 0);
INSERT INTO public.clients VALUES ('CL15700000157', 'Амина', 'Амина157@mail.ru', '84950000156', 0, 0);
INSERT INTO public.clients VALUES ('CL15800000158', 'Артем', 'Артем158@mail.ru', '84950000157', 0, 0);
INSERT INTO public.clients VALUES ('CL15900000159', 'Надежда', 'Надежда159@mail.ru', '84950000158', 0, 0);
INSERT INTO public.clients VALUES ('CL16000000160', 'Константин', 'Константин160@mail.ru', '84950000159', 0, 0);
INSERT INTO public.clients VALUES ('CL16100000161', 'Александр', 'Александр161@mail.ru', '84950000160', 0, 0);
INSERT INTO public.clients VALUES ('CL16200000162', 'Мария', 'Мария162@mail.ru', '84950000161', 0, 0);
INSERT INTO public.clients VALUES ('CL16300000163', 'Ирина', 'Ирина163@mail.ru', '84950000162', 0, 0);
INSERT INTO public.clients VALUES ('CL16400000164', 'Александр', 'Александр164@mail.ru', '84950000163', 0, 0);
INSERT INTO public.clients VALUES ('CL16500000165', 'Иван', 'Иван165@mail.ru', '84950000164', 0, 0);
INSERT INTO public.clients VALUES ('CL16600000166', 'Ева', 'Ева166@mail.ru', '84950000165', 0, 0);
INSERT INTO public.clients VALUES ('CL16700000167', 'Наталья', 'Наталья167@mail.ru', '84950000166', 0, 0);
INSERT INTO public.clients VALUES ('CL16800000168', 'Наталья', 'Наталья168@mail.ru', '84950000167', 0, 0);
INSERT INTO public.clients VALUES ('CL16900000169', 'Александр', 'Александр169@mail.ru', '84950000168', 0, 0);
INSERT INTO public.clients VALUES ('CL17000000170', 'Дария', 'Дария170@mail.ru', '84950000169', 0, 0);
INSERT INTO public.clients VALUES ('CL17100000171', 'Елизавета', 'Елизавета171@mail.ru', '84950000170', 0, 0);
INSERT INTO public.clients VALUES ('CL17200000172', 'Милана', 'Милана172@mail.ru', '84950000171', 0, 0);
INSERT INTO public.clients VALUES ('CL17300000173', 'Ирина', 'Ирина173@mail.ru', '84950000172', 0, 0);
INSERT INTO public.clients VALUES ('CL17400000174', 'Ева', 'Ева174@mail.ru', '84950000173', 0, 0);
INSERT INTO public.clients VALUES ('CL17500000175', 'Григорий', 'Григорий175@mail.ru', '84950000174', 0, 0);
INSERT INTO public.clients VALUES ('CL17600000176', 'Егор', 'Егор176@mail.ru', '84950000175', 0, 0);
INSERT INTO public.clients VALUES ('CL17700000177', 'Сергей', 'Сергей177@mail.ru', '84950000176', 0, 0);
INSERT INTO public.clients VALUES ('CL17800000178', 'София', 'София178@mail.ru', '84950000177', 0, 0);
INSERT INTO public.clients VALUES ('CL17900000179', 'Сергей', 'Сергей179@mail.ru', '84950000178', 0, 0);
INSERT INTO public.clients VALUES ('CL18000000180', 'Екатерина', 'Екатерина180@mail.ru', '84950000179', 0, 0);
INSERT INTO public.clients VALUES ('CL18100000181', 'Ирина', 'Ирина181@mail.ru', '84950000180', 0, 0);
INSERT INTO public.clients VALUES ('CL18200000182', 'Максим', 'Максим182@mail.ru', '84950000181', 0, 0);
INSERT INTO public.clients VALUES ('CL18300000183', 'Дария', 'Дария183@mail.ru', '84950000182', 0, 0);
INSERT INTO public.clients VALUES ('CL18400000184', 'Андрей', 'Андрей184@mail.ru', '84950000183', 0, 0);
INSERT INTO public.clients VALUES ('CL18500000185', 'Максим', 'Максим185@mail.ru', '84950000184', 0, 0);
INSERT INTO public.clients VALUES ('CL18600000186', 'Марина', 'Марина186@mail.ru', '84950000185', 0, 0);
INSERT INTO public.clients VALUES ('CL18700000187', 'Лев', 'Лев187@mail.ru', '84950000186', 0, 0);
INSERT INTO public.clients VALUES ('CL18800000188', 'Артем', 'Артем188@mail.ru', '84950000187', 0, 0);
INSERT INTO public.clients VALUES ('CL18900000189', 'Амина', 'Амина189@mail.ru', '84950000188', 0, 0);
INSERT INTO public.clients VALUES ('CL19000000190', 'Ева', 'Ева190@mail.ru', '84950000189', 0, 0);
INSERT INTO public.clients VALUES ('CL19100000191', 'Ева', 'Ева191@mail.ru', '84950000190', 0, 0);
INSERT INTO public.clients VALUES ('CL19200000192', 'Елена', 'Елена192@mail.ru', '84950000191', 0, 0);
INSERT INTO public.clients VALUES ('CL19300000193', 'Екатерина', 'Екатерина193@mail.ru', '84950000192', 0, 0);
INSERT INTO public.clients VALUES ('CL19400000194', 'Любовь', 'Любовь194@mail.ru', '84950000193', 0, 0);
INSERT INTO public.clients VALUES ('CL19500000195', 'Екатерина', 'Екатерина195@mail.ru', '84950000194', 0, 0);
INSERT INTO public.clients VALUES ('CL19600000196', 'Арсений', 'Арсений196@mail.ru', '84950000195', 0, 0);
INSERT INTO public.clients VALUES ('CL19700000197', 'Егор', 'Егор197@mail.ru', '84950000196', 0, 0);
INSERT INTO public.clients VALUES ('CL19800000198', 'Амина', 'Амина198@mail.ru', '84950000197', 0, 0);
INSERT INTO public.clients VALUES ('CL19900000199', 'Игорь', 'Игорь199@mail.ru', '84950000198', 0, 0);
INSERT INTO public.clients VALUES ('CL20000000200', 'Григорий', 'Григорий200@mail.ru', '84950000199', 0, 0);
INSERT INTO public.clients VALUES ('CL20100000201', 'Игорь', 'Игорь201@mail.ru', '84950000200', 0, 0);
INSERT INTO public.clients VALUES ('CL20200000202', 'Иван', 'Иван202@mail.ru', '84950000201', 0, 0);
INSERT INTO public.clients VALUES ('CL20300000203', 'Надежда', 'Надежда203@mail.ru', '84950000202', 0, 0);
INSERT INTO public.clients VALUES ('CL20400000204', 'Федор', 'Федор204@mail.ru', '84950000203', 0, 0);
INSERT INTO public.clients VALUES ('CL20500000205', 'Татьяна', 'Татьяна205@mail.ru', '84950000204', 0, 0);
INSERT INTO public.clients VALUES ('CL20600000206', 'Максим', 'Максим206@mail.ru', '84950000205', 0, 0);
INSERT INTO public.clients VALUES ('CL20700000207', 'Светлана', 'Светлана207@mail.ru', '84950000206', 0, 0);
INSERT INTO public.clients VALUES ('CL20800000208', 'Дария', 'Дария208@mail.ru', '84950000207', 0, 0);
INSERT INTO public.clients VALUES ('CL20900000209', 'Артем', 'Артем209@mail.ru', '84950000208', 0, 0);
INSERT INTO public.clients VALUES ('CL21000000210', 'Григорий', 'Григорий210@mail.ru', '84950000209', 0, 0);
INSERT INTO public.clients VALUES ('CL21100000211', 'Дария', 'Дария211@mail.ru', '84950000210', 0, 0);
INSERT INTO public.clients VALUES ('CL21200000212', 'Даниил', 'Даниил212@mail.ru', '84950000211', 0, 0);
INSERT INTO public.clients VALUES ('CL21300000213', 'Даниил', 'Даниил213@mail.ru', '84950000212', 0, 0);
INSERT INTO public.clients VALUES ('CL21400000214', 'Евгений', 'Евгений214@mail.ru', '84950000213', 0, 0);
INSERT INTO public.clients VALUES ('CL21500000215', 'Виктория', 'Виктория215@mail.ru', '84950000214', 0, 0);
INSERT INTO public.clients VALUES ('CL21600000216', 'Екатерина', 'Екатерина216@mail.ru', '84950000215', 0, 0);
INSERT INTO public.clients VALUES ('CL21700000217', 'Ольга', 'Ольга217@mail.ru', '84950000216', 0, 0);
INSERT INTO public.clients VALUES ('CL21800000218', 'Лев', 'Лев218@mail.ru', '84950000217', 0, 0);
INSERT INTO public.clients VALUES ('CL21900000219', 'Ева', 'Ева219@mail.ru', '84950000218', 0, 0);
INSERT INTO public.clients VALUES ('CL22000000220', 'Наталья', 'Наталья220@mail.ru', '84950000219', 0, 0);
INSERT INTO public.clients VALUES ('CL22100000221', 'Григорий', 'Григорий221@mail.ru', '84950000220', 0, 0);
INSERT INTO public.clients VALUES ('CL22200000222', 'Александра', 'Александра222@mail.ru', '84950000221', 0, 0);
INSERT INTO public.clients VALUES ('CL22300000223', 'Сергей', 'Сергей223@mail.ru', '84950000222', 0, 0);
INSERT INTO public.clients VALUES ('CL22400000224', 'Анна', 'Анна224@mail.ru', '84950000223', 0, 0);
INSERT INTO public.clients VALUES ('CL22500000225', 'Елизавета', 'Елизавета225@mail.ru', '84950000224', 0, 0);
INSERT INTO public.clients VALUES ('CL22600000226', 'Любовь', 'Любовь226@mail.ru', '84950000225', 0, 0);
INSERT INTO public.clients VALUES ('CL22700000227', 'Светлана', 'Светлана227@mail.ru', '84950000226', 0, 0);
INSERT INTO public.clients VALUES ('CL22800000228', 'Максим', 'Максим228@mail.ru', '84950000227', 0, 0);
INSERT INTO public.clients VALUES ('CL22900000229', 'Любовь', 'Любовь229@mail.ru', '84950000228', 0, 0);
INSERT INTO public.clients VALUES ('CL23000000230', 'Елена', 'Елена230@mail.ru', '84950000229', 0, 0);
INSERT INTO public.clients VALUES ('CL23100000231', 'Виктория', 'Виктория231@mail.ru', '84950000230', 0, 0);
INSERT INTO public.clients VALUES ('CL23200000232', 'Игорь', 'Игорь232@mail.ru', '84950000231', 0, 0);
INSERT INTO public.clients VALUES ('CL23300000233', 'Петр', 'Петр233@mail.ru', '84950000232', 0, 0);
INSERT INTO public.clients VALUES ('CL23400000234', 'Андрей', 'Андрей234@mail.ru', '84950000233', 0, 0);
INSERT INTO public.clients VALUES ('CL23500000235', 'Евгений', 'Евгений235@mail.ru', '84950000234', 0, 0);
INSERT INTO public.clients VALUES ('CL23600000236', 'Виктория', 'Виктория236@mail.ru', '84950000235', 0, 0);
INSERT INTO public.clients VALUES ('CL23700000237', 'Амина', 'Амина237@mail.ru', '84950000236', 0, 0);
INSERT INTO public.clients VALUES ('CL23800000238', 'Александр', 'Александр238@mail.ru', '84950000237', 0, 0);
INSERT INTO public.clients VALUES ('CL23900000239', 'Андрей', 'Андрей239@mail.ru', '84950000238', 0, 0);
INSERT INTO public.clients VALUES ('CL24000000240', 'Иван', 'Иван240@mail.ru', '84950000239', 0, 0);
INSERT INTO public.clients VALUES ('CL24100000241', 'Ирина', 'Ирина241@mail.ru', '84950000240', 0, 0);
INSERT INTO public.clients VALUES ('CL24200000242', 'Дария', 'Дария242@mail.ru', '84950000241', 0, 0);
INSERT INTO public.clients VALUES ('CL24300000243', 'Александр', 'Александр243@mail.ru', '84950000242', 0, 0);
INSERT INTO public.clients VALUES ('CL24400000244', 'Арсений', 'Арсений244@mail.ru', '84950000243', 0, 0);
INSERT INTO public.clients VALUES ('CL24500000245', 'Сергей', 'Сергей245@mail.ru', '84950000244', 0, 0);
INSERT INTO public.clients VALUES ('CL24600000246', 'Амина', 'Амина246@mail.ru', '84950000245', 0, 0);
INSERT INTO public.clients VALUES ('CL24700000247', 'Виктория', 'Виктория247@mail.ru', '84950000246', 0, 0);
INSERT INTO public.clients VALUES ('CL24800000248', 'Григорий', 'Григорий248@mail.ru', '84950000247', 0, 0);
INSERT INTO public.clients VALUES ('CL24900000249', 'Ринат', 'Ринат249@mail.ru', '84950000248', 0, 0);
INSERT INTO public.clients VALUES ('CL25000000250', 'Егор', 'Егор250@mail.ru', '84950000249', 0, 0);
INSERT INTO public.clients VALUES ('CL25100000251', 'Михаил', 'Михаил251@mail.ru', '84950000250', 0, 0);
INSERT INTO public.clients VALUES ('CL25200000252', 'Максим', 'Максим252@mail.ru', '84950000251', 0, 0);
INSERT INTO public.clients VALUES ('CL25300000253', 'Константин', 'Константин253@mail.ru', '84950000252', 0, 0);
INSERT INTO public.clients VALUES ('CL25400000254', 'Константин', 'Константин254@mail.ru', '84950000253', 0, 0);
INSERT INTO public.clients VALUES ('CL25500000255', 'Иван', 'Иван255@mail.ru', '84950000254', 0, 0);
INSERT INTO public.clients VALUES ('CL25600000256', 'Светлана', 'Светлана256@mail.ru', '84950000255', 0, 0);
INSERT INTO public.clients VALUES ('CL25700000257', 'Лев', 'Лев257@mail.ru', '84950000256', 0, 0);
INSERT INTO public.clients VALUES ('CL25800000258', 'Константин', 'Константин258@mail.ru', '84950000257', 0, 0);
INSERT INTO public.clients VALUES ('CL25900000259', 'Светлана', 'Светлана259@mail.ru', '84950000258', 0, 0);
INSERT INTO public.clients VALUES ('CL26000000260', 'Григорий', 'Григорий260@mail.ru', '84950000259', 0, 0);
INSERT INTO public.clients VALUES ('CL26100000261', 'Дария', 'Дария261@mail.ru', '84950000260', 0, 0);
INSERT INTO public.clients VALUES ('CL26200000262', 'Ольга', 'Ольга262@mail.ru', '84950000261', 0, 0);
INSERT INTO public.clients VALUES ('CL26300000263', 'Любовь', 'Любовь263@mail.ru', '84950000262', 0, 0);
INSERT INTO public.clients VALUES ('CL26400000264', 'Андрей', 'Андрей264@mail.ru', '84950000263', 0, 0);
INSERT INTO public.clients VALUES ('CL26500000265', 'Алексей', 'Алексей265@mail.ru', '84950000264', 0, 0);
INSERT INTO public.clients VALUES ('CL26600000266', 'Марьям', 'Марьям266@mail.ru', '84950000265', 0, 0);
INSERT INTO public.clients VALUES ('CL26700000267', 'Александр', 'Александр267@mail.ru', '84950000266', 0, 0);
INSERT INTO public.clients VALUES ('CL26800000268', 'Татьяна', 'Татьяна268@mail.ru', '84950000267', 0, 0);
INSERT INTO public.clients VALUES ('CL26900000269', 'Максим', 'Максим269@mail.ru', '84950000268', 0, 0);
INSERT INTO public.clients VALUES ('CL27000000270', 'Даниил', 'Даниил270@mail.ru', '84950000269', 0, 0);
INSERT INTO public.clients VALUES ('CL27100000271', 'Екатерина', 'Екатерина271@mail.ru', '84950000270', 0, 0);
INSERT INTO public.clients VALUES ('CL27200000272', 'Надежда', 'Надежда272@mail.ru', '84950000271', 0, 0);
INSERT INTO public.clients VALUES ('CL27300000273', 'Петр', 'Петр273@mail.ru', '84950000272', 0, 0);
INSERT INTO public.clients VALUES ('CL27400000274', 'Виктор', 'Виктор274@mail.ru', '84950000273', 0, 0);
INSERT INTO public.clients VALUES ('CL27500000275', 'Дмитрий', 'Дмитрий275@mail.ru', '84950000274', 0, 0);
INSERT INTO public.clients VALUES ('CL27600000276', 'Денис', 'Денис276@mail.ru', '84950000275', 0, 0);
INSERT INTO public.clients VALUES ('CL27700000277', 'Александра', 'Александра277@mail.ru', '84950000276', 0, 0);
INSERT INTO public.clients VALUES ('CL27800000278', 'Александра', 'Александра278@mail.ru', '84950000277', 0, 0);
INSERT INTO public.clients VALUES ('CL27900000279', 'Наталья', 'Наталья279@mail.ru', '84950000278', 0, 0);
INSERT INTO public.clients VALUES ('CL28000000280', 'Дмитрий', 'Дмитрий280@mail.ru', '84950000279', 0, 0);
INSERT INTO public.clients VALUES ('CL28100000281', 'Егор', 'Егор281@mail.ru', '84950000280', 0, 0);
INSERT INTO public.clients VALUES ('CL28200000282', 'Ольга', 'Ольга282@mail.ru', '84950000281', 0, 0);
INSERT INTO public.clients VALUES ('CL28300000283', 'Виктория', 'Виктория283@mail.ru', '84950000282', 0, 0);
INSERT INTO public.clients VALUES ('CL28400000284', 'Александра', 'Александра284@mail.ru', '84950000283', 0, 0);
INSERT INTO public.clients VALUES ('CL28500000285', 'Ольга', 'Ольга285@mail.ru', '84950000284', 0, 0);
INSERT INTO public.clients VALUES ('CL28600000286', 'Артем', 'Артем286@mail.ru', '84950000285', 0, 0);
INSERT INTO public.clients VALUES ('CL28700000287', 'Сергей', 'Сергей287@mail.ru', '84950000286', 0, 0);
INSERT INTO public.clients VALUES ('CL28800000288', 'Игорь', 'Игорь288@mail.ru', '84950000287', 0, 0);
INSERT INTO public.clients VALUES ('CL28900000289', 'Никита', 'Никита289@mail.ru', '84950000288', 0, 0);
INSERT INTO public.clients VALUES ('CL29000000290', 'Дария', 'Дария290@mail.ru', '84950000289', 0, 0);
INSERT INTO public.clients VALUES ('CL29100000291', 'Елена', 'Елена291@mail.ru', '84950000290', 0, 0);
INSERT INTO public.clients VALUES ('CL29200000292', 'Иван', 'Иван292@mail.ru', '84950000291', 0, 0);
INSERT INTO public.clients VALUES ('CL29300000293', 'Юлия', 'Юлия293@mail.ru', '84950000292', 0, 0);
INSERT INTO public.clients VALUES ('CL29400000294', 'Андрей', 'Андрей294@mail.ru', '84950000293', 0, 0);
INSERT INTO public.clients VALUES ('CL29500000295', 'София', 'София295@mail.ru', '84950000294', 0, 0);
INSERT INTO public.clients VALUES ('CL29600000296', 'Даниил', 'Даниил296@mail.ru', '84950000295', 0, 0);
INSERT INTO public.clients VALUES ('CL29700000297', 'Лев', 'Лев297@mail.ru', '84950000296', 0, 0);
INSERT INTO public.clients VALUES ('CL29800000298', 'Елена', 'Елена298@mail.ru', '84950000297', 0, 0);
INSERT INTO public.clients VALUES ('CL29900000299', 'Ринат', 'Ринат299@mail.ru', '84950000298', 0, 0);
INSERT INTO public.clients VALUES ('CL30000000300', 'Лев', 'Лев300@mail.ru', '84950000299', 0, 0);
INSERT INTO public.clients VALUES ('CL30100000301', 'София', 'София301@mail.ru', '84950000300', 0, 0);
INSERT INTO public.clients VALUES ('CL30200000302', 'Ева', 'Ева302@mail.ru', '84950000301', 0, 0);
INSERT INTO public.clients VALUES ('CL30300000303', 'Светлана', 'Светлана303@mail.ru', '84950000302', 0, 0);
INSERT INTO public.clients VALUES ('CL30400000304', 'Анна', 'Анна304@mail.ru', '84950000303', 0, 0);
INSERT INTO public.clients VALUES ('CL30500000305', 'Марьям', 'Марьям305@mail.ru', '84950000304', 0, 0);
INSERT INTO public.clients VALUES ('CL30600000306', 'Евгений', 'Евгений306@mail.ru', '84950000305', 0, 0);
INSERT INTO public.clients VALUES ('CL30700000307', 'Артем', 'Артем307@mail.ru', '84950000306', 0, 0);
INSERT INTO public.clients VALUES ('CL30800000308', 'Арсений', 'Арсений308@mail.ru', '84950000307', 0, 0);
INSERT INTO public.clients VALUES ('CL30900000309', 'Иван', 'Иван309@mail.ru', '84950000308', 0, 0);
INSERT INTO public.clients VALUES ('CL31000000310', 'Константин', 'Константин310@mail.ru', '84950000309', 0, 0);
INSERT INTO public.clients VALUES ('CL31100000311', 'Юлия', 'Юлия311@mail.ru', '84950000310', 0, 0);
INSERT INTO public.clients VALUES ('CL31200000312', 'София', 'София312@mail.ru', '84950000311', 0, 0);
INSERT INTO public.clients VALUES ('CL31300000313', 'Иван', 'Иван313@mail.ru', '84950000312', 0, 0);
INSERT INTO public.clients VALUES ('CL31400000314', 'Владимир', 'Владимир314@mail.ru', '84950000313', 0, 0);
INSERT INTO public.clients VALUES ('CL31500000315', 'Григорий', 'Григорий315@mail.ru', '84950000314', 0, 0);
INSERT INTO public.clients VALUES ('CL31600000316', 'Юлия', 'Юлия316@mail.ru', '84950000315', 0, 0);
INSERT INTO public.clients VALUES ('CL31700000317', 'Максим', 'Максим317@mail.ru', '84950000316', 0, 0);
INSERT INTO public.clients VALUES ('CL31800000318', 'Елизавета', 'Елизавета318@mail.ru', '84950000317', 0, 0);
INSERT INTO public.clients VALUES ('CL31900000319', 'Дария', 'Дария319@mail.ru', '84950000318', 0, 0);
INSERT INTO public.clients VALUES ('CL32000000320', 'Марина', 'Марина320@mail.ru', '84950000319', 0, 0);
INSERT INTO public.clients VALUES ('CL32100000321', 'Елизавета', 'Елизавета321@mail.ru', '84950000320', 0, 0);
INSERT INTO public.clients VALUES ('CL32200000322', 'Евгений', 'Евгений322@mail.ru', '84950000321', 0, 0);
INSERT INTO public.clients VALUES ('CL32300000323', 'София', 'София323@mail.ru', '84950000322', 0, 0);
INSERT INTO public.clients VALUES ('CL32400000324', 'Михаил', 'Михаил324@mail.ru', '84950000323', 0, 0);
INSERT INTO public.clients VALUES ('CL32500000325', 'Александра', 'Александра325@mail.ru', '84950000324', 0, 0);
INSERT INTO public.clients VALUES ('CL32600000326', 'Светлана', 'Светлана326@mail.ru', '84950000325', 0, 0);
INSERT INTO public.clients VALUES ('CL32700000327', 'Андрей', 'Андрей327@mail.ru', '84950000326', 0, 0);
INSERT INTO public.clients VALUES ('CL32800000328', 'Андрей', 'Андрей328@mail.ru', '84950000327', 0, 0);
INSERT INTO public.clients VALUES ('CL32900000329', 'Виктор', 'Виктор329@mail.ru', '84950000328', 0, 0);
INSERT INTO public.clients VALUES ('CL33000000330', 'Ринат', 'Ринат330@mail.ru', '84950000329', 0, 0);
INSERT INTO public.clients VALUES ('CL33100000331', 'Сергей', 'Сергей331@mail.ru', '84950000330', 0, 0);
INSERT INTO public.clients VALUES ('CL33200000332', 'Петр', 'Петр332@mail.ru', '84950000331', 0, 0);
INSERT INTO public.clients VALUES ('CL33300000333', 'София', 'София333@mail.ru', '84950000332', 0, 0);
INSERT INTO public.clients VALUES ('CL33400000334', 'Максим', 'Максим334@mail.ru', '84950000333', 0, 0);
INSERT INTO public.clients VALUES ('CL33500000335', 'Татьяна', 'Татьяна335@mail.ru', '84950000334', 0, 0);
INSERT INTO public.clients VALUES ('CL33600000336', 'Лев', 'Лев336@mail.ru', '84950000335', 0, 0);
INSERT INTO public.clients VALUES ('CL33700000337', 'Федор', 'Федор337@mail.ru', '84950000336', 0, 0);
INSERT INTO public.clients VALUES ('CL33800000338', 'Егор', 'Егор338@mail.ru', '84950000337', 0, 0);
INSERT INTO public.clients VALUES ('CL33900000339', 'Арсений', 'Арсений339@mail.ru', '84950000338', 0, 0);
INSERT INTO public.clients VALUES ('CL34000000340', 'Роман', 'Роман340@mail.ru', '84950000339', 0, 0);
INSERT INTO public.clients VALUES ('CL34100000341', 'Юлия', 'Юлия341@mail.ru', '84950000340', 0, 0);
INSERT INTO public.clients VALUES ('CL34200000342', 'Егор', 'Егор342@mail.ru', '84950000341', 0, 0);
INSERT INTO public.clients VALUES ('CL34300000343', 'Денис', 'Денис343@mail.ru', '84950000342', 0, 0);
INSERT INTO public.clients VALUES ('CL34400000344', 'Павел', 'Павел344@mail.ru', '84950000343', 0, 0);
INSERT INTO public.clients VALUES ('CL34500000345', 'Марьям', 'Марьям345@mail.ru', '84950000344', 0, 0);
INSERT INTO public.clients VALUES ('CL34600000346', 'Мария', 'Мария346@mail.ru', '84950000345', 0, 0);
INSERT INTO public.clients VALUES ('CL34700000347', 'Марьям', 'Марьям347@mail.ru', '84950000346', 0, 0);
INSERT INTO public.clients VALUES ('CL34800000348', 'Екатерина', 'Екатерина348@mail.ru', '84950000347', 0, 0);
INSERT INTO public.clients VALUES ('CL34900000349', 'Михаил', 'Михаил349@mail.ru', '84950000348', 0, 0);
INSERT INTO public.clients VALUES ('CL35000000350', 'Денис', 'Денис350@mail.ru', '84950000349', 0, 0);
INSERT INTO public.clients VALUES ('CL35100000351', 'Марина', 'Марина351@mail.ru', '84950000350', 0, 0);
INSERT INTO public.clients VALUES ('CL35200000352', 'Алексей', 'Алексей352@mail.ru', '84950000351', 0, 0);
INSERT INTO public.clients VALUES ('CL35300000353', 'Владимир', 'Владимир353@mail.ru', '84950000352', 0, 0);
INSERT INTO public.clients VALUES ('CL35400000354', 'Сергей', 'Сергей354@mail.ru', '84950000353', 0, 0);
INSERT INTO public.clients VALUES ('CL35500000355', 'Екатерина', 'Екатерина355@mail.ru', '84950000354', 0, 0);
INSERT INTO public.clients VALUES ('CL35600000356', 'Ева', 'Ева356@mail.ru', '84950000355', 0, 0);
INSERT INTO public.clients VALUES ('CL35700000357', 'Артем', 'Артем357@mail.ru', '84950000356', 0, 0);
INSERT INTO public.clients VALUES ('CL35800000358', 'Александр', 'Александр358@mail.ru', '84950000357', 0, 0);
INSERT INTO public.clients VALUES ('CL35900000359', 'Лев', 'Лев359@mail.ru', '84950000358', 0, 0);
INSERT INTO public.clients VALUES ('CL36000000360', 'Арсений', 'Арсений360@mail.ru', '84950000359', 0, 0);
INSERT INTO public.clients VALUES ('CL36100000361', 'Максим', 'Максим361@mail.ru', '84950000360', 0, 0);
INSERT INTO public.clients VALUES ('CL36200000362', 'Андрей', 'Андрей362@mail.ru', '84950000361', 0, 0);
INSERT INTO public.clients VALUES ('CL36300000363', 'Амина', 'Амина363@mail.ru', '84950000362', 0, 0);
INSERT INTO public.clients VALUES ('CL36400000364', 'Артем', 'Артем364@mail.ru', '84950000363', 0, 0);
INSERT INTO public.clients VALUES ('CL36500000365', 'Александра', 'Александра365@mail.ru', '84950000364', 0, 0);
INSERT INTO public.clients VALUES ('CL36600000366', 'Федор', 'Федор366@mail.ru', '84950000365', 0, 0);
INSERT INTO public.clients VALUES ('CL36700000367', 'Даниил', 'Даниил367@mail.ru', '84950000366', 0, 0);
INSERT INTO public.clients VALUES ('CL36800000368', 'Елена', 'Елена368@mail.ru', '84950000367', 0, 0);
INSERT INTO public.clients VALUES ('CL36900000369', 'Евгений', 'Евгений369@mail.ru', '84950000368', 0, 0);
INSERT INTO public.clients VALUES ('CL37000000370', 'Даниил', 'Даниил370@mail.ru', '84950000369', 0, 0);
INSERT INTO public.clients VALUES ('CL37100000371', 'Милана', 'Милана371@mail.ru', '84950000370', 0, 0);
INSERT INTO public.clients VALUES ('CL37200000372', 'Дмитрий', 'Дмитрий372@mail.ru', '84950000371', 0, 0);
INSERT INTO public.clients VALUES ('CL37300000373', 'Сергей', 'Сергей373@mail.ru', '84950000372', 0, 0);
INSERT INTO public.clients VALUES ('CL37400000374', 'Анна', 'Анна374@mail.ru', '84950000373', 0, 0);
INSERT INTO public.clients VALUES ('CL37500000375', 'Никита', 'Никита375@mail.ru', '84950000374', 0, 0);
INSERT INTO public.clients VALUES ('CL37600000376', 'Юлия', 'Юлия376@mail.ru', '84950000375', 0, 0);
INSERT INTO public.clients VALUES ('CL37700000377', 'Иван', 'Иван377@mail.ru', '84950000376', 0, 0);
INSERT INTO public.clients VALUES ('CL37800000378', 'Светлана', 'Светлана378@mail.ru', '84950000377', 0, 0);
INSERT INTO public.clients VALUES ('CL37900000379', 'Дария', 'Дария379@mail.ru', '84950000378', 0, 0);
INSERT INTO public.clients VALUES ('CL38000000380', 'Егор', 'Егор380@mail.ru', '84950000379', 0, 0);
INSERT INTO public.clients VALUES ('CL38100000381', 'Марина', 'Марина381@mail.ru', '84950000380', 0, 0);
INSERT INTO public.clients VALUES ('CL38200000382', 'Марьям', 'Марьям382@mail.ru', '84950000381', 0, 0);
INSERT INTO public.clients VALUES ('CL38300000383', 'Николай', 'Николай383@mail.ru', '84950000382', 0, 0);
INSERT INTO public.clients VALUES ('CL38400000384', 'Лев', 'Лев384@mail.ru', '84950000383', 0, 0);
INSERT INTO public.clients VALUES ('CL38500000385', 'Петр', 'Петр385@mail.ru', '84950000384', 0, 0);
INSERT INTO public.clients VALUES ('CL38600000386', 'Константин', 'Константин386@mail.ru', '84950000385', 0, 0);
INSERT INTO public.clients VALUES ('CL38700000387', 'Никита', 'Никита387@mail.ru', '84950000386', 0, 0);
INSERT INTO public.clients VALUES ('CL38800000388', 'Денис', 'Денис388@mail.ru', '84950000387', 0, 0);
INSERT INTO public.clients VALUES ('CL38900000389', 'Евгений', 'Евгений389@mail.ru', '84950000388', 0, 0);
INSERT INTO public.clients VALUES ('CL39000000390', 'Артем', 'Артем390@mail.ru', '84950000389', 0, 0);
INSERT INTO public.clients VALUES ('CL39100000391', 'Егор', 'Егор391@mail.ru', '84950000390', 0, 0);
INSERT INTO public.clients VALUES ('CL39200000392', 'Ольга', 'Ольга392@mail.ru', '84950000391', 0, 0);
INSERT INTO public.clients VALUES ('CL39300000393', 'Татьяна', 'Татьяна393@mail.ru', '84950000392', 0, 0);
INSERT INTO public.clients VALUES ('CL39400000394', 'Никита', 'Никита394@mail.ru', '84950000393', 0, 0);
INSERT INTO public.clients VALUES ('CL39500000395', 'Никита', 'Никита395@mail.ru', '84950000394', 0, 0);
INSERT INTO public.clients VALUES ('CL39600000396', 'Егор', 'Егор396@mail.ru', '84950000395', 0, 0);
INSERT INTO public.clients VALUES ('CL39700000397', 'София', 'София397@mail.ru', '84950000396', 0, 0);
INSERT INTO public.clients VALUES ('CL39800000398', 'Александр', 'Александр398@mail.ru', '84950000397', 0, 0);
INSERT INTO public.clients VALUES ('CL39900000399', 'Виктор', 'Виктор399@mail.ru', '84950000398', 0, 0);
INSERT INTO public.clients VALUES ('CL40000000400', 'Федор', 'Федор400@mail.ru', '84950000399', 0, 0);
INSERT INTO public.clients VALUES ('CL40100000401', 'Григорий', 'Григорий401@mail.ru', '84950000400', 0, 0);
INSERT INTO public.clients VALUES ('CL40200000402', 'Дмитрий', 'Дмитрий402@mail.ru', '84950000401', 0, 0);
INSERT INTO public.clients VALUES ('CL40300000403', 'Дария', 'Дария403@mail.ru', '84950000402', 0, 0);
INSERT INTO public.clients VALUES ('CL40400000404', 'Михаил', 'Михаил404@mail.ru', '84950000403', 0, 0);
INSERT INTO public.clients VALUES ('CL40500000405', 'Ринат', 'Ринат405@mail.ru', '84950000404', 0, 0);
INSERT INTO public.clients VALUES ('CL40600000406', 'Елена', 'Елена406@mail.ru', '84950000405', 0, 0);
INSERT INTO public.clients VALUES ('CL40700000407', 'Евгений', 'Евгений407@mail.ru', '84950000406', 0, 0);
INSERT INTO public.clients VALUES ('CL40800000408', 'Милана', 'Милана408@mail.ru', '84950000407', 0, 0);
INSERT INTO public.clients VALUES ('CL40900000409', 'Григорий', 'Григорий409@mail.ru', '84950000408', 0, 0);
INSERT INTO public.clients VALUES ('CL41000000410', 'Любовь', 'Любовь410@mail.ru', '84950000409', 0, 0);
INSERT INTO public.clients VALUES ('CL41100000411', 'Сергей', 'Сергей411@mail.ru', '84950000410', 0, 0);
INSERT INTO public.clients VALUES ('CL41200000412', 'Егор', 'Егор412@mail.ru', '84950000411', 0, 0);
INSERT INTO public.clients VALUES ('CL41300000413', 'Денис', 'Денис413@mail.ru', '84950000412', 0, 0);
INSERT INTO public.clients VALUES ('CL41400000414', 'Александр', 'Александр414@mail.ru', '84950000413', 0, 0);
INSERT INTO public.clients VALUES ('CL41500000415', 'Федор', 'Федор415@mail.ru', '84950000414', 0, 0);
INSERT INTO public.clients VALUES ('CL41600000416', 'Андрей', 'Андрей416@mail.ru', '84950000415', 0, 0);
INSERT INTO public.clients VALUES ('CL41700000417', 'Виктор', 'Виктор417@mail.ru', '84950000416', 0, 0);
INSERT INTO public.clients VALUES ('CL41800000418', 'Артем', 'Артем418@mail.ru', '84950000417', 0, 0);
INSERT INTO public.clients VALUES ('CL41900000419', 'Амина', 'Амина419@mail.ru', '84950000418', 0, 0);
INSERT INTO public.clients VALUES ('CL42000000420', 'Алексей', 'Алексей420@mail.ru', '84950000419', 0, 0);
INSERT INTO public.clients VALUES ('CL42100000421', 'Виктор', 'Виктор421@mail.ru', '84950000420', 0, 0);
INSERT INTO public.clients VALUES ('CL42200000422', 'Екатерина', 'Екатерина422@mail.ru', '84950000421', 0, 0);
INSERT INTO public.clients VALUES ('CL42300000423', 'Дария', 'Дария423@mail.ru', '84950000422', 0, 0);
INSERT INTO public.clients VALUES ('CL42400000424', 'Артем', 'Артем424@mail.ru', '84950000423', 0, 0);
INSERT INTO public.clients VALUES ('CL42500000425', 'Анна', 'Анна425@mail.ru', '84950000424', 0, 0);
INSERT INTO public.clients VALUES ('CL42600000426', 'Максим', 'Максим426@mail.ru', '84950000425', 0, 0);
INSERT INTO public.clients VALUES ('CL42700000427', 'Денис', 'Денис427@mail.ru', '84950000426', 0, 0);
INSERT INTO public.clients VALUES ('CL42800000428', 'Лев', 'Лев428@mail.ru', '84950000427', 0, 0);
INSERT INTO public.clients VALUES ('CL42900000429', 'Ева', 'Ева429@mail.ru', '84950000428', 0, 0);
INSERT INTO public.clients VALUES ('CL43000000430', 'Григорий', 'Григорий430@mail.ru', '84950000429', 0, 0);
INSERT INTO public.clients VALUES ('CL43100000431', 'Петр', 'Петр431@mail.ru', '84950000430', 0, 0);
INSERT INTO public.clients VALUES ('CL43200000432', 'Иван', 'Иван432@mail.ru', '84950000431', 0, 0);
INSERT INTO public.clients VALUES ('CL43300000433', 'Амина', 'Амина433@mail.ru', '84950000432', 0, 0);
INSERT INTO public.clients VALUES ('CL43400000434', 'Денис', 'Денис434@mail.ru', '84950000433', 0, 0);
INSERT INTO public.clients VALUES ('CL43500000435', 'Мария', 'Мария435@mail.ru', '84950000434', 0, 0);
INSERT INTO public.clients VALUES ('CL43600000436', 'Егор', 'Егор436@mail.ru', '84950000435', 0, 0);
INSERT INTO public.clients VALUES ('CL43700000437', 'Виктор', 'Виктор437@mail.ru', '84950000436', 0, 0);
INSERT INTO public.clients VALUES ('CL43800000438', 'Петр', 'Петр438@mail.ru', '84950000437', 0, 0);
INSERT INTO public.clients VALUES ('CL43900000439', 'Амина', 'Амина439@mail.ru', '84950000438', 0, 0);
INSERT INTO public.clients VALUES ('CL44000000440', 'Даниил', 'Даниил440@mail.ru', '84950000439', 0, 0);
INSERT INTO public.clients VALUES ('CL44100000441', 'Мария', 'Мария441@mail.ru', '84950000440', 0, 0);
INSERT INTO public.clients VALUES ('CL44200000442', 'Наталья', 'Наталья442@mail.ru', '84950000441', 0, 0);
INSERT INTO public.clients VALUES ('CL44300000443', 'Марьям', 'Марьям443@mail.ru', '84950000442', 0, 0);
INSERT INTO public.clients VALUES ('CL44400000444', 'Ирина', 'Ирина444@mail.ru', '84950000443', 0, 0);
INSERT INTO public.clients VALUES ('CL44500000445', 'Федор', 'Федор445@mail.ru', '84950000444', 0, 0);
INSERT INTO public.clients VALUES ('CL44600000446', 'Дария', 'Дария446@mail.ru', '84950000445', 0, 0);
INSERT INTO public.clients VALUES ('CL44700000447', 'Юлия', 'Юлия447@mail.ru', '84950000446', 0, 0);
INSERT INTO public.clients VALUES ('CL44800000448', 'Татьяна', 'Татьяна448@mail.ru', '84950000447', 0, 0);
INSERT INTO public.clients VALUES ('CL44900000449', 'Андрей', 'Андрей449@mail.ru', '84950000448', 0, 0);
INSERT INTO public.clients VALUES ('CL45000000450', 'Федор', 'Федор450@mail.ru', '84950000449', 0, 0);
INSERT INTO public.clients VALUES ('CL45100000451', 'Анна', 'Анна451@mail.ru', '84950000450', 0, 0);
INSERT INTO public.clients VALUES ('CL45200000452', 'Надежда', 'Надежда452@mail.ru', '84950000451', 0, 0);
INSERT INTO public.clients VALUES ('CL45300000453', 'Ольга', 'Ольга453@mail.ru', '84950000452', 0, 0);
INSERT INTO public.clients VALUES ('CL45400000454', 'Милана', 'Милана454@mail.ru', '84950000453', 0, 0);
INSERT INTO public.clients VALUES ('CL45500000455', 'Александра', 'Александра455@mail.ru', '84950000454', 0, 0);
INSERT INTO public.clients VALUES ('CL45600000456', 'Михаил', 'Михаил456@mail.ru', '84950000455', 0, 0);
INSERT INTO public.clients VALUES ('CL45700000457', 'Ринат', 'Ринат457@mail.ru', '84950000456', 0, 0);
INSERT INTO public.clients VALUES ('CL45800000458', 'Даниил', 'Даниил458@mail.ru', '84950000457', 0, 0);
INSERT INTO public.clients VALUES ('CL45900000459', 'Милана', 'Милана459@mail.ru', '84950000458', 0, 0);
INSERT INTO public.clients VALUES ('CL46000000460', 'Александра', 'Александра460@mail.ru', '84950000459', 0, 0);
INSERT INTO public.clients VALUES ('CL46100000461', 'Петр', 'Петр461@mail.ru', '84950000460', 0, 0);
INSERT INTO public.clients VALUES ('CL46200000462', 'Ринат', 'Ринат462@mail.ru', '84950000461', 0, 0);
INSERT INTO public.clients VALUES ('CL46300000463', 'Евгений', 'Евгений463@mail.ru', '84950000462', 0, 0);
INSERT INTO public.clients VALUES ('CL46400000464', 'Ева', 'Ева464@mail.ru', '84950000463', 0, 0);
INSERT INTO public.clients VALUES ('CL46500000465', 'Ева', 'Ева465@mail.ru', '84950000464', 0, 0);
INSERT INTO public.clients VALUES ('CL46600000466', 'Виктория', 'Виктория466@mail.ru', '84950000465', 0, 0);
INSERT INTO public.clients VALUES ('CL46700000467', 'Ева', 'Ева467@mail.ru', '84950000466', 0, 0);
INSERT INTO public.clients VALUES ('CL46800000468', 'Лев', 'Лев468@mail.ru', '84950000467', 0, 0);
INSERT INTO public.clients VALUES ('CL46900000469', 'Светлана', 'Светлана469@mail.ru', '84950000468', 0, 0);
INSERT INTO public.clients VALUES ('CL47000000470', 'Ринат', 'Ринат470@mail.ru', '84950000469', 0, 0);
INSERT INTO public.clients VALUES ('CL47100000471', 'Александра', 'Александра471@mail.ru', '84950000470', 0, 0);
INSERT INTO public.clients VALUES ('CL47200000472', 'Милана', 'Милана472@mail.ru', '84950000471', 0, 0);
INSERT INTO public.clients VALUES ('CL47300000473', 'София', 'София473@mail.ru', '84950000472', 0, 0);
INSERT INTO public.clients VALUES ('CL47400000474', 'Елена', 'Елена474@mail.ru', '84950000473', 0, 0);
INSERT INTO public.clients VALUES ('CL47500000475', 'Игорь', 'Игорь475@mail.ru', '84950000474', 0, 0);
INSERT INTO public.clients VALUES ('CL47600000476', 'Григорий', 'Григорий476@mail.ru', '84950000475', 0, 0);
INSERT INTO public.clients VALUES ('CL47700000477', 'Александра', 'Александра477@mail.ru', '84950000476', 0, 0);
INSERT INTO public.clients VALUES ('CL47800000478', 'Арсений', 'Арсений478@mail.ru', '84950000477', 0, 0);
INSERT INTO public.clients VALUES ('CL47900000479', 'Арсений', 'Арсений479@mail.ru', '84950000478', 0, 0);
INSERT INTO public.clients VALUES ('CL48000000480', 'Максим', 'Максим480@mail.ru', '84950000479', 0, 0);
INSERT INTO public.clients VALUES ('CL48100000481', 'Ольга', 'Ольга481@mail.ru', '84950000480', 0, 0);
INSERT INTO public.clients VALUES ('CL48200000482', 'Екатерина', 'Екатерина482@mail.ru', '84950000481', 0, 0);
INSERT INTO public.clients VALUES ('CL48300000483', 'Дмитрий', 'Дмитрий483@mail.ru', '84950000482', 0, 0);
INSERT INTO public.clients VALUES ('CL48400000484', 'Максим', 'Максим484@mail.ru', '84950000483', 0, 0);
INSERT INTO public.clients VALUES ('CL48500000485', 'Елизавета', 'Елизавета485@mail.ru', '84950000484', 0, 0);
INSERT INTO public.clients VALUES ('CL48600000486', 'Лев', 'Лев486@mail.ru', '84950000485', 0, 0);
INSERT INTO public.clients VALUES ('CL48700000487', 'Роман', 'Роман487@mail.ru', '84950000486', 0, 0);
INSERT INTO public.clients VALUES ('CL48800000488', 'Арсений', 'Арсений488@mail.ru', '84950000487', 0, 0);
INSERT INTO public.clients VALUES ('CL48900000489', 'Наталья', 'Наталья489@mail.ru', '84950000488', 0, 0);
INSERT INTO public.clients VALUES ('CL49000000490', 'Игорь', 'Игорь490@mail.ru', '84950000489', 0, 0);
INSERT INTO public.clients VALUES ('CL49100000491', 'Ирина', 'Ирина491@mail.ru', '84950000490', 0, 0);
INSERT INTO public.clients VALUES ('CL49200000492', 'Роман', 'Роман492@mail.ru', '84950000491', 0, 0);
INSERT INTO public.clients VALUES ('CL49300000493', 'Игорь', 'Игорь493@mail.ru', '84950000492', 0, 0);
INSERT INTO public.clients VALUES ('CL49400000494', 'Наталья', 'Наталья494@mail.ru', '84950000493', 0, 0);
INSERT INTO public.clients VALUES ('CL49500000495', 'Александр', 'Александр495@mail.ru', '84950000494', 0, 0);
INSERT INTO public.clients VALUES ('CL49600000496', 'Евгений', 'Евгений496@mail.ru', '84950000495', 0, 0);
INSERT INTO public.clients VALUES ('CL49700000497', 'Ринат', 'Ринат497@mail.ru', '84950000496', 0, 0);
INSERT INTO public.clients VALUES ('CL49800000498', 'Наталья', 'Наталья498@mail.ru', '84950000497', 0, 0);
INSERT INTO public.clients VALUES ('CL49900000499', 'Арсений', 'Арсений499@mail.ru', '84950000498', 0, 0);
INSERT INTO public.clients VALUES ('CL50000000500', 'Наталья', 'Наталья500@mail.ru', '84950000499', 0, 0);
INSERT INTO public.clients VALUES ('CL50100000501', 'Игорь', 'Игорь501@mail.ru', '84950000500', 0, 0);
INSERT INTO public.clients VALUES ('CL50200000502', 'Александр', 'Александр502@mail.ru', '84950000501', 0, 0);
INSERT INTO public.clients VALUES ('CL50300000503', 'Екатерина', 'Екатерина503@mail.ru', '84950000502', 0, 0);
INSERT INTO public.clients VALUES ('CL50400000504', 'Марьям', 'Марьям504@mail.ru', '84950000503', 0, 0);
INSERT INTO public.clients VALUES ('CL50500000505', 'Даниил', 'Даниил505@mail.ru', '84950000504', 0, 0);
INSERT INTO public.clients VALUES ('CL50600000506', 'Григорий', 'Григорий506@mail.ru', '84950000505', 0, 0);
INSERT INTO public.clients VALUES ('CL50700000507', 'Дмитрий', 'Дмитрий507@mail.ru', '84950000506', 0, 0);
INSERT INTO public.clients VALUES ('CL50800000508', 'Татьяна', 'Татьяна508@mail.ru', '84950000507', 0, 0);
INSERT INTO public.clients VALUES ('CL50900000509', 'Роман', 'Роман509@mail.ru', '84950000508', 0, 0);
INSERT INTO public.clients VALUES ('CL51000000510', 'Федор', 'Федор510@mail.ru', '84950000509', 0, 0);
INSERT INTO public.clients VALUES ('CL51100000511', 'Григорий', 'Григорий511@mail.ru', '84950000510', 0, 0);
INSERT INTO public.clients VALUES ('CL51200000512', 'Любовь', 'Любовь512@mail.ru', '84950000511', 0, 0);
INSERT INTO public.clients VALUES ('CL51300000513', 'Любовь', 'Любовь513@mail.ru', '84950000512', 0, 0);
INSERT INTO public.clients VALUES ('CL51400000514', 'Татьяна', 'Татьяна514@mail.ru', '84950000513', 0, 0);
INSERT INTO public.clients VALUES ('CL51500000515', 'Юлия', 'Юлия515@mail.ru', '84950000514', 0, 0);
INSERT INTO public.clients VALUES ('CL51600000516', 'Ева', 'Ева516@mail.ru', '84950000515', 0, 0);
INSERT INTO public.clients VALUES ('CL51700000517', 'Никита', 'Никита517@mail.ru', '84950000516', 0, 0);
INSERT INTO public.clients VALUES ('CL51800000518', 'Мария', 'Мария518@mail.ru', '84950000517', 0, 0);
INSERT INTO public.clients VALUES ('CL51900000519', 'Максим', 'Максим519@mail.ru', '84950000518', 0, 0);
INSERT INTO public.clients VALUES ('CL52000000520', 'Максим', 'Максим520@mail.ru', '84950000519', 0, 0);
INSERT INTO public.clients VALUES ('CL52100000521', 'Светлана', 'Светлана521@mail.ru', '84950000520', 0, 0);
INSERT INTO public.clients VALUES ('CL52200000522', 'Дария', 'Дария522@mail.ru', '84950000521', 0, 0);
INSERT INTO public.clients VALUES ('CL52300000523', 'Наталья', 'Наталья523@mail.ru', '84950000522', 0, 0);
INSERT INTO public.clients VALUES ('CL52400000524', 'Анна', 'Анна524@mail.ru', '84950000523', 0, 0);
INSERT INTO public.clients VALUES ('CL52500000525', 'Виктория', 'Виктория525@mail.ru', '84950000524', 0, 0);
INSERT INTO public.clients VALUES ('CL52600000526', 'Денис', 'Денис526@mail.ru', '84950000525', 0, 0);
INSERT INTO public.clients VALUES ('CL52700000527', 'Наталья', 'Наталья527@mail.ru', '84950000526', 0, 0);
INSERT INTO public.clients VALUES ('CL52800000528', 'Роман', 'Роман528@mail.ru', '84950000527', 0, 0);
INSERT INTO public.clients VALUES ('CL52900000529', 'Михаил', 'Михаил529@mail.ru', '84950000528', 0, 0);
INSERT INTO public.clients VALUES ('CL53000000530', 'Роман', 'Роман530@mail.ru', '84950000529', 0, 0);
INSERT INTO public.clients VALUES ('CL53100000531', 'Ольга', 'Ольга531@mail.ru', '84950000530', 0, 0);
INSERT INTO public.clients VALUES ('CL53200000532', 'Татьяна', 'Татьяна532@mail.ru', '84950000531', 0, 0);
INSERT INTO public.clients VALUES ('CL53300000533', 'Алексей', 'Алексей533@mail.ru', '84950000532', 0, 0);
INSERT INTO public.clients VALUES ('CL53400000534', 'Анна', 'Анна534@mail.ru', '84950000533', 0, 0);
INSERT INTO public.clients VALUES ('CL53500000535', 'Игорь', 'Игорь535@mail.ru', '84950000534', 0, 0);
INSERT INTO public.clients VALUES ('CL53600000536', 'Сергей', 'Сергей536@mail.ru', '84950000535', 0, 0);
INSERT INTO public.clients VALUES ('CL53700000537', 'Роман', 'Роман537@mail.ru', '84950000536', 0, 0);
INSERT INTO public.clients VALUES ('CL53800000538', 'Андрей', 'Андрей538@mail.ru', '84950000537', 0, 0);
INSERT INTO public.clients VALUES ('CL53900000539', 'Марина', 'Марина539@mail.ru', '84950000538', 0, 0);
INSERT INTO public.clients VALUES ('CL54000000540', 'Александра', 'Александра540@mail.ru', '84950000539', 0, 0);
INSERT INTO public.clients VALUES ('CL54100000541', 'Павел', 'Павел541@mail.ru', '84950000540', 0, 0);
INSERT INTO public.clients VALUES ('CL54200000542', 'Виктория', 'Виктория542@mail.ru', '84950000541', 0, 0);
INSERT INTO public.clients VALUES ('CL54300000543', 'Виктор', 'Виктор543@mail.ru', '84950000542', 0, 0);
INSERT INTO public.clients VALUES ('CL54400000544', 'Юлия', 'Юлия544@mail.ru', '84950000543', 0, 0);
INSERT INTO public.clients VALUES ('CL54500000545', 'Михаил', 'Михаил545@mail.ru', '84950000544', 0, 0);
INSERT INTO public.clients VALUES ('CL54600000546', 'Федор', 'Федор546@mail.ru', '84950000545', 0, 0);
INSERT INTO public.clients VALUES ('CL54700000547', 'Любовь', 'Любовь547@mail.ru', '84950000546', 0, 0);
INSERT INTO public.clients VALUES ('CL54800000548', 'Роман', 'Роман548@mail.ru', '84950000547', 0, 0);
INSERT INTO public.clients VALUES ('CL54900000549', 'Максим', 'Максим549@mail.ru', '84950000548', 0, 0);
INSERT INTO public.clients VALUES ('CL55000000550', 'Артем', 'Артем550@mail.ru', '84950000549', 0, 0);
INSERT INTO public.clients VALUES ('CL55100000551', 'Мария', 'Мария551@mail.ru', '84950000550', 0, 0);
INSERT INTO public.clients VALUES ('CL55200000552', 'Егор', 'Егор552@mail.ru', '84950000551', 0, 0);
INSERT INTO public.clients VALUES ('CL55300000553', 'Денис', 'Денис553@mail.ru', '84950000552', 0, 0);
INSERT INTO public.clients VALUES ('CL55400000554', 'Дария', 'Дария554@mail.ru', '84950000553', 0, 0);
INSERT INTO public.clients VALUES ('CL55500000555', 'Арсений', 'Арсений555@mail.ru', '84950000554', 0, 0);
INSERT INTO public.clients VALUES ('CL55600000556', 'Владимир', 'Владимир556@mail.ru', '84950000555', 0, 0);
INSERT INTO public.clients VALUES ('CL55700000557', 'Елизавета', 'Елизавета557@mail.ru', '84950000556', 0, 0);
INSERT INTO public.clients VALUES ('CL55800000558', 'Павел', 'Павел558@mail.ru', '84950000557', 0, 0);
INSERT INTO public.clients VALUES ('CL55900000559', 'Григорий', 'Григорий559@mail.ru', '84950000558', 0, 0);
INSERT INTO public.clients VALUES ('CL56000000560', 'Анна', 'Анна560@mail.ru', '84950000559', 0, 0);
INSERT INTO public.clients VALUES ('CL56100000561', 'Федор', 'Федор561@mail.ru', '84950000560', 0, 0);
INSERT INTO public.clients VALUES ('CL56200000562', 'Дмитрий', 'Дмитрий562@mail.ru', '84950000561', 0, 0);
INSERT INTO public.clients VALUES ('CL56300000563', 'Анна', 'Анна563@mail.ru', '84950000562', 0, 0);
INSERT INTO public.clients VALUES ('CL56400000564', 'Екатерина', 'Екатерина564@mail.ru', '84950000563', 0, 0);
INSERT INTO public.clients VALUES ('CL56500000565', 'Артем', 'Артем565@mail.ru', '84950000564', 0, 0);
INSERT INTO public.clients VALUES ('CL56600000566', 'Светлана', 'Светлана566@mail.ru', '84950000565', 0, 0);
INSERT INTO public.clients VALUES ('CL56700000567', 'Виктория', 'Виктория567@mail.ru', '84950000566', 0, 0);
INSERT INTO public.clients VALUES ('CL56800000568', 'Андрей', 'Андрей568@mail.ru', '84950000567', 0, 0);
INSERT INTO public.clients VALUES ('CL56900000569', 'Амина', 'Амина569@mail.ru', '84950000568', 0, 0);
INSERT INTO public.clients VALUES ('CL57000000570', 'Федор', 'Федор570@mail.ru', '84950000569', 0, 0);
INSERT INTO public.clients VALUES ('CL57100000571', 'Сергей', 'Сергей571@mail.ru', '84950000570', 0, 0);
INSERT INTO public.clients VALUES ('CL57200000572', 'Арсений', 'Арсений572@mail.ru', '84950000571', 0, 0);
INSERT INTO public.clients VALUES ('CL57300000573', 'Максим', 'Максим573@mail.ru', '84950000572', 0, 0);
INSERT INTO public.clients VALUES ('CL57400000574', 'София', 'София574@mail.ru', '84950000573', 0, 0);
INSERT INTO public.clients VALUES ('CL57500000575', 'Мария', 'Мария575@mail.ru', '84950000574', 0, 0);
INSERT INTO public.clients VALUES ('CL57600000576', 'Ирина', 'Ирина576@mail.ru', '84950000575', 0, 0);
INSERT INTO public.clients VALUES ('CL57700000577', 'Николай', 'Николай577@mail.ru', '84950000576', 0, 0);
INSERT INTO public.clients VALUES ('CL57800000578', 'Артем', 'Артем578@mail.ru', '84950000577', 0, 0);
INSERT INTO public.clients VALUES ('CL57900000579', 'Екатерина', 'Екатерина579@mail.ru', '84950000578', 0, 0);
INSERT INTO public.clients VALUES ('CL58000000580', 'Константин', 'Константин580@mail.ru', '84950000579', 0, 0);
INSERT INTO public.clients VALUES ('CL58100000581', 'Ольга', 'Ольга581@mail.ru', '84950000580', 0, 0);
INSERT INTO public.clients VALUES ('CL58200000582', 'Денис', 'Денис582@mail.ru', '84950000581', 0, 0);
INSERT INTO public.clients VALUES ('CL58300000583', 'Ольга', 'Ольга583@mail.ru', '84950000582', 0, 0);
INSERT INTO public.clients VALUES ('CL58400000584', 'Николай', 'Николай584@mail.ru', '84950000583', 0, 0);
INSERT INTO public.clients VALUES ('CL58500000585', 'Даниил', 'Даниил585@mail.ru', '84950000584', 0, 0);
INSERT INTO public.clients VALUES ('CL58600000586', 'Ева', 'Ева586@mail.ru', '84950000585', 0, 0);
INSERT INTO public.clients VALUES ('CL58700000587', 'Егор', 'Егор587@mail.ru', '84950000586', 0, 0);
INSERT INTO public.clients VALUES ('CL58800000588', 'Марина', 'Марина588@mail.ru', '84950000587', 0, 0);
INSERT INTO public.clients VALUES ('CL58900000589', 'Любовь', 'Любовь589@mail.ru', '84950000588', 0, 0);
INSERT INTO public.clients VALUES ('CL59000000590', 'Юлия', 'Юлия590@mail.ru', '84950000589', 0, 0);
INSERT INTO public.clients VALUES ('CL59100000591', 'Егор', 'Егор591@mail.ru', '84950000590', 0, 0);
INSERT INTO public.clients VALUES ('CL59200000592', 'Никита', 'Никита592@mail.ru', '84950000591', 0, 0);
INSERT INTO public.clients VALUES ('CL59300000593', 'Игорь', 'Игорь593@mail.ru', '84950000592', 0, 0);
INSERT INTO public.clients VALUES ('CL59400000594', 'Николай', 'Николай594@mail.ru', '84950000593', 0, 0);
INSERT INTO public.clients VALUES ('CL59500000595', 'Федор', 'Федор595@mail.ru', '84950000594', 0, 0);
INSERT INTO public.clients VALUES ('CL59600000596', 'Юлия', 'Юлия596@mail.ru', '84950000595', 0, 0);
INSERT INTO public.clients VALUES ('CL59700000597', 'Дария', 'Дария597@mail.ru', '84950000596', 0, 0);
INSERT INTO public.clients VALUES ('CL59800000598', 'Амина', 'Амина598@mail.ru', '84950000597', 0, 0);
INSERT INTO public.clients VALUES ('CL59900000599', 'Виктория', 'Виктория599@mail.ru', '84950000598', 0, 0);
INSERT INTO public.clients VALUES ('CL1000001', 'Милана', 'Милана1@mail.ru', '84950000000', 1850, 185.0);
INSERT INTO public.clients VALUES ('CL2000002', 'Любовь', 'Любовь2@mail.ru', '84950000001', 750, 75.0);
INSERT INTO public.clients VALUES ('CL60000000600', 'Андрей', 'Андрей600@mail.ru', '84950000599', 8000, 2167.0);


--
-- TOC entry 3467 (class 0 OID 18590)
-- Dependencies: 219
-- Data for Name: clientsrestaurants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL1000001');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL2000002');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL3000003');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL4000004');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL5000005');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL6000006');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL7000007');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL8000008');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL9000009');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL100000010');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL110000011');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL120000012');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL130000013');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL140000014');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL150000015');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL160000016');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL170000017');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL180000018');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL190000019');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL200000020');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL210000021');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL220000022');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL230000023');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL240000024');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL250000025');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL260000026');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL270000027');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL280000028');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL290000029');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL300000030');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL310000031');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL320000032');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL330000033');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL340000034');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL350000035');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL360000036');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL370000037');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL380000038');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL390000039');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL400000040');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL410000041');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL420000042');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL430000043');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL440000044');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL450000045');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL460000046');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL470000047');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL480000048');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL490000049');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL500000050');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL510000051');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL520000052');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL530000053');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL540000054');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL550000055');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL560000056');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL570000057');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL580000058');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL590000059');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL600000060');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL610000061');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL620000062');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL630000063');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL640000064');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL650000065');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL660000066');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL670000067');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL680000068');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL690000069');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL700000070');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL710000071');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL720000072');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL730000073');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL740000074');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL750000075');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL760000076');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL770000077');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL780000078');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL790000079');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL800000080');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL810000081');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL820000082');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL830000083');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL840000084');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL850000085');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL860000086');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL870000087');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL880000088');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL890000089');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL900000090');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL910000091');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL920000092');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL930000093');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL940000094');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL950000095');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL960000096');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL970000097');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL980000098');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL990000099');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL10000000100');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL10100000101');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL10200000102');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL10300000103');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL10400000104');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL10500000105');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL10600000106');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL10700000107');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL10800000108');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL10900000109');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL11000000110');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL11100000111');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL11200000112');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL11300000113');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL11400000114');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL11500000115');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL11600000116');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL11700000117');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL11800000118');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL11900000119');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL12000000120');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL12100000121');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL12200000122');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL12300000123');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL12400000124');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL12500000125');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL12600000126');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL12700000127');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL12800000128');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL12900000129');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL13000000130');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL13100000131');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL13200000132');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL13300000133');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL13400000134');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL13500000135');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL13600000136');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL13700000137');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL13800000138');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL13900000139');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL14000000140');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL14100000141');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL14200000142');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL14300000143');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL14400000144');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL14500000145');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL14600000146');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL14700000147');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL14800000148');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL14900000149');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL15000000150');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL15100000151');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL15200000152');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL15300000153');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL15400000154');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL15500000155');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL15600000156');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL15700000157');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL15800000158');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL15900000159');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL16000000160');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL16100000161');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL16200000162');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL16300000163');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL16400000164');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL16500000165');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL16600000166');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL16700000167');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL16800000168');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL16900000169');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL17000000170');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL17100000171');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL17200000172');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL17300000173');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL17400000174');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL17500000175');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL17600000176');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL17700000177');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL17800000178');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL17900000179');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL18000000180');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL18100000181');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL18200000182');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL18300000183');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL18400000184');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL18500000185');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL18600000186');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL18700000187');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL18800000188');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL18900000189');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL19000000190');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL19100000191');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL19200000192');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL19300000193');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL19400000194');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL19500000195');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL19600000196');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL19700000197');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL19800000198');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL19900000199');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL20000000200');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL20100000201');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL20200000202');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL20300000203');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL20400000204');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL20500000205');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL20600000206');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL20700000207');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL20800000208');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL20900000209');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL21000000210');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL21100000211');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL21200000212');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL21300000213');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL21400000214');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL21500000215');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL21600000216');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL21700000217');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL21800000218');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL21900000219');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL22000000220');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL22100000221');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL22200000222');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL22300000223');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL22400000224');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL22500000225');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL22600000226');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL22700000227');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL22800000228');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL22900000229');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL23000000230');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL23100000231');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL23200000232');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL23300000233');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL23400000234');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL23500000235');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL23600000236');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL23700000237');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL23800000238');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL23900000239');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL24000000240');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL24100000241');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL24200000242');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL24300000243');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL24400000244');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL24500000245');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL24600000246');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL24700000247');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL24800000248');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL24900000249');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL25000000250');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL25100000251');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL25200000252');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL25300000253');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL25400000254');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL25500000255');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL25600000256');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL25700000257');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL25800000258');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL25900000259');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL26000000260');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL26100000261');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL26200000262');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL26300000263');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL26400000264');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL26500000265');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL26600000266');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL26700000267');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL26800000268');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL26900000269');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL27000000270');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL27100000271');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL27200000272');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL27300000273');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL27400000274');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL27500000275');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL27600000276');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL27700000277');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL27800000278');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL27900000279');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL28000000280');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL28100000281');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL28200000282');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL28300000283');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL28400000284');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL28500000285');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL28600000286');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL28700000287');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL28800000288');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL28900000289');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL29000000290');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL29100000291');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL29200000292');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL29300000293');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL29400000294');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL29500000295');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL29600000296');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL29700000297');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL29800000298');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL29900000299');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL30000000300');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL30100000301');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL30200000302');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL30300000303');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL30400000304');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL30500000305');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL30600000306');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL30700000307');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL30800000308');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL30900000309');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL31000000310');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL31100000311');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL31200000312');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL31300000313');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL31400000314');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL31500000315');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL31600000316');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL31700000317');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL31800000318');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL31900000319');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL32000000320');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL32100000321');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL32200000322');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL32300000323');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL32400000324');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL32500000325');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL32600000326');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL32700000327');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL32800000328');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL32900000329');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL33000000330');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL33100000331');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL33200000332');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL33300000333');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL33400000334');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL33500000335');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL33600000336');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL33700000337');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL33800000338');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL33900000339');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL34000000340');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL34100000341');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL34200000342');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL34300000343');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL34400000344');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL34500000345');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL34600000346');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL34700000347');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL34800000348');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL34900000349');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL35000000350');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL35100000351');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL35200000352');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL35300000353');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL35400000354');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL35500000355');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL35600000356');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL35700000357');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL35800000358');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL35900000359');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL36000000360');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL36100000361');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL36200000362');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL36300000363');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL36400000364');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL36500000365');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL36600000366');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL36700000367');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL36800000368');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL36900000369');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL37000000370');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL37100000371');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL37200000372');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL37300000373');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL37400000374');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL37500000375');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL37600000376');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL37700000377');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL37800000378');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL37900000379');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL38000000380');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL38100000381');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL38200000382');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL38300000383');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL38400000384');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL38500000385');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL38600000386');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL38700000387');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL38800000388');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL38900000389');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL39000000390');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL39100000391');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL39200000392');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL39300000393');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL39400000394');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL39500000395');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL39600000396');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL39700000397');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL39800000398');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL39900000399');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL40000000400');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL40100000401');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL40200000402');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL40300000403');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL40400000404');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL40500000405');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL40600000406');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL40700000407');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL40800000408');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL40900000409');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL41000000410');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL41100000411');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL41200000412');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL41300000413');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL41400000414');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL41500000415');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL41600000416');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL41700000417');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL41800000418');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL41900000419');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL42000000420');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL42100000421');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL42200000422');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL42300000423');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL42400000424');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL42500000425');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL42600000426');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL42700000427');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL42800000428');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL42900000429');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL43000000430');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL43100000431');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL43200000432');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL43300000433');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL43400000434');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL43500000435');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL43600000436');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL43700000437');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL43800000438');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL43900000439');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL44000000440');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL44100000441');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL44200000442');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL44300000443');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL44400000444');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL44500000445');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL44600000446');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL44700000447');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL44800000448');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL44900000449');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL45000000450');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL45100000451');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL45200000452');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL45300000453');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL45400000454');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL45500000455');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL45600000456');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL45700000457');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL45800000458');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL45900000459');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL46000000460');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL46100000461');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL46200000462');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL46300000463');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL46400000464');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL46500000465');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL46600000466');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL46700000467');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL46800000468');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL46900000469');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL47000000470');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL47100000471');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL47200000472');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL47300000473');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL47400000474');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL47500000475');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL47600000476');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL47700000477');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL47800000478');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL47900000479');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL48000000480');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL48100000481');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL48200000482');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL48300000483');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL48400000484');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL48500000485');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL48600000486');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL48700000487');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL48800000488');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL48900000489');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL49000000490');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL49100000491');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL49200000492');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL49300000493');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL49400000494');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL49500000495');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL49600000496');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL49700000497');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL49800000498');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL49900000499');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL50000000500');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL50100000501');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL50200000502');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL50300000503');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL50400000504');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL50500000505');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL50600000506');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL50700000507');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL50800000508');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL50900000509');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL51000000510');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL51100000511');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL51200000512');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL51300000513');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL51400000514');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL51500000515');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL51600000516');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL51700000517');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL51800000518');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL51900000519');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL52000000520');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL52100000521');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL52200000522');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL52300000523');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL52400000524');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL52500000525');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL52600000526');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL52700000527');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL52800000528');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL52900000529');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL53000000530');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL53100000531');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL53200000532');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL53300000533');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL53400000534');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL53500000535');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL53600000536');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL53700000537');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL53800000538');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL53900000539');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL54000000540');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL54100000541');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL54200000542');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL54300000543');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL54400000544');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL54500000545');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL54600000546');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL54700000547');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL54800000548');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL54900000549');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL55000000550');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL55100000551');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL55200000552');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL55300000553');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL55400000554');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL55500000555');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL55600000556');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL55700000557');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL55800000558');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL55900000559');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL56000000560');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL56100000561');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL56200000562');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL56300000563');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL56400000564');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL56500000565');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL56600000566');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL56700000567');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL56800000568');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL56900000569');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL57000000570');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL57100000571');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL57200000572');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL57300000573');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL57400000574');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL57500000575');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL57600000576');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL57700000577');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL57800000578');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL57900000579');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL58000000580');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL58100000581');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL58200000582');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL58300000583');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL58400000584');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL58500000585');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL58600000586');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL58700000587');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL58800000588');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL58900000589');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL59000000590');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL59100000591');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL59200000592');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL59300000593');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL59400000594');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL59500000595');
INSERT INTO public.clientsrestaurants VALUES ('Аркобалено', 'CL59600000596');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL59700000597');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL59800000598');
INSERT INTO public.clientsrestaurants VALUES ('Виктор', 'CL59900000599');
INSERT INTO public.clientsrestaurants VALUES ('Клод Моне', 'CL60000000600');


--
-- TOC entry 3462 (class 0 OID 18464)
-- Dependencies: 214
-- Data for Name: dishes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dishes VALUES ('Капрезе', 200, 'томаты, моцарелла, микс салатов, соус песто, бальзамик', 300, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Том-ям', 350, 'креветки, кальмары, рис, вешенки, кинза, том-ям, лайм', 400, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Маргарита', 350, 'тесто, моцарелла, томатный соус, орегано, зира, тмин', 450, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Дорадо', 350, 'дорадо, лайм, микс салатов, морская соль', 300, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Стейка Рибай', 400, 'стейк зернового откорма, из части спинного отруба подлопаточной части туши', 500, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Филе Миньон', 250, 'стейк из вырезки с отсутствием жира', 450, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Бургер с креветкой', 210, 'креветки, помидоры, лук, соус 1000 островов, булочка, салат романо айсберг', 430, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Медовик', 190, 'медовые коржи, сметанный крем, шоколад, мед', 350, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Страчателла и томаты', 240, 'томаты, страчателла, бальзамик, соус песто', 250, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо1', 197, 'кус кус, соус медово-горчичный, пастрами, перец сладкий, лапша, сок лимона, картофель, грецкий орех, сыр чеддер, картофель', 588, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо2', 201, 'лук, имбирь, вяленые томаты', 390, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо3', 390, 'кус кус, соус чили, вырезка свиная, лапша, морковь, перец болгарский, шампиньоны', 215, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо4', 107, 'соус медово-горчичный, имбирь, белые грибы, брынза, перец сладкий, перец болгарский, морковь', 524, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо5', 233, 'пшеничное тесто, куриная грудка, паста, перец сладкий, ростбиф, соус деми глаз, запеченая тыква, перец сладкий, пастрами', 579, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо6', 384, 'куриная грудка, шампиньоны, салат айсберг, пастрами, микс салатов, морковь, сок лимона, сок лимона, капуста, креветки', 387, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо7', 358, 'шампиньоны, шампиньоны, соус БлюЧиз, имбирь, куриная грудка, перец сладкий, картофель, кальмары, салат романо', 291, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо8', 158, 'салат романо, перец сладкий, креветки, сливки', 302, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо9', 328, 'шампиньоны, сок лимона, грецкий орех, батат, батат, сыр чеддер', 350, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо10', 338, 'картофель, огурцы, перец болгарский, брынза, паста, пармезан, батат', 595, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо11', 377, 'морковь, перец сладкий, салат романо', 577, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо12', 255, 'морковь, брынза, ростбиф, лапша', 287, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо13', 231, 'лук, вяленые томаты, белые грибы, булочки', 276, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо14', 278, 'огурцы, пшеничное тесто, капуста, брынза, грецкий орех, соус БлюЧиз, запеченая тыква, грецкий орех, каперсы', 390, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо15', 192, 'запеченая тыква, салат айсберг, паста, булочки', 575, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо16', 140, 'пшеничное тесто, белые грибы, морковь, кимчи, вяленые томаты, кимчи, сок лимона, ростбиф, пармезан', 439, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо17', 345, 'соус медово-горчичный, ростбиф, морковь, лук, салат айсберг, микс салатов, паста, огурцы, сыр чеддер', 562, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо18', 260, 'картофель, запеченая тыква, соус БлюЧиз, шампиньоны', 285, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо19', 251, 'шампиньоны, соус БлюЧиз, сок лимона, соус деми глаз, пастрами, перец болгарский, сок лимона, соус медово-горчичный', 301, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо20', 115, 'паста, пастрами, сок лимона, куриная грудка, сок лимона, имбирь, соус деми глаз, салат романо, шампиньоны', 560, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо21', 400, 'булочки, соус чили, пармезан, перец сладкий', 208, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо22', 122, 'кальмары, пшеничное тесто, салат романо, батат, паста, морковь, салат романо, соус БлюЧиз, кальмары, каперсы', 405, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо23', 262, 'капуста, имбирь, кальмары, соус БлюЧиз, капуста, булочки', 291, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо24', 260, 'кимчи, соус медово-горчичный, соус чили, салат романо, ростбиф, картофель, соус медово-горчичный, пшеничное тесто, капуста, морковь', 581, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо25', 323, 'кус кус, сливки, пастрами, лук', 294, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо26', 180, 'белые грибы, картофель, перец болгарский, куриная грудка, микс салатов, огурцы, креветки, каперсы, паста', 542, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо27', 341, 'паста, каперсы, брынза, лапша, соус БлюЧиз, перец болгарский, перец болгарский, грецкий орех, капуста, соус чили', 263, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо28', 380, 'микс салатов, кус кус, кимчи', 444, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо29', 271, 'куриная грудка, белые грибы, морковь', 337, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо30', 333, 'пармезан, пастрами, сыр чеддер, батат, лапша, каперсы, пшеничное тесто, запеченая тыква, соус БлюЧиз, соус медово-горчичный', 492, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо31', 230, 'соус чили, капуста, лапша, соус чили, сок лимона, картофель, микс салатов, кус кус, сливки', 439, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо32', 307, 'пшеничное тесто, запеченая тыква, микс салатов, каперсы, соус медово-горчичный, соус деми глаз', 240, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо33', 400, 'перец сладкий, соус медово-горчичный, перец сладкий, соус медово-горчичный, имбирь, капуста, салат айсберг, лапша', 455, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо34', 349, 'сыр чеддер, кимчи, капуста, шампиньоны, ростбиф', 374, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо35', 336, 'батат, каперсы, запеченая тыква, салат романо, соус БлюЧиз, вяленые томаты, вырезка свиная', 237, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо36', 124, 'соус медово-горчичный, перец сладкий, сок лимона, батат, капуста, салат романо, батат, лук, морковь', 567, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо37', 217, 'соус деми глаз, кус кус, паста', 369, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо38', 338, 'грецкий орех, сок лимона, салат романо, булочки, кимчи, запеченая тыква, перец болгарский, соус чили, салат айсберг, перец болгарский', 217, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо39', 287, 'огурцы, запеченая тыква, каперсы, паста', 243, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо40', 103, 'микс салатов, пшеничное тесто, шампиньоны, кус кус, пастрами, кус кус, пастрами, сок лимона, сок лимона, салат айсберг', 597, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо41', 107, 'шампиньоны, кимчи, булочки', 481, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо42', 380, 'лук, салат айсберг, булочки, грецкий орех, соус деми глаз, капуста, куриная грудка, кальмары', 381, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо43', 387, 'соус чили, булочки, лук, огурцы, белые грибы, соус медово-горчичный', 230, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо44', 290, 'запеченая тыква, вяленые томаты, пшеничное тесто, салат романо, кальмары, белые грибы, капуста, соус БлюЧиз', 301, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо45', 341, 'вяленые томаты, булочки, вяленые томаты, пастрами, соус деми глаз, запеченая тыква, пармезан, батат', 454, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо46', 368, 'каперсы, булочки, белые грибы, булочки, соус деми глаз', 237, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо47', 231, 'булочки, сок лимона, кус кус', 466, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо48', 318, 'лапша, сок лимона, картофель, огурцы, перец сладкий, сок лимона, сыр чеддер, перец болгарский, картофель', 249, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо49', 373, 'сок лимона, салат романо, вяленые томаты, запеченая тыква, грецкий орех, огурцы, кус кус', 334, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо50', 322, 'огурцы, грецкий орех, морковь, пармезан, вяленые томаты, ростбиф, соус чили, паста, лук', 341, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо51', 349, 'имбирь, пармезан, кальмары, лук, каперсы, соус чили, ростбиф', 480, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо52', 115, 'соус чили, креветки, вырезка свиная, морковь, лук, пармезан, запеченая тыква, белые грибы, морковь', 374, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо53', 274, 'соус чили, перец сладкий, вырезка свиная, креветки, кимчи', 259, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо54', 163, 'микс салатов, соус чили, микс салатов, ростбиф, морковь, имбирь, сок лимона, микс салатов, лук, соус деми глаз', 279, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо55', 216, 'шампиньоны, сок лимона, пастрами, картофель, шампиньоны', 533, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо56', 138, 'брынза, кус кус, вырезка свиная, огурцы, запеченая тыква, шампиньоны, салат романо, вяленые томаты', 201, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо57', 142, 'соус медово-горчичный, каперсы, имбирь, перец сладкий, перец сладкий', 294, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо58', 122, 'вырезка свиная, пшеничное тесто, морковь', 202, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо59', 312, 'соус чили, картофель, куриная грудка, соус медово-горчичный, ростбиф, перец сладкий, соус медово-горчичный, сливки', 558, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо60', 390, 'салат айсберг, соус деми глаз, белые грибы, пшеничное тесто, пшеничное тесто', 210, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо61', 134, 'соус чили, соус БлюЧиз, огурцы, соус БлюЧиз', 587, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо62', 110, 'микс салатов, белые грибы, кус кус, ростбиф, батат', 477, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо63', 300, 'картофель, запеченая тыква, имбирь, морковь, соус медово-горчичный, шампиньоны, имбирь, соус медово-горчичный, соус медово-горчичный, брынза', 398, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо64', 174, 'каперсы, картофель, лапша, каперсы, шампиньоны, вырезка свиная, шампиньоны, батат, батат', 200, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо65', 166, 'кальмары, микс салатов, кус кус, кус кус, батат, куриная грудка, пастрами, вырезка свиная, лапша', 393, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо66', 349, 'салат айсберг, креветки, пшеничное тесто, куриная грудка, капуста, вырезка свиная', 540, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо67', 247, 'ростбиф, булочки, сок лимона, капуста, огурцы, салат романо, соус деми глаз, лапша, лук', 513, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо68', 323, 'соус медово-горчичный, капуста, вяленые томаты, куриная грудка, лук, капуста, соус деми глаз, грецкий орех, кус кус, куриная грудка', 560, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо69', 213, 'имбирь, огурцы, перец болгарский, лапша, пастрами, салат романо', 255, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо70', 361, 'соус деми глаз, кальмары, перец болгарский, перец сладкий, картофель, пшеничное тесто, соус чили, паста, картофель', 200, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо71', 201, 'огурцы, батат, микс салатов, брынза, перец сладкий, батат, микс салатов, запеченая тыква, белые грибы', 452, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо72', 212, 'перец болгарский, ростбиф, запеченая тыква, сок лимона, каперсы, кимчи, морковь, белые грибы', 561, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо73', 169, 'шампиньоны, сок лимона, сыр чеддер, куриная грудка', 523, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо74', 132, 'батат, соус деми глаз, капуста, соус БлюЧиз, ростбиф, ростбиф', 526, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо75', 266, 'булочки, куриная грудка, кальмары, брынза, пармезан, каперсы, имбирь, паста, сок лимона', 381, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо76', 198, 'соус БлюЧиз, соус БлюЧиз, кус кус, кимчи, сок лимона, батат, картофель', 464, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо77', 381, 'кус кус, лук, соус деми глаз', 296, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо78', 164, 'вырезка свиная, микс салатов, морковь, пшеничное тесто, креветки, шампиньоны, кус кус, батат, каперсы', 273, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо79', 378, 'запеченая тыква, перец болгарский, батат, кус кус, соус чили', 531, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо80', 279, 'паста, пастрами, сок лимона, креветки, перец болгарский, пастрами', 321, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо81', 336, 'каперсы, соус БлюЧиз, соус чили, салат айсберг', 301, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо82', 374, 'брынза, куриная грудка, капуста, салат айсберг, соус чили, кус кус, запеченая тыква, вырезка свиная', 242, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо83', 375, 'брынза, шампиньоны, салат романо, перец болгарский, паста, пшеничное тесто, вырезка свиная, булочки', 303, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо84', 221, 'соус деми глаз, соус чили, микс салатов, батат, вырезка свиная', 385, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо85', 294, 'брынза, брынза, салат айсберг', 313, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо86', 348, 'булочки, каперсы, кальмары, сок лимона, имбирь, шампиньоны, картофель, соус БлюЧиз', 557, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо87', 147, 'белые грибы, кус кус, морковь, пармезан', 332, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо88', 232, 'креветки, грецкий орех, соус БлюЧиз', 471, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо89', 247, 'куриная грудка, картофель, салат романо, морковь, соус деми глаз, булочки, сок лимона, булочки', 560, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо90', 143, 'кальмары, картофель, каперсы, сливки, огурцы', 404, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо91', 171, 'пастрами, брынза, перец болгарский, лапша, салат романо, соус чили', 404, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо92', 122, 'лапша, сок лимона, креветки, микс салатов, пастрами, соус чили, вяленые томаты, паста', 248, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо93', 233, 'огурцы, имбирь, вырезка свиная, капуста', 285, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо94', 116, 'огурцы, вяленые томаты, микс салатов', 291, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо95', 172, 'пшеничное тесто, каперсы, каперсы, лапша, кимчи, салат романо, имбирь, салат айсберг, ростбиф', 254, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо96', 239, 'батат, имбирь, кус кус, кус кус, соус БлюЧиз, сок лимона, каперсы, паста, имбирь, пшеничное тесто', 461, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо97', 348, 'морковь, лапша, картофель, грецкий орех, микс салатов, имбирь', 378, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо98', 371, 'салат айсберг, пшеничное тесто, булочки, ростбиф, лук, салат айсберг, соус медово-горчичный, пастрами', 398, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо99', 234, 'лук, вырезка свиная, лапша, брынза', 412, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо100', 103, 'грецкий орех, креветки, булочки', 493, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо101', 201, 'белые грибы, кус кус, булочки, паста, белые грибы, вырезка свиная, сливки, запеченая тыква', 371, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо102', 220, 'соус деми глаз, белые грибы, вырезка свиная, соус медово-горчичный', 437, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо103', 226, 'пастрами, запеченая тыква, кальмары, салат романо', 387, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо104', 322, 'лук, шампиньоны, пшеничное тесто, грецкий орех, пшеничное тесто', 554, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо105', 356, 'морковь, морковь, пастрами, запеченая тыква, креветки, белые грибы, куриная грудка, соус чили, салат романо', 351, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо106', 384, 'брынза, сок лимона, картофель, кальмары, пастрами, имбирь, грецкий орех, креветки, сливки, кус кус', 556, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо107', 347, 'креветки, пшеничное тесто, пшеничное тесто, ростбиф, батат, соус БлюЧиз', 483, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо108', 212, 'грецкий орех, соус БлюЧиз, пармезан, шампиньоны, сливки, имбирь, вяленые томаты, пшеничное тесто', 540, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо109', 331, 'ростбиф, огурцы, брынза, пастрами, пшеничное тесто, соус медово-горчичный', 556, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо110', 226, 'соус чили, куриная грудка, каперсы, салат айсберг, сок лимона', 274, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо111', 299, 'огурцы, перец болгарский, картофель, вырезка свиная', 216, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо112', 371, 'капуста, шампиньоны, грецкий орех, ростбиф', 377, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо113', 342, 'микс салатов, микс салатов, имбирь, салат айсберг, креветки, сливки, булочки, соус БлюЧиз', 330, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо114', 165, 'вяленые томаты, ростбиф, кимчи, каперсы', 498, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо115', 390, 'лук, каперсы, запеченая тыква, шампиньоны, белые грибы, капуста, салат айсберг', 259, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо116', 127, 'шампиньоны, вяленые томаты, салат айсберг, перец сладкий, салат айсберг, кимчи', 325, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо117', 246, 'имбирь, пшеничное тесто, имбирь, соус БлюЧиз, пшеничное тесто, микс салатов, морковь', 588, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо118', 236, 'каперсы, ростбиф, грецкий орех, перец сладкий, батат, морковь, паста, имбирь, лапша', 250, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо119', 181, 'брынза, лапша, пшеничное тесто, сливки, огурцы, кальмары, паста, капуста, перец сладкий', 210, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо120', 101, 'вяленые томаты, вяленые томаты, сок лимона, соус чили, кимчи, кальмары, соус чили, паста, пшеничное тесто', 426, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо121', 394, 'пармезан, вырезка свиная, микс салатов, кимчи, вяленые томаты, сок лимона, картофель', 281, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо122', 290, 'ростбиф, микс салатов, кус кус', 339, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо123', 145, 'соус БлюЧиз, пармезан, пастрами, грецкий орех, капуста, грецкий орех, запеченая тыква, грецкий орех, шампиньоны', 400, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо124', 252, 'соус БлюЧиз, кимчи, салат айсберг, сыр чеддер', 506, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо125', 348, 'брынза, капуста, креветки, креветки, пармезан, сливки, куриная грудка, кальмары, батат, вяленые томаты', 308, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо126', 186, 'батат, булочки, пшеничное тесто', 202, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо127', 128, 'сыр чеддер, перец сладкий, белые грибы, сыр чеддер, сыр чеддер, кальмары, кус кус, сок лимона, соус БлюЧиз', 547, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо128', 379, 'пшеничное тесто, соус деми глаз, капуста, шампиньоны', 474, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо129', 387, 'паста, ростбиф, капуста', 231, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо130', 152, 'батат, кус кус, креветки', 553, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо131', 300, 'имбирь, соус медово-горчичный, огурцы, брынза, шампиньоны', 375, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо132', 184, 'ростбиф, кимчи, белые грибы, лук, пшеничное тесто, брынза, перец сладкий, белые грибы, салат айсберг, имбирь', 587, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо133', 326, 'лапша, картофель, каперсы', 387, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо134', 210, 'капуста, брынза, лапша, салат айсберг, морковь, кус кус, морковь, шампиньоны', 283, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо135', 395, 'перец сладкий, соус медово-горчичный, запеченая тыква, батат, брынза, соус чили, пастрами, соус медово-горчичный', 257, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо136', 287, 'картофель, соус медово-горчичный, соус деми глаз, пастрами, ростбиф, соус чили', 348, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо137', 269, 'пшеничное тесто, салат айсберг, запеченая тыква', 382, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо138', 309, 'паста, микс салатов, креветки', 344, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо139', 235, 'имбирь, белые грибы, микс салатов, булочки, кимчи', 335, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо140', 374, 'батат, морковь, шампиньоны, креветки, лук', 583, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо141', 165, 'соус чили, сливки, вяленые томаты, булочки', 255, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо142', 342, 'имбирь, белые грибы, сок лимона, булочки', 561, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо143', 348, 'каперсы, пармезан, лук, имбирь', 428, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо144', 341, 'соус чили, вяленые томаты, сливки, брынза', 574, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо145', 351, 'брынза, пармезан, салат романо, пастрами, имбирь, перец болгарский, салат романо, соус чили', 295, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо146', 205, 'белые грибы, салат романо, лапша, запеченая тыква, перец сладкий, креветки, креветки, брынза, соус чили, шампиньоны', 393, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо147', 156, 'кальмары, креветки, соус чили, сливки, соус деми глаз, креветки, паста, каперсы', 395, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо148', 174, 'паста, шампиньоны, перец сладкий, соус медово-горчичный, кальмары, соус чили, перец болгарский, креветки, белые грибы, креветки', 357, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо149', 280, 'белые грибы, белые грибы, грецкий орех, соус БлюЧиз, капуста, белые грибы, пастрами, шампиньоны, ростбиф, соус деми глаз', 538, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо150', 107, 'вырезка свиная, лапша, паста, кальмары, каперсы, ростбиф, шампиньоны, булочки, паста, паста', 472, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо151', 191, 'запеченая тыква, пармезан, пармезан, вырезка свиная', 433, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо152', 200, 'куриная грудка, лапша, салат айсберг, огурцы, паста, соус медово-горчичный, капуста, соус деми глаз, куриная грудка', 246, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо153', 378, 'соус БлюЧиз, картофель, запеченая тыква, соус деми глаз, запеченая тыква, шампиньоны, булочки, булочки, салат айсберг, ростбиф', 339, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо154', 334, 'лук, булочки, соус деми глаз, морковь, булочки, сыр чеддер, белые грибы, пастрами, грецкий орех', 411, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо155', 216, 'лапша, соус деми глаз, соус чили, соус деми глаз, сливки, капуста, креветки, перец сладкий, перец сладкий', 323, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо156', 358, 'батат, грецкий орех, лук, паста, грецкий орех, сливки', 384, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо157', 258, 'ростбиф, сыр чеддер, кимчи, сливки, брынза', 262, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо158', 331, 'кальмары, микс салатов, пармезан, шампиньоны, каперсы, запеченая тыква, пастрами, перец сладкий', 573, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо159', 351, 'сливки, паста, соус БлюЧиз, куриная грудка, соус деми глаз', 588, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо160', 165, 'булочки, батат, кальмары, микс салатов, вырезка свиная, морковь', 353, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо161', 254, 'грецкий орех, шампиньоны, белые грибы, картофель, перец болгарский, вяленые томаты, каперсы, соус деми глаз', 233, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо162', 162, 'белые грибы, кус кус, соус деми глаз, лапша, пармезан, картофель, сливки, перец сладкий, каперсы', 269, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо163', 346, 'батат, батат, салат романо, лук, огурцы, пшеничное тесто, брынза, креветки, кальмары, перец болгарский', 521, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо164', 366, 'шампиньоны, каперсы, кус кус, вырезка свиная, микс салатов, морковь, имбирь', 360, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо165', 107, 'каперсы, имбирь, кальмары, лапша, белые грибы', 379, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо166', 343, 'батат, пармезан, куриная грудка, пшеничное тесто, картофель, имбирь, ростбиф, огурцы', 377, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо167', 123, 'шампиньоны, соус чили, салат романо, куриная грудка, пшеничное тесто, каперсы, белые грибы, креветки, сыр чеддер, запеченая тыква', 518, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо168', 258, 'сыр чеддер, сыр чеддер, картофель', 387, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо169', 320, 'белые грибы, брынза, соус БлюЧиз', 416, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо170', 362, 'вяленые томаты, сливки, морковь, паста, запеченая тыква, паста, соус БлюЧиз, шампиньоны, батат, вяленые томаты', 219, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо171', 309, 'сливки, соус деми глаз, сок лимона, огурцы, пшеничное тесто, булочки, соус деми глаз', 384, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо172', 368, 'соус БлюЧиз, соус БлюЧиз, ростбиф, лук, имбирь, соус БлюЧиз, пшеничное тесто, куриная грудка', 532, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо173', 263, 'соус медово-горчичный, имбирь, перец сладкий, соус БлюЧиз, сыр чеддер, кимчи, лук, салат романо, имбирь, соус медово-горчичный', 508, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо174', 233, 'пшеничное тесто, белые грибы, батат, вырезка свиная, картофель, кальмары, креветки, картофель', 238, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо175', 283, 'соус медово-горчичный, соус чили, пастрами, морковь, соус медово-горчичный, сливки, кальмары', 339, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо176', 280, 'перец болгарский, запеченая тыква, соус БлюЧиз, каперсы', 250, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо177', 224, 'шампиньоны, кус кус, вяленые томаты, вяленые томаты, лапша, сок лимона', 560, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо178', 185, 'каперсы, брынза, капуста, перец сладкий, соус БлюЧиз, пастрами, картофель, грецкий орех, вяленые томаты', 571, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо179', 345, 'булочки, белые грибы, сок лимона, пастрами, перец сладкий', 261, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо180', 241, 'имбирь, пшеничное тесто, сливки, соус деми глаз, соус чили, запеченая тыква, соус БлюЧиз, пшеничное тесто, ростбиф', 294, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо181', 268, 'капуста, пшеничное тесто, салат романо, креветки, булочки, паста, шампиньоны', 370, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо182', 199, 'батат, кус кус, сок лимона', 410, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо183', 242, 'соус медово-горчичный, картофель, салат романо', 362, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо184', 327, 'вырезка свиная, перец сладкий, шампиньоны', 570, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо185', 366, 'креветки, соус чили, лапша, салат айсберг, кус кус, запеченая тыква, капуста, белые грибы, грецкий орех', 458, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо186', 201, 'куриная грудка, белые грибы, соус деми глаз, брынза, вяленые томаты, кальмары, соус медово-горчичный, кус кус, капуста', 326, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо187', 219, 'картофель, запеченая тыква, микс салатов, лук, морковь, пшеничное тесто, сливки, паста, каперсы', 234, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо188', 138, 'брынза, пастрами, лук, капуста, запеченая тыква, перец сладкий', 392, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо189', 104, 'сливки, пшеничное тесто, соус БлюЧиз, салат романо, грецкий орех, капуста, вырезка свиная, соус медово-горчичный, соус деми глаз, салат романо', 589, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо190', 132, 'пастрами, соус деми глаз, морковь, пастрами, имбирь, кимчи, белые грибы, соус чили, соус медово-горчичный', 512, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо191', 112, 'перец болгарский, сливки, морковь, соус чили, морковь, кальмары, перец сладкий', 489, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо192', 267, 'лапша, капуста, перец сладкий, кальмары, соус деми глаз, батат', 354, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо193', 177, 'сыр чеддер, батат, грецкий орех, шампиньоны, шампиньоны, огурцы, креветки, салат романо, микс салатов', 375, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо194', 132, 'соус БлюЧиз, перец болгарский, соус БлюЧиз, пшеничное тесто, соус медово-горчичный, каперсы, соус чили', 313, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо195', 142, 'вяленые томаты, куриная грудка, сок лимона, брынза, перец сладкий, сливки, сок лимона, салат айсберг, кальмары', 311, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо196', 114, 'шампиньоны, кус кус, соус чили, перец сладкий, вырезка свиная, соус чили', 438, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо197', 110, 'капуста, огурцы, лук, пшеничное тесто, перец болгарский, капуста, батат, грецкий орех', 207, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо198', 112, 'соус БлюЧиз, креветки, соус чили, кальмары, кус кус, ростбиф, кальмары', 254, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо199', 301, 'соус чили, салат романо, салат айсберг, салат айсберг', 300, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо200', 364, 'соус чили, ростбиф, сливки, вырезка свиная, сок лимона, паста, перец болгарский, куриная грудка, огурцы, соус чили', 597, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо201', 375, 'батат, вяленые томаты, грецкий орех, кальмары, перец болгарский, микс салатов, грецкий орех, перец сладкий, пармезан, лапша', 367, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо202', 281, 'сок лимона, сыр чеддер, белые грибы, вырезка свиная, сливки', 514, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо203', 356, 'брынза, сок лимона, кус кус, вырезка свиная, куриная грудка, вяленые томаты, вырезка свиная', 431, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо204', 161, 'булочки, капуста, куриная грудка', 333, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо205', 261, 'куриная грудка, лапша, салат айсберг', 365, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо206', 352, 'соус БлюЧиз, кимчи, кус кус', 417, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо207', 290, 'перец сладкий, соус чили, огурцы, сыр чеддер, имбирь, сыр чеддер, грецкий орех, ростбиф', 385, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо208', 340, 'сливки, салат айсберг, пастрами, соус БлюЧиз', 212, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо209', 149, 'микс салатов, перец сладкий, лук, лук, перец болгарский, пармезан, белые грибы, лук, кус кус, вырезка свиная', 246, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо210', 189, 'пастрами, имбирь, сыр чеддер, лапша', 480, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо211', 175, 'кальмары, батат, соус деми глаз, огурцы, вырезка свиная, микс салатов, огурцы', 310, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо212', 110, 'сливки, салат романо, соус БлюЧиз', 348, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо213', 104, 'кимчи, соус чили, грецкий орех, булочки, лапша, соус БлюЧиз, креветки', 294, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо214', 256, 'паста, белые грибы, соус БлюЧиз, сыр чеддер, микс салатов, лук, белые грибы, сыр чеддер', 319, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо215', 103, 'сливки, пшеничное тесто, соус медово-горчичный, вырезка свиная, шампиньоны, шампиньоны, лук, огурцы', 598, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо216', 107, 'паста, куриная грудка, лапша, креветки, белые грибы, соус БлюЧиз, вырезка свиная, каперсы, вяленые томаты, батат', 481, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо217', 293, 'соус чили, капуста, картофель', 537, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо218', 334, 'кус кус, имбирь, паста, брынза, брынза, грецкий орех', 475, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо219', 329, 'перец болгарский, картофель, брынза, перец болгарский, перец болгарский, перец болгарский', 387, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо220', 366, 'грецкий орех, салат айсберг, имбирь, морковь', 270, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо221', 354, 'перец сладкий, каперсы, лук, куриная грудка', 334, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо222', 166, 'огурцы, кус кус, лук, запеченая тыква, вяленые томаты, куриная грудка, ростбиф, перец болгарский', 334, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо223', 291, 'микс салатов, соус деми глаз, соус деми глаз, перец болгарский, соус чили, булочки', 365, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо224', 291, 'грецкий орех, вяленые томаты, сыр чеддер, грецкий орех, соус чили, капуста', 597, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо225', 129, 'перец болгарский, капуста, сливки, салат айсберг, сливки, вяленые томаты, перец болгарский, сыр чеддер, батат, пастрами', 330, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо226', 200, 'шампиньоны, сыр чеддер, вяленые томаты, морковь, пармезан', 241, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо227', 225, 'соус медово-горчичный, куриная грудка, соус деми глаз, салат айсберг, сок лимона', 491, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо228', 384, 'паста, каперсы, вырезка свиная, каперсы, запеченая тыква, лук, пармезан, соус БлюЧиз', 499, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо229', 274, 'ростбиф, булочки, креветки, огурцы, вяленые томаты, куриная грудка, креветки, лук', 283, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо230', 372, 'грецкий орех, салат айсберг, пармезан, куриная грудка, картофель', 363, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо231', 120, 'картофель, вырезка свиная, морковь, соус чили, перец сладкий, микс салатов, лук', 533, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо232', 146, 'салат романо, брынза, пшеничное тесто, булочки, имбирь, капуста', 351, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо233', 291, 'лук, морковь, паста, куриная грудка', 575, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо234', 164, 'батат, кальмары, белые грибы, перец сладкий, салат айсберг, белые грибы, креветки, пастрами, салат романо', 478, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо235', 264, 'булочки, микс салатов, каперсы, каперсы, перец сладкий, соус деми глаз, шампиньоны, каперсы', 477, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо236', 134, 'брынза, кус кус, куриная грудка', 274, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо237', 259, 'салат айсберг, кимчи, капуста', 343, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо238', 351, 'вырезка свиная, запеченая тыква, имбирь', 273, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо239', 143, 'белые грибы, микс салатов, салат айсберг, шампиньоны, соус деми глаз, пшеничное тесто', 543, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо240', 383, 'кус кус, лапша, морковь, соус медово-горчичный, соус БлюЧиз, картофель', 273, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо241', 229, 'перец сладкий, морковь, соус медово-горчичный, лапша, морковь, сыр чеддер', 461, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо242', 197, 'куриная грудка, микс салатов, шампиньоны, микс салатов, морковь, соус чили, булочки, запеченая тыква, креветки, пастрами', 548, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо243', 350, 'вырезка свиная, шампиньоны, сливки, каперсы, соус чили, куриная грудка, грецкий орех', 367, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо244', 360, 'лук, запеченая тыква, капуста, соус БлюЧиз', 213, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо245', 113, 'шампиньоны, кус кус, соус деми глаз, капуста, салат айсберг, пастрами', 564, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо246', 367, 'грецкий орех, паста, имбирь, креветки, соус БлюЧиз', 294, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо247', 186, 'салат айсберг, сок лимона, вяленые томаты, салат романо, перец болгарский', 351, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо248', 235, 'соус чили, ростбиф, салат айсберг, креветки', 243, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо249', 262, 'соус медово-горчичный, картофель, запеченая тыква, морковь, брынза, батат, кимчи, батат, лук', 435, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо250', 340, 'морковь, кимчи, паста, вырезка свиная, брынза, брынза, шампиньоны, ростбиф', 222, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо251', 215, 'запеченая тыква, пармезан, сок лимона, сливки, кимчи, салат айсберг, сыр чеддер, картофель', 584, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо252', 353, 'лук, пастрами, лапша, вырезка свиная, шампиньоны, брынза, креветки, запеченая тыква, имбирь', 290, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо253', 244, 'кус кус, паста, лук, пармезан, батат, имбирь, соус медово-горчичный, соус БлюЧиз', 339, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо254', 127, 'кимчи, соус БлюЧиз, ростбиф, лук, брынза, пшеничное тесто', 447, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо255', 146, 'кус кус, огурцы, паста, соус деми глаз', 374, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо256', 321, 'шампиньоны, брынза, запеченая тыква, вырезка свиная', 346, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо257', 333, 'соус деми глаз, запеченая тыква, грецкий орех, огурцы, брынза, капуста, вырезка свиная, брынза, морковь, пармезан', 520, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо258', 196, 'морковь, вырезка свиная, салат романо, шампиньоны', 251, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо259', 234, 'паста, шампиньоны, каперсы, пармезан, пастрами, картофель, кальмары, капуста, лапша', 419, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо260', 387, 'куриная грудка, лапша, огурцы, кус кус, ростбиф', 309, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо261', 205, 'лапша, каперсы, кус кус, белые грибы, лапша', 444, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо262', 271, 'креветки, лапша, кимчи, запеченая тыква, паста, пармезан', 481, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо263', 319, 'соус медово-горчичный, соус БлюЧиз, соус медово-горчичный, пармезан, булочки, соус БлюЧиз, соус БлюЧиз', 590, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо264', 188, 'картофель, вырезка свиная, белые грибы, соус БлюЧиз, запеченая тыква, картофель', 341, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо265', 226, 'перец болгарский, креветки, кимчи, булочки, вяленые томаты, соус чили, соус деми глаз, лапша, салат романо, соус медово-горчичный', 352, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо266', 201, 'сок лимона, соус БлюЧиз, пастрами, пастрами, кус кус, сыр чеддер, пармезан, лук', 246, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо267', 303, 'соус деми глаз, пармезан, куриная грудка', 425, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо268', 182, 'микс салатов, соус медово-горчичный, куриная грудка, соус медово-горчичный, лапша', 322, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо269', 264, 'каперсы, соус БлюЧиз, перец болгарский, салат айсберг, лапша, паста, салат романо, запеченая тыква', 281, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо270', 359, 'брынза, пастрами, запеченая тыква', 373, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо271', 283, 'имбирь, кус кус, шампиньоны, соус деми глаз', 557, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо272', 339, 'салат романо, лапша, булочки, булочки, перец сладкий', 389, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо273', 318, 'имбирь, булочки, сыр чеддер, сок лимона, кальмары, морковь', 297, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо274', 366, 'сливки, картофель, соус БлюЧиз, белые грибы, пастрами, салат айсберг, салат романо, имбирь, имбирь, лук', 476, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо275', 239, 'перец болгарский, соус деми глаз, перец болгарский, салат романо, пастрами, салат романо, соус деми глаз, кус кус', 464, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо276', 317, 'перец болгарский, брынза, сливки, брынза, соус деми глаз, пшеничное тесто, сыр чеддер, грецкий орех, огурцы', 270, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо277', 147, 'лапша, огурцы, соус деми глаз, кимчи, запеченая тыква, батат, соус чили, микс салатов', 556, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо278', 333, 'каперсы, соус БлюЧиз, кальмары, ростбиф', 369, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо279', 210, 'шампиньоны, паста, булочки, соус чили, пармезан', 434, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо280', 361, 'пармезан, соус деми глаз, креветки, булочки, пшеничное тесто, сок лимона', 205, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо281', 144, 'куриная грудка, соус БлюЧиз, вяленые томаты, паста, микс салатов, пастрами, креветки', 433, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо282', 361, 'огурцы, лук, огурцы, белые грибы, пармезан, креветки, шампиньоны', 497, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо283', 119, 'шампиньоны, креветки, вяленые томаты, пшеничное тесто, салат айсберг, паста, запеченая тыква', 211, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо284', 300, 'сок лимона, пастрами, микс салатов, паста, пастрами, соус деми глаз, сок лимона, батат', 588, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо285', 275, 'соус деми глаз, сок лимона, лапша, имбирь, сок лимона, ростбиф, соус чили', 226, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо286', 362, 'пастрами, перец болгарский, пастрами, соус медово-горчичный, вяленые томаты', 267, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо287', 170, 'пармезан, перец сладкий, куриная грудка, капуста, соус БлюЧиз, куриная грудка', 577, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо288', 118, 'сливки, ростбиф, грецкий орех, соус деми глаз, каперсы, брынза, кимчи', 260, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо289', 239, 'куриная грудка, соус деми глаз, сок лимона', 387, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо290', 282, 'запеченая тыква, перец сладкий, каперсы, сливки, соус БлюЧиз', 255, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо291', 281, 'батат, паста, салат айсберг, запеченая тыква, кимчи, кальмары, сок лимона', 451, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо292', 149, 'вырезка свиная, соус медово-горчичный, соус БлюЧиз, сыр чеддер, шампиньоны, соус БлюЧиз, имбирь, соус медово-горчичный', 277, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо293', 313, 'перец болгарский, капуста, кальмары, кальмары, вырезка свиная, белые грибы', 256, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо294', 354, 'соус чили, картофель, сыр чеддер, сливки, грецкий орех, соус медово-горчичный, пастрами, имбирь, булочки, запеченая тыква', 345, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо295', 400, 'сок лимона, салат айсберг, соус БлюЧиз, сыр чеддер, кальмары, картофель', 482, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо296', 155, 'соус БлюЧиз, сливки, каперсы, вяленые томаты, каперсы, сыр чеддер, креветки, куриная грудка, паста', 234, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо297', 230, 'кимчи, соус чили, креветки, салат айсберг, пшеничное тесто, каперсы, брынза', 275, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо298', 353, 'белые грибы, булочки, креветки, шампиньоны', 591, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо299', 286, 'сыр чеддер, куриная грудка, куриная грудка, картофель, сок лимона, соус чили, соус чили, булочки, грецкий орех', 432, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо300', 185, 'булочки, брынза, вырезка свиная, морковь, имбирь, грецкий орех', 363, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо301', 224, 'картофель, кальмары, салат айсберг, батат, вырезка свиная, сыр чеддер, пшеничное тесто, перец сладкий', 404, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо302', 105, 'куриная грудка, креветки, кус кус, пармезан, сливки, салат айсберг, пармезан, куриная грудка, салат айсберг, белые грибы', 256, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо303', 115, 'каперсы, морковь, перец болгарский, куриная грудка', 500, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо304', 334, 'грецкий орех, соус БлюЧиз, сыр чеддер', 567, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо305', 113, 'салат романо, картофель, капуста, соус БлюЧиз', 600, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо306', 356, 'перец сладкий, лук, перец сладкий, кус кус, соус деми глаз, запеченая тыква, соус медово-горчичный, перец сладкий', 465, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо307', 308, 'сливки, микс салатов, вырезка свиная, батат, грецкий орех', 561, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо308', 271, 'сыр чеддер, перец болгарский, соус деми глаз, сок лимона, имбирь, кус кус, каперсы, булочки, пармезан, сливки', 427, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо309', 118, 'ростбиф, белые грибы, булочки, креветки, грецкий орех, кус кус, лапша, кимчи', 538, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо310', 155, 'каперсы, креветки, куриная грудка', 344, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо311', 166, 'кимчи, запеченая тыква, булочки', 578, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо312', 239, 'соус БлюЧиз, соус деми глаз, сливки, капуста', 377, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо313', 192, 'морковь, куриная грудка, куриная грудка, соус деми глаз, пастрами, брынза, брынза, микс салатов, кальмары, кимчи', 585, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо314', 389, 'лук, брынза, сливки, соус медово-горчичный, салат романо, соус БлюЧиз, пармезан', 400, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо315', 332, 'кальмары, сливки, кальмары, шампиньоны, картофель, перец сладкий, белые грибы, имбирь, сок лимона, грецкий орех', 355, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо316', 139, 'белые грибы, сок лимона, куриная грудка, перец болгарский, соус деми глаз, салат романо, соус медово-горчичный, соус БлюЧиз', 436, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо317', 362, 'капуста, ростбиф, кус кус, пшеничное тесто, имбирь, каперсы', 370, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо318', 344, 'булочки, паста, брынза, батат, пастрами', 442, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо319', 322, 'грецкий орех, сливки, ростбиф', 241, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо320', 347, 'запеченая тыква, соус деми глаз, белые грибы, грецкий орех, соус БлюЧиз, батат, микс салатов, ростбиф, соус чили, булочки', 342, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо321', 350, 'микс салатов, сыр чеддер, лук, пшеничное тесто, батат, креветки, паста', 372, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо322', 175, 'каперсы, кус кус, ростбиф, сок лимона, пармезан, перец болгарский, паста, запеченая тыква, сыр чеддер, соус БлюЧиз', 485, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо323', 328, 'перец сладкий, лук, огурцы, кимчи, каперсы, кимчи, кимчи, сыр чеддер', 440, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо324', 211, 'вырезка свиная, брынза, огурцы, соус БлюЧиз, вырезка свиная, морковь, салат айсберг, пшеничное тесто', 274, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо325', 311, 'креветки, лук, соус деми глаз, соус БлюЧиз, сыр чеддер, салат айсберг, соус медово-горчичный, запеченая тыква, грецкий орех, вяленые томаты', 541, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо326', 190, 'соус деми глаз, ростбиф, запеченая тыква, соус БлюЧиз, перец сладкий, имбирь, булочки, грецкий орех, перец сладкий', 411, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо327', 335, 'кальмары, соус чили, запеченая тыква, кимчи, кус кус, ростбиф', 274, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо328', 186, 'кальмары, соус деми глаз, шампиньоны, морковь, булочки, лапша, куриная грудка, шампиньоны, перец болгарский, брынза', 435, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо329', 359, 'креветки, соус деми глаз, кус кус, соус медово-горчичный, картофель, вяленые томаты, капуста, картофель, лапша, вяленые томаты', 436, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо330', 310, 'кус кус, салат айсберг, брынза, огурцы', 351, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо331', 217, 'батат, имбирь, перец сладкий, пшеничное тесто, огурцы, соус деми глаз, сок лимона, вырезка свиная, креветки, брынза', 266, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо332', 141, 'кус кус, картофель, грецкий орех, ростбиф', 557, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо333', 138, 'грецкий орех, соус медово-горчичный, креветки, морковь, соус БлюЧиз, соус деми глаз', 357, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо334', 239, 'микс салатов, лук, кус кус, пармезан, перец сладкий, морковь', 293, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо335', 164, 'огурцы, лапша, каперсы, картофель, лапша, сыр чеддер, микс салатов, лапша, вяленые томаты, кус кус', 321, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо336', 102, 'соус медово-горчичный, кимчи, белые грибы', 317, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо337', 333, 'ростбиф, кальмары, шампиньоны, морковь, кальмары, картофель, салат романо, грецкий орех, ростбиф, соус БлюЧиз', 443, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо338', 368, 'пшеничное тесто, ростбиф, куриная грудка, соус чили, белые грибы, каперсы', 559, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо339', 345, 'имбирь, кальмары, брынза, брынза, лапша, имбирь, микс салатов', 321, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо340', 347, 'вырезка свиная, грецкий орех, микс салатов', 470, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо341', 348, 'белые грибы, сок лимона, кальмары, салат романо', 426, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо342', 177, 'пастрами, белые грибы, вырезка свиная, белые грибы, огурцы, брынза, запеченая тыква, картофель, каперсы, картофель', 271, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо343', 138, 'грецкий орех, кальмары, запеченая тыква, соус деми глаз, пшеничное тесто, перец сладкий, картофель, куриная грудка, салат романо', 440, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо344', 133, 'имбирь, микс салатов, сыр чеддер, кимчи, микс салатов, имбирь, лук, салат романо, батат, вяленые томаты', 430, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо345', 325, 'имбирь, белые грибы, каперсы, картофель, кальмары, булочки, картофель, грецкий орех', 278, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо346', 222, 'креветки, имбирь, перец сладкий, салат айсберг, запеченая тыква, каперсы', 510, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо347', 107, 'морковь, салат айсберг, огурцы, брынза, картофель, креветки, креветки, картофель, лук, булочки', 350, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо385', 201, 'батат, куриная грудка, пармезан, кус кус, сок лимона, огурцы', 484, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо348', 334, 'ростбиф, пастрами, запеченая тыква, имбирь, ростбиф, грецкий орех, пшеничное тесто', 377, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо349', 262, 'соус БлюЧиз, соус БлюЧиз, кус кус, пастрами, ростбиф, морковь, салат айсберг', 230, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо350', 391, 'салат айсберг, лук, салат айсберг, перец сладкий, батат, вырезка свиная', 434, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо351', 269, 'грецкий орех, каперсы, лапша, морковь', 259, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо352', 272, 'перец сладкий, лапша, паста, соус деми глаз, кальмары, лапша', 347, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо353', 226, 'запеченая тыква, брынза, капуста, перец болгарский, перец болгарский, капуста, сливки, вяленые томаты', 353, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо354', 114, 'лапша, куриная грудка, морковь', 470, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо355', 107, 'пармезан, соус медово-горчичный, салат айсберг, соус чили, соус деми глаз, имбирь', 235, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо356', 217, 'сыр чеддер, огурцы, соус деми глаз, булочки, ростбиф, соус медово-горчичный', 586, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо357', 303, 'белые грибы, кимчи, имбирь, соус деми глаз, сок лимона, запеченая тыква, имбирь, кальмары, соус медово-горчичный, паста', 220, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо358', 263, 'имбирь, капуста, шампиньоны, соус деми глаз, шампиньоны', 530, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо359', 223, 'салат романо, соус медово-горчичный, ростбиф, булочки, сок лимона, запеченая тыква, батат, соус БлюЧиз, микс салатов', 578, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо360', 302, 'соус деми глаз, морковь, пшеничное тесто, вырезка свиная, пармезан, лапша, соус деми глаз', 395, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо361', 127, 'микс салатов, кальмары, кальмары, ростбиф, капуста, морковь', 570, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо362', 163, 'креветки, кальмары, салат романо', 569, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо363', 380, 'салат айсберг, соус деми глаз, имбирь, соус чили, брынза, соус БлюЧиз, кальмары, белые грибы', 518, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо364', 399, 'соус чили, запеченая тыква, салат айсберг, имбирь, соус чили, соус чили, салат айсберг, кус кус, белые грибы, креветки', 450, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо365', 249, 'соус БлюЧиз, лук, салат айсберг', 415, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо366', 315, 'вяленые томаты, кус кус, салат романо, паста, капуста, соус чили, сыр чеддер, брынза, ростбиф', 275, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо367', 132, 'креветки, сыр чеддер, кимчи', 419, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо368', 338, 'кимчи, соус медово-горчичный, салат романо', 428, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо369', 379, 'брынза, огурцы, пшеничное тесто, соус чили, булочки, соус чили, сливки', 354, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо370', 309, 'картофель, микс салатов, соус деми глаз, сыр чеддер, паста, сыр чеддер, булочки, пармезан', 433, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо371', 221, 'куриная грудка, пармезан, картофель, соус БлюЧиз, шампиньоны, батат, капуста, соус БлюЧиз', 249, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо372', 382, 'креветки, сок лимона, перец болгарский, соус чили, вяленые томаты, сливки, соус деми глаз, салат айсберг, соус БлюЧиз, капуста', 303, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо373', 126, 'ростбиф, пармезан, вяленые томаты, пармезан, салат романо, салат романо', 353, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо374', 148, 'капуста, запеченая тыква, кус кус, имбирь', 324, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо375', 262, 'белые грибы, перец болгарский, картофель, грецкий орех, лапша, батат', 348, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо376', 134, 'куриная грудка, имбирь, запеченая тыква, лук, соус БлюЧиз, соус деми глаз', 441, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо377', 137, 'грецкий орех, кимчи, сливки, перец сладкий, соус медово-горчичный, пшеничное тесто', 387, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо378', 376, 'вырезка свиная, белые грибы, ростбиф, белые грибы, соус БлюЧиз', 560, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо379', 275, 'перец болгарский, лапша, шампиньоны, ростбиф, кимчи, каперсы, каперсы, салат айсберг, сыр чеддер', 469, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо380', 317, 'соус чили, морковь, ростбиф, пастрами, булочки, салат айсберг, салат романо', 442, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо381', 300, 'пармезан, капуста, перец болгарский, соус медово-горчичный, капуста, сливки, креветки, сливки, белые грибы, сок лимона', 421, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо382', 234, 'салат айсберг, кальмары, пшеничное тесто, салат айсберг, картофель, перец болгарский, батат, паста, имбирь, пармезан', 419, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо383', 136, 'соус медово-горчичный, вырезка свиная, ростбиф, кимчи, пармезан', 365, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо384', 204, 'брынза, каперсы, огурцы, булочки, паста', 262, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо386', 221, 'запеченая тыква, картофель, микс салатов, имбирь, морковь', 446, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо387', 213, 'пармезан, имбирь, пастрами, сыр чеддер, вяленые томаты, кимчи', 423, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо388', 388, 'имбирь, салат романо, микс салатов, соус БлюЧиз, креветки, запеченая тыква, сыр чеддер, вырезка свиная, соус чили', 595, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо389', 352, 'ростбиф, лук, соус медово-горчичный, соус деми глаз, каперсы, запеченая тыква', 595, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо390', 362, 'ростбиф, соус БлюЧиз, запеченая тыква, куриная грудка, паста, сок лимона, батат, салат айсберг, вяленые томаты, батат', 462, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо391', 162, 'перец болгарский, соус медово-горчичный, соус БлюЧиз, сливки, кимчи, белые грибы, вяленые томаты, булочки', 506, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо392', 373, 'соус деми глаз, соус БлюЧиз, белые грибы, лук, соус чили, лук', 526, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо393', 227, 'салат айсберг, пастрами, запеченая тыква, имбирь, кус кус, картофель, шампиньоны, лук, грецкий орех', 404, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо394', 380, 'вяленые томаты, соус деми глаз, пшеничное тесто, куриная грудка, шампиньоны, капуста, пармезан, запеченая тыква', 204, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо395', 307, 'грецкий орех, булочки, вяленые томаты, соус деми глаз, куриная грудка, белые грибы, кимчи, вырезка свиная, каперсы, картофель', 389, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо396', 271, 'пармезан, каперсы, пшеничное тесто, капуста', 599, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо397', 351, 'кимчи, микс салатов, соус чили, салат айсберг, соус медово-горчичный, вяленые томаты, картофель, сок лимона, грецкий орех, кус кус', 327, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо398', 232, 'сок лимона, креветки, сыр чеддер, каперсы, креветки, салат романо, соус медово-горчичный, пармезан, сыр чеддер, соус чили', 447, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо399', 390, 'перец болгарский, салат романо, микс салатов, паста, пшеничное тесто, шампиньоны, соус деми глаз, лук, брынза', 517, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо400', 240, 'перец болгарский, лапша, креветки, салат айсберг, микс салатов, соус медово-горчичный, салат айсберг, вяленые томаты', 234, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо401', 187, 'куриная грудка, вяленые томаты, лук, брынза, соус чили, пастрами, вырезка свиная', 578, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо402', 317, 'булочки, булочки, батат, креветки, вырезка свиная, огурцы, перец болгарский', 351, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо403', 386, 'пшеничное тесто, креветки, салат романо, соус БлюЧиз, куриная грудка, брынза, паста, перец сладкий, огурцы', 255, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо404', 311, 'грецкий орех, булочки, каперсы, шампиньоны, лук, куриная грудка, кальмары, кальмары', 489, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо405', 302, 'белые грибы, соус медово-горчичный, кус кус, кус кус', 327, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо406', 337, 'кимчи, запеченая тыква, булочки, лук, куриная грудка, вырезка свиная, пармезан, морковь', 284, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо407', 231, 'лапша, лапша, грецкий орех, кимчи, капуста, соус деми глаз', 341, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо408', 317, 'имбирь, перец сладкий, шампиньоны, капуста, куриная грудка, вяленые томаты, сливки, соус чили, кус кус, шампиньоны', 410, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо409', 283, 'грецкий орех, имбирь, перец сладкий', 544, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо410', 266, 'грецкий орех, булочки, пастрами, паста, каперсы, соус медово-горчичный', 410, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо411', 292, 'брынза, лук, белые грибы, брынза, ростбиф, лапша, грецкий орех, перец сладкий, белые грибы, соус деми глаз', 273, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо412', 166, 'сливки, перец сладкий, капуста', 210, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо413', 175, 'батат, шампиньоны, брынза, батат, пастрами, белые грибы, креветки, паста', 396, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо414', 379, 'белые грибы, вырезка свиная, креветки, капуста, имбирь, соус медово-горчичный, батат, брынза', 228, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо415', 225, 'лапша, грецкий орех, вырезка свиная, ростбиф, пармезан, запеченая тыква, сыр чеддер, лук', 230, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо416', 218, 'пшеничное тесто, лук, микс салатов, микс салатов, грецкий орех', 278, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо417', 400, 'микс салатов, кус кус, каперсы, батат, белые грибы', 586, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо418', 212, 'соус деми глаз, огурцы, капуста, соус деми глаз, соус чили, огурцы, морковь', 577, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо419', 392, 'соус деми глаз, пармезан, пшеничное тесто, шампиньоны, имбирь, сок лимона, лук, шампиньоны', 384, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо420', 326, 'соус деми глаз, соус медово-горчичный, лапша, каперсы, огурцы, куриная грудка, морковь, перец болгарский, белые грибы, белые грибы', 448, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо421', 314, 'морковь, пшеничное тесто, грецкий орех, соус деми глаз, перец сладкий, сливки, сливки, шампиньоны', 397, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо422', 140, 'пшеничное тесто, сыр чеддер, сливки, шампиньоны, сливки, паста, лапша', 270, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо423', 332, 'шампиньоны, лапша, кальмары, соус чили, шампиньоны, имбирь, микс салатов, пармезан', 518, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо424', 253, 'пастрами, кус кус, кимчи, кус кус, огурцы, огурцы, запеченая тыква, брынза', 357, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо425', 284, 'микс салатов, салат романо, соус деми глаз, куриная грудка, пастрами, вяленые томаты, пармезан, сок лимона', 437, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо426', 308, 'вяленые томаты, соус чили, лапша', 551, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо427', 289, 'запеченая тыква, соус чили, сливки', 362, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо428', 244, 'сыр чеддер, паста, соус деми глаз, лапша', 282, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо429', 102, 'соус деми глаз, креветки, ростбиф, куриная грудка', 412, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо430', 382, 'сливки, морковь, пшеничное тесто, сыр чеддер, кимчи, кус кус, картофель, пастрами, креветки, микс салатов', 541, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо431', 202, 'картофель, запеченая тыква, пастрами, пшеничное тесто, перец сладкий, микс салатов, вяленые томаты, перец болгарский', 277, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо432', 316, 'паста, имбирь, имбирь, каперсы, соус чили', 247, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо433', 335, 'картофель, перец сладкий, морковь, имбирь, шампиньоны', 213, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо434', 309, 'перец болгарский, брынза, белые грибы, булочки, пшеничное тесто', 426, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо435', 304, 'соус медово-горчичный, салат романо, пшеничное тесто, сливки, кимчи, вяленые томаты', 595, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо436', 289, 'соус чили, шампиньоны, соус деми глаз, пшеничное тесто, лук, пшеничное тесто', 461, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо437', 288, 'шампиньоны, огурцы, пшеничное тесто, каперсы, сливки, перец болгарский, перец сладкий, перец сладкий', 269, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо438', 277, 'пастрами, булочки, лук, кус кус, лук, микс салатов', 399, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо439', 235, 'кальмары, микс салатов, перец болгарский', 241, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо440', 314, 'запеченая тыква, салат айсберг, белые грибы, грецкий орех', 241, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо441', 305, 'салат айсберг, вяленые томаты, огурцы, салат айсберг, кимчи, соус медово-горчичный, булочки, белые грибы', 581, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо442', 367, 'запеченая тыква, имбирь, кальмары', 564, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо443', 214, 'пармезан, брынза, грецкий орех, лук, вяленые томаты, капуста, сыр чеддер', 456, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо444', 325, 'салат романо, микс салатов, картофель', 555, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо445', 252, 'батат, белые грибы, креветки, салат романо, пшеничное тесто, пармезан, морковь, брынза', 381, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо446', 124, 'пастрами, вырезка свиная, огурцы, морковь, кальмары, сок лимона, морковь, лук', 313, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо447', 102, 'картофель, креветки, креветки, ростбиф, вяленые томаты', 363, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо448', 258, 'салат романо, грецкий орех, салат романо, кальмары, салат айсберг', 598, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо449', 388, 'соус БлюЧиз, запеченая тыква, кальмары, перец болгарский, вырезка свиная, соус медово-горчичный', 259, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо450', 145, 'брынза, ростбиф, сок лимона, сок лимона', 390, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо451', 329, 'куриная грудка, перец сладкий, картофель', 335, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо452', 378, 'морковь, соус чили, грецкий орех, пшеничное тесто', 513, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо453', 238, 'салат айсберг, булочки, перец болгарский', 547, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо454', 201, 'сыр чеддер, запеченая тыква, салат айсберг, лук, лук, имбирь, морковь, салат романо', 242, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо455', 107, 'соус чили, перец сладкий, запеченая тыква', 411, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо456', 293, 'шампиньоны, огурцы, перец болгарский, кус кус, вяленые томаты, пармезан, запеченая тыква, запеченая тыква, лук', 294, 'Аркобалено', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо457', 365, 'кальмары, куриная грудка, кус кус, соус чили, ростбиф, вяленые томаты, сок лимона, батат', 292, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо458', 150, 'кус кус, брынза, перец сладкий, запеченая тыква, паста', 361, 'Клод Моне', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо459', 210, 'креветки, кимчи, кус кус, соус медово-горчичный, куриная грудка', 283, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо460', 226, 'грецкий орех, перец сладкий, пастрами, морковь, сливки, грецкий орех', 596, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо461', 367, 'креветки, соус деми глаз, каперсы', 477, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо462', 378, 'салат романо, вырезка свиная, капуста, кимчи, микс салатов, паста, соус БлюЧиз, булочки, креветки, салат айсберг', 547, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо463', 112, 'соус деми глаз, пшеничное тесто, лук', 229, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо464', 269, 'паста, запеченая тыква, кус кус, соус чили', 576, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо465', 256, 'салат романо, кус кус, перец сладкий, микс салатов, пармезан, кимчи', 546, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо466', 271, 'имбирь, соус деми глаз, салат айсберг, соус БлюЧиз, ростбиф, имбирь, соус чили, сок лимона', 540, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо467', 290, 'шампиньоны, огурцы, креветки, лапша, кальмары, булочки', 394, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо468', 271, 'лапша, вяленые томаты, кимчи, булочки, брынза, соус медово-горчичный', 515, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо469', 138, 'сыр чеддер, сыр чеддер, перец сладкий, грецкий орех, шампиньоны, каперсы, сливки', 382, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо470', 308, 'батат, брынза, брынза, соус чили, паста, белые грибы, сыр чеддер, салат айсберг, пшеничное тесто', 410, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо471', 131, 'куриная грудка, кальмары, огурцы', 541, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо472', 220, 'кимчи, кус кус, картофель, грецкий орех, белые грибы, кимчи, морковь, паста, пастрами, салат романо', 403, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо473', 385, 'кимчи, имбирь, белые грибы, булочки, имбирь, куриная грудка, брынза', 295, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо474', 383, 'кальмары, морковь, вяленые томаты, соус БлюЧиз, перец болгарский, вырезка свиная, лук, салат романо, перец сладкий, кимчи', 513, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо475', 343, 'запеченая тыква, пармезан, креветки, пастрами, каперсы, каперсы', 549, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо476', 343, 'креветки, капуста, лапша, шампиньоны, паста, микс салатов, каперсы, кальмары, микс салатов', 235, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо477', 101, 'морковь, пастрами, морковь, салат романо', 410, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо478', 334, 'белые грибы, брынза, вяленые томаты, грецкий орех, морковь, салат айсберг, лапша, лук, батат, соус БлюЧиз', 356, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо479', 162, 'кимчи, брынза, картофель, имбирь, морковь, пшеничное тесто, паста', 495, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо480', 394, 'креветки, перец сладкий, пастрами, пастрами, кальмары', 365, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо481', 161, 'каперсы, пармезан, паста, соус медово-горчичный', 375, 'Виктор', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо482', 195, 'перец болгарский, пастрами, сок лимона, лук, каперсы, вырезка свиная, грецкий орех, шампиньоны, картофель, кус кус', 336, 'Аркобалено', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо483', 367, 'пшеничное тесто, брынза, куриная грудка, кимчи, морковь, соус медово-горчичный, кимчи', 463, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо484', 254, 'лук, куриная грудка, соус медово-горчичный, булочки, куриная грудка, микс салатов', 500, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо485', 289, 'картофель, булочки, перец болгарский, лапша, батат', 579, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо486', 139, 'вяленые томаты, соус медово-горчичный, запеченая тыква, огурцы, морковь, белые грибы, куриная грудка, сок лимона', 261, 'Аркобалено', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо487', 361, 'вырезка свиная, морковь, белые грибы, пшеничное тесто, брынза, ростбиф, булочки, каперсы, кимчи, кус кус', 356, 'Клод Моне', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо488', 290, 'картофель, кальмары, соус медово-горчичный, соус медово-горчичный, сок лимона, салат романо', 251, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо489', 225, 'пшеничное тесто, имбирь, куриная грудка, пармезан, куриная грудка, куриная грудка, пастрами, огурцы', 268, 'Виктор', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо490', 251, 'запеченая тыква, кус кус, шампиньоны, вяленые томаты, батат, салат айсберг, сыр чеддер', 351, 'Виктор', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо491', 328, 'салат романо, соус деми глаз, запеченая тыква, пшеничное тесто, батат, лапша, салат айсберг', 435, 'Клод Моне', 'тайская');
INSERT INTO public.dishes VALUES ('Блюдо492', 331, 'куриная грудка, сливки, сыр чеддер, перец сладкий, креветки, креветки, каперсы, куриная грудка', 434, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо493', 360, 'морковь, лапша, пармезан, кимчи, кальмары', 587, 'Виктор', 'русская');
INSERT INTO public.dishes VALUES ('Блюдо494', 194, 'кус кус, кус кус, каперсы, морковь, сливки, лук, брынза', 389, 'Аркобалено', 'французская');
INSERT INTO public.dishes VALUES ('Блюдо495', 237, 'белые грибы, вырезка свиная, имбирь, шампиньоны', 382, 'Виктор', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо496', 205, 'пастрами, микс салатов, брынза, сыр чеддер, соус деми глаз, имбирь', 413, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо497', 398, 'пармезан, соус чили, микс салатов, креветки, вырезка свиная, соус чили, булочки, пармезан, морковь', 261, 'Клод Моне', 'американская');
INSERT INTO public.dishes VALUES ('Блюдо498', 358, 'капуста, вырезка свиная, лук, вырезка свиная, перец болгарский, лук, огурцы, булочки, брынза, салат романо', 524, 'Клод Моне', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо499', 250, 'картофель, пастрами, салат айсберг, салат романо, соус медово-горчичный, кальмары, сыр чеддер, салат романо, перец болгарский, сыр чеддер', 444, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо500', 362, 'куриная грудка, сок лимона, пастрами', 484, 'Аркобалено', 'итальянская');
INSERT INTO public.dishes VALUES ('Блюдо501', 250, 'шампиньоны, сыр, яйца, базилик, уксус', 500, 'Виктор', 'французская');


--
-- TOC entry 3463 (class 0 OID 18471)
-- Dependencies: 215
-- Data for Name: drinks; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.drinks VALUES ('Текила санрайз', 250, 'текила, гренадин, апельсиной сок, лед', 20, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Ван Гог', 200, 'абсент, шампанское, лед', 30, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Апероль спитц', 250, 'апероль, просекко, содовая, лед', 15, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Шардоне Брют Балаклава', 750, 'Игристое вино, Россия', 13, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Рислинг Ханс Баер', 200, 'Белое вино, Германия', 12, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Вальполичелла Санте Риве Чело', 250, 'Красное вино, Италия', 15, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Лонг Айленд айс ти', 250, 'водка, ром, текила, джин, трипл сек, сахарный сироп, лимонный сок, кола, лед', 30, 'Виктор');
INSERT INTO public.drinks VALUES ('Негрони', 200, 'джин, вермут, красный биттер, лед', 20, 'Виктор');
INSERT INTO public.drinks VALUES ('Кровавая Мэри', 250, 'водка, томатный сок, лимонный сок, табаско, соль, перец', 15, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток1', 368, 'вода газированная, спрайт, вишневый сок, темное пиво, игристое вино, игристое вино, кокосовый ликер', 32, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток2', 195, 'сахарный сироп, апельсиновый сок, кофейный ликер', 32, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток3', 418, 'апельсиновый сок, лимонный сок, самбука, виски, дынный ликер, ром', 20, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток4', 297, 'ананасовый сок, сироп малиновый, гренадин, текила, кофейный ликер, белое вино', 37, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток5', 389, 'сок сельдерея, кокосовый ликер, лимончелло, джин', 14, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток6', 456, 'кокосовое молоко, сок лайма, вишневый сок, абсент, виски, белое вино, сливочный ликер', 35, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток7', 476, 'гренадин, лимонный сок, сливки, белое вино, текила', 9, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток8', 402, 'сироп малиновый, сироп малиновый, сахарный сироп, ванильное мороженое, сливочный ликер, апельсиновый ликер, красный вермут, лимончелло', 28, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток9', 210, 'сахарный сироп, сахарный сироп, ананасовый сок, светлое пиво, водка, ром', 34, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток10', 176, 'энергетик, пюре черной смородины, гренадин, ром, белое вино', 6, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток11', 373, 'кокосовое молоко, энергетик, красный вермут, абсент, самбука', 9, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток12', 341, 'кокосовое молоко, спрайт, вишневый сок, сахарный сироп, виски, водка, кокосовый ликер, апельсиновый ликер', 38, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток13', 212, 'сахарный сироп, лимонный сок, лимонный сок, кофейный ликер, кофейный ликер, игристое вино', 34, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток14', 479, 'кола, темное пиво', 16, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток15', 238, 'сок лайма, кокосовое молоко, кола, кокосовый ликер, коньяк', 5, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток16', 447, 'лед, апельсиновый сок, сок лайма, белый вермут', 28, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток17', 487, 'лимонный сок, вода газированная, джин, сливочный ликер, кокосовый ликер, красное вино', 11, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток18', 175, 'сок лайма, апельсиновый сок, томаный сок, кокосовое молоко, лимончелло, текила', 29, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток19', 286, 'ванильное мороженое, апельсиновый сок, энергетик, лимонный сок, белый вермут, сливочный ликер, водка', 39, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток20', 428, 'сахарный сироп, апельсиновый сок, сливочный ликер, темное пиво, белое вино', 12, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток21', 378, 'кола, вишневый сок, светлое пиво, коньяк', 17, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток22', 280, 'сок сельдерея, ванильное мороженое, сок лайма, вода газированная, коньяк, темное пиво, красный вермут, красное вино', 35, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток23', 333, 'ванильное мороженое, спрайт, сок сельдерея, персиковый ликер, белое вино', 19, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток24', 394, 'ванильное мороженое, томаный сок, энергетик, белый вермут, персиковый ликер', 39, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток25', 203, 'сливки, вишневый сок, игристое вино, кокосовый ликер, белое вино', 14, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток26', 451, 'вода газированная, сок сельдерея, тоник, темное пиво, апельсиновый ликер, водка', 8, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток27', 489, 'лед, белое вино, лимончелло, белый вермут, персиковый ликер', 32, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток28', 405, 'лимонный сок, сахарный сироп, пюре черной смородины, ананасовый сок, красное вино', 38, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток29', 492, 'спрайт, игристое вино, белый вермут', 9, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток30', 376, 'энергетик, вода газированная, кола, текила', 21, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток31', 403, 'сахарный сироп, кокосовое молоко, ананасовый сок, сок лайма, игристое вино', 18, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток32', 422, 'апельсиновый сок, дынный ликер', 9, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток200', 488, 'сливки, абсент, водка', 29, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток33', 336, 'кокосовое молоко, спрайт, сахарный сироп, сливки, белое вино', 37, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток34', 422, 'ванильное мороженое, вода газированная, вода газированная, лед, белый вермут, коньяк', 5, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток35', 223, 'сок лайма, красное вино', 24, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток36', 477, 'сироп малиновый, сок лайма, ванильное мороженое, абсент, красное вино, ром', 12, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток37', 271, 'вода газированная, кокосовый ликер, текила', 25, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток38', 424, 'вода газированная, спрайт, сливки, темное пиво, абсент, игристое вино', 38, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток39', 418, 'кокосовое молоко, тоник, ванильное мороженое, игристое вино', 18, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток40', 384, 'лед, сахарный сироп, сливочный ликер, светлое пиво, персиковый ликер, кофейный ликер', 23, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток41', 327, 'кола, кола, сахарный сироп, красный вермут, абсент, темное пиво, джин', 10, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток42', 302, 'пюре черной смородины, лимончелло, самбука, кокосовый ликер, белое вино', 17, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток43', 441, 'сок сельдерея, текила, ром, белое вино, игристое вино', 39, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток44', 247, 'ананасовый сок, коньяк', 21, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток45', 273, 'ванильное мороженое, сироп малиновый, клюквенный морс, игристое вино', 34, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток46', 248, 'лимонный сок, вода газированная, белое вино, темное пиво, абсент', 25, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток47', 279, 'лимонный сок, дынный ликер, игристое вино, лимончелло, сливочный ликер', 34, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток48', 322, 'томаный сок, вода газированная, сироп малиновый, апельсиновый сок, игристое вино, кофейный ликер, темное пиво, белый вермут', 26, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток49', 209, 'лимонный сок, гренадин, клюквенный морс, абсент', 13, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток50', 378, 'сок лайма, коньяк, темное пиво, кокосовый ликер, виски', 29, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток51', 435, 'вишневый сок, лимонный сок, дынный ликер, белый вермут', 35, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток52', 279, 'гренадин, энергетик, ананасовый сок, гренадин, апельсиновый ликер, виски, красный вермут, кокосовый ликер', 23, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток53', 380, 'сироп малиновый, персиковый ликер', 38, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток54', 203, 'сок лайма, кокосовое молоко, тоник, сахарный сироп, текила, самбука, дынный ликер', 15, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток55', 450, 'сахарный сироп, лед, персиковый ликер', 39, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток56', 310, 'энергетик, пюре черной смородины, тоник, сливки, светлое пиво', 18, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток57', 153, 'клюквенный морс, гренадин, вода газированная, белый вермут, кофейный ликер, темное пиво, красное вино', 23, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток58', 380, 'вода газированная, томаный сок, клюквенный морс, кофейный ликер, красный вермут, абсент, кокосовый ликер', 9, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток59', 394, 'клюквенный морс, тоник, апельсиновый сок, виски, кофейный ликер, виски', 30, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток60', 323, 'ванильное мороженое, сок сельдерея, пюре черной смородины, джин, игристое вино, абсент', 32, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток61', 317, 'тоник, вишневый сок, белый вермут, коньяк, коньяк', 23, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток62', 340, 'сахарный сироп, апельсиновый ликер, дынный ликер', 5, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток63', 294, 'ананасовый сок, светлое пиво', 40, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток64', 355, 'лед, кокосовое молоко, кола, лимончелло, коньяк, виски', 19, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток65', 251, 'апельсиновый сок, сахарный сироп, вишневый сок, томаный сок, светлое пиво, темное пиво, лимончелло, сливочный ликер', 10, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток66', 393, 'сахарный сироп, вода газированная, светлое пиво, ром', 37, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток67', 248, 'сироп малиновый, клюквенный морс, гренадин, персиковый ликер, текила', 31, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток68', 152, 'спрайт, ром, белое вино, игристое вино, красный вермут', 12, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток69', 452, 'лед, энергетик, персиковый ликер, самбука, апельсиновый ликер, кокосовый ликер', 30, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток70', 205, 'сахарный сироп, кофейный ликер', 38, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток71', 351, 'сахарный сироп, сливки, игристое вино, персиковый ликер, белый вермут, коньяк', 22, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток72', 406, 'пюре черной смородины, пюре черной смородины, вишневый сок, ванильное мороженое, розовое вино, светлое пиво, темное пиво, лимончелло', 25, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток73', 407, 'ванильное мороженое, кола, коньяк, абсент, текила', 23, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток74', 354, 'сахарный сироп, пюре черной смородины, коньяк, белое вино, текила', 25, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток75', 387, 'лед, энергетик, коньяк, сливочный ликер, коньяк, лимончелло', 19, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток76', 201, 'сок лайма, ром, игристое вино, белое вино', 19, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток77', 222, 'гренадин, розовое вино, текила', 34, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток78', 483, 'спрайт, лед, дынный ликер, виски, белый вермут, кокосовый ликер', 7, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток79', 191, 'апельсиновый сок, сок лайма, ананасовый сок, кокосовый ликер, белое вино, самбука', 39, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток80', 476, 'энергетик, спрайт, коньяк, текила, сливочный ликер, темное пиво', 15, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток81', 357, 'томаный сок, сок сельдерея, сливки, апельсиновый ликер', 16, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток82', 237, 'клюквенный морс, персиковый ликер', 40, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток83', 199, 'сироп малиновый, тоник, текила, лимончелло, светлое пиво', 37, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток84', 233, 'гренадин, вишневый сок, апельсиновый сок, ванильное мороженое, светлое пиво, красное вино, лимончелло, персиковый ликер', 17, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток85', 187, 'энергетик, пюре черной смородины, сливки, самбука, темное пиво', 36, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток86', 201, 'сироп малиновый, сахарный сироп, тоник, кокосовый ликер, розовое вино, красный вермут', 30, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток87', 446, 'ванильное мороженое, сироп малиновый, лимончелло', 6, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток88', 293, 'томаный сок, энергетик, розовое вино, светлое пиво', 38, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток89', 202, 'сок сельдерея, красный вермут', 32, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток90', 151, 'вишневый сок, коньяк, апельсиновый ликер, кокосовый ликер, светлое пиво', 14, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток91', 411, 'томаный сок, сок сельдерея, сок лайма, кола, светлое пиво, дынный ликер, персиковый ликер, самбука', 19, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток92', 347, 'лед, кокосовое молоко, вишневый сок, персиковый ликер, сливочный ликер', 36, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток93', 231, 'ванильное мороженое, сахарный сироп, сливочный ликер', 14, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток94', 267, 'вишневый сок, розовое вино, игристое вино, текила', 9, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток95', 306, 'пюре черной смородины, апельсиновый сок, гренадин, сок сельдерея, водка, коньяк', 15, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток96', 423, 'лед, сок лайма, сок лайма, кокосовое молоко, белый вермут, белое вино, кокосовый ликер', 30, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток97', 426, 'кокосовое молоко, сироп малиновый, апельсиновый сок, апельсиновый сок, виски, кокосовый ликер', 27, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток98', 361, 'вода газированная, томаный сок, гренадин, красный вермут, кофейный ликер, абсент, белый вермут', 29, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток99', 468, 'ананасовый сок, кола, игристое вино, темное пиво, персиковый ликер, игристое вино', 39, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток100', 313, 'томаный сок, томаный сок, текила', 30, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток101', 306, 'гренадин, красный вермут', 11, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток102', 445, 'ванильное мороженое, ананасовый сок, белый вермут, кокосовый ликер', 27, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток103', 226, 'лед, кола, сахарный сироп, белый вермут, красный вермут, лимончелло', 12, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток104', 462, 'кокосовое молоко, сок лайма, лимонный сок, вода газированная, коньяк', 35, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток105', 379, 'вода газированная, ананасовый сок, ром, белое вино', 5, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток106', 238, 'апельсиновый сок, ром, красный вермут, ром, лимончелло', 26, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток107', 176, 'пюре черной смородины, энергетик, ванильное мороженое, игристое вино, сливочный ликер, водка, лимончелло', 5, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток108', 460, 'кокосовое молоко, томаный сок, томаный сок, светлое пиво, розовое вино', 13, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток109', 397, 'ванильное мороженое, кокосовое молоко, сливочный ликер, розовое вино', 8, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток110', 262, 'тоник, кола, гренадин, красный вермут, кофейный ликер', 30, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток111', 321, 'кола, спрайт, гренадин, персиковый ликер, виски', 31, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток112', 248, 'сахарный сироп, сливочный ликер', 30, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток113', 161, 'сливки, кола, томаный сок, самбука, самбука', 18, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток157', 160, 'апельсиновый сок, лед, сок сельдерея, вишневый сок, кокосовый ликер', 11, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток114', 203, 'лед, сливки, тоник, томаный сок, кокосовый ликер, персиковый ликер, белый вермут, персиковый ликер', 40, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток115', 439, 'лимонный сок, томаный сок, энергетик, джин, апельсиновый ликер', 14, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток116', 476, 'вода газированная, текила, лимончелло', 21, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток117', 274, 'сироп малиновый, апельсиновый ликер', 31, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток118', 424, 'вишневый сок, кокосовое молоко, кола, коньяк, водка, кокосовый ликер, лимончелло', 32, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток119', 317, 'апельсиновый сок, сок лайма, белый вермут', 25, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток120', 196, 'вишневый сок, джин', 11, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток121', 306, 'энергетик, лимонный сок, лед, энергетик, красный вермут, светлое пиво, виски, текила', 25, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток122', 245, 'вишневый сок, сок сельдерея, сливки, вода газированная, светлое пиво', 29, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток123', 423, 'апельсиновый сок, сахарный сироп, белый вермут, кофейный ликер, красный вермут', 24, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток124', 296, 'сливки, вишневый сок, текила, абсент, белое вино', 38, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток125', 235, 'кокосовое молоко, ананасовый сок, апельсиновый сок, тоник, темное пиво, темное пиво, белое вино, красный вермут', 22, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток126', 186, 'ванильное мороженое, лед, кофейный ликер', 33, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток127', 409, 'вишневый сок, апельсиновый сок, джин, абсент', 40, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток128', 265, 'клюквенный морс, сливки, коньяк, виски, красный вермут, джин', 40, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток129', 486, 'клюквенный морс, томаный сок, белый вермут, коньяк, розовое вино, виски', 13, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток130', 467, 'гренадин, кола, вишневый сок, энергетик, игристое вино', 29, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток131', 255, 'вишневый сок, сок лайма, сливочный ликер', 37, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток132', 380, 'сок сельдерея, кокосовое молоко, лед, гренадин, абсент, темное пиво, водка, джин', 13, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток133', 255, 'кола, сливочный ликер, джин, красный вермут', 8, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток134', 175, 'вишневый сок, вишневый сок, кола, ванильное мороженое, кофейный ликер, красный вермут', 28, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток135', 489, 'сахарный сироп, ром', 22, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток136', 496, 'пюре черной смородины, персиковый ликер, красное вино, персиковый ликер, персиковый ликер', 22, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток137', 275, 'ванильное мороженое, сироп малиновый, кола, гренадин, виски, абсент, кокосовый ликер', 13, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток138', 482, 'тоник, энергетик, ром, светлое пиво, ром, белое вино', 20, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток139', 278, 'ванильное мороженое, ананасовый сок, ванильное мороженое, клюквенный морс, дынный ликер', 27, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток140', 333, 'пюре черной смородины, кокосовый ликер', 23, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток141', 210, 'вода газированная, сливочный ликер, светлое пиво, красное вино', 10, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток142', 224, 'сироп малиновый, вишневый сок, белое вино, белый вермут, кофейный ликер', 30, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток143', 229, 'вишневый сок, лимонный сок, сок сельдерея, джин, белое вино, ром', 10, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток144', 462, 'клюквенный морс, сок сельдерея, белый вермут', 25, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток145', 264, 'апельсиновый сок, ванильное мороженое, ванильное мороженое, тоник, темное пиво', 18, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток146', 468, 'спрайт, вишневый сок, пюре черной смородины, сливочный ликер, коньяк, персиковый ликер', 18, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток147', 284, 'пюре черной смородины, томаный сок, игристое вино', 35, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток148', 479, 'томаный сок, белый вермут, темное пиво', 40, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток149', 200, 'сироп малиновый, водка, абсент, кофейный ликер, ром', 12, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток150', 422, 'лед, красное вино, белый вермут, красный вермут, дынный ликер', 5, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток151', 280, 'сок лайма, гренадин, абсент, белое вино, виски', 23, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток152', 268, 'кола, кокосовый ликер, сливочный ликер', 6, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток153', 481, 'вода газированная, красное вино, белый вермут', 18, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток154', 162, 'сок лайма, ванильное мороженое, абсент, персиковый ликер', 37, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток155', 157, 'гренадин, томаный сок, сок лайма, сливки, красное вино, самбука, темное пиво', 6, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток156', 405, 'сок лайма, дынный ликер, джин, светлое пиво, текила', 8, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток158', 350, 'клюквенный морс, тоник, текила, самбука, белый вермут', 23, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток159', 468, 'ананасовый сок, сливки, вода газированная, кокосовое молоко, джин, ром, сливочный ликер', 16, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток160', 369, 'клюквенный морс, апельсиновый ликер, ром', 20, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток161', 407, 'кокосовое молоко, ром, сливочный ликер, персиковый ликер, водка', 37, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток162', 247, 'вода газированная, самбука', 33, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток163', 269, 'лимонный сок, ванильное мороженое, сливочный ликер, коньяк', 22, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток164', 369, 'вишневый сок, виски, дынный ликер, водка, красный вермут', 22, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток165', 174, 'сахарный сироп, лимончелло', 28, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток166', 209, 'клюквенный морс, сок лайма, лимончелло, темное пиво, красный вермут, лимончелло', 11, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток167', 433, 'сироп малиновый, лимонный сок, текила, коньяк, игристое вино, красное вино', 36, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток168', 440, 'лимонный сок, кокосовое молоко, ром, красный вермут', 20, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток169', 498, 'гренадин, лимончелло', 8, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток170', 307, 'ананасовый сок, водка', 30, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток171', 387, 'апельсиновый сок, сливки, пюре черной смородины, абсент, красный вермут, апельсиновый ликер', 28, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток172', 344, 'сахарный сироп, сахарный сироп, красное вино, коньяк, игристое вино, темное пиво', 18, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток173', 495, 'сливки, пюре черной смородины, сахарный сироп, сироп малиновый, игристое вино, водка, коньяк, персиковый ликер', 6, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток174', 217, 'сок лайма, томаный сок, белый вермут, абсент, кофейный ликер, лимончелло', 37, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток175', 366, 'спрайт, тоник, лед, сливочный ликер, апельсиновый ликер', 21, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток176', 347, 'энергетик, абсент, кокосовый ликер', 32, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток177', 464, 'кокосовое молоко, лимонный сок, вода газированная, кокосовое молоко, ром, темное пиво, виски, коньяк', 24, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток178', 376, 'сахарный сироп, кола, спрайт, сахарный сироп, абсент', 21, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток179', 407, 'клюквенный морс, вишневый сок, кофейный ликер, апельсиновый ликер, лимончелло', 39, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток180', 288, 'кола, виски, дынный ликер, водка, красный вермут', 5, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток181', 330, 'кола, гренадин, джин', 19, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток182', 261, 'тоник, сливки, джин, апельсиновый ликер, ром, кокосовый ликер', 23, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток183', 219, 'ванильное мороженое, энергетик, сливки, джин, дынный ликер', 11, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток184', 427, 'ванильное мороженое, гренадин, лимонный сок, ананасовый сок, белое вино', 7, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток185', 477, 'ананасовый сок, вишневый сок, сок лайма, ананасовый сок, джин, виски, апельсиновый ликер', 12, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток186', 475, 'тоник, ванильное мороженое, томаный сок, кофейный ликер', 11, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток187', 281, 'клюквенный морс, вишневый сок, клюквенный морс, вода газированная, виски', 17, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток188', 485, 'тоник, гренадин, ванильное мороженое, самбука, светлое пиво, виски', 7, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток189', 380, 'вода газированная, сок сельдерея, спрайт, сливочный ликер, сливочный ликер, темное пиво', 7, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток190', 377, 'кола, красное вино, виски, персиковый ликер', 33, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток191', 242, 'вишневый сок, ванильное мороженое, ванильное мороженое, лимонный сок, светлое пиво', 27, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток192', 241, 'клюквенный морс, сок лайма, апельсиновый ликер, лимончелло, белое вино', 32, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток193', 282, 'тоник, апельсиновый ликер, водка, красное вино', 23, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток194', 303, 'кола, персиковый ликер, белый вермут, сливочный ликер', 38, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток195', 406, 'апельсиновый сок, лимонный сок, лед, самбука', 21, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток196', 171, 'томаный сок, лед, кокосовый ликер, розовое вино', 33, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток197', 205, 'вишневый сок, ананасовый сок, апельсиновый сок, красный вермут', 27, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток198', 178, 'ананасовый сок, лед, клюквенный морс, томаный сок, темное пиво, абсент, кокосовый ликер, красный вермут', 22, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток199', 250, 'лед, лимонный сок, тоник, лед, коньяк, кофейный ликер, лимончелло', 17, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток201', 253, 'сливки, вишневый сок, ром, красное вино, коньяк', 29, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток202', 276, 'апельсиновый сок, вишневый сок, абсент', 13, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток203', 442, 'ананасовый сок, лед, томаный сок, сахарный сироп, ром', 8, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток204', 403, 'спрайт, спрайт, клюквенный морс, красный вермут, апельсиновый ликер, самбука, красный вермут', 34, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток205', 171, 'вишневый сок, тоник, текила, белое вино, сливочный ликер, ром', 28, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток206', 343, 'лед, томаный сок, виски, розовое вино', 33, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток207', 286, 'кокосовое молоко, томаный сок, розовое вино, самбука, кофейный ликер, розовое вино', 32, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток208', 240, 'кола, сахарный сироп, красный вермут, апельсиновый ликер', 20, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток209', 234, 'кола, сок лайма, сок сельдерея, пюре черной смородины, лимончелло, кофейный ликер, ром, водка', 11, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток210', 180, 'сок сельдерея, темное пиво, абсент, светлое пиво, белое вино', 29, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток211', 271, 'вишневый сок, клюквенный морс, светлое пиво, темное пиво, кокосовый ликер, светлое пиво', 27, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток212', 430, 'спрайт, кола, сироп малиновый, водка, дынный ликер', 10, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток213', 221, 'сливки, пюре черной смородины, розовое вино, кофейный ликер, светлое пиво, красный вермут', 35, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток214', 458, 'ванильное мороженое, персиковый ликер, красный вермут', 12, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток215', 164, 'энергетик, сок сельдерея, лед, сок лайма, розовое вино, лимончелло', 23, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток216', 242, 'лед, кола, светлое пиво', 25, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток217', 181, 'ванильное мороженое, энергетик, сок сельдерея, ананасовый сок, текила', 12, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток218', 254, 'лед, ананасовый сок, кола, ром, светлое пиво', 19, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток219', 217, 'сахарный сироп, кокосовое молоко, энергетик, водка, игристое вино, белое вино, абсент', 10, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток220', 427, 'кокосовое молоко, пюре черной смородины, виски, коньяк, персиковый ликер', 22, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток221', 465, 'сливки, апельсиновый сок, темное пиво, водка', 25, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток222', 405, 'лед, ананасовый сок, гренадин, сахарный сироп, игристое вино, красное вино', 22, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток223', 159, 'спрайт, апельсиновый сок, ванильное мороженое, тоник, дынный ликер, игристое вино, белый вермут', 12, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток224', 412, 'сок лайма, ванильное мороженое, водка', 15, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток225', 236, 'ананасовый сок, тоник, ананасовый сок, белое вино, текила, красный вермут, апельсиновый ликер', 10, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток226', 339, 'сироп малиновый, вода газированная, игристое вино', 40, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток227', 311, 'ананасовый сок, сок сельдерея, сливочный ликер, белый вермут', 11, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток228', 345, 'лимонный сок, самбука', 8, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток229', 204, 'ананасовый сок, пюре черной смородины, клюквенный морс, джин, светлое пиво, светлое пиво', 30, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток230', 192, 'энергетик, энергетик, пюре черной смородины, лимонный сок, виски, игристое вино, абсент, светлое пиво', 9, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток231', 176, 'сироп малиновый, кофейный ликер, текила, красное вино', 9, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток232', 451, 'кола, лимончелло, коньяк, апельсиновый ликер', 15, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток233', 433, 'сироп малиновый, апельсиновый сок, джин, апельсиновый ликер', 33, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток234', 484, 'ванильное мороженое, клюквенный морс, спрайт, абсент, текила', 39, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток235', 445, 'энергетик, текила, водка', 29, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток236', 150, 'сахарный сироп, светлое пиво, текила, игристое вино, кофейный ликер', 24, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток237', 243, 'лимонный сок, ананасовый сок, игристое вино', 20, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток238', 414, 'кокосовое молоко, апельсиновый сок, кокосовое молоко, пюре черной смородины, лимончелло, сливочный ликер, апельсиновый ликер, сливочный ликер', 39, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток239', 351, 'тоник, ванильное мороженое, кофейный ликер, самбука, ром', 13, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток240', 242, 'ананасовый сок, белое вино, кокосовый ликер, ром', 22, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток241', 421, 'гренадин, пюре черной смородины, кола, сахарный сироп, джин, светлое пиво', 15, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток242', 405, 'сок сельдерея, апельсиновый сок, апельсиновый сок, ванильное мороженое, красное вино, красное вино, водка, водка', 30, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток243', 354, 'сироп малиновый, лед, сливки, красный вермут', 35, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток244', 181, 'энергетик, сливки, самбука, текила, виски', 8, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток245', 158, 'кокосовое молоко, ананасовый сок, розовое вино, виски, дынный ликер', 32, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток246', 190, 'сок лайма, сироп малиновый, сливочный ликер, темное пиво', 6, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток247', 251, 'кокосовое молоко, кокосовое молоко, сливки, кокосовое молоко, апельсиновый ликер', 32, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток248', 334, 'кола, самбука, сливочный ликер', 38, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток249', 164, 'ванильное мороженое, водка, белый вермут, белый вермут, водка', 31, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток250', 169, 'лимонный сок, пюре черной смородины, вода газированная, тоник, белый вермут, кофейный ликер', 15, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток251', 371, 'гренадин, кола, сок лайма, ром, белое вино', 9, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток252', 425, 'сахарный сироп, персиковый ликер, сливочный ликер, темное пиво, светлое пиво', 36, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток253', 253, 'сироп малиновый, клюквенный морс, персиковый ликер, ром, самбука', 24, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток254', 498, 'лед, сок лайма, лед, спрайт, красный вермут', 27, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток255', 257, 'лед, вишневый сок, энергетик, коньяк', 17, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток256', 208, 'кокосовое молоко, сахарный сироп, розовое вино', 35, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток257', 312, 'сироп малиновый, джин, апельсиновый ликер', 19, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток258', 485, 'апельсиновый сок, лед, вода газированная, кофейный ликер, виски', 18, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток259', 266, 'сироп малиновый, водка', 34, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток260', 471, 'вишневый сок, светлое пиво, красный вермут', 29, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток261', 399, 'пюре черной смородины, сливки, сливочный ликер, абсент', 12, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток262', 236, 'ванильное мороженое, абсент', 32, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток263', 456, 'лед, лимонный сок, сироп малиновый, виски, ром, абсент', 33, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток264', 217, 'пюре черной смородины, персиковый ликер', 16, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток265', 288, 'тоник, сок лайма, сливки, сок лайма, дынный ликер', 37, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток266', 280, 'сироп малиновый, сок лайма, апельсиновый сок, персиковый ликер', 21, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток267', 242, 'спрайт, джин, красное вино', 5, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток268', 223, 'сок лайма, сахарный сироп, томаный сок, абсент, красный вермут', 38, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток269', 378, 'спрайт, лед, тоник, лимончелло, красное вино', 38, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток270', 260, 'апельсиновый сок, сок лайма, красное вино', 22, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток271', 279, 'лед, сок сельдерея, текила, красное вино, кофейный ликер', 38, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток272', 159, 'тоник, кола, белый вермут, виски', 38, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток273', 393, 'гренадин, лимонный сок, розовое вино, самбука, коньяк, водка', 34, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток274', 472, 'спрайт, пюре черной смородины, вода газированная, пюре черной смородины, белое вино, коньяк', 18, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток275', 211, 'клюквенный морс, самбука', 15, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток276', 255, 'томаный сок, ананасовый сок, сливки, спрайт, красный вермут, дынный ликер, текила, водка', 38, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток277', 497, 'ананасовый сок, томаный сок, сок сельдерея, вишневый сок, текила, кофейный ликер', 9, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток278', 180, 'кола, тоник, вишневый сок, игристое вино', 23, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток279', 414, 'энергетик, лед, сливки, лимонный сок, светлое пиво, персиковый ликер, светлое пиво, водка', 21, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток280', 242, 'клюквенный морс, пюре черной смородины, клюквенный морс, вода газированная, дынный ликер, кофейный ликер, темное пиво, водка', 28, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток281', 299, 'кокосовое молоко, кокосовое молоко, сливки, кокосовый ликер, белый вермут, текила, ром', 15, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток282', 484, 'гренадин, гренадин, кола, текила, текила, темное пиво, джин', 34, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток283', 241, 'апельсиновый сок, ананасовый сок, тоник, джин, персиковый ликер, ром, кокосовый ликер', 39, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток284', 284, 'вишневый сок, ром', 13, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток285', 385, 'пюре черной смородины, апельсиновый сок, розовое вино', 33, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток286', 305, 'сок лайма, сок сельдерея, текила', 10, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток287', 353, 'ванильное мороженое, вишневый сок, сливки, самбука, кофейный ликер, светлое пиво', 5, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток288', 293, 'сок лайма, апельсиновый сок, апельсиновый сок, самбука, лимончелло, белое вино, джин', 7, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток289', 324, 'клюквенный морс, спрайт, вишневый сок, клюквенный морс, розовое вино, темное пиво, красное вино', 17, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток290', 308, 'кола, гренадин, клюквенный морс, лимончелло, коньяк, текила, белый вермут', 13, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток291', 300, 'вода газированная, пюре черной смородины, томаный сок, спрайт, кокосовый ликер, лимончелло', 27, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток292', 207, 'клюквенный морс, пюре черной смородины, вода газированная, самбука, ром, красный вермут, дынный ликер', 35, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток293', 381, 'кола, апельсиновый сок, джин, текила, сливочный ликер', 11, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток294', 310, 'вода газированная, сок лайма, сок лайма, сливочный ликер, кокосовый ликер, коньяк', 11, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток295', 467, 'лимонный сок, сок сельдерея, сахарный сироп, текила', 12, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток296', 309, 'сахарный сироп, кола, игристое вино, игристое вино, сливочный ликер, виски', 28, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток297', 185, 'гренадин, светлое пиво, самбука, водка', 32, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток298', 326, 'сок лайма, сироп малиновый, лимонный сок, сливки, кофейный ликер, ром', 28, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток299', 262, 'вишневый сок, ванильное мороженое, тоник, сливки, ром, апельсиновый ликер, белое вино, дынный ликер', 16, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток300', 285, 'пюре черной смородины, белый вермут, белое вино, ром', 30, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток301', 150, 'томаный сок, тоник, томаный сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток302', 258, 'вода газированная, апельсиновый сок, вишневый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток303', 455, 'энергетик, кокосовое молоко, спрайт, кокосовое молоко, сок лайма', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток304', 161, 'сок сельдерея, апельсиновый сок, ананасовый сок, ванильное мороженое', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток305', 151, 'сливки, вишневый сок, апельсиновый сок, ананасовый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток306', 288, 'сироп малиновый, пюре черной смородины, лимонный сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток307', 194, 'сироп малиновый, сок лайма, спрайт', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток308', 317, 'кокосовое молоко, гренадин, томаный сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток309', 176, 'тоник, тоник, апельсиновый сок, гренадин, пюре черной смородины', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток310', 169, 'вода газированная, пюре черной смородины, кола', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток311', 366, 'гренадин, томаный сок, лимонный сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток312', 312, 'пюре черной смородины, томаный сок, ананасовый сок, кокосовое молоко', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток313', 303, 'сливки, клюквенный морс, сок сельдерея, сок сельдерея, ананасовый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток314', 221, 'сок сельдерея, вода газированная, вишневый сок, лед', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток315', 477, 'вишневый сок, тоник', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток316', 442, 'сок лайма, сок сельдерея, кола', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток317', 484, 'ванильное мороженое, ананасовый сок, сахарный сироп, вишневый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток318', 179, 'пюре черной смородины, апельсиновый сок, сок сельдерея, кокосовое молоко, сок сельдерея', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток319', 455, 'пюре черной смородины, кокосовое молоко', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток320', 497, 'тоник, ананасовый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток321', 188, 'ванильное мороженое, вода газированная', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток322', 233, 'кола, гренадин, ананасовый сок, сок лайма', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток323', 205, 'лимонный сок, клюквенный морс, гренадин', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток324', 259, 'тоник, лед', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток325', 371, 'сахарный сироп, томаный сок, сок сельдерея, кокосовое молоко, ванильное мороженое', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток326', 407, 'ананасовый сок, ванильное мороженое, томаный сок, спрайт', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток327', 180, 'кола, сахарный сироп', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток328', 303, 'ананасовый сок, кокосовое молоко, сахарный сироп', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток329', 318, 'сахарный сироп, тоник, сироп малиновый, сливки', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток379', 302, 'кола, спрайт, клюквенный морс', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток330', 311, 'вода газированная, сок сельдерея, кола, кокосовое молоко', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток331', 174, 'вода газированная, апельсиновый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток332', 319, 'энергетик, гренадин, сок сельдерея', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток333', 302, 'томаный сок, спрайт, гренадин, энергетик, лед', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток334', 358, 'сироп малиновый, кола, пюре черной смородины', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток335', 307, 'ананасовый сок, апельсиновый сок, сироп малиновый', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток336', 288, 'сок сельдерея, ванильное мороженое', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток337', 496, 'лед, тоник, ананасовый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток338', 183, 'кола, клюквенный морс, лед, кокосовое молоко', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток339', 289, 'кокосовое молоко, ананасовый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток340', 316, 'ванильное мороженое, сироп малиновый, пюре черной смородины, лимонный сок, сок сельдерея', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток341', 171, 'сахарный сироп, сок сельдерея, апельсиновый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток342', 305, 'гренадин, сливки', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток343', 432, 'апельсиновый сок, лимонный сок, ванильное мороженое', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток344', 449, 'ванильное мороженое, тоник, сахарный сироп, кола', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток345', 349, 'тоник, клюквенный морс, лед, лед, вода газированная', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток346', 198, 'пюре черной смородины, гренадин, томаный сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток347', 267, 'сок лайма, гренадин, гренадин, сок сельдерея, спрайт', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток348', 264, 'клюквенный морс, пюре черной смородины, лимонный сок, томаный сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток349', 291, 'вишневый сок, лимонный сок, сок лайма, кола', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток350', 292, 'вода газированная, сок лайма', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток351', 392, 'лед, клюквенный морс, вода газированная, сок сельдерея', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток352', 263, 'гренадин, сироп малиновый, апельсиновый сок, спрайт', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток353', 210, 'вишневый сок, лимонный сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток354', 238, 'сок лайма, энергетик, лимонный сок, сок лайма, сливки', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток355', 421, 'кокосовое молоко, кола, ванильное мороженое, сироп малиновый', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток356', 317, 'сок лайма, лед, томаный сок, сахарный сироп', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток357', 396, 'энергетик, энергетик, сливки, спрайт', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток358', 189, 'сок лайма, вишневый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток359', 466, 'гренадин, кола', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток360', 322, 'сироп малиновый, клюквенный морс, сок лайма, лед, сливки', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток361', 288, 'лимонный сок, спрайт', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток362', 325, 'пюре черной смородины, томаный сок, энергетик, лед, кокосовое молоко', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток363', 335, 'вишневый сок, кокосовое молоко, спрайт, энергетик, кола', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток364', 325, 'вишневый сок, сироп малиновый', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток365', 481, 'клюквенный морс, тоник, апельсиновый сок, ванильное мороженое, лед', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток366', 297, 'вишневый сок, гренадин, энергетик, лимонный сок, томаный сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток367', 466, 'ванильное мороженое, вишневый сок, томаный сок, пюре черной смородины', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток368', 316, 'сок лайма, томаный сок, энергетик, спрайт, томаный сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток369', 167, 'гренадин, сахарный сироп, тоник', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток370', 494, 'клюквенный морс, лимонный сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток371', 230, 'энергетик, кокосовое молоко, спрайт, гренадин, сахарный сироп', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток372', 394, 'пюре черной смородины, вода газированная, тоник', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток373', 414, 'вишневый сок, энергетик, апельсиновый сок, лимонный сок, ананасовый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток374', 264, 'томаный сок, ананасовый сок, гренадин, сок лайма, ананасовый сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток375', 259, 'ванильное мороженое, лед, сливки, сок лайма', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток376', 361, 'апельсиновый сок, кола, кокосовое молоко', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток377', 239, 'сироп малиновый, энергетик, апельсиновый сок, тоник', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток378', 213, 'энергетик, сахарный сироп, сок лайма', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток380', 326, 'энергетик, тоник, сахарный сироп, сахарный сироп, сироп малиновый', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток381', 220, 'лимонный сок, пюре черной смородины, тоник, ванильное мороженое', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток382', 392, 'спрайт, вода газированная, сироп малиновый, спрайт, кокосовое молоко', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток383', 469, 'вода газированная, сливки', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток384', 408, 'пюре черной смородины, клюквенный морс, сок лайма, вишневый сок, вода газированная', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток385', 498, 'энергетик, сливки, сок сельдерея', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток386', 420, 'томаный сок, сливки, сок лайма', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток387', 255, 'ананасовый сок, сливки, кокосовое молоко, гренадин', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток388', 303, 'ананасовый сок, ванильное мороженое', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток389', 205, 'вишневый сок, кокосовое молоко, сок лайма, вода газированная', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток390', 405, 'ванильное мороженое, сливки, вода газированная', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток391', 440, 'клюквенный морс, сахарный сироп', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток392', 297, 'томаный сок, кола, лед, пюре черной смородины, пюре черной смородины', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток393', 279, 'спрайт, сахарный сироп', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток394', 492, 'энергетик, сок лайма, ванильное мороженое', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток395', 493, 'энергетик, сливки', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток396', 334, 'сахарный сироп, пюре черной смородины, спрайт, гренадин', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток397', 292, 'вишневый сок, спрайт, лед, сок сельдерея', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток398', 330, 'сироп малиновый, клюквенный морс', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток399', 482, 'сок лайма, сок лайма', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток400', 351, 'кола, тоник, вода газированная', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток401', 385, 'энергетик, сливки, вишневый сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток402', 422, 'сок сельдерея, сливки, кола', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток403', 483, 'ананасовый сок, гренадин, вода газированная, вишневый сок, сливки', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток404', 210, 'спрайт, пюре черной смородины', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток405', 302, 'вода газированная, ванильное мороженое, кокосовое молоко', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток406', 406, 'кокосовое молоко, спрайт', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток407', 193, 'сироп малиновый, томаный сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток408', 196, 'сок сельдерея, спрайт, ананасовый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток409', 155, 'кола, сок сельдерея, клюквенный морс, лимонный сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток410', 227, 'кола, сливки', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток411', 453, 'клюквенный морс, вода газированная, сливки, сливки', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток412', 281, 'вода газированная, кола, сок лайма, кокосовое молоко', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток413', 193, 'апельсиновый сок, сок сельдерея', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток414', 340, 'ананасовый сок, лимонный сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток415', 305, 'кола, пюре черной смородины', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток416', 229, 'кола, лед, клюквенный морс, вишневый сок, ванильное мороженое', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток417', 189, 'сок сельдерея, сок сельдерея, кола', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток418', 392, 'гренадин, кокосовое молоко, кокосовое молоко, сироп малиновый', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток419', 227, 'сок лайма, тоник, вишневый сок, клюквенный морс, сок сельдерея', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток420', 249, 'сок лайма, апельсиновый сок, пюре черной смородины', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток421', 368, 'апельсиновый сок, сок сельдерея, гренадин', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток422', 266, 'кола, тоник, ананасовый сок, спрайт, сок сельдерея', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток423', 331, 'спрайт, вода газированная, спрайт, пюре черной смородины, тоник', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток424', 400, 'сахарный сироп, вишневый сок, сок сельдерея, томаный сок, вишневый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток425', 220, 'сахарный сироп, спрайт, ванильное мороженое, тоник, спрайт', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток426', 439, 'сливки, сливки', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток427', 188, 'сок сельдерея, кокосовое молоко, энергетик, томаный сок, клюквенный морс', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток428', 365, 'ананасовый сок, лимонный сок, апельсиновый сок, пюре черной смородины', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток429', 469, 'ванильное мороженое, вода газированная, кола', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток430', 172, 'тоник, сахарный сироп, гренадин, сахарный сироп, лед', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток431', 363, 'сок сельдерея, вода газированная, энергетик', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток432', 290, 'вишневый сок, тоник', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток433', 209, 'кокосовое молоко, апельсиновый сок, гренадин, клюквенный морс', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток434', 397, 'кола, лимонный сок, ванильное мороженое, кокосовое молоко', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток435', 227, 'энергетик, сироп малиновый', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток436', 444, 'сок лайма, сок лайма, сахарный сироп', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток437', 166, 'томаный сок, кола, клюквенный морс, томаный сок, гренадин', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток438', 271, 'лед, тоник, сахарный сироп, лимонный сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток439', 221, 'сироп малиновый, сок лайма, лимонный сок, сироп малиновый', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток440', 323, 'вишневый сок, лед', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток441', 263, 'томаный сок, ванильное мороженое, кокосовое молоко, сок сельдерея, вода газированная', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток442', 312, 'вишневый сок, вода газированная, энергетик, вода газированная, ванильное мороженое', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток443', 308, 'кола, энергетик', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток444', 390, 'сок сельдерея, лимонный сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток445', 393, 'апельсиновый сок, томаный сок, спрайт, гренадин', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток446', 436, 'сливки, энергетик, лимонный сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток447', 450, 'вода газированная, энергетик, сок сельдерея, ананасовый сок, сахарный сироп', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток448', 192, 'ванильное мороженое, сок сельдерея, лед, сок лайма, спрайт', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток449', 221, 'ванильное мороженое, вода газированная', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток450', 248, 'вода газированная, апельсиновый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток451', 242, 'вода газированная, пюре черной смородины', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток452', 328, 'вишневый сок, пюре черной смородины', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток453', 183, 'вода газированная, спрайт, сироп малиновый, энергетик, лед', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток454', 246, 'сок сельдерея, энергетик', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток455', 444, 'лед, пюре черной смородины, сахарный сироп, ванильное мороженое', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток456', 369, 'кола, сок лайма, клюквенный морс', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток457', 279, 'энергетик, пюре черной смородины', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток458', 333, 'сок сельдерея, ванильное мороженое, ванильное мороженое, томаный сок, апельсиновый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток459', 450, 'кола, тоник, сахарный сироп, энергетик, кола', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток460', 356, 'сок лайма, кокосовое молоко, сливки, лимонный сок, ванильное мороженое', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток461', 212, 'сироп малиновый, сахарный сироп, вишневый сок, пюре черной смородины, клюквенный морс', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток462', 298, 'ананасовый сок, вода газированная, сироп малиновый, ванильное мороженое, апельсиновый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток463', 471, 'спрайт, тоник, пюре черной смородины, лед, кола', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток464', 289, 'пюре черной смородины, кокосовое молоко, сахарный сироп, кокосовое молоко', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток465', 437, 'сок сельдерея, сахарный сироп, сок лайма, спрайт, клюквенный морс', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток466', 456, 'томаный сок, сок сельдерея, сок лайма, ванильное мороженое, тоник', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток467', 420, 'кокосовое молоко, кокосовое молоко, ананасовый сок, спрайт', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток468', 344, 'сахарный сироп, лимонный сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток469', 379, 'сироп малиновый, тоник, тоник, клюквенный морс', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток470', 346, 'пюре черной смородины, апельсиновый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток471', 334, 'энергетик, сливки, томаный сок, апельсиновый сок, сахарный сироп', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток472', 328, 'кола, лед, томаный сок, тоник', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток473', 401, 'сок сельдерея, пюре черной смородины, ананасовый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток474', 487, 'спрайт, сливки, сок лайма', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток475', 195, 'лимонный сок, вода газированная', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток476', 485, 'сахарный сироп, лимонный сок, сахарный сироп', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток477', 239, 'лимонный сок, кола, ананасовый сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток478', 365, 'кола, энергетик, гренадин', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток479', 308, 'сироп малиновый, вода газированная, клюквенный морс, спрайт, ананасовый сок', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток480', 238, 'кола, кола, сок сельдерея, ванильное мороженое, сок лайма', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток481', 237, 'гренадин, кокосовое молоко, пюре черной смородины, лимонный сок, пюре черной смородины', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток482', 188, 'клюквенный морс, сливки', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток483', 436, 'вода газированная, вишневый сок, сироп малиновый', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток484', 232, 'гренадин, ванильное мороженое, вишневый сок, томаный сок, гренадин', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток485', 167, 'сливки, лимонный сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток486', 346, 'вишневый сок, лимонный сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток487', 440, 'кола, пюре черной смородины, кола, сахарный сироп', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток488', 424, 'гренадин, вишневый сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток489', 234, 'лед, пюре черной смородины, сок сельдерея, лед', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток490', 335, 'лед, кола', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток491', 160, 'лимонный сок, вишневый сок, лимонный сок, лед, энергетик', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток492', 277, 'клюквенный морс, сок сельдерея, лимонный сок, сахарный сироп, сок лайма', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток493', 404, 'клюквенный морс, лед, клюквенный морс, вишневый сок, кола', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток494', 162, 'томаный сок, сахарный сироп, тоник, ванильное мороженое', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток495', 453, 'тоник, вишневый сок, сахарный сироп, сироп малиновый, сок сельдерея', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток496', 473, 'лимонный сок, ванильное мороженое, сливки', 0, 'Виктор');
INSERT INTO public.drinks VALUES ('Напиток497', 239, 'спрайт, энергетик, сливки', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток498', 475, 'энергетик, томаный сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток499', 199, 'сливки, ванильное мороженое, вишневый сок', 0, 'Аркобалено');
INSERT INTO public.drinks VALUES ('Напиток500', 431, 'гренадин, тоник, томаный сок', 0, 'Клод Моне');
INSERT INTO public.drinks VALUES ('Напиток501', 250, 'водка, пиво', 40, 'Виктор');


--
-- TOC entry 3470 (class 0 OID 18785)
-- Dependencies: 234
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.products VALUES ('Продукт1', 32.176, '2023-04-20', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт2', 46.269, '2023-12-05', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт3', 24.279, '2023-08-05', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт4', 29.067, '2023-10-09', 24, 'Виктор');
INSERT INTO public.products VALUES ('Продукт5', 45.2, '2023-02-22', 30, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт6', 16.477, '2023-06-20', 30, 'Виктор');
INSERT INTO public.products VALUES ('Продукт7', 1.608, '2023-10-04', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт8', 45.556, '2023-03-16', 9, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт9', 48.649, '2023-10-18', 30, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт10', 34.484, '2023-09-06', 26, 'Виктор');
INSERT INTO public.products VALUES ('Продукт11', 30.148, '2023-01-20', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт12', 4.331, '2023-10-11', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт13', 6.318, '2023-06-08', 3, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт14', 20.892, '2023-09-12', 6, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт15', 49.882, '2023-08-24', 7, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт16', 38.787, '2023-03-28', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт17', 36.536, '2023-01-16', 9, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт18', 10.284, '2023-12-12', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт19', 14.115, '2023-04-13', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт20', 33.623, '2023-10-11', 29, 'Виктор');
INSERT INTO public.products VALUES ('Продукт21', 16.398, '2023-10-06', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт22', 10.371, '2023-07-15', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт23', 14.357, '2023-08-27', 10, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт24', 34.681, '2023-11-07', 5, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт25', 26.273, '2023-09-06', 22, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт26', 31.738, '2023-10-01', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт27', 38.638, '2023-04-13', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт28', 36.063, '2023-10-28', 13, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт29', 2.299, '2023-08-28', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт30', 44.351, '2023-12-09', 18, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт31', 25.172, '2023-02-19', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт32', 39.144, '2023-10-09', 13, 'Виктор');
INSERT INTO public.products VALUES ('Продукт33', 37.391, '2023-08-07', 19, 'Виктор');
INSERT INTO public.products VALUES ('Продукт34', 17.962, '2023-10-11', 19, 'Виктор');
INSERT INTO public.products VALUES ('Продукт35', 40.725, '2023-01-17', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт36', 29.639, '2023-02-07', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт37', 38.249, '2023-01-20', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт38', 13.658, '2023-05-17', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт39', 18.109, '2023-07-21', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт40', 13.695, '2023-05-08', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт41', 2.446, '2023-09-08', 16, 'Виктор');
INSERT INTO public.products VALUES ('Продукт42', 35.948, '2023-07-19', 13, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт43', 44.324, '2023-04-12', 11, 'Виктор');
INSERT INTO public.products VALUES ('Продукт44', 18.696, '2023-05-25', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт45', 34.481, '2023-12-20', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт46', 47.721, '2023-01-14', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт47', 20.625, '2023-09-22', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт48', 4.649, '2023-04-13', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт49', 43.767, '2023-02-23', 8, 'Виктор');
INSERT INTO public.products VALUES ('Продукт50', 1.967, '2023-11-09', 14, 'Виктор');
INSERT INTO public.products VALUES ('Продукт51', 8.086, '2023-10-13', 13, 'Виктор');
INSERT INTO public.products VALUES ('Продукт52', 8.973, '2023-04-27', 28, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт53', 49.749, '2023-12-07', 10, 'Виктор');
INSERT INTO public.products VALUES ('Продукт54', 29.474, '2023-10-05', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт55', 20.86, '2023-06-04', 24, 'Виктор');
INSERT INTO public.products VALUES ('Продукт56', 38.025, '2023-03-04', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт57', 8.824, '2023-11-09', 2, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт58', 23.866, '2023-02-26', 19, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт59', 15.132, '2023-06-11', 6, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт60', 29.424, '2023-05-09', 13, 'Виктор');
INSERT INTO public.products VALUES ('Продукт61', 11.727, '2023-03-27', 7, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт62', 39.033, '2023-01-10', 21, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт63', 21.66, '2023-04-09', 13, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт64', 46.033, '2023-02-20', 14, 'Виктор');
INSERT INTO public.products VALUES ('Продукт65', 32.163, '2023-12-18', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт66', 33.514, '2023-06-16', 24, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт67', 31.466, '2023-11-06', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт68', 34.699, '2023-02-06', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт69', 24.2, '2023-04-11', 14, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт70', 25.566, '2023-06-22', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт71', 27.593, '2023-01-20', 7, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт72', 18.436, '2023-11-26', 10, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт73', 23.619, '2023-05-18', 21, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт74', 49.364, '2023-09-10', 7, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт75', 10.739, '2023-03-23', 19, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт76', 32.275, '2023-06-18', 19, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт77', 32.521, '2023-07-22', 10, 'Виктор');
INSERT INTO public.products VALUES ('Продукт78', 6.652, '2023-04-21', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт79', 33.955, '2023-05-01', 10, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт80', 32.315, '2023-09-24', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт81', 18.934, '2023-01-11', 28, 'Виктор');
INSERT INTO public.products VALUES ('Продукт82', 40.412, '2023-10-25', 14, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт83', 47.149, '2023-03-08', 23, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт84', 1.227, '2023-04-07', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт85', 44.376, '2023-03-08', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт86', 22.713, '2023-11-13', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт87', 18.484, '2023-06-27', 20, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт88', 28.386, '2023-01-01', 18, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт89', 2.578, '2023-04-10', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт90', 20.905, '2023-02-25', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт91', 33.052, '2023-06-01', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт92', 26.126, '2023-01-27', 23, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт93', 30.381, '2023-04-17', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт94', 13.506, '2023-03-12', 18, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт95', 47.357, '2023-09-05', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт96', 15.105, '2023-10-28', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт97', 41.066, '2023-02-15', 25, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт98', 13.523, '2023-12-15', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт99', 46.69, '2023-01-02', 6, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт100', 19.398, '2023-05-11', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт101', 23.923, '2023-07-20', 7, 'Виктор');
INSERT INTO public.products VALUES ('Продукт102', 20.371, '2023-08-09', 28, 'Виктор');
INSERT INTO public.products VALUES ('Продукт103', 7.784, '2023-01-11', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт104', 34.095, '2023-08-24', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт105', 19.079, '2023-11-21', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт106', 13.557, '2023-03-02', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт107', 31.712, '2023-10-06', 30, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт108', 3.148, '2023-04-28', 4, 'Виктор');
INSERT INTO public.products VALUES ('Продукт109', 6.787, '2023-09-18', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт110', 24.327, '2023-11-25', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт111', 30.04, '2023-01-05', 2, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт112', 11.958, '2023-10-02', 24, 'Виктор');
INSERT INTO public.products VALUES ('Продукт113', 36.108, '2023-09-04', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт114', 10.482, '2023-12-25', 19, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт115', 30.934, '2023-07-08', 11, 'Виктор');
INSERT INTO public.products VALUES ('Продукт116', 47.129, '2023-03-18', 8, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт117', 4.13, '2023-08-05', 29, 'Виктор');
INSERT INTO public.products VALUES ('Продукт118', 39.626, '2023-06-13', 16, 'Виктор');
INSERT INTO public.products VALUES ('Продукт119', 40.305, '2023-09-23', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт120', 23.636, '2023-06-03', 1, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт121', 22.674, '2023-03-22', 8, 'Виктор');
INSERT INTO public.products VALUES ('Продукт122', 35.705, '2023-02-09', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт123', 7.493, '2023-07-26', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт124', 7.621, '2023-03-20', 27, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт125', 21.404, '2023-08-09', 20, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт126', 13.398, '2023-01-16', 14, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт127', 33.445, '2023-10-14', 6, 'Виктор');
INSERT INTO public.products VALUES ('Продукт128', 18.844, '2023-10-27', 10, 'Виктор');
INSERT INTO public.products VALUES ('Продукт129', 45.013, '2023-01-18', 20, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт130', 18.356, '2023-03-26', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт131', 40.218, '2023-02-05', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт132', 28.785, '2023-08-16', 28, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт133', 26.284, '2023-02-28', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт134', 44.76, '2023-11-17', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт135', 39.549, '2023-11-01', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт136', 1.785, '2023-09-21', 7, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт137', 11.654, '2023-03-25', 23, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт138', 38.065, '2023-08-27', 5, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт139', 24.896, '2023-11-22', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт140', 6.851, '2023-02-26', 20, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт141', 4.853, '2023-12-07', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт142', 28.578, '2023-08-12', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт143', 48.789, '2023-03-27', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт144', 7.733, '2023-06-04', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт145', 22.66, '2023-11-24', 28, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт146', 35.912, '2023-02-08', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт147', 37.741, '2023-08-06', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт148', 20.458, '2023-08-17', 1, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт149', 13.021, '2023-09-05', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт150', 6.785, '2023-09-16', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт151', 48.812, '2023-01-19', 18, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт152', 12.696, '2023-08-23', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт153', 11.926, '2023-01-18', 18, 'Виктор');
INSERT INTO public.products VALUES ('Продукт154', 29.773, '2023-02-02', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт155', 5.769, '2023-05-10', 25, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт156', 14.126, '2023-06-22', 19, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт157', 21.199, '2023-05-05', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт158', 29.278, '2023-09-02', 1, 'Виктор');
INSERT INTO public.products VALUES ('Продукт159', 28.041, '2023-03-17', 1, 'Виктор');
INSERT INTO public.products VALUES ('Продукт160', 23.019, '2023-03-11', 26, 'Виктор');
INSERT INTO public.products VALUES ('Продукт161', 45.612, '2023-12-09', 5, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт162', 26.009, '2023-01-09', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт163', 18.64, '2023-02-13', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт164', 3.841, '2023-07-27', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт165', 46.103, '2023-07-12', 8, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт166', 29.399, '2023-12-18', 9, 'Виктор');
INSERT INTO public.products VALUES ('Продукт167', 33.96, '2023-01-01', 8, 'Виктор');
INSERT INTO public.products VALUES ('Продукт168', 43.334, '2023-12-05', 13, 'Виктор');
INSERT INTO public.products VALUES ('Продукт169', 4.075, '2023-08-03', 20, 'Виктор');
INSERT INTO public.products VALUES ('Продукт170', 49.842, '2023-06-09', 25, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт171', 5.596, '2023-06-09', 7, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт172', 7.899, '2023-03-26', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт173', 35.096, '2023-10-20', 5, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт174', 29.066, '2023-10-05', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт175', 27.618, '2023-04-07', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт176', 4.586, '2023-09-11', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт177', 35.805, '2023-02-21', 3, 'Виктор');
INSERT INTO public.products VALUES ('Продукт178', 2.963, '2023-09-22', 8, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт179', 23.207, '2023-08-05', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт180', 3.201, '2023-06-09', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт181', 4.467, '2023-08-09', 23, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт182', 15.912, '2023-11-10', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт183', 17.97, '2023-05-21', 5, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт184', 5.039, '2023-08-16', 7, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт185', 44.486, '2023-05-13', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт186', 41.134, '2023-11-11', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт187', 38.318, '2023-12-07', 27, 'Виктор');
INSERT INTO public.products VALUES ('Продукт188', 42.878, '2023-07-03', 5, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт189', 37.978, '2023-05-01', 18, 'Виктор');
INSERT INTO public.products VALUES ('Продукт190', 19.696, '2023-04-10', 8, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт191', 18.492, '2023-06-07', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт192', 13.05, '2023-01-04', 21, 'Виктор');
INSERT INTO public.products VALUES ('Продукт193', 3.318, '2023-10-28', 30, 'Виктор');
INSERT INTO public.products VALUES ('Продукт194', 11.967, '2023-10-26', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт195', 14.755, '2023-01-26', 1, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт196', 13.12, '2023-01-08', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт197', 8.443, '2023-12-18', 19, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт198', 25.34, '2023-01-11', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт199', 41.708, '2023-12-16', 6, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт200', 46.955, '2023-02-09', 14, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт201', 42.452, '2023-07-08', 1, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт202', 36.965, '2023-12-11', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт203', 32.046, '2023-01-06', 24, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт204', 11.073, '2023-08-28', 15, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт205', 8.297, '2023-12-12', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт206', 41.331, '2023-09-16', 5, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт207', 36.56, '2023-11-28', 23, 'Виктор');
INSERT INTO public.products VALUES ('Продукт208', 9.867, '2023-09-14', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт209', 3.164, '2023-02-08', 19, 'Виктор');
INSERT INTO public.products VALUES ('Продукт210', 39.971, '2023-01-17', 17, 'Виктор');
INSERT INTO public.products VALUES ('Продукт211', 42.516, '2023-05-22', 7, 'Виктор');
INSERT INTO public.products VALUES ('Продукт212', 6.282, '2023-04-27', 6, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт213', 9.051, '2023-10-06', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт214', 48.524, '2023-05-01', 7, 'Виктор');
INSERT INTO public.products VALUES ('Продукт215', 22.525, '2023-09-25', 3, 'Виктор');
INSERT INTO public.products VALUES ('Продукт216', 9.221, '2023-03-19', 22, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт217', 35.916, '2023-01-21', 1, 'Виктор');
INSERT INTO public.products VALUES ('Продукт218', 47.131, '2023-08-21', 6, 'Виктор');
INSERT INTO public.products VALUES ('Продукт219', 15.776, '2023-02-07', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт220', 21.928, '2023-04-03', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт221', 28.058, '2023-11-26', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт222', 29.346, '2023-08-11', 18, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт223', 15.97, '2023-10-16', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт224', 41.35, '2023-10-10', 18, 'Виктор');
INSERT INTO public.products VALUES ('Продукт225', 7.996, '2023-05-18', 7, 'Виктор');
INSERT INTO public.products VALUES ('Продукт226', 48.137, '2023-03-13', 6, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт227', 15.337, '2023-06-24', 16, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт228', 11.794, '2023-10-10', 11, 'Виктор');
INSERT INTO public.products VALUES ('Продукт229', 43.912, '2023-05-04', 7, 'Виктор');
INSERT INTO public.products VALUES ('Продукт230', 4.488, '2023-03-28', 29, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт231', 40.149, '2023-07-02', 21, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт232', 47.185, '2023-12-13', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт233', 47.382, '2023-12-21', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт234', 31.194, '2023-06-04', 30, 'Виктор');
INSERT INTO public.products VALUES ('Продукт235', 1.243, '2023-08-27', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт236', 35.296, '2023-04-11', 18, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт237', 2.181, '2023-05-05', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт238', 46.075, '2023-01-25', 5, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт239', 47.489, '2023-09-26', 26, 'Виктор');
INSERT INTO public.products VALUES ('Продукт240', 39.911, '2023-07-28', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт241', 27.297, '2023-12-01', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт242', 49.845, '2023-09-25', 2, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт243', 33.49, '2023-11-26', 21, 'Виктор');
INSERT INTO public.products VALUES ('Продукт244', 25.728, '2023-11-08', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт245', 29.66, '2023-07-24', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт246', 12.214, '2023-02-24', 2, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт247', 24.798, '2023-08-15', 21, 'Виктор');
INSERT INTO public.products VALUES ('Продукт248', 6.181, '2023-05-05', 17, 'Виктор');
INSERT INTO public.products VALUES ('Продукт249', 21.629, '2023-05-19', 27, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт250', 9.362, '2023-10-09', 12, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт251', 45.291, '2023-04-07', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт252', 15.873, '2023-09-17', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт253', 44.196, '2023-01-21', 5, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт254', 13, '2023-03-10', 18, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт255', 14.232, '2023-11-15', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт256', 15.144, '2023-07-19', 19, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт257', 22.553, '2023-03-20', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт258', 9.493, '2023-03-01', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт259', 7.116, '2023-10-01', 19, 'Виктор');
INSERT INTO public.products VALUES ('Продукт260', 29.064, '2023-03-13', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт261', 38.129, '2023-02-20', 7, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт262', 17.394, '2023-03-26', 2, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт263', 18.001, '2023-04-07', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт264', 7.3, '2023-06-06', 12, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт265', 42.249, '2023-11-21', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт266', 1.912, '2023-01-16', 22, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт267', 12.726, '2023-10-02', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт268', 7.954, '2023-09-26', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт269', 8.964, '2023-05-10', 6, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт270', 13.431, '2023-02-04', 1, 'Виктор');
INSERT INTO public.products VALUES ('Продукт271', 41.257, '2023-11-19', 29, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт272', 28.416, '2023-04-05', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт273', 28.35, '2023-11-28', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт274', 23.316, '2023-06-20', 13, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт275', 23.523, '2023-06-13', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт276', 6.89, '2023-11-07', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт277', 49.96, '2023-06-25', 10, 'Виктор');
INSERT INTO public.products VALUES ('Продукт278', 36.968, '2023-03-10', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт279', 23.959, '2023-01-20', 23, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт280', 25.992, '2023-11-09', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт281', 34.479, '2023-04-20', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт282', 30.391, '2023-06-20', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт283', 9.86, '2023-09-20', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт284', 16.481, '2023-10-12', 23, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт285', 26.683, '2023-11-24', 9, 'Виктор');
INSERT INTO public.products VALUES ('Продукт286', 44.386, '2023-02-26', 6, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт287', 17.347, '2023-07-10', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт288', 7.027, '2023-08-20', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт289', 15.545, '2023-04-17', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт290', 33.405, '2023-08-05', 20, 'Виктор');
INSERT INTO public.products VALUES ('Продукт291', 19.958, '2023-11-04', 26, 'Виктор');
INSERT INTO public.products VALUES ('Продукт292', 21.619, '2023-08-07', 1, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт293', 26.596, '2023-10-10', 27, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт294', 44.94, '2023-09-26', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт295', 12.319, '2023-02-23', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт296', 28.939, '2023-05-28', 1, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт297', 16.915, '2023-07-25', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт298', 8.653, '2023-07-09', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт299', 24.469, '2023-10-04', 30, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт300', 18.517, '2023-10-19', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт301', 1.957, '2023-02-13', 28, 'Виктор');
INSERT INTO public.products VALUES ('Продукт302', 5.701, '2023-06-16', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт303', 11.271, '2023-07-26', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт304', 16.424, '2023-02-13', 9, 'Виктор');
INSERT INTO public.products VALUES ('Продукт305', 29.647, '2023-09-25', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт306', 39.41, '2023-06-04', 3, 'Виктор');
INSERT INTO public.products VALUES ('Продукт307', 25.725, '2023-12-12', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт308', 32.479, '2023-12-11', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт309', 19.211, '2023-10-27', 9, 'Виктор');
INSERT INTO public.products VALUES ('Продукт310', 27.96, '2023-07-20', 14, 'Виктор');
INSERT INTO public.products VALUES ('Продукт311', 2.882, '2023-11-26', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт312', 29.464, '2023-09-15', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт313', 40.691, '2023-10-06', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт314', 39.771, '2023-10-18', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт315', 16.62, '2023-11-16', 27, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт316', 5.514, '2023-01-06', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт317', 19.032, '2023-05-09', 5, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт318', 11.273, '2023-07-06', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт319', 47.049, '2023-11-28', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт320', 18.734, '2023-02-22', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт321', 12.223, '2023-11-03', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт322', 45.515, '2023-06-25', 22, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт323', 36.726, '2023-06-18', 15, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт324', 35.948, '2023-02-18', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт325', 35.747, '2023-02-14', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт326', 14.615, '2023-10-07', 16, 'Виктор');
INSERT INTO public.products VALUES ('Продукт327', 38.969, '2023-02-17', 9, 'Виктор');
INSERT INTO public.products VALUES ('Продукт328', 43.809, '2023-09-08', 27, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт329', 45.746, '2023-11-20', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт330', 25.757, '2023-05-17', 15, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт331', 16.039, '2023-08-02', 17, 'Виктор');
INSERT INTO public.products VALUES ('Продукт332', 46.814, '2023-03-17', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт333', 1.446, '2023-05-03', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт334', 8.942, '2023-06-22', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт335', 46.345, '2023-09-21', 14, 'Виктор');
INSERT INTO public.products VALUES ('Продукт336', 3.109, '2023-04-10', 21, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт337', 39.709, '2023-12-24', 22, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт338', 44.561, '2023-05-19', 30, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт339', 36.258, '2023-09-02', 18, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт340', 27.063, '2023-04-28', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт341', 38.466, '2023-06-22', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт342', 30.803, '2023-06-25', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт343', 2.716, '2023-12-05', 8, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт344', 27.187, '2023-05-11', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт345', 10.484, '2023-04-23', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт346', 43.471, '2023-05-02', 5, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт347', 35.901, '2023-07-06', 15, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт348', 2.665, '2023-11-25', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт349', 37.835, '2023-03-28', 3, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт350', 22.737, '2023-01-04', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт351', 32.497, '2023-02-09', 30, 'Виктор');
INSERT INTO public.products VALUES ('Продукт352', 5.034, '2023-02-16', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт353', 10.263, '2023-04-24', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт354', 32.208, '2023-01-13', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт355', 47.027, '2023-10-22', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт356', 3.829, '2023-08-07', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт357', 11.102, '2023-05-19', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт358', 25.945, '2023-05-26', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт359', 32.879, '2023-06-10', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт360', 38.099, '2023-08-24', 10, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт361', 40.132, '2023-02-11', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт362', 14.718, '2023-06-23', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт363', 3.9, '2023-12-06', 3, 'Виктор');
INSERT INTO public.products VALUES ('Продукт364', 14.354, '2023-09-08', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт365', 16.596, '2023-08-23', 21, 'Виктор');
INSERT INTO public.products VALUES ('Продукт366', 47.386, '2023-02-23', 23, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт367', 7.795, '2023-05-07', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт368', 47.667, '2023-02-03', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт369', 33.94, '2023-04-19', 19, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт370', 15.249, '2023-04-15', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт371', 20.104, '2023-11-14', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт372', 46.48, '2023-05-08', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт373', 34.184, '2023-11-17', 17, 'Виктор');
INSERT INTO public.products VALUES ('Продукт374', 24.711, '2023-02-22', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт375', 22.417, '2023-02-14', 27, 'Виктор');
INSERT INTO public.products VALUES ('Продукт376', 18.435, '2023-05-11', 23, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт377', 34.539, '2023-12-28', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт378', 1.836, '2023-11-20', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт379', 20.966, '2023-06-25', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт380', 45.695, '2023-05-27', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт381', 15.107, '2023-03-13', 27, 'Виктор');
INSERT INTO public.products VALUES ('Продукт382', 19.114, '2023-01-19', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт383', 41.673, '2023-01-02', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт384', 17.878, '2023-05-23', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт385', 37.718, '2023-01-25', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт386', 30.773, '2023-09-10', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт387', 34.858, '2023-05-07', 19, 'Виктор');
INSERT INTO public.products VALUES ('Продукт388', 1.257, '2023-06-09', 18, 'Виктор');
INSERT INTO public.products VALUES ('Продукт389', 13.8, '2023-07-16', 21, 'Виктор');
INSERT INTO public.products VALUES ('Продукт390', 47.528, '2023-10-05', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт391', 45.293, '2023-12-09', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт392', 25.288, '2023-08-27', 10, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт393', 4.611, '2023-04-18', 16, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт394', 8.77, '2023-05-02', 15, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт395', 5.166, '2023-07-26', 30, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт396', 35.356, '2023-07-09', 13, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт397', 21.319, '2023-06-09', 21, 'Виктор');
INSERT INTO public.products VALUES ('Продукт398', 1.84, '2023-07-18', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт399', 48.743, '2023-03-13', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт400', 46.594, '2023-05-09', 28, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт401', 3.131, '2023-12-15', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт402', 6.912, '2023-06-09', 4, 'Виктор');
INSERT INTO public.products VALUES ('Продукт403', 38.196, '2023-08-23', 30, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт404', 30.953, '2023-05-02', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт405', 3.258, '2023-11-06', 12, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт406', 20.432, '2023-10-24', 1, 'Виктор');
INSERT INTO public.products VALUES ('Продукт407', 10.153, '2023-05-03', 13, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт408', 8.54, '2023-09-22', 9, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт409', 34.775, '2023-12-23', 24, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт410', 23.929, '2023-06-01', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт411', 3.261, '2023-07-08', 3, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт412', 8.839, '2023-02-01', 9, 'Виктор');
INSERT INTO public.products VALUES ('Продукт413', 31.844, '2023-01-15', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт414', 38.814, '2023-09-23', 3, 'Виктор');
INSERT INTO public.products VALUES ('Продукт415', 11.986, '2023-02-17', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт416', 7.863, '2023-02-02', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт417', 10.492, '2023-08-12', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт418', 8.771, '2023-12-27', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт419', 14.018, '2023-12-19', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт420', 30.792, '2023-10-14', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт421', 21.653, '2023-02-13', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт422', 27.186, '2023-06-06', 27, 'Виктор');
INSERT INTO public.products VALUES ('Продукт423', 45.905, '2023-02-06', 24, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт424', 36.552, '2023-06-01', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт425', 24.814, '2023-07-05', 22, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт426', 19.037, '2023-12-28', 21, 'Виктор');
INSERT INTO public.products VALUES ('Продукт427', 11.205, '2023-11-26', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт428', 19.198, '2023-10-08', 1, 'Виктор');
INSERT INTO public.products VALUES ('Продукт429', 47.545, '2023-05-17', 3, 'Виктор');
INSERT INTO public.products VALUES ('Продукт430', 6.238, '2023-08-20', 28, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт431', 7.851, '2023-02-10', 5, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт432', 6.012, '2023-07-25', 29, 'Виктор');
INSERT INTO public.products VALUES ('Продукт433', 30.346, '2023-10-25', 18, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт434', 49.355, '2023-04-14', 20, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт435', 15.55, '2023-07-24', 9, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт436', 49.622, '2023-12-16', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт437', 35.189, '2023-02-13', 29, 'Виктор');
INSERT INTO public.products VALUES ('Продукт438', 10.986, '2023-09-16', 22, 'Виктор');
INSERT INTO public.products VALUES ('Продукт439', 28.364, '2023-08-23', 29, 'Виктор');
INSERT INTO public.products VALUES ('Продукт440', 3.772, '2023-05-19', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт441', 29.68, '2023-01-28', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт442', 24.338, '2023-01-12', 19, 'Виктор');
INSERT INTO public.products VALUES ('Продукт443', 7.087, '2023-06-19', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт444', 37.757, '2023-12-08', 6, 'Виктор');
INSERT INTO public.products VALUES ('Продукт445', 44.362, '2023-03-05', 3, 'Виктор');
INSERT INTO public.products VALUES ('Продукт446', 38.035, '2023-05-10', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт447', 33.809, '2023-11-14', 12, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт448', 18.739, '2023-11-27', 1, 'Виктор');
INSERT INTO public.products VALUES ('Продукт449', 36.889, '2023-11-20', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт450', 4.305, '2023-04-18', 16, 'Виктор');
INSERT INTO public.products VALUES ('Продукт451', 36.852, '2023-05-23', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт452', 47.839, '2023-08-12', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт453', 39.447, '2023-08-21', 6, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт454', 38.241, '2023-02-12', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт455', 28.883, '2023-04-27', 17, 'Виктор');
INSERT INTO public.products VALUES ('Продукт456', 48.186, '2023-07-14', 22, 'Виктор');
INSERT INTO public.products VALUES ('Продукт457', 22.751, '2023-05-25', 1, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт458', 36.152, '2023-04-26', 10, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт459', 40.084, '2023-09-20', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт460', 36.308, '2023-11-27', 9, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт461', 31.2, '2023-04-03', 13, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт462', 33.914, '2023-11-22', 7, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт463', 40.395, '2023-04-23', 12, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт464', 3.505, '2023-03-11', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт465', 24.92, '2023-04-13', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт466', 19.724, '2023-06-26', 30, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт467', 19.176, '2023-11-26', 8, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт468', 2.622, '2023-11-15', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт469', 48.579, '2023-03-28', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт470', 45.742, '2023-10-09', 20, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт471', 33.552, '2023-08-22', 13, 'Виктор');
INSERT INTO public.products VALUES ('Продукт472', 18.37, '2023-05-16', 20, 'Виктор');
INSERT INTO public.products VALUES ('Продукт473', 47.891, '2023-04-03', 16, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт474', 43.954, '2023-08-02', 30, 'Виктор');
INSERT INTO public.products VALUES ('Продукт475', 27.92, '2023-02-26', 22, 'Виктор');
INSERT INTO public.products VALUES ('Продукт476', 15.426, '2023-07-16', 15, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт477', 15.451, '2023-06-04', 18, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт478', 43.836, '2023-03-16', 7, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт479', 44.272, '2023-07-23', 11, 'Виктор');
INSERT INTO public.products VALUES ('Продукт480', 37.72, '2023-09-17', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт481', 11.422, '2023-01-09', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт482', 11.95, '2023-05-26', 5, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт483', 43.364, '2023-11-04', 8, 'Виктор');
INSERT INTO public.products VALUES ('Продукт484', 48.408, '2023-02-26', 9, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт485', 11.683, '2023-08-03', 28, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт486', 1.274, '2023-03-06', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт487', 31.888, '2023-10-09', 13, 'Виктор');
INSERT INTO public.products VALUES ('Продукт488', 34.779, '2023-02-28', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт489', 42.648, '2023-09-19', 1, 'Виктор');
INSERT INTO public.products VALUES ('Продукт490', 47.697, '2023-03-11', 8, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт491', 18.218, '2023-09-09', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт492', 28.361, '2023-11-28', 30, 'Виктор');
INSERT INTO public.products VALUES ('Продукт493', 47.107, '2023-07-08', 3, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт494', 31.48, '2023-09-10', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт495', 22.819, '2023-12-17', 8, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт496', 7.01, '2023-11-15', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт497', 48.416, '2023-03-06', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт498', 6.344, '2023-03-03', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт499', 11.078, '2023-01-25', 1, 'Виктор');
INSERT INTO public.products VALUES ('Продукт500', 32.568, '2023-03-13', 21, 'Виктор');
INSERT INTO public.products VALUES ('Продукт501', 36.735, '2023-10-09', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт502', 41.459, '2023-10-06', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт503', 9.206, '2023-12-18', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт504', 27.709, '2023-09-21', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт505', 8.116, '2023-06-28', 27, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт506', 29.9, '2023-02-10', 23, 'Виктор');
INSERT INTO public.products VALUES ('Продукт507', 36.282, '2023-11-23', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт508', 36.516, '2023-10-05', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт509', 39.074, '2023-10-01', 9, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт510', 3.492, '2023-07-15', 26, 'Виктор');
INSERT INTO public.products VALUES ('Продукт511', 37.965, '2023-12-23', 3, 'Виктор');
INSERT INTO public.products VALUES ('Продукт512', 22.222, '2023-11-26', 30, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт513', 20.896, '2023-05-15', 26, 'Виктор');
INSERT INTO public.products VALUES ('Продукт514', 49.329, '2023-11-18', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт515', 11.727, '2023-12-24', 11, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт516', 12.11, '2023-11-16', 14, 'Виктор');
INSERT INTO public.products VALUES ('Продукт517', 43.653, '2023-08-04', 7, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт518', 5.731, '2023-02-04', 23, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт519', 27.434, '2023-03-16', 21, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт520', 24.326, '2023-05-17', 23, 'Виктор');
INSERT INTO public.products VALUES ('Продукт521', 33.58, '2023-09-25', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт522', 23.54, '2023-02-01', 27, 'Виктор');
INSERT INTO public.products VALUES ('Продукт523', 33.206, '2023-04-12', 21, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт524', 46.848, '2023-06-10', 7, 'Виктор');
INSERT INTO public.products VALUES ('Продукт525', 39.336, '2023-04-15', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт526', 4.163, '2023-09-15', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт527', 36.422, '2023-05-14', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт528', 24.744, '2023-06-02', 10, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт529', 6.289, '2023-06-08', 15, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт530', 2.89, '2023-01-08', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт531', 1.195, '2023-02-26', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт532', 26.216, '2023-07-07', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт533', 19.528, '2023-02-17', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт534', 36.341, '2023-09-15', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт535', 43.094, '2023-08-26', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт536', 13.168, '2023-10-12', 10, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт537', 47.705, '2023-01-14', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт538', 42.561, '2023-09-25', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт539', 9.714, '2023-07-11', 5, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт540', 3.136, '2023-06-11', 27, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт541', 26.583, '2023-05-01', 22, 'Виктор');
INSERT INTO public.products VALUES ('Продукт542', 48.708, '2023-04-09', 27, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт543', 17.146, '2023-06-21', 7, 'Виктор');
INSERT INTO public.products VALUES ('Продукт544', 15.835, '2023-09-25', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт545', 16.115, '2023-04-02', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт546', 36.526, '2023-11-15', 12, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт547', 23.682, '2023-06-19', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт548', 37.876, '2023-07-11', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт549', 14.645, '2023-05-27', 10, 'Виктор');
INSERT INTO public.products VALUES ('Продукт550', 47.527, '2023-10-12', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт551', 26.976, '2023-11-21', 19, 'Виктор');
INSERT INTO public.products VALUES ('Продукт552', 40.845, '2023-06-17', 5, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт553', 36.369, '2023-01-19', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт554', 29.227, '2023-08-15', 18, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт555', 9.982, '2023-02-24', 9, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт556', 1.611, '2023-12-23', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт557', 48.623, '2023-06-15', 23, 'Виктор');
INSERT INTO public.products VALUES ('Продукт558', 6.614, '2023-11-25', 19, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт559', 1.332, '2023-01-12', 5, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт560', 40.293, '2023-01-26', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт561', 14.897, '2023-06-16', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт562', 16.423, '2023-11-22', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт563', 4.043, '2023-06-07', 15, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт564', 11.566, '2023-01-23', 16, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт565', 33.45, '2023-10-12', 3, 'Виктор');
INSERT INTO public.products VALUES ('Продукт566', 35.564, '2023-11-13', 1, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт567', 3.592, '2023-04-24', 5, 'Виктор');
INSERT INTO public.products VALUES ('Продукт568', 18.78, '2023-04-11', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт569', 47.045, '2023-10-04', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт570', 48.085, '2023-06-25', 24, 'Виктор');
INSERT INTO public.products VALUES ('Продукт571', 39.141, '2023-08-26', 18, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт572', 6.95, '2023-08-15', 27, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт573', 43.163, '2023-01-28', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт574', 2.995, '2023-10-01', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт575', 4.722, '2023-01-02', 12, 'Виктор');
INSERT INTO public.products VALUES ('Продукт576', 2.362, '2023-08-16', 11, 'Виктор');
INSERT INTO public.products VALUES ('Продукт577', 36.19, '2023-03-17', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт578', 33.786, '2023-08-15', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт579', 29.64, '2023-07-26', 15, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт580', 11.615, '2023-05-08', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт581', 40.751, '2023-02-07', 16, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт582', 39.079, '2023-06-12', 11, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт583', 37.173, '2023-11-11', 21, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт584', 11.38, '2023-08-24', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт585', 15.451, '2023-12-17', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт586', 16.736, '2023-09-27', 6, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт587', 36.358, '2023-07-03', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт588', 48.426, '2023-08-20', 7, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт589', 14.816, '2023-04-20', 20, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт590', 37.518, '2023-12-13', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт591', 24.342, '2023-01-03', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт592', 11.006, '2023-07-06', 28, 'Виктор');
INSERT INTO public.products VALUES ('Продукт593', 29.167, '2023-01-16', 27, 'Виктор');
INSERT INTO public.products VALUES ('Продукт594', 10.158, '2023-02-09', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт595', 45.209, '2023-10-21', 21, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт596', 40.406, '2023-03-18', 18, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт597', 29.92, '2023-04-14', 9, 'Виктор');
INSERT INTO public.products VALUES ('Продукт598', 15.588, '2023-12-21', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт599', 39.228, '2023-10-21', 28, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт600', 8.127, '2023-12-18', 12, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт601', 42.213, '2023-02-08', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт602', 49.618, '2023-01-19', 27, 'Виктор');
INSERT INTO public.products VALUES ('Продукт603', 27.236, '2023-03-05', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт604', 46.145, '2023-07-11', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт605', 35.028, '2023-07-15', 23, 'Виктор');
INSERT INTO public.products VALUES ('Продукт606', 23.502, '2023-07-16', 25, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт607', 23.81, '2023-09-12', 24, 'Виктор');
INSERT INTO public.products VALUES ('Продукт608', 28.856, '2023-02-16', 29, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт609', 48.934, '2023-03-06', 14, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт610', 32.201, '2023-09-01', 11, 'Виктор');
INSERT INTO public.products VALUES ('Продукт611', 32.528, '2023-04-03', 10, 'Виктор');
INSERT INTO public.products VALUES ('Продукт612', 21.96, '2023-01-23', 21, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт613', 20.157, '2023-08-08', 15, 'Виктор');
INSERT INTO public.products VALUES ('Продукт614', 10.064, '2023-09-03', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт615', 11.989, '2023-11-04', 21, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт616', 10.539, '2023-09-09', 21, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт617', 10.226, '2023-09-28', 13, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт618', 40.009, '2023-06-14', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт619', 6.076, '2023-01-14', 30, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт620', 5.638, '2023-06-08', 10, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт621', 16.432, '2023-09-18', 26, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт622', 9.664, '2023-07-16', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт623', 17.009, '2023-05-04', 21, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт624', 17.463, '2023-03-11', 11, 'Виктор');
INSERT INTO public.products VALUES ('Продукт625', 46.068, '2023-02-08', 30, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт626', 9.936, '2023-11-12', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт627', 33.711, '2023-05-26', 17, 'Виктор');
INSERT INTO public.products VALUES ('Продукт628', 10.781, '2023-12-18', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт629', 29.677, '2023-08-22', 8, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт630', 4.303, '2023-05-06', 15, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт631', 36.931, '2023-10-23', 6, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт632', 21.627, '2023-12-03', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт633', 49.257, '2023-06-08', 13, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт634', 46.907, '2023-04-11', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт635', 26.027, '2023-07-22', 14, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт636', 26.721, '2023-07-14', 8, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт637', 40.022, '2023-05-11', 4, 'Виктор');
INSERT INTO public.products VALUES ('Продукт638', 29.487, '2023-08-22', 7, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт639', 11.094, '2023-04-02', 3, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт640', 32.855, '2023-12-15', 22, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт641', 1.851, '2023-11-14', 11, 'Виктор');
INSERT INTO public.products VALUES ('Продукт642', 6.038, '2023-09-17', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт643', 20.448, '2023-12-14', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт644', 6.864, '2023-12-01', 9, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт645', 8.282, '2023-01-20', 21, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт646', 38.395, '2023-08-07', 8, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт647', 49.816, '2023-01-21', 23, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт648', 3.702, '2023-09-18', 9, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт649', 11.021, '2023-12-11', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт650', 3.838, '2023-06-20', 13, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт651', 42.422, '2023-09-09', 5, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт652', 8.181, '2023-07-10', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт653', 30.367, '2023-12-28', 12, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт654', 46.613, '2023-04-10', 29, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт655', 35.376, '2023-12-24', 13, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт656', 32.983, '2023-10-03', 24, 'Виктор');
INSERT INTO public.products VALUES ('Продукт657', 31.13, '2023-09-27', 22, 'Виктор');
INSERT INTO public.products VALUES ('Продукт658', 26.005, '2023-11-23', 10, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт659', 10.773, '2023-01-12', 17, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт660', 28.647, '2023-03-13', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт661', 48.356, '2023-02-04', 3, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт662', 3.096, '2023-08-06', 27, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт663', 35.856, '2023-09-22', 4, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт664', 15.395, '2023-11-10', 13, 'Виктор');
INSERT INTO public.products VALUES ('Продукт665', 39.486, '2023-04-12', 18, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт666', 4.361, '2023-12-27', 25, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт667', 49.892, '2023-10-27', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт668', 9.428, '2023-09-06', 20, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт669', 14.413, '2023-07-10', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт670', 37.535, '2023-05-18', 6, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт671', 25.699, '2023-04-24', 24, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт672', 41.383, '2023-03-09', 10, 'Виктор');
INSERT INTO public.products VALUES ('Продукт673', 14.673, '2023-09-14', 25, 'Виктор');
INSERT INTO public.products VALUES ('Продукт674', 18.336, '2023-02-20', 22, 'Виктор');
INSERT INTO public.products VALUES ('Продукт675', 44.879, '2023-06-22', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт676', 41.455, '2023-11-02', 20, 'Виктор');
INSERT INTO public.products VALUES ('Продукт677', 32.333, '2023-12-05', 23, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт678', 20.312, '2023-05-10', 7, 'Виктор');
INSERT INTO public.products VALUES ('Продукт679', 33.942, '2023-02-08', 20, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт680', 32.813, '2023-12-15', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт681', 23.281, '2023-03-25', 16, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт682', 25.825, '2023-03-01', 23, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт683', 20.794, '2023-03-04', 8, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт684', 9.263, '2023-11-04', 10, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт685', 4.098, '2023-04-09', 30, 'Виктор');
INSERT INTO public.products VALUES ('Продукт686', 40.093, '2023-07-05', 18, 'Виктор');
INSERT INTO public.products VALUES ('Продукт687', 45.982, '2023-05-08', 29, 'Виктор');
INSERT INTO public.products VALUES ('Продукт688', 38.669, '2023-10-19', 20, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт689', 49.242, '2023-12-20', 26, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт690', 16.675, '2023-02-01', 4, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт691', 10.885, '2023-12-19', 17, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт692', 27.07, '2023-02-26', 13, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт693', 3.474, '2023-06-06', 10, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт694', 6.828, '2023-09-03', 8, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт695', 38.333, '2023-01-14', 2, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт696', 44.798, '2023-03-14', 1, 'Клод Моне');
INSERT INTO public.products VALUES ('Продукт697', 29.544, '2023-02-08', 23, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт698', 44.088, '2023-10-14', 2, 'Виктор');
INSERT INTO public.products VALUES ('Продукт699', 9.513, '2023-08-05', 25, 'Аркобалено');
INSERT INTO public.products VALUES ('Продукт700', 4.273, '2023-09-27', 7, 'Виктор');


--
-- TOC entry 3464 (class 0 OID 18489)
-- Dependencies: 216
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.restaurants VALUES ('Клод Моне', 60, 'ул. Франзуская, д. 1', 12, 9720);
INSERT INTO public.restaurants VALUES ('Аркобалено', 70, 'ул. Радужная, д. 1', 12, 2110);
INSERT INTO public.restaurants VALUES ('Виктор', 60, 'ул. Отельная, д. 1', 12, 16890);


--
-- TOC entry 3465 (class 0 OID 18496)
-- Dependencies: 217
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.suppliers VALUES ('Тимур', 'оптовая', 'импортер', 'Клод Моне');
INSERT INTO public.suppliers VALUES ('Крутая икра', 'розничная', 'производитель', 'Клод Моне');
INSERT INTO public.suppliers VALUES ('Вкусные продукты', 'оптовая', 'дистрибьютер', 'Аркобалено');
INSERT INTO public.suppliers VALUES ('Хорошая еда', 'оптовая', 'импортер', 'Виктор');


--
-- TOC entry 3469 (class 0 OID 18618)
-- Dependencies: 221
-- Data for Name: work_place; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.work_place VALUES ('Клод Моне', 2000001);
INSERT INTO public.work_place VALUES ('Клод Моне', 2000002);
INSERT INTO public.work_place VALUES ('Аркобалено', 2000003);
INSERT INTO public.work_place VALUES ('Аркобалено', 2000004);
INSERT INTO public.work_place VALUES ('Виктор', 2000005);
INSERT INTO public.work_place VALUES ('Виктор', 2000006);
INSERT INTO public.work_place VALUES ('Клод Моне', 3000001);
INSERT INTO public.work_place VALUES ('Клод Моне', 3000002);
INSERT INTO public.work_place VALUES ('Клод Моне', 3000003);
INSERT INTO public.work_place VALUES ('Клод Моне', 3000004);
INSERT INTO public.work_place VALUES ('Аркобалено', 3000005);
INSERT INTO public.work_place VALUES ('Аркобалено', 3000006);
INSERT INTO public.work_place VALUES ('Аркобалено', 3000007);
INSERT INTO public.work_place VALUES ('Аркобалено', 3000008);
INSERT INTO public.work_place VALUES ('Виктор', 3000009);
INSERT INTO public.work_place VALUES ('Виктор', 3000010);
INSERT INTO public.work_place VALUES ('Виктор', 3000011);
INSERT INTO public.work_place VALUES ('Виктор', 3000012);
INSERT INTO public.work_place VALUES ('Клод Моне', 4000001);
INSERT INTO public.work_place VALUES ('Клод Моне', 4000002);
INSERT INTO public.work_place VALUES ('Клод Моне', 4000003);
INSERT INTO public.work_place VALUES ('Клод Моне', 4000004);
INSERT INTO public.work_place VALUES ('Аркобалено', 4000005);
INSERT INTO public.work_place VALUES ('Аркобалено', 4000006);
INSERT INTO public.work_place VALUES ('Аркобалено', 4000007);
INSERT INTO public.work_place VALUES ('Аркобалено', 4000008);
INSERT INTO public.work_place VALUES ('Виктор', 4000009);
INSERT INTO public.work_place VALUES ('Виктор', 4000010);
INSERT INTO public.work_place VALUES ('Виктор', 4000011);
INSERT INTO public.work_place VALUES ('Виктор', 4000012);
INSERT INTO public.work_place VALUES ('Клод Моне', 1000001);
INSERT INTO public.work_place VALUES ('Клод Моне', 1000002);
INSERT INTO public.work_place VALUES ('Аркобалено', 1000003);
INSERT INTO public.work_place VALUES ('Аркобалено', 1000004);
INSERT INTO public.work_place VALUES ('Виктор', 1000005);
INSERT INTO public.work_place VALUES ('Виктор', 1000006);


--
-- TOC entry 3468 (class 0 OID 18607)
-- Dependencies: 220
-- Data for Name: workers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.workers VALUES (4000001, 'Анастасия', 'Анисимова', 'Степановна', 'ж', '1982-11-11', '84000000001', 40, 0, 'waiter_mone');
INSERT INTO public.workers VALUES (4000002, 'Александра', 'Бубнова', 'Блондиновна', 'ж', '1982-12-12', '84000000002', 40, 0, 'waiter_mone');
INSERT INTO public.workers VALUES (4000003, 'Илья', 'Уродов', 'Владимирович', 'м', '1982-10-10', '84000000003', 40, 0, 'waiter_mone');
INSERT INTO public.workers VALUES (4000004, 'Ева', 'Белецкая', 'Никитовна', 'ж', '1982-09-09', '84000000004', 40, 0, 'waiter_mone');
INSERT INTO public.workers VALUES (4000006, 'Официант', 'Официантов', 'Официантович', 'м', '1982-07-07', '84000000006', 40, 0, 'waiter_arcobaleno');
INSERT INTO public.workers VALUES (4000007, 'Бук', 'Буков', 'Букович', 'м', '1983-11-01', '84000000007', 40, 0, 'waiter_arcobaleno');
INSERT INTO public.workers VALUES (2000002, 'Ольга', 'Воронцова', 'Владимировна', 'ж', '2003-10-28', '82000000002', 40, 0, 'barmen_mone');
INSERT INTO public.workers VALUES (2000006, 'Тартар', 'Тар', 'Тартарович', 'м', '2000-12-11', '82000000006', 40, 0, 'barmen_victor');
INSERT INTO public.workers VALUES (2000003, 'Михаил', 'Тимонин', 'Сергеевич', 'м', '2007-12-21', '82000000003', 40, 0, 'barmen_arcobaleno');
INSERT INTO public.workers VALUES (2000004, 'Бармен', 'Бар', 'Барменович', 'м', '1999-12-12', '82000000004', 40, 0, 'barmen_arcobaleno');
INSERT INTO public.workers VALUES (3000001, 'Арсений', 'Чуганин', 'Андреевич', 'м', '1980-01-01', '83000000001', 40, 0, 'cook_mone');
INSERT INTO public.workers VALUES (3000002, 'Максим', 'Лавров', 'Огузович', 'м', '1981-10-28', '83000000002', 40, 0, 'cook_mone');
INSERT INTO public.workers VALUES (3000004, 'Федор', 'Юрченко', 'Михайлович', 'м', '1981-01-01', '83000000004', 40, 0, 'cook_mone');
INSERT INTO public.workers VALUES (3000009, 'Мохито', 'Мох', 'Мохитович', 'м', '1990-10-12', '83000000009', 40, 0, 'cook_victor');
INSERT INTO public.workers VALUES (3000010, 'Ананас', 'Анан', 'Ананасович', 'м', '1990-10-13', '83000000010', 40, 0, 'cook_victor');
INSERT INTO public.workers VALUES (3000011, 'Крем', 'Кремов', 'Кремович', 'м', '1990-10-14', '83000000011', 40, 0, 'cook_victor');
INSERT INTO public.workers VALUES (3000012, 'Помидор', 'Сеньор', 'Помидорович', 'м', '1990-10-15', '83000000012', 40, 0, 'cook_victor');
INSERT INTO public.workers VALUES (3000005, 'Денис', 'Крылов', 'Андреевич', 'м', '1982-10-28', '83000000005', 40, 0, 'cook_arcobaleno');
INSERT INTO public.workers VALUES (3000006, 'Лев', 'Соловьев', 'Семенович', 'м', '1982-12-21', '83000000006', 40, 0, 'cook_arcobaleno');
INSERT INTO public.workers VALUES (3000008, 'Суп', 'Супов', 'Супович', 'м', '1990-10-11', '83000000008', 40, 0, 'cook_arcobaleno');
INSERT INTO public.workers VALUES (4000005, 'Виолетта', 'Второстепенная', 'Заднеплановна', 'ж', '1982-08-08', '84000000005', 47, 2625, 'waiter_arcobaleno');
INSERT INTO public.workers VALUES (4000009, 'Михаил', 'Михаилов', 'Михаилович', 'м', '1983-10-03', '84000000009', 40, 0, 'waiter_victor');
INSERT INTO public.workers VALUES (4000010, 'Екатерина', 'Екат', 'Екатериновна', 'ж', '1983-09-04', '84000000010', 40, 0, 'waiter_victor');
INSERT INTO public.workers VALUES (2000001, 'Константин', 'Анисимов', 'Тимофеевич', 'м', '1999-01-01', '82000000001', 40, 0, 'barmen_mone');
INSERT INTO public.workers VALUES (2000005, 'Оливье', 'Новогоднев', 'Салатович', 'м', '2000-11-21', '82000000005', 40, 0, 'barmen_victor');
INSERT INTO public.workers VALUES (1000002, 'Михаил', 'Гебреселассие', 'Джекович', 'м', '1982-05-05', '81000000002', 40, 0, 'manager_mone');
INSERT INTO public.workers VALUES (1000001, 'Виктория', 'Гончарова', 'Сергеевна', 'ж', '1982-06-06', '81000000001', 40, 0, 'manager_mone');
INSERT INTO public.workers VALUES (1000005, 'Мария', 'Мар', 'Мариевна', 'ж', '1982-02-02', '81000000005', 40, 0, 'manager_victor');
INSERT INTO public.workers VALUES (1000006, 'Иван', 'Иванов', 'Иванович', 'м', '1982-02-01', '81000000006', 40, 0, 'manager_victor');
INSERT INTO public.workers VALUES (1000004, 'Менеджер', 'Менеджеров', 'Менеджерович', 'м', '1982-03-03', '81000000004', 40, 0, 'manager_arcobaleno');
INSERT INTO public.workers VALUES (4000011, 'Сергей', 'Сергеев', 'Сергеевич', 'м', '1983-08-05', '84000000011', 40, 0, 'waiter_victor');
INSERT INTO public.workers VALUES (4000012, 'Виктор', 'Вик', 'Викторович', 'м', '1983-07-06', '84000000012', 40, 0, 'waiter_victor');
INSERT INTO public.workers VALUES (4000008, 'Елена', 'Еле', 'Еленовна', 'ж', '1983-12-02', '84000000008', 40, 0, 'waiter_arcobaleno');
INSERT INTO public.workers VALUES (3000007, 'Повар', 'Пов', 'Поваров', 'м', '1990-10-10', '83000000007', 40, 0, 'cook_arcobaleno');
INSERT INTO public.workers VALUES (1000003, 'София', 'Толстая', 'Яновна', 'ж', '1982-04-04', '81000000003', 27, -11700, 'manager_arcobaleno');
INSERT INTO public.workers VALUES (3000003, 'Виктор', 'Баринов', 'Петрович', 'м', '1970-12-21', '83000000003', 42, 1000, 'cook_mone');


--
-- TOC entry 3272 (class 2606 OID 18587)
-- Name: clients clients_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_email_key UNIQUE (email);


--
-- TOC entry 3274 (class 2606 OID 18589)
-- Name: clients clients_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_phone_number_key UNIQUE (phone_number);


--
-- TOC entry 3276 (class 2606 OID 18585)
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (card_id);


--
-- TOC entry 3262 (class 2606 OID 18470)
-- Name: dishes dishes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes
    ADD CONSTRAINT dishes_pkey PRIMARY KEY (dish_name);


--
-- TOC entry 3265 (class 2606 OID 18477)
-- Name: drinks drinks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinks
    ADD CONSTRAINT drinks_pkey PRIMARY KEY (drink_name);


--
-- TOC entry 3287 (class 2606 OID 18791)
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_name);


--
-- TOC entry 3268 (class 2606 OID 18495)
-- Name: restaurants restaurants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (restaurant_name);


--
-- TOC entry 3270 (class 2606 OID 18502)
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (company_name);


--
-- TOC entry 3284 (class 2606 OID 18624)
-- Name: work_place work_place_id_worker_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_place
    ADD CONSTRAINT work_place_id_worker_key UNIQUE (id_worker);


--
-- TOC entry 3280 (class 2606 OID 18617)
-- Name: workers workers_phone_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_phone_number_key UNIQUE (phone_number);


--
-- TOC entry 3282 (class 2606 OID 18613)
-- Name: workers workers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workers
    ADD CONSTRAINT workers_pkey PRIMARY KEY (id_worker);


--
-- TOC entry 3277 (class 1259 OID 18704)
-- Name: index_clients_card_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_clients_card_id ON public.clients USING btree (card_id);


--
-- TOC entry 3278 (class 1259 OID 18705)
-- Name: index_clients_phone_number; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX index_clients_phone_number ON public.clients USING btree (phone_number);


--
-- TOC entry 3263 (class 1259 OID 18702)
-- Name: index_dishes; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_dishes ON public.dishes USING btree (dish_name);


--
-- TOC entry 3266 (class 1259 OID 18701)
-- Name: index_drinks; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_drinks ON public.drinks USING btree (drink_name);


--
-- TOC entry 3285 (class 1259 OID 18797)
-- Name: index_products; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX index_products ON public.products USING btree (product_name);


--
-- TOC entry 3296 (class 2620 OID 18689)
-- Name: clients calc_points_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER calc_points_trigger BEFORE INSERT OR UPDATE OF spend_money ON public.clients FOR EACH ROW EXECUTE FUNCTION public.calc_points();


--
-- TOC entry 3297 (class 2620 OID 18693)
-- Name: clients calc_restaurant_earnings_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER calc_restaurant_earnings_trigger BEFORE UPDATE OF spend_money ON public.clients FOR EACH ROW EXECUTE FUNCTION public.calc_restaurant_earnings();


--
-- TOC entry 3298 (class 2620 OID 18773)
-- Name: workers calculate_premium_workers_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER calculate_premium_workers_trigger BEFORE INSERT OR UPDATE OF waste_hours, post ON public.workers FOR EACH ROW EXECUTE FUNCTION public.calculate_premium_workers();


--
-- TOC entry 3291 (class 2606 OID 18625)
-- Name: clientsrestaurants clientsrestaurants_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientsrestaurants
    ADD CONSTRAINT clientsrestaurants_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.clients(card_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3292 (class 2606 OID 18635)
-- Name: clientsrestaurants clientsrestaurants_restaurant_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientsrestaurants
    ADD CONSTRAINT clientsrestaurants_restaurant_name_fkey FOREIGN KEY (restaurant_name) REFERENCES public.restaurants(restaurant_name) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3288 (class 2606 OID 18524)
-- Name: dishes dishes_restaurant_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dishes
    ADD CONSTRAINT dishes_restaurant_name_fkey FOREIGN KEY (restaurant_name) REFERENCES public.restaurants(restaurant_name) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3289 (class 2606 OID 18529)
-- Name: drinks drinks_restaurant_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drinks
    ADD CONSTRAINT drinks_restaurant_name_fkey FOREIGN KEY (restaurant_name) REFERENCES public.restaurants(restaurant_name) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3295 (class 2606 OID 18792)
-- Name: products products_restaurant_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_restaurant_name_fkey FOREIGN KEY (restaurant_name) REFERENCES public.restaurants(restaurant_name) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3290 (class 2606 OID 18539)
-- Name: suppliers suppliers_restaurant_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_restaurant_name_fkey FOREIGN KEY (restaurant_name) REFERENCES public.restaurants(restaurant_name) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3293 (class 2606 OID 18650)
-- Name: work_place work_place_id_worker_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_place
    ADD CONSTRAINT work_place_id_worker_fkey FOREIGN KEY (id_worker) REFERENCES public.workers(id_worker) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3294 (class 2606 OID 18645)
-- Name: work_place work_place_restaurant_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_place
    ADD CONSTRAINT work_place_restaurant_name_fkey FOREIGN KEY (restaurant_name) REFERENCES public.restaurants(restaurant_name) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3453 (class 0 OID 18464)
-- Dependencies: 214
-- Name: dishes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.dishes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3458 (class 3256 OID 18779)
-- Name: dishes dishes_cook_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY dishes_cook_policy ON public.dishes TO cooks USING (((( SELECT work_place.restaurant_name
   FROM (public.work_place
     JOIN public.workers ON ((work_place.id_worker = workers.id_worker)))
  WHERE ((workers.post)::text = CURRENT_USER)
 LIMIT 1))::text = (restaurant_name)::text));


--
-- TOC entry 3456 (class 3256 OID 18777)
-- Name: dishes dishes_waiter_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY dishes_waiter_policy ON public.dishes TO waiters USING (((( SELECT work_place.restaurant_name
   FROM (public.work_place
     JOIN public.workers ON ((work_place.id_worker = workers.id_worker)))
  WHERE ((workers.post)::text = CURRENT_USER)
 LIMIT 1))::text = (restaurant_name)::text));


--
-- TOC entry 3454 (class 0 OID 18471)
-- Dependencies: 215
-- Name: drinks; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.drinks ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3459 (class 3256 OID 18784)
-- Name: drinks drinks_barmen_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY drinks_barmen_policy ON public.drinks TO barmens USING (((( SELECT work_place.restaurant_name
   FROM (public.work_place
     JOIN public.workers ON ((work_place.id_worker = workers.id_worker)))
  WHERE ((workers.post)::text = CURRENT_USER)
 LIMIT 1))::text = (restaurant_name)::text));


--
-- TOC entry 3457 (class 3256 OID 18778)
-- Name: drinks drinks_waiter_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY drinks_waiter_policy ON public.drinks TO waiters USING (((( SELECT work_place.restaurant_name
   FROM (public.work_place
     JOIN public.workers ON ((work_place.id_worker = workers.id_worker)))
  WHERE ((workers.post)::text = CURRENT_USER)
 LIMIT 1))::text = (restaurant_name)::text));


--
-- TOC entry 3455 (class 0 OID 18785)
-- Dependencies: 234
-- Name: products; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 3461 (class 3256 OID 18799)
-- Name: products products_barmen_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY products_barmen_policy ON public.products TO barmens USING (((( SELECT work_place.restaurant_name
   FROM (public.work_place
     JOIN public.workers ON ((work_place.id_worker = workers.id_worker)))
  WHERE ((workers.post)::text = CURRENT_USER)
 LIMIT 1))::text = (restaurant_name)::text));


--
-- TOC entry 3460 (class 3256 OID 18798)
-- Name: products products_cook_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY products_cook_policy ON public.products TO cooks USING (((( SELECT work_place.restaurant_name
   FROM (public.work_place
     JOIN public.workers ON ((work_place.id_worker = workers.id_worker)))
  WHERE ((workers.post)::text = CURRENT_USER)
 LIMIT 1))::text = (restaurant_name)::text));


--
-- TOC entry 3476 (class 0 OID 0)
-- Dependencies: 238
-- Name: FUNCTION calc_sum_earnings(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calc_sum_earnings() TO restaurant_managers;


--
-- TOC entry 3477 (class 0 OID 0)
-- Dependencies: 239
-- Name: FUNCTION find_product_and_min_keep_count(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.find_product_and_min_keep_count() TO barmens;
GRANT ALL ON FUNCTION public.find_product_and_min_keep_count() TO cooks;


--
-- TOC entry 3478 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE work_place; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.work_place TO restaurant_managers;
GRANT SELECT ON TABLE public.work_place TO waiters;
GRANT SELECT ON TABLE public.work_place TO cooks;
GRANT SELECT ON TABLE public.work_place TO barmens;


--
-- TOC entry 3479 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE workers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.workers TO restaurant_managers;
GRANT SELECT ON TABLE public.workers TO waiters;
GRANT SELECT ON TABLE public.workers TO cooks;
GRANT SELECT ON TABLE public.workers TO barmens;


--
-- TOC entry 3480 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE barmens_arcobaleno; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.barmens_arcobaleno TO restaurant_managers;


--
-- TOC entry 3481 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE barmens_klod_mone; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.barmens_klod_mone TO restaurant_managers;


--
-- TOC entry 3482 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE barmens_victor; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.barmens_victor TO restaurant_managers;


--
-- TOC entry 3483 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE clients; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.clients TO restaurant_managers;
GRANT SELECT,INSERT ON TABLE public.clients TO waiters;


--
-- TOC entry 3484 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE clientsrestaurants; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.clientsrestaurants TO restaurant_managers;


--
-- TOC entry 3485 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE cooks_arcobaleno; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.cooks_arcobaleno TO restaurant_managers;


--
-- TOC entry 3486 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE cooks_klod_mone; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.cooks_klod_mone TO restaurant_managers;


--
-- TOC entry 3487 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE cooks_victor; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.cooks_victor TO restaurant_managers;


--
-- TOC entry 3488 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE dishes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.dishes TO restaurant_managers;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.dishes TO cooks;
GRANT SELECT ON TABLE public.dishes TO waiters;


--
-- TOC entry 3489 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE drinks; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.drinks TO restaurant_managers;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.drinks TO barmens;
GRANT SELECT ON TABLE public.drinks TO waiters;


--
-- TOC entry 3490 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE managers_arcobaleno; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.managers_arcobaleno TO restaurant_managers;


--
-- TOC entry 3491 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE managers_klod_mone; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.managers_klod_mone TO restaurant_managers;


--
-- TOC entry 3492 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE managers_victor; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.managers_victor TO restaurant_managers;


--
-- TOC entry 3493 (class 0 OID 0)
-- Dependencies: 234
-- Name: TABLE products; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.products TO cooks;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.products TO barmens;
GRANT SELECT ON TABLE public.products TO restaurant_managers;


--
-- TOC entry 3494 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE restaurants; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.restaurants TO restaurant_managers;


--
-- TOC entry 3495 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE suppliers; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.suppliers TO restaurant_managers;


--
-- TOC entry 3496 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE waiters_arcobaleno; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.waiters_arcobaleno TO restaurant_managers;


--
-- TOC entry 3497 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE waiters_klod_mone; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.waiters_klod_mone TO restaurant_managers;


--
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE waiters_victor; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.waiters_victor TO restaurant_managers;


-- Completed on 2023-12-05 19:44:07

--
-- PostgreSQL database dump complete
--

