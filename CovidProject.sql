SELECT * FROM 
PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * FROM 
PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Kullanmak istediðimiz verileri seçelim..
SELECT location, date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Ülkemizin Toplam Vaka ile Toplam Ölüm arasýndaki yüzdelik iliþkiye bakýþ...
SELECT location, date,total_cases,total_deaths,
(CAST(total_deaths AS numeric) / total_cases) * 100 AS ÖLÜM_ORANI
FROM PortfolioProject..CovidDeaths
WHERE location = 'Turkey'
ORDER BY 2;

--Ülkemizin toplam vaka sayýsý ile nüfus arasýndaki YÜZDELÝK iliþkiye bakýþ...
SELECT location,date,population,total_cases,
(CAST(total_cases AS numeric) /population) * 100 AS VAKA_ORANI
FROM PortfolioProject..CovidDeaths
WHERE location = 'Turkey'
ORDER BY 2;

-- Nüfusa göre enfekte oraný en fazla olan ülke hangisidir?
SELECT location, population,MAX(total_cases) AS EN_YÜKSEK_VAKA_SAYISI,
(CAST(MAX(total_cases) AS decimal) / NULLIF(population,0)) *100 AS VAKA_NUFUS_ORANI
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY VAKA_NUFUS_ORANI DESC;

--Ülkelere göre en fazla ölüm sayýlarý ne alemde?
SELECT location,MAX(total_deaths) AS en_yüksek_ölüm_sayýsý
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY en_yüksek_ölüm_sayýsý DESC;


--Kýtalara göre en fazla ölüm sayýlarý?
SELECT continent,MAX(total_deaths) AS MAX_ÖLÜM
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAX_ÖLÜM DESC;


--Nüfusa göre en yüksek ölüm oranlarýna sahip olan 10 ülkeyi sýralayýnýz...
SELECT TOP 10 location,population,MAX(CAST(total_deaths AS int)) AS EN_YÜKSEK_ÖLÜM,
MAX((CAST(total_deaths AS numeric) / NULLIF(population,0))) * 100 AS NÜFUS_ÖLÜM_ORANI
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY NÜFUS_ÖLÜM_ORANI DESC;

-- TÜM DÜNYADA, BELÝRLÝ GÜNLERE GÖRE TOPLAM ÖLÜM SAYISININ TOPLAM VAKA SAYISINA GÖRE ORANI NEDÝR?
SELECT date, SUM(new_cases) AS TOPLAM_VAKA, SUM(new_deaths) TOPLAM_ÖLÜM,
SUM(CAST(total_deaths AS numeric)) / NULLIF(SUM(total_cases),0) * 100
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- DÜNYADA TOPLAM VAKA ÝLE TOPLAM ÖLÜM SAYISI NEDÝR?
SELECT SUM(new_cases) AS TOPLAM_VAKA, SUM(new_deaths) TOPLAM_ÖLÜM,
SUM(CAST(new_deaths AS numeric)) / NULLIF(SUM(new_cases),0) * 100
FROM PortfolioProject..CovidDeaths

--Aþýlama sayýlarýný gösteren tabloya eriþelim.
SELECT * FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Aþýlama sayýlarý ile toplam nüfus arasýndaki oranlara eriþelim.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- Türkiye'nin günden güne yapýlan aþýlama sayýlarýný bulup, kümülatif toplamýný veren sorguyu yazalým.
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







