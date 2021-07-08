--1) Hangi markadan kaç tane araca sahibiz?
--How many cars do we have for each brand?
SELECT BRAND,COUNT(*) AS TOPLAM_ARAC_SAYISI
FROM WEBOFFERS
GROUP BY BRAND
ORDER BY TOPLAM_ARAC_SAYISI DESC

--2) 50 yılı aşkın arabaları markaya göre filtreleyen SQL kodu
--Extract the cars which have more than fifty years.
SELECT BRAND,COUNT(BRAND) AS TOPLAM_ARAC_SAYISI
FROM WEBOFFERS
WHERE DATEDIFF(YEAR,YEAR_,GETDATE()) >=50 
GROUP BY BRAND
ORDER BY TOPLAM_ARAC_SAYISI DESC

--3) Hangi şehirde kaç tane araç ilanımız var?
--How many cars we have for each city?
SELECT C.CITY, COUNT(W.BRAND) AS ARAC_TOPLAM
FROM WEBOFFERS W
INNER JOIN CITY C ON C.ID = W.CITYID
GROUP BY C.CITY
ORDER BY ARAC_TOPLAM DESC

--4) Markalara göre toplam araçların tüm marka araç sayısına göre yüzdeliği?
--Find the ratio of the brand of cars when we examine total brand count in every car
SELECT BRAND, COUNT(*) AS ARAC_SAYİSİ,
ROUND(
CONVERT(FLOAT,COUNT(*)) / (SELECT COUNT(*) FROM WEBOFFERS) * 100,2) AS YUZDELIK
FROM WEBOFFERS
GROUP BY BRAND 
ORDER BY ARAC_SAYİSİ DESC

-- Aynı soruyu subquery tekniği ile yapalım.
--Do it again by using subquery 
SELECT CITY,
(SELECT COUNT(*) FROM WEBOFFERS WHERE CITYID = C.ID) AS ARAC_SAYİSİ
FROM CITY C
ORDER BY 2 DESC

--5) Hangi semtte en fazla araç ilanı bulunmakta?
--In which district do we have highest number of car?
SELECT DISTRICT,
(SELECT COUNT(*) FROM WEBOFFERS WHERE DISTRICTID = D.ID) AS TOPLAM_ARAC
FROM DISTRICT D
ORDER BY TOPLAM_ARAC DESC


--6) 2014-2018 Yılları arasında Volkswagen marka araçtan, dizel yakıtlı, İstanbulda ve Sahibinden olan araçları bulan SQL sorgusu.
--Find the Volkwagen cars which has to be spesific criterias.
-- Ayrıca artan fiyat ve azalan KM'ye göre işlem yapsın.
SELECT C.CITY, W.TITLE,W.BRAND,W.MODEL,
W.PRICE,W.YEAR_,W.KM,W.FUEL,W.FROMWHO
FROM WEBOFFERS W
INNER JOIN CITY C ON C.ID = W.CITYID
WHERE C.CITY = 'İstanbul' AND
W.FROMWHO = 'Sahibinden' AND 
W.BRAND = 'Volkswagen' AND
W.FUEL = 'Dizel' AND
W.YEAR_ BETWEEN '2014' AND '2018'
ORDER BY W.KM , W.PRICE

--7) Yukarıdaki kriterlere ek otomatik vites olan araçları getiren sorgu nasıldır?
--Adding another criteria, automatic gear option, and find the result.
SELECT C.CITY, W.TITLE,W.BRAND,W.MODEL,W.SHIFTTYPE,W.PRICE,W.YEAR_,W.KM,W.FUEL, W.FROMWHO
FROM WEBOFFERS W
INNER JOIN CITY C ON C.ID = W.CITYID
WHERE C.CITY = 'İstanbul' AND
W.FROMWHO = 'Sahibinden' AND 
W.BRAND = 'Volkswagen' AND
W.FUEL = 'Dizel' AND
W.YEAR_ BETWEEN '2014' AND '2018' AND
W.SHIFTTYPE = 'Otomatik Vites'
ORDER BY W.KM , W.PRICE

