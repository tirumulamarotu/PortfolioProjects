select *
from PortfolioProject.dbo.CovidDeaths

select *
from covidVaccinations

use PortfolioProject

select *
from CovidDeaths
where continent is not null
order by 3,4;

--select *
--from CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths
order by 1,2;

--Looking at Total Cases vs Total Deaths.
--Shows the likelihood of dying if contracted covid 

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
from CovidDeaths
where location like '%states%';

--shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
from CovidDeaths
where location like '%states%'

--what country has the highest infection rates compared to population

Select location, population, max(total_cases) HighestInfectionCount, max((total_cases/population)) * 100 AS PercentPopulationInfected
from CovidDeaths
Group by location, population
Order by PercentPopulationInfected Desc;

--How many percent of people died from covid per country

Select location, max(cast(total_deaths as int)) TotalDeathCount
from CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount Desc;

----break down by continent/location

Select continent, max(cast(total_deaths as int)) TotalDeathCount
from CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount Desc;

Select location, max(cast(total_deaths as int)) TotalDeathCount
from CovidDeaths
where continent is null
Group by location
Order by TotalDeathCount Desc;

--Global numbers

Select date, sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where Continent is not null
Group By date
order by 1,2;

Select sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where Continent is not null;

--total population vs vaccinated

select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location Order by cd.location,cd.date)
as RollingPeopleVaccinated
from CovidDeaths CD
Join CovidVaccinations CV
on CD.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3;


--Use CTE

with PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location Order by cd.location,cd.date)
as RollingPeopleVaccinated
from CovidDeaths CD
Join CovidVaccinations CV
on CD.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
from PopVsVac;

--temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

Insert into #PercentPopulationVaccinated

Select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location Order by cd.location,cd.date)
as RollingPeopleVaccinated
from CovidDeaths CD
Join CovidVaccinations CV
on CD.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated;

--creating view to store data for visualisation

Create View PercentPopulationVaccinated as 
Select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations
, sum(convert(int,cv.new_vaccinations)) over (partition by cd.location Order by cd.location,cd.date)
as RollingPeopleVaccinated
from CovidDeaths CD
Join CovidVaccinations CV
on CD.location = cv.location
and cd.date = cv.date
where cd.continent is not null


Select *
from PercentPopulationVaccinated

