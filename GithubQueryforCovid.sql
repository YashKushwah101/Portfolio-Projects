Select *
from [Portfolio Project 1].dbo.Covid
where continent is not null
order by 3,4

--Select *
--from [Portfolio Project 1].dbo.CovidVax
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project 1].dbo.Covid
where continent is not null
order by 1,2

-- Total Cases vs Total Death Scenario/Stats
-- Likelihood of deying by covid in India 
Select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project 1].dbo.Covid
where location like 'India'
order by 1,2

-- Now we are taking a look at the total cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from [Portfolio Project 1].dbo.Covid
where location like 'India'
order by 1,2

-- Countries with highest infection rate compared to population

Select location, Max(total_cases) as Highest_Infection_Count, population, Max((total_cases/population)*100) as InfectedPercentage
from [Portfolio Project 1].dbo.Covid
--where location like 'India'
where continent is not null
group by location, population
order by 4 desc


--Countires With Highest Death Rate

Select location, max(cast(total_deaths as int)) as TotalDeath, max((total_deaths/population)*100) as TotalDeathRate
from [Portfolio Project 1].dbo.Covid
--where location like 'India'
where continent is not null
group by location
order by TotalDeath desc

-- Playing with global Numbers


select date, sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
From [Portfolio Project 1].dbo.Covid
where continent is not null
group by date
order by 1,2

-- Total Stats

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project 1].dbo.Covid
where continent is not null 
--Group By date
order by 1,2

--Now adding a new table for more data

Select *
from [Portfolio Project 1].dbo.CovidVaccinations

-- looking at toal population vs vaccinations with the help of cte, first we are getting our data ready since we cant use the same colum we just created to do maths/Calculations over it

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location,death.date) as VaccinationSummationOverTime

from [Portfolio Project 1].dbo.Covid as death
join [Portfolio Project 1].dbo.CovidVaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
	where death.continent is not Null and vac.continent is not null
	order by 2,3


	with CTE_PopvsVac (continent, location,date, population,new_vaccinations, VaccinationSummationOverTime)
	as
	(
	Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location,death.date) as VaccinationSummationOverTime

from [Portfolio Project 1].dbo.Covid as death
join [Portfolio Project 1].dbo.CovidVaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
	where death.continent is not Null and vac.continent is not null
	
)

select *, (VaccinationSummationOverTime/population)*100
from CTE_PopvsVac
order by 2,3

-- That took some time!

--To be honest idk what I am doing anymore, but data is fun, or am I the only one here? I should make a journal here and keep my darkest thoughts here , who's gonna read it anyway ?

--back to work , working on temp tables 



drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated

(continent varchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinationSummationOverTime numeric
)
insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location,death.date) as VaccinationSummationOverTime

from [Portfolio Project 1].dbo.Covid as death
join [Portfolio Project 1].dbo.CovidVaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
	where death.continent is not Null
	

	select *, (VaccinationSummationOverTime/population)*100
from #PercentPopulationVaccinated
order by 1,2,3,4


-- Creating view to store dota

create view  PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as bigint)) over (partition by death.location order by death.location,death.date) as VaccinationSummationOverTime

from [Portfolio Project 1].dbo.Covid as death
join [Portfolio Project 1].dbo.CovidVaccinations as vac
	on death.location = vac.location
	and death.date = vac.date
	where death.continent is not Null
	--order by 2,3
	

select *
from PercentPopulationVaccinated
