
USE PortfolioProjects

Select * 
From PortfolioProjects..CovidDeaths
Where continent is not null
Order by 3,4

--select * 
--from PortfolioProjects..CovidVaccinations
--ORDER BY 3,4

select location, date, total_cases, new_cases,total_deaths,population
from PortfolioProjects..CovidDeaths
Where continent is not null
order by 1,2

--Looking Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProjects..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Total Cases vs Popoulation

select location, date,population, total_cases,  (total_cases/population)*100 as DeathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%states%'
Where continent is not null
order by 1,2

--Looking at Countries have highest infection rate according to Population

select location, population, max(total_cases) as HighestInfectionCount,  max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProjects..CovidDeaths
--where location like '%states%'
Where continent is not null
group by location,population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%states%'
Where continent is not null
group by location
order by TotalDeathCount Desc

--Let's break things down by continent


--Showing continents with the highest death count per popoulation

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProjects..CovidDeaths
--where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount Desc

--Global Numbers

select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, SUM(CAST(new_deaths as INT))/Sum(new_cases)*100 as deathPercentage
from PortfolioProjects..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--Looking for Total vaccination VS Population


select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(int,VAC.new_vaccinations)) OVER (Partition by DEA.location Order by DEA.location, DEA.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM
PortfolioProjects..CovidDeaths DEA
JOIN PortfolioProjects..CovidVaccinations VAC
  ON DEA.location = VAC.location
  and DEA.date = VAC.date
WHERE DEA.continent is not null
order by 2,3


 --USE CTE

With PopvsVac (continent, location, date, population, new_vaccination,RollingPeopleVaccinated)
as 
(
select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(int,VAC.new_vaccinations)) OVER (Partition by DEA.location Order by DEA.location, DEA.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM
PortfolioProjects..CovidDeaths DEA
JOIN PortfolioProjects..CovidVaccinations VAC
  ON DEA.location = VAC.location
  and DEA.date = VAC.date
WHERE DEA.continent is not null
--order by 2,3
 ) 
 SELECT *, (RollingPeopleVaccinated/population)*100 
 FROM PopvsVac



 --TEMP TABLE

 Drop Table IF exists #PercentPopulationVaccinated
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
select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(int,VAC.new_vaccinations)) OVER (Partition by DEA.location Order by DEA.location, DEA.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM
PortfolioProjects..CovidDeaths DEA
JOIN PortfolioProjects..CovidVaccinations VAC
  ON DEA.location = VAC.location
  and DEA.date = VAC.date
--WHERE DEA.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
 FROM #PercentPopulationVaccinated

 --Creatinhg View to store data for later visualizations

Create View PercentPopulationVaccinated as
select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CONVERT(int,VAC.new_vaccinations)) OVER (Partition by DEA.location Order by DEA.location, DEA.date)
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100
FROM
PortfolioProjects..CovidDeaths DEA
JOIN PortfolioProjects..CovidVaccinations VAC
  ON DEA.location = VAC.location
  and DEA.date = VAC.date
WHERE DEA.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated


