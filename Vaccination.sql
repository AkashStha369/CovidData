-- 1.) total test vs positive rate

select sum(total_tests) as TotalTests, avg(positive_rate) as AveragePositiveRate
FROM public."CovidVaccination"
where (continent is not null)
AND (total_tests is not null) AND (positive_rate is not null)
order by 1,2

-- 2.) Percentage of Population vaccinated using CTE:

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

--3.)Total Vaccination continent as per population 
SELECT location, max(total_vaccinations) as TotalVaccinations
FROM public."CovidVaccination"
where continent is null AND location not in ('World', 'European Union', 'International') and
(total_vaccinations is not null)
group by location
order by TotalVaccinations desc

--4 Ranking highest vaccination rate of countries with population
SELECT location, date, population, max(total_vaccinations) as TotalVaccinations, Max(total_vaccinations/population)*100 as percentagevaccinated
FROM public."CovidVaccination"
where population is not null and total_vaccinations is not null and location not in ('International')
group by location, population, date
order by percentagevaccinated asc
