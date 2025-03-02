--1. Total Cases & Death 
select  sum(new_deaths) as TotalDeaths, sum(new_cases) as TotalCases, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage  
FROM public."CovidDeaths"
where (continent is not null)
AND (new_deaths is not null) AND (new_cases is not null)
order by 1,2

--2 Highest death count as per population by Continent
SELECT location, max(total_deaths) as TotalDeathCount
FROM public."CovidDeaths"
where continent is null AND location not in ('World', 'European Union', 'International') and
(total_deaths is not null)
group by location
order by TotalDeathCount desc


--3.
with popvsvac(continent, location, date, population, new_vaccinations, cummulativefrequency_peoplevaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as cummulativefrequency_peoplevaccinated
from public."CovidDeaths" dea
Join public."CovidVaccination" vac
	on dea.location=vac.location
	and dea.date=vac.date
where (dea.continent is not null) AND (vac.new_vaccinations is not null)
order by 2,3)

select *, (cummulativefrequency_peoplevaccinated/population)*100 as percentage_vaccinated
from popvsvac


--4 Ranking highest infection rate of countries with population
SELECT location, date, population, max(total_cases) as HighestCases, Max(total_cases/population)*100 as percentageinfected
FROM public."CovidDeaths"
where total_cases is not null and location not in ('International') 
group by location, population, date
order by percentageinfected desc








