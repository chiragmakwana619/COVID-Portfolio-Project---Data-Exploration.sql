
/*Covid 19 Data Exploration
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


select * 
from ProjectPortfolio..CovidDeath
order by 3,4

--select * 
--from ProjectPortfolio..CovidVaccination
--order by 3,4


-- Select the data that we are going to using.
select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeath
order by 1,2

--Looking at total cases vs total deaths
--Showing liklihood of dying if you contacted with covid in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from ProjectPortfolio..CovidDeath 
where location like '%India%'
order by 1,2


--Looking at total cases vs total population
-- show what percentage of population got covid
select location, date,population, total_cases, (total_cases/population)*100 as percentPopulationInfected
from ProjectPortfolio..CovidDeath 
where location like '%India%'
order by 1,2


--looking at coutry with highest infectionRate compared to population.
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from ProjectPortfolio..CovidDeath 
--where location like '%India%'
group by location, population
order by PercentPopulationInfected desc


-- showing country with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeath 
--where location like '%India%'
where continent is  null
group by location
order by TotalDeathCount desc


-- lets break down things by continent

--showing continent with highest deathcount  per population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeath 
where continent is not null
group by continent
order by TotalDeathCount desc


--Globel Numbers
select date, sum(new_cases) as totalcase, sum(cast(new_deaths as int)) as totalDeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from ProjectPortfolio..CovidDeath 
where continent is not null
group by date
--where location like '%India%'
order by 1,2


--joining table of death and vaccination
select * 
from ProjectPortfolio..CovidDeath dea
join  ProjectPortfolio..CovidVaccination vac
	on dea.location=vac.location
	and dea.date=vac.date
    
    

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 