--8) İllere göre Sahibinden ya da galeriden çıkışlı kaçar tane aracımız mevcut?
--According to the provinces, how many vehicles do we have from the owner or from the gallery?
SELECT C.CITY,
(SELECT COUNT(*) FROM WEBOFFERS WHERE C.ID = CITYID) AS TOPLAM_ARAC,
(SELECT COUNT(*) FROM WEBOFFERS WHERE CITYID = C.ID AND FROMWHO = 'Sahibinden') AS SAHIBINDEN_TOPLAM,
(SELECT COUNT(*) FROM WEBOFFERS WHERE CITYID = C.ID AND FROMWHO = 'Galeriden') AS GALERIDEN_TOPLAM
FROM CITY C
ORDER BY TOPLAM_ARAC DESC

--9) HATAY ilinde bu rakamları irdelemek için gereken SQL kodu
--SQL code required to return this in the province of HATAY
SELECT C.CITY,
(SELECT COUNT(*) FROM WEBOFFERS WHERE C.ID = CITYID) AS TOPLAM_ARAC,
(SELECT COUNT(*) FROM WEBOFFERS WHERE CITYID = C.ID AND FROMWHO = 'Sahibinden') AS SAHIBINDEN_TOPLAM,
(SELECT COUNT(*) FROM WEBOFFERS WHERE CITYID = C.ID AND FROMWHO = 'Galeriden') AS GALERIDEN_TOPLAM
FROM CITY C
WHERE C.CITY = 'HATAY'
ORDER BY TOPLAM_ARAC DESC

--ARAÇLAR AĞIRLIKLI OLARAK GALERİDEN SATILIYOR.

--10) Ankara şehrinde araçları 0 kilometre olarak listeleyen SQL kodu.
--SQL code that lists vehicles as 0 kilometers in Ankara.
SELECT W.BRAND,C.CITY, COUNT(*) AS SIFIR_OTOMOBIL
FROM WEBOFFERS W
INNER JOIN CITY C ON C.ID = W.CITYID
WHERE C.CITY = 'ANKARA' AND W.KM = 0
GROUP BY  W.BRAND,C.CITY

--11) Veri setimizde ikinci el ve sıfır kilometre araçların sayısını veren SQL kodu.
-- SQL code that gives the number of used and zero kilometer vehicles in our dataset.
SELECT COUNT(
CASE 
	WHEN KM = 0 THEN 'SIFIR_KİLOMETRE_ARAC'
	END) AS SIFIR_KM_ARAC_SAYISI,
COUNT(
	CASE WHEN KM <> 0 THEN 'IKINCI_EL_ARAC'
	END) AS IKINCI_EL_ARAC_SAYISI
FROM WEBOFFERS 

--12) Kaç farklı(benzersiz) araç modelimiz mevcut?
--How many unique card brands are in the dataset?
SELECT COUNT(DISTINCT(BRAND)) AS MARKA_SAYISI
FROM WEBOFFERS

--Diger yol olarak GROUP BY kullanabiliriz.
--You can also use the Group BY
SELECT BRAND FROM WEBOFFERS
GROUP BY BRAND

--13) Veri tabanına ORIGIN sütununu ekleyen SQL kodu.
--Add another column to the table which is called ORIGIN
ALTER TABLE WEBOFFERS ADD ORIGIN  VARCHAR(50)

--14) Araç markalarına göre ORIGIN sütununu güncelleyen SQL kodu.
--Örneğin: Audi -Almanya olacak şekilde

