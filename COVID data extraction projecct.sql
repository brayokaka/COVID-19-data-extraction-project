SELECT * 
FROM [Portfolio Project]..['Covid Deaths$']
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * 
FROM [Portfolio Project]..['Covid Vaccinations$']
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..['Covid Deaths$']
ORDER BY 1,2;

--Looking at total cases vs total deaths
--Shows the probability of dying if you contract covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..['Covid Deaths$']
WHERE location LIKE '%kenya%'
ORDER BY 1,2;

--Loooking at the total cases vs population
--Shows what percentage of the population contracted covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
FROM [Portfolio Project]..['Covid Deaths$']
WHERE location LIKE '%kenya%'
ORDER BY 1,2;

--Looking at countries with the highest infection rate

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
FROM [Portfolio Project]..['Covid Deaths$']
GROUP BY location, population
ORDER BY CasePercentage DESC;


--Showing countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM [Portfolio Project]..['Covid Deaths$']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Lets break things down by continent
--Showing the continents with the highest death counts

SELECT continent, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM [Portfolio Project]..['Covid Deaths$']
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as INT)) as Total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..['Covid Deaths$']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--Looking at the total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['Covid Deaths$'] dea
JOIN [Portfolio Project]..['Covid Vaccinations$'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--USE CTE

WITH PopvsVac (Continent, Locatin, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['Covid Deaths$'] dea
JOIN [Portfolio Project]..['Covid Vaccinations$'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentpopulationVaccinated
CREATE TABLE #PercentpopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)



INSERT INTO #PercentpopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['Covid Deaths$'] dea
JOIN [Portfolio Project]..['Covid Vaccinations$'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated)*100
FROM #PercentpopulationVaccinated;

--Creating view to store data for later visualization

CREATE VIEW PercentpopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..['Covid Deaths$'] dea
JOIN [Portfolio Project]..['Covid Vaccinations$'] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentpopulationVaccinated;
