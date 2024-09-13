
-- Select data
-- I will be focusing on Bangladesh in this project

select continent,location,date,total_cases, new_cases,total_deaths,population
from dbo.CovidDeaths
where continent is not null
order by 1,2

-- Death percentage in a given location 

select location,date, total_cases, total_deaths, (total_deaths *1.0/total_cases) *100  as Death_Percentage 
from dbo.CovidDeaths
where 
location like '%Bangladesh%' -- update this to change location
and continent is not null 
order by 1,2

-- looking at Total Cases vs Population

select location,date, population, total_cases, (total_cases *1.0/population) *100  as Case_Percentage 
from dbo.CovidDeaths
where 
location like '%Bangladesh%' -- update this to change location
and continent is not null 
order by 1,2

-- Looking at countires with the highest infection rate to population

select location,population, max(total_cases) as Highest_infection, max((total_cases *1.0/population) *100)  as Percentage_Infected 
from dbo.CovidDeaths
Where 
continent is not null 
group by location,population
order by Percentage_Infected desc


-- Showing countries with the highest death count per population

select location,max(total_deaths) as Total_death 
from dbo.CovidDeaths
Where 
continent is not null 
group by location
order by  Total_death desc


-- Data by Continent
-- Showing Continents with the highest death rate

select continent,max(total_deaths) as Total_death 
from dbo.CovidDeaths
Where 
continent is not null 
group by continent
order by  Total_death desc

-- Global numbers

select sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths, (sum(new_deaths) *1.0/sum(new_cases)) *100 as Death_Percentage 
from dbo.CovidDeaths
where 
continent is not null 
order by 1,2

-- Global numbers by date

select date, sum(new_cases) as Total_cases, sum(new_deaths) as Total_deaths,(sum(new_deaths) *1.0/sum(new_cases)) *100  as Death_Percentage 
from dbo.CovidDeaths
where 
continent is not null 
group by date
order by 1,2

-- Looking for vaccination percentage
-- USE CTE

With VaccinationRate (Continent, Location,Date,Population,New_Vaccination,Rolling_VaccinationCount)
as(
Select death.continent,death.location,death.date,death.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by death.location order by death.location, death.date ) as Rolling_VaccinationCount
from dbo.CovidDeaths death
join dbo.CovidVaccination Vac
  on death.location = vac.location
  and death.date = vac.date

where 
death.continent is not null)

select *, (Rolling_VaccinationCount/Population) *100
from VaccinationRate


-- USE Temporary Table
Drop table if exists #PercentVaccinated  -- Allows edit or update the table
Create Table #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingVaccinated numeric
)

Insert into #PercentVaccinated
Select death.continent,death.location,death.date,death.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by death.location order by death.location, death.date ) as Rolling_VaccinationCount
from dbo.CovidDeaths death
join dbo.CovidVaccination Vac
  on death.location = vac.location
  and death.date = vac.date
where 
death.continent is not null

select *, (RollingVaccinated/Population) *100
from #PercentVaccinated


-- Crating views to store data for later

Create view PercentVaccinated as
Select death.continent,death.location,death.date,death.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by death.location order by death.location, death.date ) as Rolling_VaccinationCount
from dbo.CovidDeaths death
join dbo.CovidVaccination Vac
  on death.location = vac.location
  and death.date = vac.date
where 
death.continent is not null

Create view ContinentDeath as
select continent,max(total_deaths) as Total_death 
from dbo.CovidDeaths
Where 
continent is not null 
group by continent
