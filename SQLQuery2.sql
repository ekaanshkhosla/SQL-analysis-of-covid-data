/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Aggregate Functions, Creating Views, Converting Data Types
*/


Select *
From Project..CV --Covid Vaccine

Select *
From Project..CD --Covid deaths
order by 3

Select Location, date, total_cases, new_cases, total_deaths, population
From Project..CD
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DP  --Death Percentage
From Project..CD
Where Location like '%Germany%'
order by 1,2



Select Location, date, total_cases, population, (total_deaths/population)*100 as DP  --Death Percentage by population
From Project..CD
Where Location like '%Germany%'
order by 1,2


-- country with highest infection rate

Select Location, population, MAX(total_cases) as HIC, MAX(total_cases/population)*100 as IP  --HIC: Highest infection count, IP: infection percentage 
From Project..CD
Group By location,population
order by IP desc



-- Showing countries with Highest Death count per population

Select Location, population, MAX(cast(total_deaths as int)) as TDC, MAX(cast(total_deaths as int)/population)*100 as DP --Death percentage
From Project..CD
where continent is not null
Group By location,population
order by TDC desc 



-- Data Analysis by continent

Select continent, MAX(cast(total_deaths as int)) as TDC, MAX(cast(total_deaths as int)/population)*100 as DP
From Project..CD
where continent is not null
AND location not like '%income%' 
AND location not like '%International%'
Group By continent
order by TDC desc 



-- GLOBAL NUMBERS

Select date, SUM(new_cases) TC, SUM(cast(new_deaths as int)) as TD , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DP
From Project..CD
where continent is not null
Group By date
order by 1 



--  Total Population vs Vaccinations

Select D.continent, D.location, D.date, D.population,V.new_vaccinations
, SUM(Convert(bigint, V.new_vaccinations)) OVER (Partition by D.location order by D.location,
D.date) as RPV
From Project..CV V
Join Project..CD D
	On V.date = D.date
	and V.location = D.location 
where D.continent is not null
order by 2,3



--USE CTE

with PopvsVac ( continent, location, date, population, new_vaccinations, RPV )
as
(
Select D.continent, D.location, D.date, D.population,V.new_vaccinations
, SUM(Convert(bigint, V.new_vaccinations)) OVER (Partition by D.location order by D.location,
D.date) as RPV
From Project..CV V
Join Project..CD D
	On V.date = D.date
	and V.location = D.location 
where D.continent is not null
--order by 2,3
)
Select *, (RPV/Population)*100
From PopvsVac




--Create view to store data

Create View PPV as 
Select D.continent, D.location, D.date, D.population,V.new_vaccinations
, SUM(Convert(bigint, V.new_vaccinations)) OVER (Partition by D.location order by D.location,
D.date) as RPV
From Project..CV V
Join Project..CD D
	On V.date = D.date
	and V.location = D.location 
where D.continent is not null

Select * from PPV

