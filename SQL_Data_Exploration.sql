--DATA EXPLORATION 

--The first sight of our tables
SELECT * FROM 
PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * FROM 
PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Kullanmak istedigimiz verileri secelim..
--Choosing the data what we wanted to go with.
SELECT location, date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Ulkemizin Toplam Vaka ile Toplam olum arasýndaki yüzdelik iliskiye bakýs...
--Looking the relation between the total cases and death tools as a ratio of our country.
SELECT location, date,total_cases,total_deaths,
(CAST(total_deaths AS numeric) / total_cases) * 100 AS ÖLÜM_ORANI
FROM PortfolioProject..CovidDeaths
WHERE location = 'Turkey'
ORDER BY 2;

--Ulkemizin toplam vaka sayýsý ile nüfus arasýndaki yüzdelik iliþkiye bakýþ...
--Looking the relation between the total cases and population as a ratio of our country.
SELECT location,date,population,total_cases,
(CAST(total_cases AS numeric) /population) * 100 AS VAKA_ORANI
FROM PortfolioProject..CovidDeaths
WHERE location = 'Turkey'
ORDER BY 2;

-- Nufusa göre enfekte oraný en fazla olan ulke hangisidir?
-- Which country has the highest infected number according to its population.
SELECT location, population,MAX(total_cases) AS EN_YÜKSEK_VAKA_SAYISI,
(CAST(MAX(total_cases) AS decimal) / NULLIF(population,0)) *100 AS VAKA_NUFUS_ORANI
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY VAKA_NUFUS_ORANI DESC;

--Ülkelere göre en fazla ölüm sayýlarý ne alemde?
-- What about the death tools according to countries.
SELECT location,MAX(total_deaths) AS en_yüksek_ölüm_sayýsý
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY en_yüksek_ölüm_sayýsý DESC;

--Kýtalara göre en fazla ölüm sayýlarý?
-- How about the death tools according to continents.
SELECT continent,MAX(total_deaths) AS MAX_ÖLÜM
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAX_ÖLÜM DESC;


--Nufusa göre en yüksek ölüm oranlarýna sahip olan 10 ülkeyi sýralayýnýz...
-- Order the 10 countries which have the highest death tool according to their populations.
SELECT TOP 10 location,population,MAX(CAST(total_deaths AS int)) AS EN_YÜKSEK_ÖLÜM,
MAX((CAST(total_deaths AS numeric) / NULLIF(population,0))) * 100 AS NÜFUS_ÖLÜM_ORANI
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY NÜFUS_ÖLÜM_ORANI DESC;

-- TÜM DÜNYADA, BELÝRLÝ GÜNLERE GÖRE TOPLAM ÖLÜM SAYISININ TOPLAM VAKA SAYISINA GÖRE ORANI NEDÝR?
-- What are the ratios if we look the relation between death numbers and new cases for each day?
SELECT date, SUM(new_cases) AS TOPLAM_VAKA, SUM(new_deaths) TOPLAM_ÖLÜM,
SUM(CAST(total_deaths AS numeric)) / NULLIF(SUM(total_cases),0) * 100
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- DÜNYADA TOPLAM VAKA ÝLE TOPLAM ÖLÜM SAYISI NEDÝR?
-- What is the total cases and total death numbers?
SELECT SUM(new_cases) AS TOPLAM_VAKA, SUM(new_deaths) TOPLAM_ÖLÜM,
SUM(CAST(new_deaths AS numeric)) / NULLIF(SUM(new_cases),0) * 100
FROM PortfolioProject..CovidDeaths

--Aþýlama sayýlarýný gösteren tabloya eriþelim.
--Access the another table which is called vaccinations.
SELECT * FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Aþýlama sayýlarý ile toplam nüfus arasýndaki oranlara eriþelim.
--What is the relation between vaccinations numbers and total cases?
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- Türkiye'nin günden güne yapýlan aþýlama sayýlarýný bulup, kümülatif toplamýný veren sorguyu yazalým.
-- Find the Turkey's vaccinations numbers day by day and find cumulative ratio according to its populatios.
WITH AÞI_TABLO (Continent, Location, Date, Population, New_Vaccinations, Cumulative_Vac_Numbers)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS KÜMÜLATÝF_AÞILAMA
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL
)
SELECT *,
CAST(Cumulative_Vac_Numbers AS numeric) / Population * 100 AS AÞILAMA_ORANI
FROM AÞI_TABLO
WHERE Location = 'Turkey';

-- Tüm ülkelerin En güncel aþýlanma oranlarý ??
--What about the most recent vaccinations numbers of any country.
WITH AÞI_TABLO (Continent, Location, Date, Population, New_Vaccinations, Cumulative_Vac_Numbers)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS KÜMÜLATÝF_AÞILAMA
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL
)
SELECT Location, MAX(CAST(Cumulative_Vac_Numbers AS numeric) / NULLIF(Population,0) * 100) AS AÞILAMA_ORANI
FROM AÞI_TABLO
GROUP BY Location
ORDER BY AÞILAMA_ORANI DESC;


--Temp Table
--Do it by using temp tables.
DROP TABLE IF EXISTS #AÞILAMA_ORANLARI
CREATE TABLE #AÞILAMA_ORANLARI
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date Datetime ,
Population numeric,
New_Vaccinations numeric,
Cumulative_Num_Of_Vacs numeric
)

INSERT INTO #AÞILAMA_ORANLARI
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS KÜMÜLATÝF_AÞILAMA
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

SELECT *,
CAST(Cumulative_Num_Of_Vacs AS numeric) / Population * 100 AS AÞILAMA_ORANI
FROM #AÞILAMA_ORANLARI

--Creating View to store data to visualize
CREATE VIEW BOLGELER_OLUMLER AS
SELECT location,MAX(total_deaths) AS en_yüksek_ölüm_sayýsý
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY en_yüksek_ölüm_sayýsý DESC

select * from BOLGELER_OLUMLER







