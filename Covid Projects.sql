Select * 
from dbo.['Covid deaths$']
order by 3,4

--Select * 
--from dbo.Covidvaccinations$
--order by 3,4

  Select Location, date, total_cases, new_cases, total_deaths, population
  from dbo.['Covid deaths$']
  order by 1,2

--Total cases vs total deaths
-- shows the likelyhood of dying if you contract coviv in your country
  Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100
  as DeathPercentage
  from dbo.['Covid deaths$']
  where location like '%Nigeria%'
  order by 1,2

  -- Total cases vs Population
  Select Location, date, population, total_cases,(total_cases/population)*100
  as Percentpopulationinfected
  from dbo.['Covid deaths$']
--where location like '%Nigeria%'
  order by 1,2

 -- Countries with the highest infection rate compared with Population
 
 Select Location,population,Max(total_cases) as HighestInfectioncount,Max((total_cases/population))*100
  as Percentpopulationinfected
  from dbo.['Covid deaths$']
  --where location like '%Nigeria%'
  group by Location, Population
  order by Percentpopulationinfected desc
 
 --Countries with the highest death count per population
 Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
 from dbo.['Covid deaths$']
 --where location like '%Nigeria%'
 where continent is not null
 group by Location
 order by TotaldeathCount desc

 --Analysing by continent

 Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
 from dbo.['Covid deaths$']
 --where location like '%Nigeria%'
 where continent is not null
 group by continent
 order by TotaldeathCount desc

 -- Continent with highest death count per population

 Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
 from dbo.['Covid deaths$']
 --where location like '%Nigeria%'
 where continent is not null
 group by continent
 order by TotaldeathCount desc
 

 --Global Cases

 Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,  
 Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
 from dbo.['Covid deaths$']
 --where location like '%Nigeria%'
 where continent is not null
 --group by date
 order by 1,2

 --Total number of people in the world that was vaccinated
 Select * 
 from dbo.['Covid deaths$']
 join dbo.Covidvaccinations$
 on dbo.['Covid deaths$'].location = dbo.Covidvaccinations$.location
 and dbo.['Covid deaths$'].date = dbo.Covidvaccinations$.date

 Select dbo.['Covid deaths$'].continent, dbo.['Covid deaths$'].location, dbo.['Covid deaths$'].population,
 dbo.Covidvaccinations$.new_vaccinations
 from dbo.['Covid deaths$']
 join dbo.Covidvaccinations$
 on dbo.['Covid deaths$'].location = dbo.Covidvaccinations$.location
 and dbo.['Covid deaths$'].date = dbo.Covidvaccinations$.date
 where dbo.['Covid deaths$'].continent is not null
 order by 2,3
 

 -- Use CTE
With PopVSVac ( continent, Location, Date, Population, new_vaccinations,RollingPeopleVaccinated)
as
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , Sum(cast (vac.new_vaccinations as INT)) Over ( Partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
 from dbo.['Covid deaths$'] dea
 join dbo.Covidvaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
 --order by 2,3
 )
 Select *, (RollingPeopleVaccinated/population)*100
 from PopVSVac
 

 --Temp Table
 
 Drop Table if exists #PercentPopulationVaccinated
  Create table #PercentPopulationVaccinated
 (
 Continent nvarchar (225),
 Location nvarchar (225),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric,
 )
  
 insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , Sum(cast (vac.new_vaccinations as INT)) Over ( Partition by dea.location order by dea.location, dea.date)
 as RollingPeopleVaccinated
 from dbo.['Covid deaths$'] dea
 join dbo.Covidvaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
 --order by 1,2

  Select *, (RollingPeopleVaccinated/population)*100
 from #PercentPopulationVaccinated