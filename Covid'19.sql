/****** Script for SelectTopNRows command from SSMS  ******/
 
 -- Covid'19 data exploration 

  -- Data representing Covid cases(total & new), deaths and overall population

  SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM Covid..CovidDeaths
  WHERE continent is not null
  ORDER BY 1,2;

  -- Total Cases vs Total Deaths

  SELECT location, date, total_cases, total_deaths, (total_deaths/CAST(total_cases as decimal))*100 as death_percentage
  FROM Covid..CovidDeaths
  WHERE continent is not null
  ORDER BY 1,2;

  --Total Cases vs Population 

  SELECT location, date, total_cases, population, (total_cases/CAST(population as decimal))*100 as Contraction_percentage
  FROM Covid..CovidDeaths
  WHERE continent is not null
  ORDER BY 1,2;

  -- Total Cases vs Population Cumuulative Inefection Country-Wise

  SELECT 
  location, population, MAX(total_cases) as totalcases, MAX(total_cases/CAST(population as decimal))*100 as Contraction_Percentage
  FROM Covid..CovidDeaths
  WHERE continent is not null
  GROUP BY location, population
  ORDER BY Contraction_Percentage desc;

  -- Percentage of contraction & deaths in India as of August'22

  SELECT 
  location, MAX(date) as latest_date, MAX(total_deaths) as totaldeaths, MAX(total_cases) as totalcases, MAX(population) as total_population, 
  MAX(total_deaths/CAST(total_cases as decimal))*100 as Death_Percentage, MAX(total_cases/CAST(population as decimal))*100 as Contraction_Percentage
  FROM Covid..CovidDeaths
  WHERE location = 'India'
  GROUP BY location
  ORDER BY Contraction_Percentage;

  -- Deaths with population countrywise

  SELECT 
  location, MAX(total_deaths) as Total_deaths, MAX(population) as total_population,  
  MAX(total_deaths/CAST(population as decimal))*100 as death_by_pop
  FROM Covid..CovidDeaths
  WHERE continent is not null
  GROUP BY location
  ORDER BY Total_deaths desc;

	--Now showing data for new cases and deaths globally from starting


  SELECT date, SUM(new_cases) as Total_New_Cases, SUM(new_deaths) as Total_New_Deaths, 
  (SUM(CAST(new_deaths as decimal))/SUM(new_cases))*100 as New_death_Percentage
  FROM Covid..CovidDeaths
  WHERE continent is not null
  GROUP BY date
  ORDER BY 1

  SELECT SUM(new_cases) as Total_New_Cases, SUM(new_deaths) as Total_New_Deaths, 
  (SUM(CAST(new_deaths as decimal))/SUM(new_cases))*100 as New_death_Percentage
  FROM Covid..CovidDeaths
  WHERE continent is not null
  ORDER BY 1


  ---Vaccinations vs Population
  --No.of Vaccinations across different locations with date

  SELECT
  D.location, D.continent, D.date, D.population, V.new_vaccinations,
  SUM(new_vaccinations) OVER (Partition by D.location ORDER by D.date, D.location) as Cumulative_Vaccinations
  FROM Covid..CovidDeaths D
  JOIN Covid..CovidVaccinations V
  ON D.location = V.location
  and D.date = V.date
  WHERE D.continent is not null
  ORDER BY 1,3

  --Population taken Vaccinations by CTE

  WITH PeopleVaccinated (location,continent,date,population,new_vaccinations,Cumulative_Vaccinations)
  as
  (
  SELECT
  D.location, D.continent, D.date, D.population, V.new_vaccinations,
  SUM(new_vaccinations) OVER (Partition by D.location ORDER by D.date, D.location) as Cumulative_Vaccinations
  FROM Covid..CovidDeaths D
  JOIN Covid..CovidVaccinations V
  ON D.location = V.location
  and D.date = V.date
  WHERE D.continent is not null
  )
  SELECT *,(Cumulative_Vaccinations/cast(population as decimal))*100 as Vaccination_Percentage
  FROM PeopleVaccinated


  --Creating New Table and Inserting Sorted data into it.

  CREATE TABLE VaccinatedPopulation
  (location varchar(255),
  continent varchar(255),
  date datetime,
  population bigint,
  new_vaccinations bigint,
  Cumulative_Vaccinations bigint);
  
  INSERT INTO VaccinatedPopulation
  SELECT
  D.location, D.continent, D.date, D.population, V.new_vaccinations,
  SUM(new_vaccinations) OVER (Partition by D.location ORDER by D.date, D.location) as Cumulative_Vaccinations
  FROM Covid..CovidDeaths D
  JOIN Covid..CovidVaccinations V
  ON D.location = V.location
  and D.date = V.date;
 
  SELECT *,(Cumulative_Vaccinations/cast(population as decimal))*100 as Vaccination_Percentage
  FROM VaccinatedPopulation;

  --Creating view and storing data in it.

  CREATE VIEW 
  VaccinatedPopulationView as
  SELECT
  D.location, D.continent, D.date, D.population, V.new_vaccinations,
  SUM(new_vaccinations) OVER (Partition by D.location ORDER by D.date, D.location) as Cumulative_Vaccinations
  FROM Covid..CovidDeaths D
  JOIN Covid..CovidVaccinations V
  ON D.location = V.location
  and D.date = V.date

