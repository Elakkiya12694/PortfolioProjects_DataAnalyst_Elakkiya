---Exploring the data
select * from PortfolioProject..CovidDeaths
order by 3,4


--select * from PortfolioProject..CovidVaccinations
--order by 3,4

---Extracting the data which will be used further
select Location, Date, population, total_cases, new_cases, total_deaths
from PortfolioProject..CovidDeaths
order by 1,2


---Analyzing Total cases vs Total deaths and calculating Death percentage
select Location, Date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location in ('Sweden', 'India') 
and continent is not null
order by 1,2


---Analyzing Total cases vs Population and calculating the percentage of Covid affected persons in Total population
select Location, Date, population, total_cases, (total_cases/population)*100 as Covid_Affected_Percentage
from PortfolioProject..CovidDeaths
where location in ('Sweden', 'India') 
and continent is not null
order by 1,2


---Finding the country which has highest infection rate compared to population
select Location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as High_Covid_Affected_Percentage
from PortfolioProject..CovidDeaths 
where continent is not null
Group by location, population
order by High_Covid_Affected_Percentage desc


---Finding the country which has highest death count compared to population
select Location, population, MAX(cast(total_deaths as int)) as Highest_Death_Count  --since the datatype of total_deaths is nvarchar, converting it to int as we are calculating the count of total_deaths
from PortfolioProject..CovidDeaths 
where continent is not null
Group by location, population
order by Highest_Death_Count desc


---Finding the highest death count continent wise
select continent, MAX(cast(total_deaths as int)) as Highest_Death_Count 
from PortfolioProject..CovidDeaths 
where continent is not null
Group by continent
order by Highest_Death_Count desc


---Finding the Global death percentage numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


---Analyzing Total population vs Vaccinations using CTE
With PopulationVsVaccination(Continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.location order by d.location,d.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
	join PortfolioProject..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopulationVsVaccination


---Creating Temp table
Drop Table if exists #PercentageOfPopulationVaccinated
Create Table #PercentageOfPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentageOfPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.location order by d.location,d.date ROWS UNBOUNDED PRECEDING)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
	join PortfolioProject..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
--where d.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 as Percentage_Population_Vaccinated
from #PercentageOfPopulationVaccinated


--Creating a view to store data for visulaizations
Create View PercentageOfPopulationVaccinated as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition by d.location order by d.location,d.date ROWS UNBOUNDED PRECEDING)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths d
	join PortfolioProject..CovidVaccinations v
	on d.location=v.location
	and d.date=v.date
where d.continent is not null

select * from PercentageOfPopulationVaccinated