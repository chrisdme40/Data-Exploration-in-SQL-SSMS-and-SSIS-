select * from Portfolioproject..Covidvaccination

select * from Portfolioproject..CovidDeaths$ order by 3,4

select location,date,total_cases, new_cases, total_deaths,population
from Portfolioproject..CovidDeaths$
order by 1,2

--estimated percentage of dieing if contacted by covid
select location,date,total_cases,  total_deaths ,(total_deaths/total_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths$
where location like'%states%'
order by 1,2

--looking at total cases vs population
-- shows what percentage of population got covid

select location,date,total_cases,population ,(total_cases/population)*100 as casepercentage
from Portfolioproject..CovidDeaths$
where location like'%states%'
order by 1,2


--looking at countries with highest infection rate compared to population

select location,max(total_cases) as highestinfectioncount,population ,max((total_cases/population))*100 as casepercentage
from Portfolioproject..CovidDeaths$
--where location like'%states%'
group by location,population
order by casepercentage desc

--showing with countries highest death count per population

--the problem occured was the total_deaths datatype was giving problems
--these problems occur and the solution was to cast the data into integer
--after that we discovered that we want specific locations where as 
--it was considering continent as the location where the continent was null
--these kind of problems will occur when your doing data exploration
--so we inserted a where clause where continent is not null

select * from Portfolioproject..CovidDeaths$ 
where continent is not null 
order by 3,4

select location,max(cast(total_deaths as int)) as totaldeathcount
from Portfolioproject..CovidDeaths$
--where location like'%states%'
where continent is not null 
group by location
order by totaldeathcount desc

--now lets see by continent

--shows continent with highest death count per population

select continent,max(cast(total_deaths as int)) as totaldeathcount
from Portfolioproject..CovidDeaths$
--where location like'%states%'
where continent is not null 
group by continent
order by totaldeathcount desc


-- global numbers

--newcases vs deaths,deathpercentage on new cases each day 

select date,sum(new_cases) as totalcases, sum(cast(new_deaths as int))as totaldeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths$
-- where location like'%states%'
where continent is not null
group by date
order by 1,2

--total  cases vs total deaths and overall deathpercentage

select sum(new_cases) as totalcases, sum(cast(new_deaths as int))as totaldeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from Portfolioproject..CovidDeaths$
-- where location like'%states%'
where continent is not null
--group by date
order by 1,2


--lookinf at total population vs vaccination

select dea.continent,dea.location,dea.date
,dea.population,vac.new_vaccinations
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..Covidvaccination vac
on dea.location =vac.location
and  dea.date = vac.date
where dea.continent is not null
order by 2,3

--after the query we wanted to add the new vaccinations to add the
-- vaccinations each day

select dea.continent,dea.location,dea.date
,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..Covidvaccination vac
on dea.location =vac.location
and  dea.date = vac.date
where dea.continent is not null
order by 2,3

----(rollingpeoplevaccinated/population)*100 it gave an error cause we cant use
--a column we just created to then use the next one so what we need
--to create a cte or temptable
--use cte 
-- if t  he number of columns in the cte is different than the query it will give an error


with popvsvac (continent, location ,date ,population, ner_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date
,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..Covidvaccination vac
on dea.location =vac.location
and  dea.date = vac.date
where dea.continent is not null
 --order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100 
from popvsvac 


--Temp Table

drop table if exists #percentpopulationvaccinated 
-- drop table is use cause if you want to make changes it will give error
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric)


insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date
,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..Covidvaccination vac
on dea.location =vac.location
and  dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(rollingpeoplevaccinated/population)*100 
from #percentpopulationvaccinated



--creating view to store data for later visualizations

create view percentpopulationvaccination as
select dea.continent,dea.location,dea.date
,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date)
as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from Portfolioproject..CovidDeaths$ dea
join Portfolioproject..Covidvaccination vac
on dea.location =vac.location
and  dea.date = vac.date
where dea.continent is not null
--order by 2,3

 





