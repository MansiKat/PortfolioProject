Select *
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2

-- Total cases vs Total Deaths

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
Order by 1,2,3

-- Total cases vs population

Select location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))* 100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
Order by 1,2

-- Countries with Highest Infection Rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max(cast(total_cases as float)/cast(population as float))* 100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- Countries with Highest Death Count per population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continent with highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers

Select date, sum(new_cases), sum(new_deaths), (SUM(new_deaths)/SUM(new_cases))* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group by date
Order by 1,2

Select sum(new_cases), sum(new_deaths), (SUM(new_deaths)/SUM(new_cases))* 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--Group by date
Order by 1,2


Select *
FROM PortfolioProject..CovidVaccinations

-- Total Population VS Vaccinations

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccinations as Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL
ORDER BY 2,3

--USE CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) As (
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccinations as Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL
--ORDER BY 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert Into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccinations as Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
--WHERE Dea.continent is NOT NULL
--ORDER BY 2,3
Select * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for Visualization

Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) 
OVER (PARTITION BY Dea.location ORDER BY Dea.location, Dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths as Dea
JOIN PortfolioProject..CovidVaccinations as Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
WHERE Dea.continent is NOT NULL
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated