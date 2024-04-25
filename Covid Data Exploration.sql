
select *
	from PortfolioProject..CovidDeaths
	where continent is not null
	order by 3,4

--select *
--	from PortfolioProject..CovidVaccinations
--	order by 3,4

-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you get COVID in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Analysing Total Cases vs Population
-- Shows what Percentage of population got infected by Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries	with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighesInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING DOWN BY CONTINENT	
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Looking at Total Population vs Vaccination
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(COALESCE(vac.new_vaccinations, 0)) OVER ( PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(COALESCE(vac.new_vaccinations, 0)) OVER ( PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
  ON dea.location = vac.location 
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COALESCE(vac.new_vaccinations, 0)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COALESCE(vac.new_vaccinations, 0)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
