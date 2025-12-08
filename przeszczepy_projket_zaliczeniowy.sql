--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

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
-- Name: grupa_krwi; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.grupa_krwi AS ENUM (
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    '0+',
    '0-'
);


ALTER TYPE public.grupa_krwi OWNER TO postgres;

--
-- Name: plec; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.plec AS ENUM (
    'M',
    'K'
);


ALTER TYPE public.plec OWNER TO postgres;

--
-- Name: aktualizuj_przypisanie(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.aktualizuj_przypisanie() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE "Dawca"
    SET "przypisanie" = 1
    WHERE "id" = NEW."id_dawca";

    UPDATE "Biorca"
    SET "przypisanie" = 1
    WHERE "id" = NEW."id_biorca";

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.aktualizuj_przypisanie() OWNER TO postgres;

--
-- Name: losowa_data(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.losowa_data(priorytet integer) RETURNS date
    LANGUAGE plpgsql
    AS $$
DECLARE
    losowa_liczba INTEGER;
BEGIN
 CASE 
        WHEN priorytet = 1 THEN 
            losowa_liczba := floor(random() * 60) + 1; 
            RETURN CURRENT_DATE + losowa_liczba;
        WHEN priorytet = 2 THEN
            losowa_liczba := floor(random() * 336) + 60; 
            RETURN CURRENT_DATE + losowa_liczba;
        WHEN priorytet = 3 THEN
            losowa_liczba := floor(random() * 1461) + 365; 
            RETURN CURRENT_DATE + losowa_liczba;
        ELSE
            RETURN CURRENT_DATE;
    END CASE;
END;
$$;


ALTER FUNCTION public.losowa_data(priorytet integer) OWNER TO postgres;

--
-- Name: oblicz_wiek(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.oblicz_wiek(data_urodzenia date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN DATE_PART('year', AGE(CURRENT_DATE, data_urodzenia));
END;
$$;


ALTER FUNCTION public.oblicz_wiek(data_urodzenia date) OWNER TO postgres;

--
-- Name: roznica_wieku(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.roznica_wieku(data_urodzenia1 date, data_urodzenia2 date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN ABS(DATE_PART('year', AGE(data_urodzenia1, data_urodzenia2)));
END;
$$;


ALTER FUNCTION public.roznica_wieku(data_urodzenia1 date, data_urodzenia2 date) OWNER TO postgres;

--
-- Name: sprawdz_przeszczep(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sprawdz_przeszczep() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    dawca_organ_id INTEGER;
    biorca_organ_id INTEGER;
    lekarz_specjalizacja_id INTEGER;
BEGIN
    SELECT organ_id INTO dawca_organ_id
    FROM public."Dawca"
    WHERE id = NEW.id_dawca;

    SELECT organ_id INTO biorca_organ_id
    FROM public."Biorca"
    WHERE id = NEW.id_biorca;

    SELECT specjalizacja_id INTO lekarz_specjalizacja_id
    FROM public."Lekarz"
    WHERE id = NEW.id_lekarz;

    IF dawca_organ_id IS DISTINCT FROM biorca_organ_id OR dawca_organ_id IS DISTINCT FROM lekarz_specjalizacja_id THEN
        RAISE EXCEPTION 'Organ dawcy, biorcy i specjalizacja lekarza muszą być zgodne';
    END IF;

    IF NEW.data < CURRENT_DATE THEN
        RAISE EXCEPTION 'Data przeszczepu musi być co najmniej dzisiejsza';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.sprawdz_przeszczep() OWNER TO postgres;

--
-- Name: update_zajete_terminy(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_zajete_terminy() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO "ZajeteTerminy" ("data", "id_lekarz")
    VALUES (NEW."data", NEW."id_lekarz");

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_zajete_terminy() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Biorca; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Biorca" (
    id integer NOT NULL,
    imie character varying(50),
    nazwisko character varying(50),
    plec public.plec,
    organ_id integer,
    data_ur date,
    grupa_krwi public.grupa_krwi,
    priorytet integer,
    kontakt character varying(12),
    przypisanie integer
);


ALTER TABLE public."Biorca" OWNER TO postgres;

--
-- Name: Biorca_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Biorca_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Biorca_id_seq" OWNER TO postgres;

--
-- Name: Biorca_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Biorca_id_seq" OWNED BY public."Biorca".id;


--
-- Name: Dawca; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Dawca" (
    id integer NOT NULL,
    imie character varying(50),
    nazwisko character varying(50),
    plec public.plec,
    organ_id integer,
    data_ur date,
    data_sm date,
    grupa_krwi public.grupa_krwi,
    kontakt character varying(12),
    przypisanie integer
);


ALTER TABLE public."Dawca" OWNER TO postgres;

--
-- Name: Dawca_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Dawca_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Dawca_id_seq" OWNER TO postgres;

--
-- Name: Dawca_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Dawca_id_seq" OWNED BY public."Dawca".id;


--
-- Name: Lekarz; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Lekarz" (
    id integer NOT NULL,
    imie character varying(50),
    nazwisko character varying(50),
    specjalizacja_id integer,
    id_szpital integer,
    kontakt character varying(50)
);


ALTER TABLE public."Lekarz" OWNER TO postgres;

--
-- Name: Lekarz_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Lekarz_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Lekarz_id_seq" OWNER TO postgres;

--
-- Name: Lekarz_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Lekarz_id_seq" OWNED BY public."Lekarz".id;


--
-- Name: Organ; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Organ" (
    id integer NOT NULL,
    nazwa character varying(30)
);


ALTER TABLE public."Organ" OWNER TO postgres;

--
-- Name: Organ_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Organ_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Organ_id_seq" OWNER TO postgres;

--
-- Name: Organ_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Organ_id_seq" OWNED BY public."Organ".id;


--
-- Name: Priorytet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Priorytet" (
    id integer NOT NULL,
    nazwa character varying(50)
);


ALTER TABLE public."Priorytet" OWNER TO postgres;

--
-- Name: Priorytet_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Priorytet_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Priorytet_id_seq" OWNER TO postgres;

--
-- Name: Priorytet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Priorytet_id_seq" OWNED BY public."Priorytet".id;


--
-- Name: Przeszczep; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Przeszczep" (
    id integer NOT NULL,
    id_biorca integer,
    id_dawca integer,
    id_lekarz integer,
    data date
);


ALTER TABLE public."Przeszczep" OWNER TO postgres;

--
-- Name: Przeszczep_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Przeszczep_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Przeszczep_id_seq" OWNER TO postgres;

--
-- Name: Przeszczep_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Przeszczep_id_seq" OWNED BY public."Przeszczep".id;


--
-- Name: Specjalizacja; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Specjalizacja" (
    id integer NOT NULL,
    nazwa character varying(50),
    id_organ integer
);


ALTER TABLE public."Specjalizacja" OWNER TO postgres;

--
-- Name: Specjalizacja_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Specjalizacja_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Specjalizacja_id_seq" OWNER TO postgres;

--
-- Name: Specjalizacja_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Specjalizacja_id_seq" OWNED BY public."Specjalizacja".id;


--
-- Name: Szpital; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Szpital" (
    id integer NOT NULL,
    nazwa character varying(50),
    adres character varying(70),
    kontakt character varying(12)
);