--14) SQL code updating ORIGIN column according to vehicle brands.
--For example: Audi -Germany
UPDATE WEBOFFERS 
SET ORIGIN = (CASE 
	WHEN BRAND IN('Audi','BMW','Mercedes','Volkswagen','Porsche') THEN 'Almanya'
	WHEN BRAND IN('Chevrolet','Ford') THEN 'ABD'
	WHEN BRAND IN('Citroen','Dacia','Peugeot','Renault') THEN 'Fransa'
	WHEN BRAND IN('Fiat','Jeep') THEN 'İtalya'
	WHEN BRAND IN('Honda','Hyundai','Toyota','Suzuki','Nissan','Mazda') THEN 'Japonya'
	WHEN BRAND = 'Kia' THEN 'Güney Kore'
	WHEN BRAND = 'Tofaş' THEN 'Türkiye'
	WHEN BRAND = 'Volvo' THEN 'İsviçre'
	WHEN BRAND = 'Skoda' THEN 'Çek Cumhuriyeti'
	WHEN BRAND = 'Seat' THEN 'İspanya'
END)
--15) Almanya menşeili araçları listeleyen SQL kodu.
--15) SQL code listing vehicles originating in Germany.

SELECT DISTINCT(BRAND),ORIGIN
FROM WEBOFFERS
WHERE ORIGIN = 'Almanya'

--Araçların ortalama fiyatını bulan, fiyat alanı NULL değere sahipse 0 yapıp hesaplayan SQL kodu.
----SQL code that finds the average price of the vehicles and sets it to 0 if the price field has a NULL value.

SELECT ROUND(AVG(COALESCE(PRICE,0)),2)
FROM WEBOFFERS

--16) Ülkelerin araç markalarına göre Toplam sayıyı veren SQL kodu.
----16) The SQL code that gives the total number according to the vehicle brands of the countries.

SELECT ORIGIN,BRAND,COUNT(*) AS ARAC_SAYISI
FROM WEBOFFERS
GROUP BY ORIGIN,BRAND
ORDER BY ORIGIN

--17) Bulunduğumuz yıla göre araba yaşını bulan, araba yaşının 30 ve üstü olduğu araçlara HURDA TEŞVİK alabilir yazısı belirten SQL kodu.
--17) The SQL code that finds the age of the car according to the year we are in, and states that the vehicles with the age of 30 and above can receive SCRAP INCENTIVES.

SELECT TITLE,BRAND,MODEL, ORIGIN,KM,PRICE,
DATEDIFF(YEAR,YEAR_,GETDATE()) AS ARABA_YAS,
CASE
	WHEN DATEDIFF(YEAR,YEAR_,GETDATE()) >= 30  THEN 'ARAC HURDA TESVİK ALABİLİR'
	ELSE 'HURDA TESVİK ALMAYA UYGUN DEĞİL'
	END AS HURDA_KONTROL
FROM WEBOFFERS
ORDER BY ARABA_YAS ASC

--18 HURDA teşviği almaya hak kazanmış araç sayımız kaçtır?
--18 How many vehicles are eligible for the Scrap Incentive?
SELECT COUNT(*) AS TOPLAM_ARAC_SAYISI, 
COUNT(CASE
	WHEN DATEDIFF(YEAR,YEAR_,GETDATE()) >= 30  THEN 'ARAC HURDA TESVİK ALABİLİR'
	END) AS HURDA_ARAC_TESVİK_SAYISI
FROM WEBOFFERS


--19) Hurda teşviği kazanan araçlardan en çok hangi ülkede mevcut?
---19) Which country has the most vehicles that receive scrap incentives?

SELECT ORIGIN,COUNT(*) AS TOPLAM_ARAC_SAYISI, 
COUNT(CASE
	WHEN DATEDIFF(YEAR,YEAR_,GETDATE()) >= 30  THEN 'ARAC HURDA TESVİK ALABİLİR'
	END) AS HURDA_ARAC_SAYISI
FROM WEBOFFERS
GROUP BY ORIGIN
ORDER BY HURDA_ARAC_SAYISI DESC
--En fazla hurda araç teşviği kazanabilecek ülke TÜRKİYE
----The country that can get the most scrap vehicle incentives is TURKEY

--20 Araç markalarının toplam araç sayılarına göre yüzdeliğini bulan SQL kodunu yazalım.
--20 Let's write the SQL code that finds the percentage of vehicle brands according to the total number of vehicles.
SELECT BRAND,COUNT(*) AS TOPLAMARAC,
ROUND(
CONVERT(FLOAT,COUNT(*)) / (SELECT COUNT(*) FROM WEBOFFERS )*100,2) AS TOPLAM_YUZDE
FROM WEBOFFERS
GROUP BY BRAND
ORDER BY TOPLAM_YUZDE DESC
--21 Ülkelere göre Hurda araçlar toplam araçların kaçta kaçını kapsıyor?
--21 What percentage of the total vehicles do scrap vehicles cover by country?
SELECT ORIGIN, COUNT(*) AS TOPLAM_ARAC_SAYISI,
SUM(CASE WHEN DATEDIFF(YEAR,YEAR_,GETDATE()) >= 30 THEN 1 ELSE 0 END) AS HURDA_SAYISI,
ROUND((SUM(CAST(CASE WHEN DATEDIFF(YEAR,YEAR_,GETDATE()) >= 30 THEN 1 ELSE 0 END AS numeric))
/
COUNT(*) * 100),2) AS HURDA_ARAC_YUZDESI
FROM WEBOFFERS
GROUP BY ORIGIN
ORDER BY HURDA_ARAC_YUZDESI DESC
--22 Araç markalarına göre Ortalama, Maximum,Minumum ve Fiyat Standart Sapmalarını bulalım.
--22 Let's find the Average, Maximum, Minimum and Price Standard Deviations according to vehicle brands.
SELECT BRAND,
ROUND(AVG(PRICE),0) ORTALAMA_FIYAT,
MAX(PRICE) ENYUKSEK_FIYAT,
ROUND(STDEV(PRICE),0) FIYAT_STANDART_SAPMA
FROM WEBOFFERS
GROUP BY BRAND
ORDER BY BRAND

--23 Grupladığımız araç markalarının Fiyat standart sapmalarına göre Azalan değerde sıralaması nasıl olur?
--23 How do we rank the vehicle brands we have grouped in Descending value according to their Price standard deviations?
SELECT BRAND,
ROUND(AVG(PRICE),0) ORTALAMA_FIYAT,
MAX(PRICE) ENYUKSEK_FIYAT,
ROUND(STDEV(PRICE),0) FIYAT_STANDART_SAPMA
FROM WEBOFFERS
GROUP BY BRAND
ORDER BY FIYAT_STANDART_SAPMA DESC

--Fiyat standart sapması en fazla olan araç markası Porschedir. En az ise Tofaş
--The vehicle brand with the highest price standard deviation is Porsche. At least Tofaş


--24) RAISEPRICE adlı başka bir alan adı ekleyelim. Bu alan adı araçların zamlı halini belirtecek.
--24) Let's add another domain name RAISEPRICE. This domain name will indicate the increased price version of the vehicles.

ALTER TABLE WEBOFFERS ADD RAISEPRICE float
--PRICE alanı üzerinden RAISEPRICE alanını %30 oranında zamlı hale getirelim. Yani RAISEPRICE alanı PRICE alanının %30 fazlası olacak.
--Let's increase the RAISEPRICE field by 30% over the --PRICE field. So the RAISEPRICE area will be 30% more than the PRICE area.

UPDATE WEBOFFERS SET RAISEPRICE = PRICE + (PRICE *30 /100)

-- Zamlı fiyatlar üzerinden ORTALAMA,MİN, MAX VE STANDART SAPMA DEĞERLERİNİ KONTROL EDELİM.
-- LET'S CHECK THE AVERAGE, MIN, MAX AND STANDARD DEVIATION VALUES over the increased prices
SELECT BRAND,
ROUND(AVG(RAISEPRICE),0) ORTALAMA_FIYAT,
MAX(RAISEPRICE) ENYUKSEK_FIYAT,
ROUND(STDEV(RAISEPRICE),0) FIYAT_STANDART_SAPMA
FROM WEBOFFERS
GROUP BY BRAND
ORDER BY BRAND

