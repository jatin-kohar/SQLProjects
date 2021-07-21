/*
Data Exploration on Global Covid-19 Dataset 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT * FROM [covid EDA project]..['CovidDeaths']
order by 3,4



--Selecting the data to be used from the CovidDeaths database

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [covid EDA project]..['CovidDeaths']
ORDER BY 1,2



--Using Death Ratio to analyse the likelihood of dying if one contracts coronavirus in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRatio
FROM [covid EDA project]..['CovidDeaths']
WHERE location like '%India'
ORDER BY 1,2



--Using Total Cases vs Population to show what percentage of population got infected by Covid in each country

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM [covid EDA project]..['CovidDeaths']
--WHERE location like '%India'
ORDER BY 1,2



--Looking at countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM [covid EDA project]..['CovidDeaths']
--WHERE location like '%India'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc



-- Looking at countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [covid EDA project]..['CovidDeaths']
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc



--ANALYSING DATA BY CONTINENTS

--Looking at contintents with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [covid EDA project]..['CovidDeaths']
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc



-- Analysing the global cases and death numbers by date

SELECT date, SUM(new_cases) as NewCasesPerDay, SUM(cast(new_deaths as int)) as NewDeathsPerDay, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [covid EDA project]..['CovidDeaths']
where continent is not null
GROUP BY date
order by 1,2



--Joining the CovidDeaths Dataset and CovidVaccination Dataset

SELECT * 
FROM [covid EDA project]..['CovidDeaths'] deaths
JOIN [covid EDA project]..['CovidVaccinations'] vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date



-- Looking at new vaccinations in each country by date

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations 
FROM [covid EDA project]..['CovidDeaths'] deaths
JOIN [covid EDA project]..['CovidVaccinations'] vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date
where deaths.continent is not null
order by 2,3



-- looking at Total Population vs Vaccinations to observe the percentage of population that has received at least one Covid Vaccine

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, 
SUM(CONVERT(int, vacs.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM [covid EDA project]..['CovidDeaths'] deaths
JOIN [covid EDA project]..['CovidVaccinations'] vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date
where deaths.continent is not null 
order by 2,3 



-- Get Percentage of population vaccinated in India by date by using CTE to perform calculation on partition by function.

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS
(SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, 
SUM(CONVERT(int, vacs.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM [covid EDA project]..['CovidDeaths'] deaths
JOIN [covid EDA project]..['CovidVaccinations'] vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date
where deaths.continent is not null)
SELECT * , (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM PopvsVac
where Location LIKE '%India'



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PopVaccinated
CREATE TABLE #PopVaccinated
(
Continent nvarchar(255),
Location nvarchar(225),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PopVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, 
SUM(CONVERT(int, vacs.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM [covid EDA project]..['CovidDeaths'] deaths
JOIN [covid EDA project]..['CovidVaccinations'] vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date
where deaths.continent is not null 
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentPopulationVaccinated
FROM #PopVaccinated



-- Creating view to store data for later visualisation

CREATE VIEW PctPopulationVaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, 
SUM(CONVERT(int, vacs.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM [covid EDA project]..['CovidDeaths'] deaths
JOIN [covid EDA project]..['CovidVaccinations'] vacs
	ON deaths.location = vacs.location
	AND deaths.date = vacs.date
where deaths.continent is not null


