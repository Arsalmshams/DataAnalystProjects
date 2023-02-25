Select *
From PortfolioProject..['Covid Deaths$']
Where continent is not null
order by 3,4


Select *
From PortfolioProject..['Covid Vaccinations$']
order by 3,4


-- Data to be explored
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..['Covid Deaths$']
Order by 1,2


-- Following query shows Fatality rate for each date for all Countries using Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
Order by 1,2

-- Following query shows Fatality rate for each date in Canada using Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
Where location = 'Canada'
Order by 1,2


-- Following query shows % of population that was affected by Covid in Canada
Select location, date, population, total_cases, (total_cases/population)*100 as Affected_Population
From PortfolioProject..['Covid Deaths$']
Where location = 'Canada'
Order by 1,2


-- Following query shows Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Affected_Population
From PortfolioProject..['Covid Deaths$']
Group by location, population
Order by Affected_Population desc


-- Following query shows countries with Highest Death Count per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Let's zoom out and check out the same data from a higher level

-- Following query shows Continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths$']
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Current Global Numbers
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths$']
Where continent is not null
--Group by date
Order by 1,2


-- Using Common Table Expression (CTE)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (PeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for visualizations
 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From PortfolioProject..['Covid Deaths$'] dea
Join PortfolioProject..['Covid Vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PercentPopulationVaccinated