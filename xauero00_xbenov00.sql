-----------------------------------------------------------
-- IDS 2. projekt - SQL databaze
-- Pavlina Auerova (xauero00)
-- Martin Benovic (xbenov00)
-- Zadani c. 61 - Kavarensky povalec
-----------------------------------------------------------

----------------------- 1. CAST ---------------------------
-- drop tabulek 
DROP TABLE Osoba CASCADE CONSTRAINTS;
DROP TABLE Majitel CASCADE CONSTRAINTS;
DROP TABLE Zamestnanec CASCADE CONSTRAINTS;
DROP TABLE Uzivatel CASCADE CONSTRAINTS;
DROP TABLE Zamestnava CASCADE CONSTRAINTS;
DROP TABLE Kavarna CASCADE CONSTRAINTS;
DROP TABLE Smena CASCADE CONSTRAINTS;
DROP TABLE Kava CASCADE CONSTRAINTS;
DROP TABLE Kavova_zrna CASCADE CONSTRAINTS;
DROP TABLE Cupping_akce CASCADE CONSTRAINTS;
DROP TABLE Recenze CASCADE CONSTRAINTS;
DROP TABLE Reakce CASCADE CONSTRAINTS;
DROP TABLE Vlastni CASCADE CONSTRAINTS;
DROP TABLE Navstevuje CASCADE CONSTRAINTS;
DROP TABLE Nabizi CASCADE CONSTRAINTS;
DROP TABLE Akce_nabizi CASCADE CONSTRAINTS;
DROP TABLE Sedelaz CASCADE CONSTRAINTS;
DROP TABLE Porada CASCADE CONSTRAINTS;
DROP TABLE Oblibena_kavarna CASCADE CONSTRAINTS;
DROP TABLE Oblibena_kava CASCADE CONSTRAINTS;
-- 4. cast
DROP SEQUENCE seq_recenze; 
DROP PROCEDURE prum_cena_ochutnavky;
DROP PROCEDURE pocet_navstevniku_kavarny;
DROP MATERIALIZED VIEW cupping_akce_kava;

--vytvoreni tabulek
CREATE TABLE Osoba(
id INT NOT NULL PRIMARY KEY,
jmeno VARCHAR(30) NOT NULL, 
prijmeni VARCHAR(30) NOT NULL,
heslo CHAR(50) NOT NULL,
telefon CHAR(13) NOT NULL CHECK(REGEXP_LIKE(telefon, '[\+0-9]{4} ?[0-9]{3} ?[0-9]{3} ?[0-9]{3}')), 
datum_narozeni DATE NOT NULL,
email VARCHAR(50) NOT NULL UNIQUE CHECK(REGEXP_LIKE(email, '^[a-z]+[a-z0-9\.]*@[a-z0-9\.-]+\.[a-z]{2,}$'))
);

CREATE TABLE Majitel(
id_majitel INT,
id INT,
CONSTRAINT PK_majitel PRIMARY KEY (id_majitel),
CONSTRAINT FK_majitel_osoba FOREIGN KEY (id) REFERENCES Osoba ON DELETE CASCADE
);

CREATE TABLE Zamestnanec(
id_zamestnanec INT,
id INT,
cislo_uctu CHAR(15) NOT NULL UNIQUE CHECK(REGEXP_LIKE(cislo_uctu, '^(?:([0-9]{1,6})-)?([0-9]{2,10})\/([0-9]{4})$')), 
CONSTRAINT PK_zamestnanec PRIMARY KEY (id_zamestnanec),
CONSTRAINT FK_zamestnanec_osoba FOREIGN KEY (id) REFERENCES Osoba ON DELETE CASCADE
);

CREATE TABLE Uzivatel(
id_uzivatel INT,
prezdivka VARCHAR(50) NOT NULL UNIQUE,
pocet_vypitych_salku_denne INTEGER,
id INT,
CONSTRAINT PK_uzivatel PRIMARY KEY (id_uzivatel),
CONSTRAINT FK_uzivatel_osoba FOREIGN KEY (id) REFERENCES Osoba ON DELETE CASCADE
);

CREATE TABLE Zamestnava(
id_zamestnanec INT,
id_majitel INT,
id INT,
CONSTRAINT PK_zamestnava
    PRIMARY KEY (id_zamestnanec, id_majitel),
CONSTRAINT FK_zamestnava_zamestnance
    FOREIGN KEY (id)
    REFERENCES Majitel
    ON DELETE CASCADE,
CONSTRAINT FK_zamestnany
    FOREIGN KEY (id)
    REFERENCES Zamestnanec
    ON DELETE CASCADE
);

CREATE TABLE Kavarna(
ICO INT NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(ICO, '[0-9]{8}$')),
nazev VARCHAR(50) NOT NULL,
ulice VARCHAR(50) NOT NULL,
cislo_popisne INTEGER NOT NULL,
mesto VARCHAR(50) NOT NULL,
psc INTEGER NOT NULL,
hodin_od INT NOT NULL CHECK (hodin_od BETWEEN 0 AND 23),
hodin_do INT NOT NULL CHECK (hodin_do BETWEEN 0 AND 23),
pocet_mist INTEGER,
prumerne_hodnoceni INTEGER CHECK(REGEXP_LIKE(prumerne_hodnoceni, '[1-5]{1}'))
);

CREATE TABLE Smena(
den CHAR(2) CHECK (den IN('PO', 'UT', 'ST', 'CT', 'PA', 'SO', 'NE')),
smena_od INT NOT NULL CHECK (smena_od BETWEEN 0 AND 23),
smena_do INT NOT NULL CHECK (smena_do BETWEEN 0 AND 23),
id_zamestnance INT,
ICO_kavarny INT,
id INT,
ICO INT,
CONSTRAINT PK_smena PRIMARY KEY (id_zamestnance, ICO_kavarny),
CONSTRAINT FK_ma_smenu FOREIGN KEY (id) REFERENCES Zamestnanec ON DELETE CASCADE,
CONSTRAINT FK_smena_kavarna FOREIGN KEY (ICO) REFERENCES Kavarna ON DELETE CASCADE
);

CREATE TABLE Kava (
id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
nazev VARCHAR(30) NOT NULL,
zpusob_pripravy VARCHAR(50),
mnozstvi INTEGER NOT NULL, 
cena INTEGER NOT NULL 
);

CREATE TABLE Kavova_zrna (
id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
odruda VARCHAR(30) NOT NULL,
stupen_kyselosti VARCHAR(50),
aroma VARCHAR(30),
oblast_puvodu VARCHAR(50)
);

CREATE TABLE Cupping_akce (
id INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
datum_konani DATE,
akce_od INT NOT NULL CHECK (akce_od BETWEEN 0 AND 23),
akce_do INT NOT NULL CHECK (akce_do BETWEEN 0 AND 23),
pocet_volnych_mist INTEGER,
cena_ochutnavky NUMBER(3) NOT NULL
);

CREATE TABLE Recenze (
id INT NOT NULL,
ICO INT NOT NULL CHECK(REGEXP_LIKE(ICO, '^[0-9]{8}')),
datum DATE,
pocet_hvezdicek INTEGER,
obsah_recenze VARCHAR(250),
CONSTRAINT PK_recenze PRIMARY KEY (id),
CONSTRAINT FK_recenze FOREIGN KEY (ICO) REFERENCES Kavarna ON DELETE CASCADE
);

CREATE TABLE Reakce (
id_reakce INT,
id_recenze INT,
id INT,
datum DATE,
obsah_reakce VARCHAR(250),
pocet_palcu_nahoru INTEGER,
pocet_palcu_dolu INTEGER,
CONSTRAINT PK_reakce PRIMARY KEY (id_reakce, id_recenze),
CONSTRAINT FK_recenze_reakce FOREIGN KEY (id) REFERENCES Recenze ON DELETE CASCADE
);

CREATE TABLE Vlastni(
id INT,
ICO INT,
CONSTRAINT PK_vlastni
    PRIMARY KEY (id, ICO),
CONSTRAINT FK_majitel_kavarny
    FOREIGN KEY (id)
    REFERENCES Majitel
    ON DELETE CASCADE,
CONSTRAINT FK_kavarna_ma_majitele
    FOREIGN KEY (ICO)
    REFERENCES Kavarna
    ON DELETE CASCADE
);

CREATE TABLE Navstevuje(
id INT,
ICO INT,
CONSTRAINT PK_navstevuje
    PRIMARY KEY (id, ICO),
CONSTRAINT FK_navsteva_kavarny
    FOREIGN KEY (id)
    REFERENCES Osoba
    ON DELETE CASCADE,
CONSTRAINT FK_kavarna_navstevovana
    FOREIGN KEY (ICO)
    REFERENCES Kavarna
    ON DELETE CASCADE
);

CREATE TABLE Nabizi(
id INT,
ICO INT,
id_kava INT,
ICO_kavarna INT,
CONSTRAINT PK_nabizi
    PRIMARY KEY (id_kava, ICO_kavarna),
CONSTRAINT FK_nabizena_kava
    FOREIGN KEY (id)
    REFERENCES Kava
    ON DELETE CASCADE,
CONSTRAINT FK_kava_v_kavarna
    FOREIGN KEY (ICO)
    REFERENCES Kavarna
    ON DELETE CASCADE
);

CREATE TABLE Akce_nabizi(
id_kava INT,
id_akce INT,
id INT,
CONSTRAINT PK_nabizi_na_akci
    PRIMARY KEY (id_kava, id_akce),
CONSTRAINT FK_kava_na_akci
    FOREIGN KEY (id)
    REFERENCES Kava
    ON DELETE CASCADE,
CONSTRAINT FK_akce_kava
    FOREIGN KEY (id)
    REFERENCES Cupping_akce
    ON DELETE CASCADE
);

CREATE TABLE Sedelaz(
id_kava INT,
id_zrna INT,
id INT,
CONSTRAINT PK_sedelaz
    PRIMARY KEY (id_kava, id_zrna),
CONSTRAINT FK_kava_ze_zrn
    FOREIGN KEY (id)
    REFERENCES Kava
    ON DELETE CASCADE,
CONSTRAINT FK_zrna_do_kavy
    FOREIGN KEY (id)
    REFERENCES Kavova_zrna
    ON DELETE CASCADE
);

CREATE TABLE Porada(
id INT,
ICO INT,
id_akce INT,
ICO_kavarna INT,
CONSTRAINT PK_porada
    PRIMARY KEY (id_akce, ICO_kavarna),
CONSTRAINT FK_kavarna_porada
    FOREIGN KEY (ICO)
    REFERENCES Kavarna
    ON DELETE CASCADE,
CONSTRAINT FK_akce_v_kavarna
    FOREIGN KEY (id)
    REFERENCES Cupping_akce
    ON DELETE CASCADE
);

CREATE TABLE Oblibena_kavarna(
id INT,
ICO INT,
id_uzivatel INT,
ICO_kavarna INT,
CONSTRAINT PK_kavarna_oblibena
    PRIMARY KEY (id_uzivatel, ICO_kavarna),
CONSTRAINT FK_kavarna_oblibil
    FOREIGN KEY (ICO)
    REFERENCES Kavarna
    ON DELETE CASCADE,
CONSTRAINT FK_uzivatel_oblibil_kavarnu
    FOREIGN KEY (id)
    REFERENCES Uzivatel
    ON DELETE CASCADE
);

CREATE TABLE Oblibena_kava(
id INT,
id_uzivatel INT,
id_kava INT,
CONSTRAINT PK_kava_oblibena
    PRIMARY KEY (id_uzivatel, id_kava),
CONSTRAINT FK_kava_oblibil
    FOREIGN KEY (id)
    REFERENCES Kava
    ON DELETE CASCADE,
CONSTRAINT FK_uzivatel_oblibil_kavu
    FOREIGN KEY (id)
    REFERENCES Uzivatel
    ON DELETE CASCADE
);
-------------------- KONEC 1. CASTI -----------------------

-- (4. cast) Trigger pro automaticke generovani hodnot primarniho klice tabulky recenze
CREATE SEQUENCE seq_recenze
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER gen_pk_recenze
BEFORE INSERT ON Recenze
FOR EACH ROW
BEGIN
        :NEW.id := seq_recenze.NEXTVAL;
END;
/

-- Trigger 2 Kontrola oteviraci doby
-- (nebo zmenit konkretni hodnoty viz discord)
CREATE OR REPLACE TRIGGER tr_valid_ot_doba
AFTER INSERT OR UPDATE ON Kavarna
FOR EACH ROW
BEGIN
    IF  :NEW.hodin_od >= :NEW.hodin_do OR 
        :NEW.hodin_od is null OR
        :NEW.hodin_do is null
    THEN
        Raise_Application_Error(-20204, 'Nespravne zadana oteviraci doba!');
    END IF;
        
END;
/

----------------------- 2. CAST ---------------------------
-- insert
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('1', 'Terry', 'Pratchett', 'nejakeheslo123', '+420345234678', TO_DATE('1934-09-06', 'yyyy/mm/dd'), 'discworld@mail.com');
INSERT INTO Uzivatel (id, id_uzivatel, prezdivka, pocet_vypitych_salku_denne)
VALUES ('1', '1001', 'Ter', '2');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('2', 'John', 'Lucas', 'dejmetomu5', '+420456734854', TO_DATE('1965-05-03', 'yyyy/mm/dd'), 'disccccc@gmail.de');
INSERT INTO Uzivatel (id, id_uzivatel, prezdivka, pocet_vypitych_salku_denne)
VALUES ('2', '1002', 'Johny', '1');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('3', 'Delilah', 'Tobin', 'MamRadKebab', '+420746729801', TO_DATE('1988-10-14', 'yyyy/mm/dd'), 'nejakymail@mail.cz');
INSERT INTO Uzivatel (id, id_uzivatel, prezdivka, pocet_vypitych_salku_denne)
VALUES ('3', '1003', 'Deli', '3');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('4', 'Freddy', 'Mercury', 'i-like-music', '+420644799205', TO_DATE('1970-03-23', 'yyyy/mm/dd'), 'queen@gmail.com');
INSERT INTO Uzivatel (id, id_uzivatel, prezdivka, pocet_vypitych_salku_denne)
VALUES ('4', '1004', 'Queen', '2');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('5', 'Tom', 'Hanks', 'b0nb0n13r4', '+420706321851', TO_DATE('1995-04-10', 'yyyy/mm/dd'), 'run.forest.run@email.sk');
INSERT INTO Uzivatel (id, id_uzivatel, prezdivka, pocet_vypitych_salku_denne)
VALUES ('5', '1005', 'Forest', '4');

INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('6', 'Martin', 'Kretini', 'alecau123', '+420345685943', TO_DATE('1956-11-26', 'yyyy/mm/dd'), 'jaksemas@gmail.com');
INSERT INTO Majitel (id, id_majitel)
VALUES ('6', '11');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('7', 'Pauline', 'Terrac', 'taktrebastrebas7', '+420543234565', TO_DATE('1966-12-16', 'yyyy/mm/dd'), 'mailujeme@mail.com');
INSERT INTO Majitel (id, id_majitel)
VALUES ('7', '12');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('8', 'Alan', 'Turing', 'Silne-Heslo987', '+420649538525', TO_DATE('1998-12-28', 'yyyy/mm/dd'), 'aturing@email.uk');
INSERT INTO Majitel (id, id_majitel)
VALUES ('8', '13');

INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('9', 'Majk', 'Amaze', 'inout6', '+420987567876', TO_DATE('1970-04-11', 'yyyy/mm/dd'), 'fitit@eemail.com');
INSERT INTO Zamestnanec (id, id_zamestnanec, cislo_uctu)
VALUES ('9', '101', '1393238750/0600');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('10', 'Kamil', 'Novy', 'aaaakce', '+420345654345', TO_DATE('1981-02-06', 'yyyy/mm/dd'), 'novinkydonovin@gimail.com');
INSERT INTO Zamestnanec (id, id_zamestnanec, cislo_uctu)
VALUES ('10', '102', '1051237890/2005');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('11', 'Katherine', 'Johnson', 'one.two.three', '+420745620341', TO_DATE('2000-02-20', 'yyyy/mm/dd'), 'johnsonk@nasa.com');
INSERT INTO Zamestnanec (id, id_zamestnanec, cislo_uctu)
VALUES ('11', '103', '1381201895/3030');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('12', 'Usain', 'Bolt', 'namydlenejblesk', '+420678654123', TO_DATE('1993-09-19', 'yyyy/mm/dd'), 'fastestman@mail.com');
INSERT INTO Zamestnanec (id, id_zamestnanec, cislo_uctu)
VALUES ('12', '104', '2038215490/5050');
INSERT INTO Osoba (id, jmeno, prijmeni, heslo, telefon, datum_narozeni, email)
VALUES ('13', 'Sviatlana', 'Tsikhanouskaya', 'freedom456', '+420604564379', TO_DATE('1996-05-23', 'yyyy/mm/dd'), 'forbelarus@email.com');
INSERT INTO Zamestnanec (id, id_zamestnanec, cislo_uctu)
VALUES ('13', '105', '1271264815/0100');

INSERT INTO Kavarna (ICO, nazev, ulice, cislo_popisne, mesto, psc, hodin_od, hodin_do, pocet_mist, prumerne_hodnoceni)
VALUES ('29307104', 'DRING CAFFE s.r.o.', 'Olomoucká', '797', 'Brno', '61800', '9', '18', '60', '5');
INSERT INTO Kavarna (ICO, nazev, ulice, cislo_popisne, mesto, psc, hodin_od, hodin_do, pocet_mist, prumerne_hodnoceni)
VALUES ('25098985', 'Hard Rock Cafe (Czech Republic), s.r.o.', 'Malé náměstí', '142', 'Praha', '11000', '8', '19', '130', '4');
INSERT INTO Kavarna (ICO, nazev, ulice, cislo_popisne, mesto, psc, hodin_od, hodin_do, pocet_mist, prumerne_hodnoceni)
VALUES ('34709748', 'Čauky mňauky cafe s.r.o.', 'Veleslavínova', '1864', 'Ostrava', '70200', '10', '17', '90', '5');
INSERT INTO Kavarna (ICO, nazev, ulice, cislo_popisne, mesto, psc, hodin_od, hodin_do, pocet_mist, prumerne_hodnoceni)
VALUES ('15153557', 'KAFE JAK LUSK', 'Třída Svobody', '4', 'Olomouc', '77900', '7', '19', '55', '4');
INSERT INTO Kavarna (ICO, nazev, ulice, cislo_popisne, mesto, psc, hodin_od, hodin_do, pocet_mist, prumerne_hodnoceni)
VALUES ('16223940', 'KAFÉ OKOLO', 'Lannova', '6', 'České Budějovice', '37001', '8', '17', '42', '3');
INSERT INTO Kavarna (ICO, nazev, ulice, cislo_popisne, mesto, psc, hodin_od, hodin_do, pocet_mist, prumerne_hodnoceni)
VALUES ('27906663', 'REPUBLICA COFFEE CZ', 'T. G. Masaryka', '28', 'Karlovy Vary', '36001', '10', '18', '76', '4');

INSERT INTO Kava (nazev, zpusob_pripravy, mnozstvi, cena)
VALUES ('Latte macchiato', 'Vrstvení kávy a mléka', '250', '59');
INSERT INTO Kava (nazev, zpusob_pripravy, mnozstvi, cena)
VALUES ('Espresso', 'Namletí kávových zrn + zalití vroucí vodou', '30', '49');
INSERT INTO Kava (nazev, zpusob_pripravy, mnozstvi, cena)
VALUES ('Cappuccino', 'Namletí kávových zrn + mléčná pěna', '200', '49');
INSERT INTO Kava (nazev, zpusob_pripravy, mnozstvi, cena)
VALUES ('Café cortado', 'Namletí kávových zrn + nalití horkého mléka', '50', '59');
INSERT INTO Kava (nazev, zpusob_pripravy, mnozstvi, cena)
VALUES ('Caffé mocca', 'Namletí kávových zrn + sirup + kakao + mléko', '50', '69');

INSERT INTO Kavova_zrna (odruda, stupen_kyselosti, aroma, oblast_puvodu)
VALUES ('Arusha', 'kyselá s bohatší chutí', 'výrazné medové', 'Tanzanie a Papua Nová Guinea');
INSERT INTO Kavova_zrna (odruda, stupen_kyselosti, aroma, oblast_puvodu)
VALUES ('Bourbon', 'nízká s čokoládovými tóny', 'sušené ovoce', 'Bourbon');
INSERT INTO Kavova_zrna (odruda, stupen_kyselosti, aroma, oblast_puvodu)
VALUES ('Harar', 'nízká', 'citrusové', 'Etiopie');
INSERT INTO Kavova_zrna (odruda, stupen_kyselosti, aroma, oblast_puvodu)
VALUES ('Kermal', 'nízká', 'karamelové', 'Etiopie');
INSERT INTO Kavova_zrna (odruda, stupen_kyselosti, aroma, oblast_puvodu)
VALUES ('Minali', 'střední', 'ovocné', 'Etiopie');