ALTER TABLE public."Szpital" OWNER TO postgres;

--
-- Name: Szpital_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."Szpital_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Szpital_id_seq" OWNER TO postgres;

--
-- Name: Szpital_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."Szpital_id_seq" OWNED BY public."Szpital".id;


--
-- Name: ZajeteTerminy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."ZajeteTerminy" (
    id_lekarz integer,
    data date
);


ALTER TABLE public."ZajeteTerminy" OWNER TO postgres;

--
-- Name: kontakt_przeszczep; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.kontakt_przeszczep AS
 SELECT p.id AS przeszczep,
    b.kontakt AS biorca,
    d.kontakt AS dawca,
    l.kontakt AS lekarz,
    sz.kontakt AS szpital
   FROM ((((public."Przeszczep" p
     LEFT JOIN public."Biorca" b ON ((b.id = p.id_biorca)))
     LEFT JOIN public."Dawca" d ON ((d.id = p.id_dawca)))
     LEFT JOIN public."Lekarz" l ON ((l.id = p.id_lekarz)))
     LEFT JOIN public."Szpital" sz ON ((sz.id = l.id_szpital)));


ALTER VIEW public.kontakt_przeszczep OWNER TO postgres;

--
-- Name: lekarz_info; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.lekarz_info AS
 SELECT (((l.imie)::text || ' '::text) || (l.nazwisko)::text) AS lekarz,
    s.nazwa AS specjalizacja,
    (((sz.nazwa)::text || ', '::text) || (sz.adres)::text) AS szpital
   FROM ((public."Lekarz" l
     LEFT JOIN public."Specjalizacja" s ON ((l.specjalizacja_id = s.id)))
     LEFT JOIN public."Szpital" sz ON ((l.id_szpital = sz.id)));


