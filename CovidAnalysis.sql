use Projects;

select *
from Projects..CovidDeaths;


select *
from Projects..CovidVaccination
order by location;


select location,date,total_cases,new_cases,total_deaths,population
from Projects..CovidDeaths
order by location;

--Death percentage in every country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Projects..CovidDeaths
where location like '%Pak%'
order by location;

--Population by got covid infection
select location,date,population, total_cases, (total_cases/population)*100 as GotCovidPercentage
from Projects..CovidDeaths
--where location like '%Pak%'
order by GotCovidPercentage desc;

--maximum infection by population
select location,population, max(total_cases) as MaximumCases, max((total_cases/population))*100 as MaxGotCovidPercentage
from Projects..CovidDeaths
group by location,population
--where location like '%Pak%'
order by MaxGotCovidPercentage desc;


--Countries with highest death count
select location,continent, max(cast(total_deaths as int)) as TotalDeaths
from Projects..CovidDeaths
where continent is not null
group by location,continent
order by TotalDeaths desc;


--Total deaths by continent
select continent,max(cast(total_deaths as int)) as TotalDeaths
from Projects..CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc

--Analysing globally
select sum(total_cases) as Total_Cases,sum(cast(total_deaths as bigint)) as Total_Deaths, sum(cast(total_deaths as bigint))/sum(total_cases)*100 as Percentage_grobally
from Projects..CovidDeaths
where continent is not null
order by Percentage_grobally desc


-- joining the tables
select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidVaccination.new_vaccinations
from Projects..CovidDeaths
join Projects..CovidVaccination
on CovidDeaths.date=CovidVaccination.date
and CovidDeaths.location=CovidVaccination.location
where CovidDeaths.continent is not null
order by CovidVaccination.new_vaccinations desc


--Looking for new vaccinations
select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidVaccination.new_vaccinations,
sum(cast(CovidVaccination.new_vaccinations as BIGINT)) over (Partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.Date)
from Projects..CovidDeaths
join Projects..CovidVaccination
on CovidDeaths.date=CovidVaccination.date
and CovidDeaths.location=CovidVaccination.location
where CovidDeaths.continent is not null
order by 2,3


--Percentage of vaccination by using CTE
with percdeath(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidVaccination.new_vaccinations,
sum(cast(CovidVaccination.new_vaccinations as BIGINT)) over (Partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.Date)as RollingPeopleVaccinated
from Projects..CovidDeaths
join Projects..CovidVaccination
on CovidDeaths.date=CovidVaccination.date
and CovidDeaths.location=CovidVaccination.location
where CovidDeaths.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as vaccination_Percentage
from percdeath


--Creating view
create view PercentageofVaccination as 
select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidVaccination.new_vaccinations,
sum(cast(CovidVaccination.new_vaccinations as BIGINT)) over (Partition by CovidDeaths.location order by CovidDeaths.location, CovidDeaths.Date)as RollingPeopleVaccinated
from Projects..CovidDeaths
join Projects..CovidVaccination
on CovidDeaths.date=CovidVaccination.date
and CovidDeaths.location=CovidVaccination.location
where CovidDeaths.continent is not null
--order by 2,3

select * from PercentageofVaccination