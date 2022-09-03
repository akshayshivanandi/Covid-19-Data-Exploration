
-- SQL queries for Power BI


-- Showing Overall cases, deaths and death percentage

--1)
SELECT 
SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(cast(new_deaths as decimal))/SUM(New_Cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- Deaths around the Continents

--2)
SELECT 
location, SUM(new_deaths) as TotalDeathCount
FROM Covid..CovidDeaths
Where continent is null 
and location in ('Europe', 'Asia', 'North America', 'South America','Africa', 'Oceania')
GROUP BY location
ORDER BY TotalDeathCount desc


--Showing Total deaths by population

--3)
SELECT 
Location, Population, max(total_deaths) as Total_deaths, MAX(cast(total_deaths as decimal))/population*100 as DeathPercentagebyPopulation
FROM Covid..CovidDeaths
WHERE continent is not null 
GROUP BY location, population
ORDER BY 1,2


-- Showing Percentage of Population infected with Covid

--4)
SELECT 
Location, Population, MAX(total_cases) as Total_cases,  Max(total_cases/cast(population as decimal))*100 as PercentPopulationInfected
FROM Covid..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-----Showing total_cases and deaths on daily basis

--5)
SELECT
date, SUM(total_cases) as Total_Cases, SUM(total_deaths) as Total_Deaths
FROM Covid..CovidDeaths
GROUP BY date
order by date