ALTER VIEW public.lekarz_info OWNER TO postgres;

--
-- Name: przeszczep_biorca_dawca; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.przeszczep_biorca_dawca AS
 SELECT p.id AS przeszczep_id,
    p.data AS przeszczep_data,
    (((b.imie)::text || ' '::text) || (b.nazwisko)::text) AS biorca,
    public.oblicz_wiek(b.data_ur) AS wiek_biorcy,
    (((d.imie)::text || ' '::text) || (d.nazwisko)::text) AS dawca,
    public.oblicz_wiek(d.data_ur) AS wiek_dawcy,
    o.nazwa AS organ
   FROM (((public."Przeszczep" p
     LEFT JOIN public."Biorca" b ON ((p.id_biorca = b.id)))
     LEFT JOIN public."Dawca" d ON ((p.id_dawca = d.id)))
     LEFT JOIN public."Organ" o ON ((d.organ_id = o.id)));


ALTER VIEW public.przeszczep_biorca_dawca OWNER TO postgres;

--
-- Name: przeszczep_lekarz_szpital; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.przeszczep_lekarz_szpital AS
 SELECT p.id,
    (((l.imie)::text || ' '::text) || (l.nazwisko)::text) AS lekarz,
    s.nazwa AS specjalizacja_lekarz,
    sz.nazwa AS nazwa_szpital,
    sz.adres AS adres_szpital
   FROM (((public."Przeszczep" p
     LEFT JOIN public."Lekarz" l ON ((p.id_lekarz = l.id)))
     LEFT JOIN public."Specjalizacja" s ON ((l.specjalizacja_id = s.id)))
     LEFT JOIN public."Szpital" sz ON ((l.id_szpital = sz.id)));


ALTER VIEW public.przeszczep_lekarz_szpital OWNER TO postgres;

--
-- Name: zapotrzebowanie_organ; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.zapotrzebowanie_organ AS
 SELECT o.nazwa AS organ,
    COALESCE(b.zapotrzebowanie, (0)::bigint) AS zapotrzebowanie,
    COALESCE(d.dostepnosc, (0)::bigint) AS dostepnosc
   FROM ((public."Organ" o
     LEFT JOIN ( SELECT "Biorca".organ_id,
            count(*) AS zapotrzebowanie
           FROM public."Biorca"
          GROUP BY "Biorca".organ_id) b ON ((o.id = b.organ_id)))
     LEFT JOIN ( SELECT "Dawca".organ_id,
            count(*) AS dostepnosc
           FROM public."Dawca"
          GROUP BY "Dawca".organ_id) d ON ((o.id = d.organ_id)));


ALTER VIEW public.zapotrzebowanie_organ OWNER TO postgres;

--
-- Name: Biorca id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Biorca" ALTER COLUMN id SET DEFAULT nextval('public."Biorca_id_seq"'::regclass);


--
-- Name: Dawca id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dawca" ALTER COLUMN id SET DEFAULT nextval('public."Dawca_id_seq"'::regclass);


--
-- Name: Lekarz id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lekarz" ALTER COLUMN id SET DEFAULT nextval('public."Lekarz_id_seq"'::regclass);


--
-- Name: Organ id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Organ" ALTER COLUMN id SET DEFAULT nextval('public."Organ_id_seq"'::regclass);


--
-- Name: Priorytet id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Priorytet" ALTER COLUMN id SET DEFAULT nextval('public."Priorytet_id_seq"'::regclass);


--
-- Name: Przeszczep id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Przeszczep" ALTER COLUMN id SET DEFAULT nextval('public."Przeszczep_id_seq"'::regclass);


--
-- Name: Specjalizacja id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Specjalizacja" ALTER COLUMN id SET DEFAULT nextval('public."Specjalizacja_id_seq"'::regclass);


--
-- Name: Szpital id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Szpital" ALTER COLUMN id SET DEFAULT nextval('public."Szpital_id_seq"'::regclass);


