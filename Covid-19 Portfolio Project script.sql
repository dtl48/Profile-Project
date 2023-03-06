
Select *
from PortfolioProject..coviddeaths$
Where continent is not null
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths$
Where continent is not null
order by 1,2

-- Looking at total cases vs Total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PerecentPopulationInfected
From PortfolioProject..coviddeaths$
-- Where loaction like '%states%'
order by 1,2

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_deaths/total_cases)*100 as PerecentPopulationInfected
From PortfolioProject..coviddeaths$
-- Where loaction like '%states%'
Group by Location, population
order by PerecentPopulationInfected desc

-- Showing Countries with highest Death count per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- stats by continent / Showing continents with the highest death count per population

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as PerecentPopulationInfected
From PortfolioProject..coviddeaths$
-- Where loaction like '%states%'
Where continent is not null
Group by date
order by 1,2

-- Total deaths in world

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..coviddeaths$
-- Where loaction like '%states%'
Where continent is not null
-- Group by date
order by 1,2


-- looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- CTE

With PopvsVac ( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..coviddeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2, 3

-- Working with view

Select *
From PercentPopulationVaccinated