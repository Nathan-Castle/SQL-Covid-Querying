Select *
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From CovidPortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using 
Select location, date, total_cases, new_cases, total_deaths, population
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
Where location like '%Canada' and
continent is not null
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
Where location like '%Canada' and
continent is not null
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidPortfolioProject..CovidDeaths
--Where location like '%Canada%'
Group by location, population
Order by PercentPopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT (Right way)
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
--Where location like '%Canada%'
Where continent is null
Group by location
Order by TotalDeathCount desc

-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
--Where location like '%Canada%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT (Wrong way)
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidPortfolioProject..CovidDeaths
--Where location like '%Canada%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS of Total Cases and Deaths per day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
-- Where location like '%Canada' and
Where continent is not null
Group by date
Order by 1,2

-- All Total Cases and Deaths to this day 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidPortfolioProject..CovidDeaths
-- Where location like '%Canada' and
Where continent is not null

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingSumVaccination,
--	RollingSumVaccination/population)*100
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not NULL
Order by 2,3


-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingSumVaccination)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingSumVaccination
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingSumVaccination/population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingSumVaccination numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingSumVaccination
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not NULL
Select *, (RollingSumVaccination/population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingSumVaccination
From CovidPortfolioProject..CovidDeaths dea
Join CovidPortfolioProject..CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not NULL

Select *
From PercentPopulationVaccinated