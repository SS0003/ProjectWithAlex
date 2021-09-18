
use AlexPortfolioProject


-- looking at the total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs popuylation 
select location, date, total_cases, total_deaths, round((total_cases/population)*100,4) as PercentPopulationInfected
from CovidDeaths
where continent is not null
order by 1,2


-- looking at the countries with highest infection rate vs population
select location, population, max(total_cases) as HihestInfectionCount, round(max(total_cases/population)*100, 2) as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc

-- showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location 
order by TotalDeathCount desc


-- Showing Continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global numbers 
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPrecentage
from CovidDeaths
where continent is not null
order by 1,2


-- Looking at total population vs vaccinations 
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d 
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac


-- Temp Table
/*drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast( v.new_vaccinations as int)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d 
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
--where d.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated 
*/

--creating view for visualizations
create view PercentPopulationVaccinated as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(convert(int, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from CovidDeaths d 
join CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null

select * from PercentPopulationVaccinated
