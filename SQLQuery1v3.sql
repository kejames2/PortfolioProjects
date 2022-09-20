Select *
From [Portfolio Project].dbo.CovidDeaths
Where Continent is not null
Order by 3,4

--Select *
--From dbo.CovidVaccinations
--Order by 3,4

--Select the data for use
Select Location, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
Order by 1,2

-- Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract Covid in your Country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths

Where Location = 'United States'
Order by 1,2

--Total Cases vs. Population of US
--Shows what percentage of population with Covid in US
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths
Where Location = 'United States'
Order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From dbo.CovidDeaths
Group by Location, population
--Where Location = 'United States'
Order by PercentPopulationInfected desc

-- Let's Break Things Down by Continent 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Group by continent
--Where Location = 'United States'
Order by TotalDeathCount desc


--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
Where continent is not null
Group by Location
--Where Location = 'United States'
Order by TotalDeathCount desc

--GLOBAL NUMBERS
--Total Cases per day
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
--Where Location = 'United States'
Where continent is not null
Group by date
Order by 1,2

--Total Cases in general
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project].dbo.CovidDeaths
--Where Location = 'United States'
Where continent is not null
--Group by date
Order by 1,2

--First Join (Date and Location Join)
Select *
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 

--Looking at Total Population v. Vaccinations:

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null 
Order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date)
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null 
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location)
Order by dea.location, dea.date
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null 
Order by 2,3
--RollingPeopleVaccinated: Looking at Total Population v. Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null and vac.new_vaccinations is not null
Order by 2,3


--USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null and vac.new_vaccinations is not null 
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinatedTable
Create Table #PercentPopulationVaccinatedTable 
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinatedTable
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null and vac.new_vaccinations is not null
--Order by 1,2,3

Select *
From #PercentPopulationVaccinatedTable 

--Creating View to store data for later visualization

Create View PercentPopulationVaccinatedTable as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(CAST(vac.new_vaccinations as bigint))OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location 
	and dea.date = vac.date 
Where dea.continent is not null
--Order by 2,3