--Minimum, Maximum, Ortalama fiyat gibi özelliklerin artacağı gibi STANDART SAPMA tarafında da geniş artışlar olacaktır.
-- As the minimum, maximum, average price will increase, there will be wide increases on the STANDARD DEVIATION side.

--25 BMW ve Volkswagen araçlarında KM'si 50000 ile 100000 arasında olan araçların fiyatlarını da getiren SQL kodu.

--25 SQL code for BMW and Volkswagen vehicles, which also brings the prices of vehicles with KM between 50000 and 100000.
SELECT BRAND,RAISEPRICE,KM
FROM WEBOFFERS
WHERE KM BETWEEN 50000 AND 100000 AND BRAND IN ('BMW', 'Volkswagen')
GROUP BY BRAND,RAISEPRICE,KM
ORDER BY KM ASC

--26 Ortalama zamlı fiyatı 100.000 bin lira ve daha düşük olan araçları getiren SQL kodu.
--26 The SQL code that returns vehicles with an average price increase of 100,000 thousand liras or less.
SELECT BRAND,
ROUND(AVG(RAISEPRICE),0) AS ORTALAMA_FIYAT
FROM WEBOFFERS
GROUP BY BRAND
HAVING(ROUND(AVG(RAISEPRICE),0)) <=100000
ORDER BY ORTALAMA_FIYAT DESC

-- 27) Kullanıcıların bilgilerinin tutulduğu tabloda bugün doğum günü olan Kaç kişi var?
-- 27) How many people whose birthdays are in the table where the users' information is kept?
SELECT ID,USERNAME_,NAMESURNAME,BIRTHDATE,GETDATE() AS BUGUN
FROM USER_
WHERE
DATEPART(MONTH,BIRTHDATE) = DATEPART(MONTH,GETDATE())
AND
DATEPART(DAY,BIRTHDATE) = DATEPART(DAY,GETDATE())

-- OR
SELECT COUNT(ID) AS DOGUM_GUNU_OLAN_KISI_SAYISI
FROM USER_
WHERE
DATEPART(MONTH,BIRTHDATE) = DATEPART(MONTH,GETDATE())
AND
DATEPART(DAY,BIRTHDATE) = DATEPART(DAY,GETDATE())

--28 Araçları sahip olduğu KM 'ye göre kategorilere ayıran ve kaçtane bu aralıkta araç olduğunu bulan SQL kodu.
--28 SQL code that categorizes vehicles according to KM they have and finds how many vehicles are in this range.
SELECT SUM( 
CASE	
	WHEN KM = 0	THEN 1 ELSE 0
	END) AS 'SIFIR_KM_ARAC_SAYISI',
SUM(CASE 
	WHEN KM BETWEEN 50000 AND 99999
	THEN 1 ELSE 0
	END) AS '50BIN_100BIN_KM',
SUM(CASE
	WHEN KM BETWEEN 100000 AND 499999 THEN 1 ELSE 0
	END) AS '100_BIN_500BIN_KM',
SUM(CASE
WHEN KM >=500000 THEN 1 ELSE 0
END) AS '500BIN_KM_USTU'
FROM WEBOFFERS	

--29 En az iki tane araç sahibi olan kişileri listeleyelim
--29 List people who own at least two vehicles
SELECT U.USERNAME_,U.NAMESURNAME,W.BRAND
FROM USER_ U
LEFT JOIN WEBOFFERS W ON W.USERID = U.ID
GROUP BY U.USERNAME_,U.NAMESURNAME,W.BRAND
HAVING COUNT(DISTINCT W.ID) >= 2; 

