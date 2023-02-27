 --COVID 19 DATA EXPLORATION

 --Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types

Select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


-- Select Data that we are going to be starting with

Select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,new_cases,total_deaths,population,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
and location ='India'
order by 2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location,date,population,total_cases,(total_cases/population)*100 as PopulationInfectedRate
from PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select location,population,MAX(total_cases) as TotalCovidCount,MAX((total_cases/population))*100 as HighestPopulationInfectedRate
from PortfolioProject..CovidDeaths
where continent is not null 
group by location,population
order by HighestPopulationInfectedRate desc

-- Countries with Highest Death Count per Population

Select location,MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount desc

-- Countries with Highest Death Rate compared to Population

Select location,population,MAX(CAST(total_deaths as int)) as TotalDeathCount,MAX((CAST(total_deaths as int)/population))*100 as HighestPopulationDeathRate
from PortfolioProject..CovidDeaths
where continent is not null 
group by location,population
order by HighestPopulationDeathRate desc

-- Showing contintents and countries with the total death count per population
 

Select continent,location,MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent,location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

Select continent,MAX(CAST(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by HighestDeathCount desc

-- GLOBAL LEVEL EXPLORATION
 Select SUM(new_cases) as TotalCases,SUM(CAST(new_deaths as int)) as TotalDeaths,(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as TotalDeathPercentage
 from PortfolioProject..CovidDeaths
where continent is not null 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

 SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS int))
 OVER(PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated,(RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

 
-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS int))
 OVER(PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
 FROM PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location and dea.date=vac.date
 where dea.continent is not null
 
 ) 
 Select * ,(RollingPeopleVaccinated/Population)*100 as TotalVaccinatedRate from PopvsVac

 --TEMP TABLE
DROP TABLE IF EXISTS  #PercentPopulationVaccinated  
Create table #PercentPopulationVaccinated (
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

 Insert into #PercentPopulationVaccinated 
 SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS int))
 OVER(PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location and dea.date=vac.date
 where dea.continent is not null

  Select * ,(RollingPeopleVaccinated/Population)*100 as TotalVaccinatedRate from #PercentPopulationVaccinated


 -- Creating View to store data for later visualizations

 Create view PercentPopulationVaccinated as
 SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,SUM(CAST(vac.new_vaccinations AS int))
 OVER(PARTITION BY dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 Join PortfolioProject..CovidVaccinations vac
 ON dea.location=vac.location and dea.date=vac.date
 where dea.continent is not null

 Select * from PercentPopulationVaccinated