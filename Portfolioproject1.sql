--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

SELECT *
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2



-- Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (try_cast(total_deaths as decimal(12,2)) / NULLIF(try_cast(total_cases as int),0))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

select location, date, total_cases, total_deaths, (CONVERT(DECIMAL(18,2), total_deaths) / CONVERT(DECIMAL(18,2), total_cases) )*100 as DeathPercent
from Portfolioproject..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, Population, total_cases,  (try_cast(total_cases as decimal(12,2)) / NULLIF(try_cast(population as int),0))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Where location like '%Canada%'
ORDER BY 1,2

--Looking at countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as Percentpopulationinfected
FROM PortfolioProject..COVIDDEATHS$
Group by Location,Population
ORDER BY PercentPopulationInfected desc

-- Showing Countries with Highest Death Count Per Population

Select Location, Population, MAX(total_deaths) as HighestDeathsCount, Max(total_deaths/population)*100 as PercentpopulationDeaths
FROM PortfolioProject..COVIDDEATHS$
Group by Location,Population
ORDER BY PercentPopulationDeaths desc

-- Showing Countries with Highest Daeth Count Per Population

SELECT Location, MAX(Cast (total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..COVIDDEATHS$
WHERE Continent is not null
Group by Location
ORDER BY TotalDeathsCount desc

SELECT *
FROM PortfolioProject..Coviddeaths$
WHERE Continent is not null
ORDER BY 3,4


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT Continent, MAX(Cast (total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..COVIDDEATHS$
WHERE Continent is not null
Group by Continent
ORDER BY TotalDeathsCount desc

SELECT Location , MAX(Cast (total_deaths as int)) as TotalDeathsCount
FROM PortfolioProject..COVIDDEATHS$
WHERE Continent is null
Group by Location
ORDER BY TotalDeathsCount desc

-- Global Numbers
SELECT SUM (new_cases) as total_cases,SUM(cast (new_deaths as int)) as total_deaths, Sum(Cast (new_deaths  as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..COVIDDEATHS$
WHERE Continent is NOT null
--GROUP BY date
ORDER BY 1,2

SELECT *
FROM PortfolioProject..COVIDDEATHS$ DEA
JOIN Portfolioproject..COVIDVACCINATION$ VAC
 ON DEA.LOCATION=VAC.LOCATION
 and DEA.DATE=VAC.DATE
 ORDER BY 1,2
  
  --Looking at total population vs total vaccination
  
  SELECT SUM(cast (Population as int)) as totalpopulation , SUM(cast (total_vaccinations as int)), SUM(cast(total_vaccinations as int))/ SUM(cast(Population as int))*100 as vaccinationpercentage
  FROM PortfolioProject..COVIDDEATHS$ DEA
  JOIN Portfolioproject..COVIDVACCINATION$ VAC
 ON DEA.LOCATION=VAC.LOCATION
 and DEA.DATE=VAC.DATE
 
 SELECT dea.continent, dea.location, dea.date, dea.population, VAC.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
 from PortfolioProject..COVIDDEATHS$ dea
 JOIN Portfolioproject..COVIDVACCINATION$ VAC
 ON dea.location=vac.location
 and dea.date=vac.date
 Where (cast(vac.new_vaccinations as bigint)) is not null
 ORDER BY 2,3

 SELECT dea.continent, dea.location, dea.date, dea.population, VAC.new_vaccinations
 , SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date)
 from PortfolioProject..COVIDDEATHS$ dea
 JOIN Portfolioproject..COVIDVACCINATION$ VAC
 ON dea.location=vac.location
 and dea.date=vac.date
 --Where dea.continent is not null
 ORDER BY 2,3
  

--USE CTE

WITH PopvsVAC (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, VAC.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
 from PortfolioProject..COVIDDEATHS$ dea
 JOIN Portfolioproject..COVIDVACCINATION$ VAC
 ON dea.location=vac.location
 and dea.date=vac.date
 Where dea.continent is not null)
 --ORDER BY 2,3
 SELECT *,( Rollingpeoplevaccinated/ Population)*100
 FROM POPVSVAC

 --TEMP TABLE
 Drop table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 new_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, VAC.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
 from PortfolioProject..COVIDDEATHS$ dea
 JOIN Portfolioproject..COVIDVACCINATION$ VAC
 ON dea.location=vac.location
 and dea.date=vac.date
 --Where (cast(vac.new_vaccinations as bigint)) is not null
 --ORDER BY 2,3
 SELECT *,( Rollingpeoplevaccinated/ Population)*100
 FROM #PercentPopulationVaccinated

 --Creating view to store data for later visualisations

 Create View PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, VAC.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as Rollingpeoplevaccinated
 from PortfolioProject..COVIDDEATHS$ dea
 JOIN Portfolioproject..COVIDVACCINATION$ VAC
 ON dea.location=vac.location
 and dea.date=vac.date
 Where dea.continent is not null
 --ORDER BY 2,3

 SELECT*
 FROM PercentPopulationVaccinated