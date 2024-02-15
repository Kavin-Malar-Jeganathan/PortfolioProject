--Select * from CovidDeaths
--select location, date, total_cases, total_deaths, population
--from CovidDeaths
--order by 1,2

--Total cases Vs total deaths
select location, date, total_cases(cast as int), total_deaths(cast as int), population, (total_deaths(cast as int)/total_cases(cast as int))*100 as deathsVsCases
from CovidDeaths
order by 1,2

--Total cases Vs total deaths
select location, date, total_cases, total_deaths, population, (total_deaths/population)*100 as Death_Percent
from CovidDeaths
where location = 'India' and continent is not null
order by 1,2

--Looking at each country's highest deaths
select location, total_cases, total_deaths, population, max(total_deaths) as MaxDeath
from CovidDeaths
order by 1,2
group by location,  total_cases, total_deaths, population



--looking at all countries Infection rate compared to the population 

select location, population, max(total_cases) as MaxInfectedCases, max(total_cases/population) as InfectedPercent
from PortfolioProject..CovidDeaths
where continent is not null and location = 'United States'
group by Location, population
order by 4 DESC

--looking at all countries death rate compared to the population 

select location, population, max(cast(total_deaths as int)) as MaxDeath, max(cast(total_deaths/population as float)) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 DESC

select location, max(total_deaths) as MaxDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 1 DESC

--BREAKING THINGS BY CONTINENT

--Looking atcontinents with highest death count per population

select continent, max(cast(total_deaths as int)) as MaxDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 DESC

--correct one
select location, max(cast(total_deaths as int)) as MaxDeath
from PortfolioProject..CovidDeaths
where continent is null and location not like '%income%'
group by location
order by 2 DESC

--GLOBAL NUMBERS
select date, sum(New_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(New_deaths as float))/sum(cast(new_cases as float))*100
from PortfolioProject..CovidDeaths
where continent is not null and new_Cases <> 0
group by date
order by 1

select date, sum(New_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(New_deaths as float))/sum(cast(new_cases as float))*100
from PortfolioProject..CovidDeaths
where continent is not null and new_Cases <> 0
group by total_cases

--Joining the 2 tables
select * from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
on dea.date = vac.date and dea.location = vac.location

-- Showing how much of the population is vaccinated
select dea.date, dea.location, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
on dea.date = vac.date and dea.location = vac.location
where dea.location is not null
order by 1,2

--with running count
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location)
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--using CTE
with PopulationVsVaccinated (continent, location, date, population, New_Vaccinaitons, People_vaccinated_Rolling_count)
as 
( select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinatedRolling
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date where dea.continent is not null
)
select *, People_vaccinated_Rolling_count/population as Percent_Vaccinated from PopulationVsVaccinated


--using Temp table
drop table if exists #PercentPeopleVaccinated

create table #PercentPeopleVaccinated (
Continent nvarchar(150),
Location nvarchar(150),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedRolling numeric
)

insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedRolling
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date where dea.continent is not null

--select *, peopleVaccinatedRolling from #PercentPeopleVaccinated

--using Views to store data for data visualization
create view PercentPopulationVaccnated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedRolling
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date where dea.continent is not null

select * from PercentPopulationVaccnated

drop view PercentPopulationVaccnated

--view 2
create view peoplevaccinatedview as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(numeric,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinatedRolling
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date where dea.continent is not null

select * from peoplevaccinatedview
drop view peoplevaccinatedview 