--
-- Data for Name: Biorca; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Biorca" (id, imie, nazwisko, plec, organ_id, data_ur, grupa_krwi, priorytet, kontakt, przypisanie) FROM stdin;
131	Jan	Zieliński	M	3	1982-03-05	AB+	2	333444000	1
40	Patryk	Wojciechowski	M	1	1977-04-05	A+	2	567890123	1
88	Andrzej	Wiśniewski	M	2	1984-10-20	B-	2	222333777	1
94	Tomasz	Kowal	M	3	1983-11-25	B+	2	888999333	1
101	Agnieszka	Pawlak	K	5	1984-06-15	A+	3	555666111	1
86	Marcin	Mazur	M	5	1981-02-25	0+	3	000111444	\N
15	Karolina	Pawlak	K	5	1980-03-20	A+	3	555666888	\N
70	Tomasz	Sokołowski	M	4	1992-09-14	0-	2	444555777	\N
97	Katarzyna	Wysocka	K	1	1990-11-22	A-	2	111222777	\N
93	Monika	Zielińska	K	2	1989-03-12	A-	1	777888222	\N
95	Barbara	Nowicka	K	4	1985-02-15	AB+	3	999000444	\N
96	Dawid	Wiśniewski	M	5	1987-08-30	0+	1	000111555	\N
99	Magdalena	Mazur	K	3	1986-09-30	AB+	1	333444999	\N
102	Michał	Nowak	M	1	1992-10-25	0+	1	666777222	\N
103	Anna	Kaczmarek	K	2	1985-05-22	A-	2	777888333	\N
104	Grzegorz	Wiśniewski	M	3	1987-08-05	B-	3	888999444	\N
105	Joanna	Król	K	4	1991-12-12	AB+	1	999000555	\N
106	Piotr	Wójcik	M	5	1978-04-10	0-	2	000111666	\N
107	Marek	Adamski	M	1	1980-09-15	A-	3	111222888	\N
123	Agnieszka	Pawlak	K	5	1984-06-15	A+	3	555666111	\N
122	Piotr	Zieliński	M	4	1993-01-20	0-	2	444555000	\N
57	Janusz	Kowal	M	1	1980-05-20	0-	2	666777000	\N
108	Magdalena	Kowalska	K	2	1984-07-10	B+	1	222333999	\N
111	Kinga	Wysocka	K	3	1990-01-10	AB+	3	333444888	\N
112	Wojciech	Kowalski	M	4	1979-09-30	0-	1	444555999	\N
113	Magdalena	Pawlak	K	5	1988-04-20	A+	2	555666000	\N
115	Monika	Zielińska	K	2	1989-03-12	A-	1	777888222	\N
116	Tomasz	Kowal	M	3	1991-11-25	B+	2	888999333	\N
117	Barbara	Nowicka	K	4	1985-02-15	AB+	3	999000444	\N
118	Dawid	Wiśniewski	M	5	1987-08-30	0+	1	000111555	\N
121	Magdalena	Mazur	K	3	1986-09-30	AB+	1	333444999	\N
124	Michał	Nowak	M	1	1992-10-25	0+	1	666777222	\N
125	Anna	Kaczmarek	K	2	1985-05-22	A-	2	777888333	\N
126	Grzegorz	Wiśniewski	M	3	1987-08-05	B-	3	888999444	\N
127	Joanna	Król	K	4	1991-12-12	AB+	1	999000555	\N
22	Bartosz	Woźniak	M	3	1984-06-07	B+	2	789012345	\N
23	Karolina	Dąbrowska	K	4	1991-12-05	AB-	3	890123456	\N
24	Rafał	Kaczmarek	M	5	1989-04-21	A+	1	901234567	\N
26	Sebastian	Pawlak	M	2	1992-08-09	A-	3	123456780	\N
27	Natalia	Kowalska	K	3	1987-01-24	B-	1	234567890	\N
28	Tomasz	Zalewski	M	4	1979-12-28	AB+	2	345678901	\N
29	Ewelina	Nowicka	K	5	1990-05-18	0-	3	456789012	\N
30	Marek	Jankowski	M	1	1986-07-30	B+	1	567890123	\N
31	Joanna	Król	K	2	1982-03-03	AB-	2	678901234	\N
32	Adam	Kamiński	M	3	1985-11-11	A+	3	789012345	\N
33	Anna	Lewandowska	K	4	1978-06-14	0+	1	890123456	\N
34	Kamil	Piotrowski	M	5	1991-01-27	A-	2	901234567	\N
35	Sylwia	Sikorska	K	1	1980-09-02	B-	3	012345678	\N
36	Łukasz	Wróbel	M	2	1983-12-22	AB+	1	123456789	\N
37	Katarzyna	Górska	K	3	1986-11-16	0-	2	234567890	\N
38	Grzegorz	Kwiatkowski	M	4	1989-07-20	B+	3	345678901	\N
39	Magdalena	Kozłowska	K	5	1992-05-12	AB-	1	456789012	\N
41	Izabela	Mazurek	K	2	1984-01-19	0+	3	678901234	\N
42	Jakub	Szymczak	M	3	1991-08-24	A-	1	789012345	\N
43	Maria	Pawłowska	K	4	1987-10-13	B-	2	890123456	\N
44	Marcin	Adamski	M	5	1981-06-08	AB+	3	901234567	\N
45	Zuzanna	Chmielewska	K	1	1990-03-26	0-	1	012345678	\N
46	Andrzej	Głowacki	M	2	1982-07-18	B+	2	123456780	\N
48	Anna	Nowicka	K	2	1990-06-25	B-	2	777888000	\N
49	Michał	Kowalski	M	3	1973-12-01	AB-	3	888999111	\N
51	Piotr	Król	M	5	1991-01-15	0-	2	000111333	\N
54	Katarzyna	Wójcik	K	3	1989-09-25	AB+	2	333444777	\N
59	Rafał	Duda	M	3	1991-08-30	AB+	1	888999222	\N
64	Grzegorz	Zając	M	3	1991-12-05	AB-	2	888999000	\N
66	Kamil	Wysocki	M	5	1986-11-30	0+	1	000111222	\N
60	Sylwia	Kowal	K	4	1985-12-10	A+	2	999000333	\N
85	Sylwia	Kowal	K	4	1985-12-10	A+	2	999000333	\N
25	Zofia	Wójcik	K	1	1983-10-17	0+	2	012345678	\N
119	Katarzyna	Wysocka	K	1	1990-11-22	A-	2	111222777	\N
5	Ewelina	Kowal	K	5	1978-11-12	A-	2	555666777	\N
67	Monika	Adamska	K	1	1995-02-10	A-	2	111222444	\N
69	Magdalena	Dąbrowska	K	3	1988-04-12	AB+	1	333444666	\N
73	Anna	Nowicka	K	2	1990-06-25	B-	2	777888000	\N
74	Michał	Kowalski	M	3	1973-12-01	AB-	3	888999111	\N
76	Piotr	Król	M	5	1991-01-15	0-	2	000111333	\N
79	Katarzyna	Wójcik	K	3	1989-09-25	AB+	2	333444777	\N
84	Rafał	Duda	M	3	1991-08-30	AB+	1	888999222	\N
87	Ewa	Król	K	1	1993-06-05	A-	1	111222666	1
78	Marek	Adamski	M	2	1985-03-22	B+	1	222333666	1
4	Adam	Wójcik	M	4	1982-01-30	0+	1	444555666	1
50	Elżbieta	Wysocka	K	4	1984-08-10	A+	1	999000222	1
81	Beata	Wiśniewska	K	5	1978-07-30	A-	1	555666999	1
72	Dawid	Kubiak	M	1	1979-11-30	0+	1	666777999	1
62	Ewa	Król	K	1	1993-06-05	A-	1	111222666	\N
7	Barbara	Mazur	K	2	1987-08-22	B+	1	777888999	\N
53	Marek	Adamski	M	2	1985-03-22	B+	1	222333666	\N
1	Agnieszka	Nowak	K	1	1985-05-10	A+	1	111222333	\N
89	Kinga	Wysocka	K	3	1990-01-10	AB+	3	333444888	\N
90	Wojciech	Kowalski	M	4	1979-09-30	0-	1	444555999	\N
91	Magdalena	Pawlak	K	5	1988-04-20	A+	2	555666000	\N
110	Andrzej	Wiśniewski	M	2	1984-10-20	B-	2	222333777	1
56	Beata	Wiśniewska	K	5	1978-07-30	A-	1	555666999	\N
109	Jan	Zieliński	M	3	1982-03-05	AB+	2	333444000	\N
75	Elżbieta	Wysocka	K	4	1984-08-10	A+	1	999000222	\N
128	Piotr	Wójcik	M	5	1978-04-10	0-	2	000111666	\N
129	Marek	Adamski	M	1	1980-09-15	A-	3	111222888	\N
130	Magdalena	Kowalska	K	2	1984-07-10	B+	1	222333999	\N
2	Michał	Kowalski	M	2	1972-03-25	B-	2	222333444	\N
14	Tomasz	Sokołowski	M	4	1992-09-14	0-	2	444555777	\N
12	Jan	Jankowski	M	2	1975-05-22	B-	3	222333555	\N
80	Jakub	Zieliński	M	4	1990-02-10	0+	3	444555888	\N
6	Paweł	Kaczmarek	M	1	1981-03-14	0-	3	666777888	\N
55	Jakub	Zieliński	M	4	1990-02-10	0+	3	444555888	\N
3	Joanna	Wiśniewska	K	3	1990-09-17	AB+	3	333444555	\N
120	Paweł	Król	M	2	1981-04-25	B-	3	222333888	\N
58	Joanna	Kaczmarek	K	2	1987-04-22	B-	3	777888111	\N
77	Agnieszka	Nowak	K	1	1982-10-20	A-	3	111222555	\N
114	Piotr	Kowal	M	1	1983-05-25	0+	3	666777111	\N
9	Marta	Król	K	4	1983-07-19	A+	3	999000111	\N
8	Grzegorz	Zając	M	3	1991-12-05	AB-	2	888999000	\N
10	Kamil	Wysocki	M	5	1986-11-30	0+	1	000111222	\N
11	Monika	Adamska	K	1	1995-02-10	A-	2	111222444	\N
13	Magdalena	Dąbrowska	K	3	1988-04-12	AB+	1	333444666	\N
16	Damian	Nowak	M	2	1980-05-14	A+	2	123456789	\N
17	Ewa	Kowalczyk	K	3	1985-08-23	B-	3	234567890	\N
18	Wojciech	Zieliński	M	4	1977-11-12	AB+	1	345678901	\N
19	Alicja	Kowalska	K	5	1993-03-15	0+	2	456789012	\N
21	Agnieszka	Wiśniewska	K	2	1981-02-25	0-	1	678901234	\N
100	Piotr	Zieliński	M	4	1993-01-20	0-	2	444555000	\N
47	Dawid	Kubiak	M	1	1979-11-30	0+	1	666777999	\N
63	Barbara	Mazur	K	2	1987-08-22	B+	1	777888999	\N
82	Janusz	Kowal	M	1	1980-05-20	0-	2	666777000	\N
52	Agnieszka	Nowak	K	1	1982-10-20	A-	3	111222555	\N
92	Piotr	Kowal	M	1	1983-05-25	0+	3	666777111	\N
83	Joanna	Kaczmarek	K	2	1987-04-22	B-	3	777888111	\N
68	Jan	Jankowski	M	2	1975-05-22	B-	3	222333555	\N
65	Marta	Król	K	4	1983-07-19	A+	3	999000111	\N
98	Paweł	Król	M	2	1981-04-25	B-	3	222333888	\N
20	Maciej	Szymański	M	1	1988-09-19	A-	3	567890123	\N
61	Marcin	Mazur	M	5	1981-02-25	0+	3	000111444	\N
71	Karolina	Pawlak	K	5	1980-03-20	A+	3	555666888	\N
\.


