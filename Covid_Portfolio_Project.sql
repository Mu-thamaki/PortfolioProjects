--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccines
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


--Converting nvarchar to float
--SELECT *
--FROM CovidDeaths

--EXEC sp_help 'CovidDeaths'

--ALTER TABLE CovidDeaths
--ALTER COLUMN total_deaths float 


--Looking at Total Cases vs Total Deaths.
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2 DESC


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

--SELECT location, date, total_cases, population, (total_cases/population)*100 AS cases_percentage
--FROM CovidDeaths
--WHERE location like '%states%' and continent is not null
--ORDER BY 1,2


-- Looking at Countries with highest infection rate compared to population
-- Some of these figures seem exhagerated. This could be due to recording of repeated cases and not individual cases

SELECT location, population, MAX(total_cases) as max_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- Showing Deaths By Continent

SELECT continent, MAX(total_deaths) as total_death_count
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC



-- Showing countries with highest death count per population

SELECT location, MAX(total_deaths) as total_death_count
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC


-- Gloabal Numbers

SELECT SUM(new_cases) total_new_cases, SUM(new_deaths) total_new_deaths, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage 
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs vaccination
-- Use CTE

WITH PopvsVax (continent, location, date, population, new_vaccinations, total_vaxed)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
		SUM(vax.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) total_vaxed
FROM CovidDeaths deaths
JOIN CovidVaccines vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
WHERE deaths.continent is not null
--ORDER BY 1,2,3
)

SELECT *, (total_vaxed/population)*100
FROM PopvsVax

--ALTER TABLE CovidVaccines
--ALTER COLUMN new_vaccinations float 


--TEMP TABLE
DROP TABLE IF EXISTS #Percent_Pop_Vaxed
CREATE TABLE #Percent_Pop_Vaxed
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Total_Vaccinated numeric
)

INSERT INTO #Percent_Pop_Vaxed
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
		SUM(vax.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) total_vaxed
FROM CovidDeaths deaths
JOIN CovidVaccines vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
WHERE deaths.continent is not null
--ORDER BY 1,2,3


SELECT *, (Total_Vaccinated/Population)*100 as Percentage_vaxed
FROM #Percent_Pop_Vaxed


-- Creating view to store data for later visualization

CREATE VIEW Percent_Population_Vaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
		SUM(vax.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) total_vaxed
FROM CovidDeaths deaths
JOIN CovidVaccines vax
	ON deaths.location = vax.location
	and deaths.date = vax.date
WHERE deaths.continent is not null


SELECT *
FROM Percent_Population_Vaccinated