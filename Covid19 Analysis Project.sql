SELECT * 
FROM PortfolioProject..covidDeaths
WHERE continent is NOT null 
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..covidVaccinations
--ORDER BY 3,4

--Getting the data

SELECT location, date, total_cases, new_cases, population, total_deaths
FROM PortfolioProject..covidDeaths 
ORDER BY 1,2

--Total cases vs Total deaths

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject..covidDeaths 
WHERE location like '%india%'
ORDER BY 1,2

--total cases vs population

SELECT location, date, total_cases,population, (total_cases/population) * 100 as PoplulationInfected
FROM PortfolioProject..covidDeaths 
WHERE location like '%india%'
ORDER BY 1,2

--Highest country Infection rate by population

SELECT location,population, MAX(total_cases) AS highestInfection , MAX((total_cases/population)) * 100 as PoplulationInfected
FROM PortfolioProject..covidDeaths 
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY PoplulationInfected desc

-- highest deaths per population

SELECT location, MAX(cast(total_deaths AS int)) AS highestdeaths 
FROM PortfolioProject..covidDeaths 
--WHERE location like '%india%'
WHERE continent is NOT null
GROUP BY location
ORDER BY highestdeaths desc

--by continent

SELECT continent, MAX(cast(total_deaths AS int)) AS highestdeaths 
FROM PortfolioProject..covidDeaths 
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY highestdeaths desc


--global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as Death_precentage
FROM PortfolioProject..covidDeaths 
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Covid Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not NULL
ORDER BY 2,3

--Total populations vs total vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER ( PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not NULL
ORDER BY 2,3

--Using CTE(common table expression) for above query

WITH popVSvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER ( PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not NULL
--ORDER BY 2,3
)
SELECT *, ( RollingPeopleVaccinated/population)*100 AS VaccinatedPercent
FROM popVSvac


--Creating TEMP table

DROP table if exists  #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric ,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER ( PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
--WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, ( RollingPeopleVaccinated/population)*100 as percentpopulated
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated1

AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;