--
-- Data for Name: Dawca; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Dawca" (id, imie, nazwisko, plec, organ_id, data_ur, data_sm, grupa_krwi, kontakt, przypisanie) FROM stdin;
3	Ewa	Wiśniewska	K	3	1979-02-25	2019-12-12	AB+	345678901	\N
5	Magdalena	Kowalczyk	K	5	1978-08-14	2022-03-25	A-	567890123	1
8	Krzysztof	Zając	M	3	1983-06-21	2018-10-10	B+	890123456	1
7	Joanna	Mazur	K	2	1990-09-05	\N	B+	\N	1
6	Paweł	Kaczmarek	M	1	1982-03-11	2020-05-16	0-	678901234	\N
10	Grzegorz	Wysocki	M	5	1976-11-11	2017-08-22	0+	012345678	\N
9	Karolina	Król	K	4	1981-12-12	2019-01-01	A+	901234567	1
16	Marcin	Kubiak	M	1	1985-08-24	2018-06-17	0+	678901234	1
13	Justyna	Dąbrowska	K	3	1977-02-10	2021-07-14	AB+	345678901	1
1	Anna	Nowak	K	1	1975-05-20	2021-04-15	A+	123456789	1
12	Rafał	Jankowski	M	2	1984-03-15	2016-12-30	B-	234567890	1
2	Tomasz	Kowalski	M	2	1980-07-18	2020-09-20	B-	234567890	1
15	Marta	Pawlak	K	5	1980-05-09	2019-04-22	A+	567890123	1
14	Wojciech	Sokołowski	M	4	1992-10-18	\N	0-	\N	\N
11	Katarzyna	Adamska	K	1	1988-04-19	\N	A-	\N	1
4	Michał	Wójcik	M	4	1985-01-30	\N	0+	\N	1
\.


--
-- Data for Name: Lekarz; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Lekarz" (id, imie, nazwisko, specjalizacja_id, id_szpital, kontakt) FROM stdin;
1	Jan	Kowalski	1	1	884011655
2	Anna	Nowak	2	2	222333444
3	Piotr	Wiśniewski	3	3	333444555
4	Katarzyna	Wójcik	4	4	444555666
5	Tomasz	Kowal	5	5	555666777
6	Monika	Zielińska	1	6	666777888
7	Marek	Kamiński	2	7	777888999
8	Joanna	Lewandowska	3	8	888999000
9	Adam	Szymański	4	9	999000111
10	Magdalena	Zalewska	5	10	000111222
11	Grzegorz	Piotrowski	1	11	111222444
12	Paweł	Włodarczyk	2	12	222333555
\.


--
-- Data for Name: Organ; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Organ" (id, nazwa) FROM stdin;
1	Serce
2	Wątroba
3	Płuca
4	Nerki
5	Trzustka
\.


--
-- Data for Name: Priorytet; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Priorytet" (id, nazwa) FROM stdin;
1	Wysoki
2	Średni
3	Niski
\.


--
-- Data for Name: Przeszczep; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Przeszczep" (id, id_biorca, id_dawca, id_lekarz, data) FROM stdin;
534	87	11	11	2024-06-25
535	78	7	12	2024-07-23
536	4	4	9	2024-06-01
537	50	9	4	2024-06-15
538	81	5	10	2024-07-01
539	72	16	6	2024-06-05
540	131	13	8	2024-10-31
541	40	1	1	2025-04-21
542	88	12	7	2024-08-10
543	94	8	3	2025-05-14
544	110	2	2	2025-03-24
545	101	15	5	2027-10-20
\.


--
-- Data for Name: Specjalizacja; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Specjalizacja" (id, nazwa, id_organ) FROM stdin;
1	Kardiolog	1
2	Hepatolog	2
3	Pulmonolog	3
4	Nefrolog	4
5	Hepatolog	5
\.


--
-- Data for Name: Szpital; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."Szpital" (id, nazwa, adres, kontakt) FROM stdin;
1	Szpital Uniwersytecki	ul. Uniwersytecka 1, Kraków	123456789
2	Szpital Wojewódzki	ul. Wojewódzka 10, Warszawa	987654321
3	Szpital Miejski	ul. Miejska 5, Wrocław	456789123
4	Szpital Kliniczny	ul. Kliniczna 3, Poznań	321654987
5	Szpital Specjalistyczny	ul. Specjalistyczna 8, Gdańsk	654123987
6	Szpital Powiatowy	ul. Powiatowa 15, Łódź	789456123
7	Szpital Wojskowy	ul. Wojskowa 7, Lublin	987321654
8	Szpital Akademicki	ul. Akademicka 12, Katowice	123789456
9	Szpital Prywatny	ul. Prywatna 6, Białystok	789123456
10	Szpital Onkologiczny	ul. Onkologiczna 4, Olsztyn	321987654
11	Szpital Chorób Zakaźnych	ul. Zakaźna 11, Rzeszów	654789321
12	Szpital Geriatryczny	ul. Geriatryczna 18, Zielona Góra	654987321
\.


--
-- Data for Name: ZajeteTerminy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."ZajeteTerminy" (id_lekarz, data) FROM stdin;
11	2024-06-25
12	2024-07-23
9	2024-06-01
4	2024-06-15
10	2024-07-01
6	2024-06-05
8	2024-10-31
1	2025-04-21
7	2024-08-10
3	2025-05-14
2	2025-03-24
5	2027-10-20
\.


--
-- Name: Biorca_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Biorca_id_seq"', 131, true);


--
-- Name: Dawca_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Dawca_id_seq"', 16, true);


--
-- Name: Lekarz_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Lekarz_id_seq"', 12, true);


--
-- Name: Organ_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Organ_id_seq"', 5, true);


--
-- Name: Priorytet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Priorytet_id_seq"', 1, false);


--
-- Name: Przeszczep_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Przeszczep_id_seq"', 545, true);


--
-- Name: Specjalizacja_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Specjalizacja_id_seq"', 5, true);


--
-- Name: Szpital_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Szpital_id_seq"', 12, true);


