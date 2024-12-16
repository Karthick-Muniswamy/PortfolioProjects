use [Covid Project];
--Total Cases vs Total Death
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [dbo].[CovidDeaths$]
where location like '%states%'
order by 1,2;

--Total Cases vs Population
select location, date, total_cases, population, (total_cases/population)*100 as PopulationInfectedPercentage
from [dbo].[CovidDeaths$]
where location like '%states%'
order by 1,2;

--Countries with highest infection rate by population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectedPercentage
from [dbo].[CovidDeaths$]
group by location, population
order by PopulationInfectedPercentage desc;

--Countries with highest Death count by population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths$]
where continent is not null
group by location
order by TotalDeathCount desc;

--Combining both tables
select *
from CovidDeaths$ d
join CovidVaccinations$ v
on d.location = v.location and d.date = v.date;

--Total population vs vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingTotalVaccination
from CovidDeaths$ d
join CovidVaccinations$ v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3;

with PopvsVac (continent, location, date, population, new_vaccination, RollingTotalVaccination)
as 
(
	select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingTotalVaccination
	from CovidDeaths$ d
	join CovidVaccinations$ v
	on d.location = v.location and d.date = v.date
	where d.continent is not null
)	

select *, (RollingTotalVaccination/population)*100 as VaccinationOverPopulation from PopvsVac;


--TEMP TABLE
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric, 
RollingTotalVaccination numeric
)

insert into #percentpopulationvaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingTotalVaccination
	from CovidDeaths$ d
	join CovidVaccinations$ v
	on d.location = v.location and d.date = v.date
	where d.continent is not null

select *, (RollingTotalVaccination/population)*100 as VaccinationOverPopulation from #percentpopulationvaccinated;

--Create VIEW
create view percentpopulationvaccinated
as select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
	sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingTotalVaccination
	from CovidDeaths$ d
	join CovidVaccinations$ v
	on d.location = v.location and d.date = v.date
	where d.continent is not null