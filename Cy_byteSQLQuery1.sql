Select *
from Project..['Covid deaths$']
order by 3,4

--Looking at particular columns on the table 
Select Location, date, total_cases, new_cases, total_deaths, population
from Project..['Covid deaths$']
order by 1,2

--Looking at the total cases vs total death
Select Location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as float)/ cast(total_cases as float))*100 as DeathPercentage 
from Project..['Covid deaths$']
order by 1,2

--looking at total case vs population in south africa
Select continent, location, date, total_cases, population
from Project..['Covid deaths$']
where location like '%south africa%'
and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestIfectiousCount, Max((total_cases/population)) as PercentPopulationIfected
From Project..['Covid deaths$']
Group by Location,population
order by PercentPopulationIfected desc

--looking at countries/continent with the highest death count per population
Select continent, MAX(total_deaths) as TotalDeathCount
From Project..['Covid deaths$']
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Project..['Covid deaths$']
where continent is not null
Order By 1,2

--working with JOINS
Select *
from Project..['Covid deaths$'] dea
join Project..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date

--looking at the total population vs Vaccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
  as FPeopleVaccinated
from Project..['Covid deaths$'] dea
join Project..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3

-- Using CTE 
with popvsvas (continent, location, date, population,new_vaccinations, FpeopleVaccinated)
as
(
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
  as FPeopleVaccinated
from Project..['Covid deaths$'] dea
join Project..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3


)
select *, (FPeopleVaccinated/population)*100 as FpvPerPop
from popvsvas


--temp table
DROP Table If exists #PercentPopulationVccinated
Create Table #PercentPopulationVccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
FPeopleVaccinated numeric
)
insert into #PercentPopulationVccinated
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
  as FPeopleVaccinated
from Project..['Covid deaths$'] dea
join Project..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3
select *, (FPeopleVaccinated/population)*100 as FpvPerPop
from #PercentPopulationVccinated

--Creating view for storing data for Visualisation
Create View PercentPopulationVccinated
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)
  as FPeopleVaccinated
from Project..['Covid deaths$'] dea
join Project..CovidVaccination$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
--order by 2,3

Select *
From PercentPopulationVccinated