--
-- Name: Biorca Biorca_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Biorca"
    ADD CONSTRAINT "Biorca_pkey" PRIMARY KEY (id);


--
-- Name: Dawca Dawca_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dawca"
    ADD CONSTRAINT "Dawca_pkey" PRIMARY KEY (id);


--
-- Name: Lekarz Lekarz_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lekarz"
    ADD CONSTRAINT "Lekarz_pkey" PRIMARY KEY (id);


--
-- Name: Organ Organ_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Organ"
    ADD CONSTRAINT "Organ_pkey" PRIMARY KEY (id);


--
-- Name: Priorytet Priorytet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Priorytet"
    ADD CONSTRAINT "Priorytet_pkey" PRIMARY KEY (id);


--
-- Name: Przeszczep Przeszczep_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Przeszczep"
    ADD CONSTRAINT "Przeszczep_pkey" PRIMARY KEY (id);


--
-- Name: Specjalizacja Specjalizacja_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Specjalizacja"
    ADD CONSTRAINT "Specjalizacja_pkey" PRIMARY KEY (id);


--
-- Name: Szpital Szpital_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Szpital"
    ADD CONSTRAINT "Szpital_pkey" PRIMARY KEY (id);


--
-- Name: Przeszczep after_insert_przeszczep; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_insert_przeszczep AFTER INSERT ON public."Przeszczep" FOR EACH ROW EXECUTE FUNCTION public.update_zajete_terminy();


--
-- Name: Przeszczep aktualizuj_przypisanie_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER aktualizuj_przypisanie_trigger AFTER INSERT ON public."Przeszczep" FOR EACH ROW EXECUTE FUNCTION public.aktualizuj_przypisanie();


--
-- Name: Przeszczep sprawdz_przeszczep_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER sprawdz_przeszczep_trigger BEFORE INSERT OR UPDATE ON public."Przeszczep" FOR EACH ROW EXECUTE FUNCTION public.sprawdz_przeszczep();


--
-- Name: Biorca Biorca_organ_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Biorca"
    ADD CONSTRAINT "Biorca_organ_id_fkey" FOREIGN KEY (organ_id) REFERENCES public."Organ"(id);


--
-- Name: Biorca Biorca_priorytet_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Biorca"
    ADD CONSTRAINT "Biorca_priorytet_fkey" FOREIGN KEY (priorytet) REFERENCES public."Priorytet"(id);


--
-- Name: Dawca Dawca_organ_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Dawca"
    ADD CONSTRAINT "Dawca_organ_id_fkey" FOREIGN KEY (organ_id) REFERENCES public."Organ"(id);


--
-- Name: Lekarz Lekarz_id_szpital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lekarz"
    ADD CONSTRAINT "Lekarz_id_szpital_fkey" FOREIGN KEY (id_szpital) REFERENCES public."Szpital"(id);


--
-- Name: Lekarz Lekarz_specjalizacja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Lekarz"
    ADD CONSTRAINT "Lekarz_specjalizacja_id_fkey" FOREIGN KEY (specjalizacja_id) REFERENCES public."Specjalizacja"(id);


--
-- Name: Przeszczep Przeszczep_id_biorca_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Przeszczep"
    ADD CONSTRAINT "Przeszczep_id_biorca_fkey" FOREIGN KEY (id_biorca) REFERENCES public."Biorca"(id);


--
-- Name: Przeszczep Przeszczep_id_dawca_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Przeszczep"
    ADD CONSTRAINT "Przeszczep_id_dawca_fkey" FOREIGN KEY (id_dawca) REFERENCES public."Dawca"(id);


--
-- Name: Przeszczep Przeszczep_id_lekarz_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Przeszczep"
    ADD CONSTRAINT "Przeszczep_id_lekarz_fkey" FOREIGN KEY (id_lekarz) REFERENCES public."Lekarz"(id);


--
-- Name: Specjalizacja Specjalizacja_id_organ_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Specjalizacja"
    ADD CONSTRAINT "Specjalizacja_id_organ_fkey" FOREIGN KEY (id_organ) REFERENCES public."Organ"(id);


--
-- Name: ZajeteTerminy ZajeteTerminy_id_lekarz_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."ZajeteTerminy"
    ADD CONSTRAINT "ZajeteTerminy_id_lekarz_fkey" FOREIGN KEY (id_lekarz) REFERENCES public."Lekarz"(id);


--
-- PostgreSQL database dump complete
--

