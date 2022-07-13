Select * from CovidDeaths
order by 3,4

--Select * from dbo.CovidVaccinations
--order by 3,4


--Total Deaths Vs Total Cases
Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths
where location = 'India'
order by 3 desc

--Total Cases Vs Population (population % who have suffered CoVID)
Select Location, date, total_cases, new_cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths
where location = 'India'
order by 2

--Countries with Highest Infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfection, MAX((total_cases/Population))*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths
where continent is not null
Group by Location, population
order by 4 DESC

--Countries with Highest Death count compared to population
Select Location,Population, MAX(CAST(total_deaths AS int)) as HighestDeathCount,MAX((CAST(total_deaths AS int)/Population))*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths
where continent is not null
Group by Location, population
order by 4 DESC

--Continents with Highest Death count compared to population
Select continent, MAX(CAST(total_deaths AS int)) as HighestDeathCount,MAX((CAST(total_deaths AS int)/Population))*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths
where continent is not null
Group by continent
order by 3 DESC

-- Checking global new cases and deaths and comparing the ratio
Select Date, SUM(new_cases) as [casesperday], SUM(CAST(new_deaths as Float)) as [deathsperday],
SUM(CAST(new_deaths as Float))/ SUM(new_cases)*100 as percentdeathperday
from CovidDeaths
where continent is not  null
Group by date
order by 1

--Recurring vaccinations count
With PopVsVac (location, date, population, vacs, rollingcount)
AS (
Select de.location, de.date, population, new_vaccinations, SUM(CAST(new_vaccinations as int)) OVER (Partition by de.location order by de.location, de.date) as totalvactilldate
From Portfolioproject..CovidDeaths de
Join CovidVaccinations vac
on de.date = vac.date and de.location = vac.location
where de.continent is not null
)
Select *, rollingcount/population*100
from PopVsVac
Where location = 'India'


--Creating a view for showing Highest Death Count by Continent
Create View VwMaxDeathbyContinent
AS 
Select continent, MAX(CAST(total_deaths AS int)) as HighestDeathCount,MAX((CAST(total_deaths AS int)/Population))*100 as PercentPopulationInfected
from Portfolioproject..CovidDeaths
where continent is not null
Group by continent


---------------------------------------------------------------------------------------------------------------------------------------
--For Visualization purposes using Power BI

-- 1. Global Infected Vs Deaths
Select SUM(new_cases) as [infected], SUM(CAST(new_deaths as Float)) as [deaths],
SUM(CAST(new_deaths as Float))/ SUM(new_cases)*100 as percentdeath
from Portfolioproject..CovidDeaths
where continent is not  null
order by 1,2

-- 2. Deaths by continent
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

-- 3. Location wise infection percentage
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- 4. Continent wise infection Vs Death percentage 
Select location, SUM(cast(new_cases as int)) as TotalInfectedCount, SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalinfectedCount desc

-- 5. For comparing CoVID cases different countries over a period 
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc