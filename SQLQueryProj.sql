--Shows likelihood of death in U.S.
Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as Death_percentage
From PortProj1..covidDeaths$
where location like '%states%'
order by 1,2

--total cases vs population in U.S.
Select location, date, total_cases, population, (cast(total_deaths as float)/population)*100 as Cases_percentage
From PortProj1..covidDeaths$
--where location like '%states%'
order by 1,2

-- Highest Infection Rate
Select location, population, MAX(cast(total_cases as int)) as HighestInfectionCount, MAX((cast(total_cases as int)/population))*100 as Infection_percentage
From PortProj1..covidDeaths$
--where location like '%states%'
Where continent is not null
Group by location, population
order by Infection_percentage desc

--Highest death %
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortProj1..covidDeaths$
--where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Breaking things by continent
--showing continents with highest death counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortProj1..covidDeaths$
--where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--global numbers by dates

Select date, SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(New_deaths)*100 as percentageDeaths
From PortProj1..covidDeaths$
--where location like '%states%'
Where continent is not null and new_cases!=0
Group by date
order by 1,2

-- Total Population vs vaccination
Select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacc
From PortProj1..covidDeaths$ dea
Join PortProj1..covidvacc$ vac
On dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
and vac.new_vaccinations!=0
Order by 2,3


--Using CTE
With PopvsVac(Continent, Location, Date,Population, New_Vaccination,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacc
From PortProj1..covidDeaths$ dea
Join PortProj1..covidvacc$ vac
On dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
and vac.new_vaccinations!=0
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
-- if alterations
DROP TABLE if exists PercentagePopulationVaccinated

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccination numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacc
From PortProj1..covidDeaths$ dea
Join PortProj1..covidvacc$ vac
On dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
and vac.new_vaccinations!=0
--Order by 2,3

Select *, (RollingPeopleVaccination/Population)*100
From #PercentagePopulationVaccinated

--Create View for data viz

Create View PercentagePopulationVaccinated as
Select dea.continent,dea.location, dea.date , dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVacc
From PortProj1..covidDeaths$ dea
Join PortProj1..covidvacc$ vac
On dea.location=vac.location
and dea.date= vac.date
where dea.continent is not null
and vac.new_vaccinations!=0
--Order by 2,3