INSERT INTO Cupping_akce (datum_konani, akce_od, akce_do, pocet_volnych_mist, cena_ochutnavky)
VALUES (TO_DATE('2021-07-30', 'yyyy/mm/dd'), '14', '16', '30', '150');
INSERT INTO Cupping_akce (datum_konani, akce_od, akce_do, pocet_volnych_mist, cena_ochutnavky)
VALUES (TO_DATE('2021-04-21', 'yyyy/mm/dd'), '13', '14', '15', '175');
INSERT INTO Cupping_akce (datum_konani, akce_od, akce_do, pocet_volnych_mist, cena_ochutnavky)
VALUES (TO_DATE('2021-05-14', 'yyyy/mm/dd'), '15', '16', '20', '160');
INSERT INTO Cupping_akce (datum_konani, akce_od, akce_do, pocet_volnych_mist, cena_ochutnavky)
VALUES (TO_DATE('2021-06-08', 'yyyy/mm/dd'), '16', '17', '25', '145');
INSERT INTO Cupping_akce (datum_konani, akce_od, akce_do, pocet_volnych_mist, cena_ochutnavky)
VALUES (TO_DATE('2021-05-29', 'yyyy/mm/dd'), '17', '18', '20', '155');
INSERT INTO Cupping_akce (datum_konani, akce_od, akce_do, pocet_volnych_mist, cena_ochutnavky)
VALUES (TO_DATE('2021-07-03', 'yyyy/mm/dd'), '15', '17', '22', '165');

INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('29307104', TO_DATE('2020-05-05', 'yyyy/mm/dd'), '5', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. In laoreet, magna id viverra tincidunt, sem odio bibendum justo, vel imperdiet sapien wisi sed libero.');
INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('25098985', TO_DATE('2020-08-23', 'yyyy/mm/dd'), '4', 'Fusce suscipit libero eget elit. Et harum quidem rerum facilis est et expedita distinctio.');
INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('34709748', TO_DATE('2021-01-19', 'yyyy/mm/dd'), '3', 'Nulla pulvinar eleifend sem. Nam sed tellus id magna elementum tincidunt.');
INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('15153557', TO_DATE('2021-02-27', 'yyyy/mm/dd'), '5', 'Pellentesque pretium lectus id turpis. Duis risus.');
INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('16223940', TO_DATE('2021-03-02', 'yyyy/mm/dd'), '4', 'Maecenas aliquet accumsan leo. Suspendisse nisl. Proin pede metus, vulputate nec, fermentum fringilla, vehicula vitae, justo.');
INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('27906663', TO_DATE('2020-06-11', 'yyyy/mm/dd'), '5', 'Integer rutrum, orci vestibulum ullamcorper ultricies, lacus quam ultricies odio, vitae placerat pede sem sit amet enim.');
INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('29307104', TO_DATE('2020-04-28', 'yyyy/mm/dd'), '5', 'Nulla turpis magna, cursus sit amet, suscipit a, interdum id, felis. Fusce aliquam vestibulum ipsum.');
INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('27906663', TO_DATE('2021-01-13', 'yyyy/mm/dd'), '2', 'Aenean vel massa quis mauris vehicula lacinia. Sed elit dui, pellentesque a, faucibus vel, interdum nec, diam.');
INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('15153557', TO_DATE('2020-12-02', 'yyyy/mm/dd'), '4', 'Fusce dui leo, imperdiet in, aliquam sit amet, feugiat eu, orci. Nullam eget nisl.');
INSERT INTO Recenze (ICO, datum, pocet_hvezdicek, obsah_recenze)
VALUES ('29307104', TO_DATE('2021-03-26', 'yyyy/mm/dd'), '5', 'Curabitur vitae diam non enim vestibulum interdum.');

INSERT INTO Reakce (id_reakce, id_recenze, datum, obsah_reakce, pocet_palcu_nahoru, pocet_palcu_dolu)
VALUES ('10', '1', TO_DATE('2020-11-13', 'yyyy/mm/dd'), 'Vestibulum erat nulla, ullamcorper nec, rutrum non, nonummy ac, erat. Nullam sapien sem, ornare ac, nonummy non, lobortis a enim.', '3', '5');
INSERT INTO Reakce (id_reakce, id_recenze, datum, obsah_reakce, pocet_palcu_nahoru, pocet_palcu_dolu)
VALUES ('11', '2', TO_DATE('2021-02-26', 'yyyy/mm/dd'), 'Aliquam erat volutpat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.', '1', '0');
INSERT INTO Reakce (id_reakce, id_recenze, datum, obsah_reakce, pocet_palcu_nahoru, pocet_palcu_dolu)
VALUES ('12', '3', TO_DATE('2021-02-04', 'yyyy/mm/dd'), 'Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos.', '0', '0');
INSERT INTO Reakce (id_reakce, id_recenze, datum, obsah_reakce, pocet_palcu_nahoru, pocet_palcu_dolu)
VALUES ('13', '2', TO_DATE('2020-09-30', 'yyyy/mm/dd'), 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '2', '8');
INSERT INTO Reakce (id_reakce, id_recenze, datum, obsah_reakce, pocet_palcu_nahoru, pocet_palcu_dolu)
VALUES ('14', '2', TO_DATE('2020-10-15', 'yyyy/mm/dd'), 'Praesent id justo in neque elementum ultrices.', '7', '1');
INSERT INTO Reakce (id_reakce, id_recenze, datum, obsah_reakce, pocet_palcu_nahoru, pocet_palcu_dolu)
VALUES ('15', '6', TO_DATE('2020-08-22', 'yyyy/mm/dd'), 'Etiam ligula pede, sagittis quis, interdum ultricies, scelerisque eu.', '4', '0');
INSERT INTO Reakce (id_reakce, id_recenze, datum, obsah_reakce, pocet_palcu_nahoru, pocet_palcu_dolu)
VALUES ('16', '7', TO_DATE('2020-05-17', 'yyyy/mm/dd'), 'Aliquam erat volutpat. Donec quis nibh at felis congue commodo.', '6', '2');
INSERT INTO Reakce (id_reakce, id_recenze, datum, obsah_reakce, pocet_palcu_nahoru, pocet_palcu_dolu)
VALUES ('17', '1', TO_DATE('2021-08-04', 'yyyy/mm/dd'), 'Pellentesque sapien. Integer lacinia. Curabitur sagittis hendrerit ante.', '15', '3');
INSERT INTO Reakce (id_reakce, id_recenze, datum, obsah_reakce, pocet_palcu_nahoru, pocet_palcu_dolu)
VALUES ('18', '3', TO_DATE('2021-03-06', 'yyyy/mm/dd'), 'Fusce tellus. Aliquam id dolor. Proin mattis lacinia justo.', '0', '1');

INSERT INTO Smena (den, smena_od, smena_do, id_zamestnance, ICO_kavarny)
VALUES ('PO', '8', '19', '103', '25098985');
INSERT INTO Smena (den, smena_od, smena_do, id_zamestnance, ICO_kavarny)
VALUES ('ST', '9', '18', '101', '29307104');
INSERT INTO Smena (den, smena_od, smena_do, id_zamestnance, ICO_kavarny)
VALUES ('PA', '7', '19', '105', '15153557');
INSERT INTO Smena (den, smena_od, smena_do, id_zamestnance, ICO_kavarny)
VALUES ('CT', '10', '17', '102', '34709748');
INSERT INTO Smena (den, smena_od, smena_do, id_zamestnance, ICO_kavarny)
VALUES ('UT', '8', '17', '103', '16223940');
INSERT INTO Smena (den, smena_od, smena_do, id_zamestnance, ICO_kavarny)
VALUES ('PO', '10', '18', '101', '27906663');

INSERT INTO Akce_nabizi(id_kava, id_akce)
VALUES ('1', '1');
INSERT INTO Akce_nabizi(id_kava, id_akce)
VALUES ('2', '1');
INSERT INTO Akce_nabizi(id_kava, id_akce)
VALUES ('3', '1');
INSERT INTO Akce_nabizi(id_kava, id_akce)
VALUES ('1', '2');
INSERT INTO Akce_nabizi(id_kava, id_akce)
VALUES ('2', '2');
INSERT INTO Akce_nabizi(id_kava, id_akce)
VALUES ('3', '2');
INSERT INTO Akce_nabizi(id_kava, id_akce)
VALUES ('5', '2');
INSERT INTO Akce_nabizi(id_kava, id_akce)
VALUES ('2', '3');
INSERT INTO Akce_nabizi(id_kava, id_akce)
VALUES ('3', '3');

INSERT INTO Nabizi(id_kava, ICO_kavarna)
VALUES ('1', '15153557');
INSERT INTO Nabizi(id_kava, ICO_kavarna)
VALUES ('3', '15153557');
INSERT INTO Nabizi(id_kava, ICO_kavarna)
VALUES ('2', '15153557');
INSERT INTO Nabizi(id_kava, ICO_kavarna)
VALUES ('2', '29307104');
INSERT INTO Nabizi(id_kava, ICO_kavarna)
VALUES ('4', '15153557');
INSERT INTO Nabizi(id_kava, ICO_kavarna)
VALUES ('5', '29307104');
INSERT INTO Nabizi(id_kava, ICO_kavarna)
VALUES ('3', '29307104');
INSERT INTO Nabizi(id_kava, ICO_kavarna)
VALUES ('2', '34709748');
INSERT INTO Nabizi(id_kava, ICO_kavarna)
VALUES ('1', '34709748');

INSERT INTO Navstevuje(id, ICO)
VALUES ('1', '29307104');
INSERT INTO Navstevuje(id, ICO)
VALUES ('2', '29307104');
INSERT INTO Navstevuje(id, ICO)
VALUES ('3', '29307104');
INSERT INTO Navstevuje(id, ICO)
VALUES ('5', '29307104');
INSERT INTO Navstevuje(id, ICO)
VALUES ('1', '25098985');
INSERT INTO Navstevuje(id, ICO)
VALUES ('3', '25098985');
INSERT INTO Navstevuje(id, ICO)
VALUES ('4', '25098985');
INSERT INTO Navstevuje(id, ICO)
VALUES ('1', '34709748');
INSERT INTO Navstevuje(id, ICO)
VALUES ('3', '34709748');

INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('1', '1');
INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('1', '3');
INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('1', '5');
INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('2', '1');
INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('2', '2');
INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('3', '3');
INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('3', '4');
INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('3', '5');
INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('4', '1');
INSERT INTO Sedelaz(id_kava, id_zrna)
VALUES ('4', '5');

-- update
UPDATE Kavarna SET prumerne_hodnoceni = (SELECT AVG(pocet_hvezdicek) FROM Recenze WHERE Recenze.ICO = Kavarna.ICO);

-------------------- KONEC 2. CASTI -----------------------

----------------------- 3. CAST ---------------------------

-- spojeni dvou tabulek
-- Jake recenze ma kavarna DRING CAFE s.r.o.?
SELECT r1.obsah_recenze, r1.datum, r1.pocet_hvezdicek
FROM Recenze r1 NATURAL JOIN Kavarna k1
WHERE k1.nazev = 'DRING CAFFE s.r.o.';

-- Jake jsou kontaktni udaje zamestnancu a jejich cisla uctu?
SELECT o1.jmeno, o1.prijmeni, o1.telefon, o1.email, z1.cislo_uctu
FROM Osoba o1, Zamestnanec z1
WHERE o1.id=z1.id;

-- spojeni tri tabulek
-- V kolik hodin se kona cupping akce 30.7. a co tam budou podavat za kavu?
SELECT c1.akce_od, c1.akce_do, k2.nazev, k2.zpusob_pripravy
FROM Cupping_akce c1, Akce_nabizi a1
JOIN Kava k2 ON a1.id_kava=k2.id
WHERE c1.datum_konani='30-JUL-21';

-- dva dotazy s klauzulí GROUP BY a agregační funkcí
-- Vypis jmena kavaren podle poctu navstevniku
SELECT Kavarna.nazev, COUNT(DISTINCT O.id)
FROM Kavarna NATURAL JOIN Navstevuje, Osoba O
WHERE O.id = Navstevuje.id
GROUP BY nazev
ORDER BY 2 DESC;

-- Cupping akce v jakem datu nabizi vice jak 2 kavy?
SELECT C.datum_konani, K.nazev, COUNT(DISTINCT A.id_kava)
FROM  Kava K, Cupping_akce C, Akce_nabizi A
WHERE C.id = A.id_akce
GROUP BY C.datum_konani, K.nazev
HAVING COUNT(DISTINCT A.id_kava) > 2;

-- jeden dotaz obsahující predikát EXISTS
-- Ktere osoby nejsou uzivatele?
SELECT o2.jmeno, o2.prijmeni
FROM Osoba o2
WHERE NOT EXISTS (
    SELECT *
    FROM Uzivatel u1
    WHERE o2.id=u1.id
);

-- jeden dotaz s predikátem IN s vnořeným selectem (nikoliv IN s množinou konstantních dat)
-- Vypis informace o vsech kavach nabizenych v kavarne 'KAFE JAK LUSK'
SELECT Kava.nazev, Kava.zpusob_pripravy, Kava.mnozstvi, Kava.cena
FROM Kava
WHERE Kava.id IN (
    SELECT Nabizi.id_kava
    FROM Nabizi
    WHERE Nabizi.ICO_kavarna IN (
        SELECT ICO
        FROM Kavarna
        WHERE Kavarna.nazev='KAFE JAK LUSK'
    )
);

-------------------- KONEC 3. CASTI ----------------------- 

--------------------- 4. a 5. CAST ------------------------

-- Demonstrace triggeru (1) pro automaticke generovani hodnot primarniho klice tabulky Recenze ze sekvence
SELECT id, ICO, datum, obsah_recenze
FROM Recenze
ORDER BY id;

-- Demonstrace triggeru (2) pro kontrolu oteviraci doby (testovani nevhodneho vstupu, vyhodi chybu)
--INSERT INTO Kavarna (ICO, nazev, ulice, cislo_popisne, mesto, psc, hodin_od, hodin_do, pocet_mist, prumerne_hodnoceni)
--VALUES ('29508102', 'Nejaka kavarna', 'Ulice', '42', 'Brno', '61200', '19', '18', '42', '5');


-- Procedury
SET serveroutput ON;

-- Procedura (1) vypocita prumernou cenu ochutnavek na cupping akcich
CREATE OR REPLACE PROCEDURE prum_cena_ochutnavky
AS
CURSOR cena_akce IS SELECT cena_ochutnavky FROM Cupping_akce;
    tmp cena_akce%ROWTYPE; 
    pocet_akci INTEGER;
    cena_soucet INTEGER;
BEGIN
pocet_akci := 0;
cena_soucet := 0;
OPEN cena_akce;
LOOP
    FETCH cena_akce INTO tmp;
    EXIT WHEN cena_akce%NOTFOUND;

    pocet_akci := pocet_akci + 1;
    cena_soucet := cena_soucet + tmp.cena_ochutnavky;
END LOOP;
DBMS_OUTPUT.PUT_LINE('Prumerna cena ochutnavky na cupping akcich je ' || ROUND(cena_soucet/pocet_akci));
EXCEPTION
WHEN ZERO_DIVIDE THEN
DBMS_OUTPUT.PUT_LINE('Nelze vypocitat prumernou cenu ochutnavky!');
WHEN OTHERS THEN
Raise_Application_Error(-20005, 'Nastala chyba!');
END;
/
-- Ukazka prvni procedury
EXECUTE prum_cena_ochutnavky();


-- Procedura (2) pocita kolik uzivatelu chodi do dane kavarny
CREATE OR REPLACE PROCEDURE pocet_navstevniku_kavarny(nazev_kavarny IN VARCHAR) 
AS
    uzivatele INTEGER; 
    navstevnici INTEGER; 
    ICO_kavarna Kavarna.ICO%TYPE;
    id_kavarny Kavarna.ICO%TYPE;
CURSOR cursor_kavarna IS SELECT ICO_kavarna FROM Navstevuje;
BEGIN
    SELECT COUNT(*) INTO uzivatele FROM Osoba;
    navstevnici := 0;

    SELECT ICO INTO id_kavarny
    FROM Kavarna
    WHERE nazev = nazev_kavarny;

    OPEN cursor_kavarna;
    LOOP
        FETCH cursor_kavarna INTO ICO_kavarna;
        EXIT WHEN cursor_kavarna%NOTFOUND;

        IF ICO_kavarna = id_kavarny THEN
            navstevnici := navstevnici + 1;
        END IF;
    END LOOP;
    CLOSE cursor_kavarna;
    DBMS_OUTPUT.put_line('Kavarnu ' || nazev_kavarny || ' navstevuje ' || navstevnici || ' uzivatelu z ' || uzivatele || ' celkoveho poctu uzivatelu.');

    EXCEPTION WHEN NO_DATA_FOUND THEN
    BEGIN
        DBMS_OUTPUT.put_line('Kavarna ' || nazev_kavarny || ' nebyla nalezena!');
    END;
END;
/
-- Ukazka druhe procedury
EXECUTE pocet_navstevniku_kavarny('DRING CAFFE s.r.o.');


-- EXPLAIN PLAN 
EXPLAIN PLAN FOR
SELECT
    Z.oblast_puvodu AS puvod,
    COUNT(S.id_kava) AS pocet
FROM Kavova_zrna Z
JOIN Sedelaz S ON  S.id_zrna = Z.id
WHERE Z.oblast_puvodu LIKE 'Etiopie'
GROUP BY Z.id, Z.oblast_puvodu
HAVING COUNT(S.id_kava) > 1
ORDER BY puvod;
-- vypis
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
-- index
CREATE INDEX zrna_etiopie ON Kavova_zrna (oblast_puvodu);

EXPLAIN PLAN FOR
SELECT
    Z.oblast_puvodu AS puvod,
    COUNT(S.id_kava) AS pocet
FROM Kavova_zrna Z
JOIN Sedelaz S ON  S.id_zrna = Z.id
WHERE Z.oblast_puvodu LIKE 'Etiopie'
GROUP BY Z.id, Z.oblast_puvodu
HAVING COUNT(S.id_kava) > 1
ORDER BY puvod;
-- vypis
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- Materializovany pohled na souhrn kav na cupping akcich
CREATE MATERIALIZED VIEW cupping_akce_kava AS
SELECT
    Kava.id,
    Kava.nazev,
    COUNT(Akce_nabizi.id_akce) AS akce_count
FROM Kava
LEFT JOIN Akce_nabizi ON Akce_nabizi.id_kava = Kava.id
GROUP BY Kava.id, Kava.nazev;

SELECT * FROM cupping_akce_kava;


-- Pristupy
GRANT ALL ON Osoba TO xbenov00;
GRANT ALL ON Majitel TO xbenov00;
GRANT ALL ON Zamestnanec TO xbenov00;
GRANT ALL ON Uzivatel TO xbenov00;
GRANT ALL ON Zamestnava TO xbenov00;
GRANT ALL ON Kavarna TO xbenov00;
GRANT ALL ON Smena TO xbenov00;
GRANT ALL ON Kava TO xbenov00;
GRANT ALL ON Kavova_zrna TO xbenov00;
GRANT ALL ON Cupping_akce TO xbenov00;
GRANT ALL ON Recenze TO xbenov00;
GRANT ALL ON Reakce TO xbenov00;
GRANT ALL ON Vlastni TO xbenov00;
GRANT ALL ON Navstevuje TO xbenov00;
GRANT ALL ON Nabizi TO xbenov00;
GRANT ALL ON Akce_nabizi TO xbenov00;
GRANT ALL ON Sedelaz TO xbenov00;
GRANT ALL ON Porada TO xbenov00;
GRANT ALL ON Oblibena_kavarna TO xbenov00;
GRANT ALL ON Oblibena_kava TO xbenov00;

GRANT EXECUTE ON prum_cena_ochutnavky TO xbenov00;
GRANT EXECUTE ON pocet_navstevniku_kavarny TO xbenov00;
GRANT ALL ON cupping_akce_kava TO xbenov00;

------------------ KONEC 4. a 5. CASTI -------------------- 