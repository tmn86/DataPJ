#------------------------------------------------------#
#--------- Explore COVD19 data using MySQL-------------#
#------------------------------------------------------#



#-------Select data that is going to be used--------

select location, date, total_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1,2;



#----------Total cases vs total deaths------------------

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where continent is not null
order by 1,2;



#-- Looking at specific country using wildcard

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location like '%vietnam%'
and continent is not null
order by DeathPercentage desc;



#--------------Total cases vs Population-----------------------------------
#--Show what percentage of population got Covid

select location, population, date, total_cases, (total_cases/population)*100 as CasesPercentage 
from coviddeaths
#where location like '%state%'
where continent is not null
order by 1,2;



#-------Country with highest infection rate compared to population----------------

select location, population, max(total_cases) as HighestCases, max(total_cases/population)*100 as CasesPopulationRate
from coviddeaths
where continent is not null
group by location
order by CasesPopulationRate desc;



#-------Country with highest deaths count per population----------

select location, population, max(total_cases) as HighestCases, max(total_cases/population)*100 as CasesPopulationRate
from coviddeaths
where continent is not null
group by location
order by CasesPopulationRate desc;

#---------Country with highest deaths count per population----------


Select location, population, max(total_deaths) as HighestDeaths, max(total_deaths/population)*100 as DeathsPopulationRate
from coviddeaths
where continent is not null
group by location
order by DeathsPopulationRate desc;



#--------Country and number of highest deaths------------


Select location, population, max(total_deaths) as HighestDeaths
from coviddeaths
where continent is not null
group by location
order by HighestDeaths desc;



#----------Number of Deaths per region--------------


Select location, max(total_deaths) as HighestDeaths
from coviddeaths
where continent is null
group by location
order by HighestDeaths desc;




#------------Global number by date------------------


select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_percentage
from coviddeaths
where continent is not null
group by date
order by 1 desc;



#-------------Total global number-----------------------


select sum(new_cases), sum(new_deaths), sum(new_deaths)/sum(new_cases)*100 as death_percentage
from coviddeaths
where continent is not null
order by 1,2;




#--------------Join coviddeaths table and covidvaccination table----------------


Select * from DataPJ.coviddeaths dea
join DataPJ.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date;




#------------------Total population vs vaccination------------------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from DataPJ.coviddeaths dea
join DataPJ.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3;




#-------------------Use CTE-----------------------------


With PopVsVac(Continent, Location, Date, Population, PeopleVaccinated,RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population,vac.people_fully_vaccinated,
sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from DataPJ.coviddeaths dea
join DataPJ.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)
select *, (RollingPeopleVaccinated/Population)*100 as VacPercentage 
from PopVsVac;



#-------------CTE for Vaccinated/Population---------------------




With PopVsVac(Continent, Location, Date, Population, NewVaccination,PeopleVaccinated,RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,vac.people_fully_vaccinated,
sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from DataPJ.coviddeaths dea
join DataPJ.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null)
select *, (PeopleVaccinated/Population)*100 as VacPercentage 
from PopVsVac
having VacPercentage > 100;




#----------------------Using TEMP table---------------------------


#----Create temp table

drop table if exists PercentPopulationVaccinated;
Create temporary table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date date,
Population bigint(10),
NewVaccination bigint(10),
RollingPeopleVaccinated bigint(10)
);

#----Insert into temp table

insert into PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population,vac.people_fully_vaccinated,
sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from DataPJ.coviddeaths dea
join DataPJ.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;
select *, (RollingPeopleVaccinated/Population)*100 as VacPercentage 
from PercentPopulationVaccinated; 






#------------------Create view---------------

Create or replace view v_PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population,vac.people_fully_vaccinated,
sum(vac.new_vaccinations) Over (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from DataPJ.coviddeaths dea
join DataPJ.covidvaccination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;
select *, (RollingPeopleVaccinated/Population)*100 as VacPercentage 
from v_PercentPopulationVaccinated; 
