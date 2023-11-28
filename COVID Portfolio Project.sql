select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

select location, 
	   date, 
	   total_cases, 
	   new_cases, 
	   total_deaths, 
	   population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN INDONESIA

select location, 
	   date, 
	   total_cases, 
	   total_deaths,
	   (convert(float,total_deaths))/(convert(float,total_cases)) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and location like '%Indonesia%'
order by 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS THE PERCENTAGE OF POPULATION GOT COVID

select location, 
	   date, 
	   population,
	   total_cases, 
	   (convert(float,total_cases))/(convert(float,population)) * 100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

select location, 
	   population,
	   max(convert(int, total_cases)) as HighestInfectionCount,
	   max(convert(int, total_cases)/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--LET'S BREAK THINGS DOWN BY CONTINENT

select location, 
	   max(convert(float, total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

select location, 
	   max(convert(float, total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

select continent, 
	   max(convert(float, total_deaths)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null 
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select sum(new_cases) as TotalCases,
	   sum(cast(new_deaths as int)) as TotalDeath,
	   sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATION

select dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%Netherlands%'
)

select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.location like '%Netherlands%'
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

create view PercentPopulationVaccinated as
select dea.continent, 
	   dea.location,
	   dea.date,
	   dea.population,
	   vac.new_vaccinations,
	   sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated