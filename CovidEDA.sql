/*
 Covid 19 Data Exploration
 
 SKills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
 */


SELECT *
FROM CovidDeaths 
ORDER BY 3,4


--Select Data that we are going to start with

SELECT location, date ,total_cases, new_cases , total_deaths , population
FROM CovidDeaths
WHERE continent IS NOT NULL 


--Total cases vs total death
--Shows likelihood of dying if you contract covid in UK

SELECT location, date, total_cases , total_deaths , (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM CovidDeaths 
WHERE location LIKE '%Kingdom' AND continent IS NOT NULL 
ORDER BY 1,2


--Total cases vs Population
--Shows what percentage of population got covid

SELECT location, date, population, total_cases , (CAST(total_cases AS float)/CAST(population AS float))*100 AS PopulationInfectedPercent
FROM CovidDeaths cd 
WHERE location LIKE '%Kingdom' AND continent IS NOT NULL
ORDER BY 1,2


--Countries with Highest Infection Rate vs population

SELECT location, population, MAX(CAST(total_cases AS float)) AS HighestInfectionCount, 
	MAX(CAST(total_cases AS float)/CAST(population AS float))*100 AS PopulationInfectedPercent
FROM CovidDeaths cd 
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY PopulationInfectedPercent DESC 


--COUNTRIES with Highest Death Count

SELECT  location , MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM CovidDeaths cd 
WHERE continent IS NOT NULL AND location NOT IN (
												'Upper middle income','High income','Europe','North America','Asia',
												'South America','Lower middle income','European Union','World'
												)
GROUP BY location  
ORDER BY TotalDeathCount DESC


--CONTINENTS with Highest Death Count

SELECT continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM CovidDeaths cd 
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
 
--WORLD Death Percentage

SELECT date,SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths , SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1

--Total WORLD cases, deaths, and death percentage

SELECT SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths , SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DeathPercentage
FROM CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1


--JOINING Vaccination Table and Death Table
--Total Population vs Total Vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths cd
JOIN CovidVaccinations cv  
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL AND cd.location NOT IN (
												'Upper middle income','High income','Europe','North America','Asia',
												'South America','Lower middle income','European Union','World','Africa'
												)
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH  PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths cd
JOIN CovidVaccinations cv  
	ON cd.location = cv.location 
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL AND cd.location NOT IN (
												'Upper middle income','High income','Europe','North America','Asia',
												'South America','Lower middle income','European Union','World','Africa'
												)
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE


DROP Table if exists temp.PercentPopulationVaccinated
Create Table temp.PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into temp.PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From temp.PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentagePopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 








