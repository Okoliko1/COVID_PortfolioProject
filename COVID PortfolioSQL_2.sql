SELECT *
FROM Portfolio_Activity.dbo.covid_deaths
where continent is not null
order by 3,4



--SELECT *
--FROM Portfolio_Activity.dbo.covidvaccinations
--order by 3,4

-- select data that we are going to be using


SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Portfolio_Activity.dbo.covid_deaths
where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- showing the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as Death_Percentage
FROM Portfolio_Activity.dbo.covid_deaths
where location like '%state%'
and continent is not null
order by 1,2


-- Looking at Total Cases Vs Population

-- Shows what percentage of population got covid

SELECT location, date, population, total_cases,  (Total_cases/population)*100 as PercentPopulationInfected
FROM Portfolio_Activity.dbo.covid_deaths
where continent is not null
--where location like '%state%'
order by 1,2

--Country with highest infection rate compared to population


SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((Total_cases/population))*100 as PercentPopulationInfected
FROM Portfolio_Activity.dbo.covid_deaths
where continent is not null
--where location like '%state%'
group by location, population
order by PercentPopulationInfected desc

--Showing Countries With Highest Deat Count Per Population

SELECT location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM Portfolio_Activity.dbo.covid_deaths
--where location like '%state%'
where continent is not null
group by location 
order by TotalDeathCount desc

-- BREAKING DOWN BY CONTINENT

-- Showing The Continent With The highest Death Count Per Population

SELECT continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM Portfolio_Activity.dbo.covid_deaths
--where location like '%state%'
where continent is not null
group by continent 
order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage 
FROM Portfolio_Activity.dbo.covid_deaths
--where location like '%state%'
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM Portfolio_Activity..covid_deaths dea
join Portfolio_Activity..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM Portfolio_Activity.dbo.covid_deaths dea
join Portfolio_Activity.dbo.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *, (RollingPeopleVacinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP table if exists #PercentPopulation_Vaccinated
create table #PercentPopulation_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric,
)

insert into #PercentPopulation_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM Portfolio_Activity..covid_deaths dea
join Portfolio_Activity..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulation_Vaccinated


-- Creating View to store data for later visualization

Create View PercentPopulation_Vaccinated01 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 ,SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM Portfolio_Activity.dbo.covid_deaths dea
join Portfolio_Activity.dbo.covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
 

 select *
 from Portfolio_Activity.dbo.PercentPopulation_Vaccinated01

