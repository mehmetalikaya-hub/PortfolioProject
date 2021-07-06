SELECT * FROM 
PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * FROM 
PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Kullanmak istedi�imiz verileri se�elim..
SELECT location, date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- �lkemizin Toplam Vaka ile Toplam �l�m aras�ndaki y�zdelik ili�kiye bak��...
SELECT location, date,total_cases,total_deaths,
(CAST(total_deaths AS numeric) / total_cases) * 100 AS �L�M_ORANI
FROM PortfolioProject..CovidDeaths
WHERE location = 'Turkey'
ORDER BY 2;

--�lkemizin toplam vaka say�s� ile n�fus aras�ndaki Y�ZDEL�K ili�kiye bak��...
SELECT location,date,population,total_cases,
(CAST(total_cases AS numeric) /population) * 100 AS VAKA_ORANI
FROM PortfolioProject..CovidDeaths
WHERE location = 'Turkey'
ORDER BY 2;

-- N�fusa g�re enfekte oran� en fazla olan �lke hangisidir?
SELECT location, population,MAX(total_cases) AS EN_Y�KSEK_VAKA_SAYISI,
(CAST(MAX(total_cases) AS decimal) / NULLIF(population,0)) *100 AS VAKA_NUFUS_ORANI
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY VAKA_NUFUS_ORANI DESC;

--�lkelere g�re en fazla �l�m say�lar� ne alemde?
SELECT location,MAX(total_deaths) AS en_y�ksek_�l�m_say�s�
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY en_y�ksek_�l�m_say�s� DESC;


--K�talara g�re en fazla �l�m say�lar�?
SELECT continent,MAX(total_deaths) AS MAX_�L�M
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAX_�L�M DESC;


--N�fusa g�re en y�ksek �l�m oranlar�na sahip olan 10 �lkeyi s�ralay�n�z...
SELECT TOP 10 location,population,MAX(CAST(total_deaths AS int)) AS EN_Y�KSEK_�L�M,
MAX((CAST(total_deaths AS numeric) / NULLIF(population,0))) * 100 AS N�FUS_�L�M_ORANI
FROM PortfolioProject..CovidDeaths
GROUP BY location,population
ORDER BY N�FUS_�L�M_ORANI DESC;

-- T�M D�NYADA, BEL�RL� G�NLERE G�RE TOPLAM �L�M SAYISININ TOPLAM VAKA SAYISINA G�RE ORANI NED�R?
SELECT date, SUM(new_cases) AS TOPLAM_VAKA, SUM(new_deaths) TOPLAM_�L�M,
SUM(CAST(total_deaths AS numeric)) / NULLIF(SUM(total_cases),0) * 100
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- D�NYADA TOPLAM VAKA �LE TOPLAM �L�M SAYISI NED�R?
SELECT SUM(new_cases) AS TOPLAM_VAKA, SUM(new_deaths) TOPLAM_�L�M,
SUM(CAST(new_deaths AS numeric)) / NULLIF(SUM(new_cases),0) * 100
FROM PortfolioProject..CovidDeaths

--A��lama say�lar�n� g�steren tabloya eri�elim.
SELECT * FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--A��lama say�lar� ile toplam n�fus aras�ndaki oranlara eri�elim.
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- T�rkiye'nin g�nden g�ne yap�lan a��lama say�lar�n� bulup, k�m�latif toplam�n� veren sorguyu yazal�m.
WITH A�I_TABLO (Continent, Location, Date, Population, New_Vaccinations, Cumulative_Vac_Numbers)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS K�M�LAT�F_A�ILAMA
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL
)
SELECT *,
CAST(Cumulative_Vac_Numbers AS numeric) / Population * 100 AS A�ILAMA_ORANI
FROM A�I_TABLO
WHERE Location = 'Turkey';

-- T�m �lkelerin En g�ncel a��lanma oranlar� ??
WITH A�I_TABLO (Continent, Location, Date, Population, New_Vaccinations, Cumulative_Vac_Numbers)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS K�M�LAT�F_A�ILAMA
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL
)
SELECT Location, MAX(CAST(Cumulative_Vac_Numbers AS numeric) / NULLIF(Population,0) * 100) AS A�ILAMA_ORANI
FROM A�I_TABLO
GROUP BY Location
ORDER BY A�ILAMA_ORANI DESC;


--Temp Table
DROP TABLE IF EXISTS #A�ILAMA_ORANLARI
CREATE TABLE #A�ILAMA_ORANLARI
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date Datetime ,
Population numeric,
New_Vaccinations numeric,
Cumulative_Num_Of_Vacs numeric
)

INSERT INTO #A�ILAMA_ORANLARI
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS K�M�LAT�F_A�ILAMA
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

SELECT *,
CAST(Cumulative_Num_Of_Vacs AS numeric) / Population * 100 AS A�ILAMA_ORANI
FROM #A�ILAMA_ORANLARI

--Creating View to store data to visualize
CREATE VIEW BOLGELER_OLUMLER AS
SELECT location,MAX(total_deaths) AS en_y�ksek_�l�m_say�s�
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY en_y�ksek_�l�m_say�s� DESC

select * from BOLGELER_OLUMLER







