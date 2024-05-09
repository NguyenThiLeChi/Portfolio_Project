use PortfolioProject
/*select*from dbo.CovidVaccinations 
order by 3,4 */

Select *
From dbo.CovidDeaths
Order by 3,4

---Select Data that we are going to using

Select 
      location, 
	  date, 
	  total_cases, 
	  new_cases, 
	  total_deaths, 
	  population
From CovidDeaths
Order by 1,2

---Looking at Total cases, Total Deaths 
---Shows likelihood of dying if you contract covid in country

Select 
      location, 
	  date, 
	  total_cases, 
	  total_deaths, 
	  (total_deaths/total_cases)*100 DeathPercentage
From CovidDeaths
where continent is not null
Order by 1,2 desc

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select 
      location, 
	  date, 
	  total_cases, 
	  total_deaths, 
	  (total_deaths/population)*100 PercentPopulationInfected
From CovidDeaths
Order by 1,2 desc

-- Countries with Highest Infection Rate compared to Population

Select 
    location, 
    population, 
	Max(total_cases) as HighestInfectionCount, 
	Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by location, population
Order by PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

Select 
     location, 
	 Max(cast(Total_deaths as Int)) as TotalDeath
From CovidDeaths
where continent is not null
group by location
order by TotalDeath DESC


--Showing contintents with the highest death 
Select
     continent,
	 Max(cast(total_deaths as Int)) as TotalDeath
From CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeath DESC


--The incidence of new COVID by date

Select 
     date,
	 sum(new_cases) total_cases_new,
	 sum(cast(new_deaths as Int)) as total_death_new,
	 (sum(cast(new_deaths as Int))/sum(new_cases))*100 as Percent_new_death
From CovidDeaths
where continent is not null
group by date 
order by date desc


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select
     d.continent,
	 d.location,
	 d.date,
	 d.population,
	 v.new_vaccinations,
	 sum(cast(v.new_vaccinations as Int)) Over (Partition by d.location Order by d.location, d.date) RollingPeopleVaccinated  
From CovidDeaths as d
JOIN CovidVaccinations as v
ON d.date = v.date
AND d.location = v.location
WHERE d.continent is not null
Group by 
     d.continent,
	 d.location,
	 d.date,
	 d.population,
	 v.new_vaccinations
Order by 6 DESC



-- Using CTE to perform Calculation on Partition By in previous query

WITH table1 AS
(SELECT
     d.continent,
	 d.location,
	 d.date,
	 d.population,
	 v.new_vaccinations,
	 sum(cast(v.new_vaccinations as Int)) Over (Partition by d.location Order by d.location, d.date) RollingPeopleVaccinated  
From CovidDeaths as d
JOIN CovidVaccinations as v
ON d.date = v.date
AND d.location = v.location
WHERE d.continent is not null
Group by 
     d.continent,
	 d.location,
	 d.date,
	 d.population,
	 v.new_vaccinations
)
SELECT *,(RollingPeopleVaccinated/population)*100 Percent_
FROM table1
ORDER BY 7 DESC


---- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
);

Insert into #PercentPopulationVaccinated
SELECT 
     d.continent,
	 d.location,
	 d.date,
	 d.population,
	 v.new_vaccinations,
	 sum(cast(v.new_vaccinations as Int)) Over (Partition by d.location Order by d.location, d.date) RollingPeopleVaccinated 
     FROM CovidDeaths d
JOIN CovidVaccinations v
On d.date = v.date
AND d.location = v.location
WHERE d.continent is not null
Group by 
     d.continent,
	 d.location,
	 d.date,
	 d.population,
	 v.new_vaccinations
Select *, (RollingPeopleVaccinated/Population)*100 as Percent_
From #PercentPopulationVaccinated	
order by 7 DESC