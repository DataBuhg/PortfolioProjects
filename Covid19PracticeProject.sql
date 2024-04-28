-- CREATE TABLE FOR COVID 19 DATA
CREATE TABLE "covid19"
(
	iso_code VARCHAR,
	continent VARCHAR,
	"location" VARCHAR,
	"date" DATE,
	total_cases NUMERIC,
	new_cases NUMERIC,
	new_cases_smoothed NUMERIC,
	total_deaths NUMERIC,
	new_deaths NUMERIC,
	new_deaths_smoothed NUMERIC,
	total_cases_per_million NUMERIC,
	new_cases_per_million NUMERIC,
	new_cases_smoothed_per_million NUMERIC,
	total_deaths_per_million NUMERIC,
	new_deaths_per_million NUMERIC,
	new_deaths_smoothed_per_million NUMERIC,
	reproduction_rate NUMERIC,
	icu_patients NUMERIC,
	icu_patients_per_million NUMERIC,
	hosp_patients NUMERIC,
	hosp_patients_per_million NUMERIC,
	weekly_icu_admissions NUMERIC,
	weekly_icu_admissions_per_million NUMERIC,
	weekly_hosp_admissions NUMERIC,
	weekly_hosp_admissions_per_million NUMERIC,
	total_tests	NUMERIC,
	new_tests NUMERIC,
	total_tests_per_thousand NUMERIC,
	new_tests_per_thousand NUMERIC,
	new_tests_smoothed NUMERIC,
	new_tests_smoothed_per_thousand NUMERIC,
	positive_rate NUMERIC,
	tests_per_case NUMERIC,
	tests_units NUMERIC,
	total_vaccinations NUMERIC,
	people_vaccinated NUMERIC,
	people_fully_vaccinated NUMERIC,
	total_boosters NUMERIC,
	new_vaccinations NUMERIC,
	new_vaccinations_smoothed NUMERIC,
	total_vaccinations_per_hundred NUMERIC,
	people_vaccinated_per_hundred NUMERIC,
	people_fully_vaccinated_per_hundred NUMERIC,
	total_boosters_per_hundred NUMERIC,
	new_vaccinations_smoothed_per_million NUMERIC,
	new_people_vaccinated_smoothed NUMERIC,
	new_people_vaccinated_smoothed_per_hundred NUMERIC,
	stringency_index NUMERIC,
	population_density NUMERIC,
	median_age NUMERIC,
	aged_65_older NUMERIC,
	aged_70_older NUMERIC,
	gdp_per_capita NUMERIC,
	extreme_poverty NUMERIC,
	cardiovasc_death_rate NUMERIC,
	diabetes_prevalence NUMERIC,
	female_smokers NUMERIC,
	male_smokers NUMERIC,
	handwashing_facilities NUMERIC,
	hospital_beds_per_thousand NUMERIC,
	life_expectancy NUMERIC,
	human_development_index NUMERIC,
	population NUMERIC,
	excess_mortality_cumulative_absolute NUMERIC,
	excess_mortality_cumulative NUMERIC,
	excess_mortality NUMERIC,
	excess_mortality_cumulative_per_million NUMERIC
);
-- IMPORTED THE DATA THROUGH THE TERMINAL USING THIS COMMAND \copy covid19 from '/Users/leonupshaw/Downloads/owid-covid-data.csv' delimiter ',' CSV HEADER;

-- THEN CHECKED IF THE TABLE ACTUALLY IMPORTED (SET A LIMIT OF 10 DUE TO THE SIZE OF THE DATA)

SELECT *
FROM covid19
WHERE continent IS NOT NULL
LIMIT 100;

-- SELECT THE DATE WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid19
ORDER BY 1,2;

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
CREATE VIEW TotalCases_Vs_TotalDeaths AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases
)*100 AS deaths_percentage
FROM covid19
WHERE LOCATION LIKE 'United States' AND continent IS NOT NULL -- Looking at the death percentage in US 
ORDER BY 1,2;

-- LOOKING AT THE TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF THE POPULATION GOT COVID
CREATE VIEW Population_Percentage_GotCovid AS

SELECT location, date, total_cases, population, (total_cases/ population
)*100 AS CovidPopulation_percentage
FROM covid19
WHERE LOCATION LIKE 'United States' AND continent IS NOT NULL -- Looking at the death percentage in the US
ORDER BY 1,2;

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
CREATE VIEW HighestInfectionRate_Compared_Population AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)
)*100 AS PercentInfectedPopulation
FROM covid19
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentInfectedPopulation DESC;

-- SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION
-- TOTAL_DEATHS WAS ORIGINALLY AS VARCHAR (STRING) AND WAS CONVERTED TO NUMERIC TO GET THE CORRECT RESULT
CREATE VIEW Highest_Death_Count_PerPopulation AS
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM covid19
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC;

-- BREAKING DOWN THE QUERY BY CONTINENT NOW 
CREATE VIEW TotalDeaths_Continents AS
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM covid19
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;
-- SHOWING THE CONTINENT WITH THE HIGHEST DEATH COUNT ^


-- GLOBAL NUMBERS
CREATE VIEW NewCases_Vs_TotalDeaths_Global AS

SELECT location, SUM(new_cases) AS Sum_NewCases, SUM(new_deaths) AS Sum_Deaths --, (total_deaths/total_cases)*100 AS deaths_percentage
FROM covid19
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 1,2;

CREATE VIEW DeathPercentage_Continent AS

SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths , (SUM(new_deaths) / SUM(new_cases))*100 AS death_percentage
FROM covid19
WHERE continent IS NOT NULL
--GROUP BY date,
ORDER BY 1,2;

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

CREATE VIEW TotalPopulation_vs_Vaccinations AS

SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY LOCATION ORDER BY location, date) AS RollingNum_People_Vaccinated
FROM covid19
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- CTE (Broken)
WITH Pop_V_Vaccination AS(
SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY LOCATION ORDER BY location, date) AS RollingNum_People_Vaccinated
FROM covid19
WHERE continent IS NOT NULL
ORDER BY 1,2);

-- TEMP TABLE

CREATE TABLE Percent_People_Vaccinated(

continent VARCHAR(255),
location VARCHAR(255),
date TIMESTAMP,
population NUMERIC,
new_vaccinations NUMERIC,
RollingNum_People_Vaccinated NUMERIC
);


INSERT INTO Percent_People_Vaccinated

SELECT continent, location, date, population, new_vaccinations, SUM(new_vaccinations) OVER (PARTITION BY LOCATION ORDER BY location, date) AS RollingNum_People_Vaccinated
FROM covid19
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- PERCENT PEOPLE VACCINATED QUERY

CREATE VIEW PercentPeople_Vaccinated AS

SELECT *, (RollingNum_People_Vaccinated/population)*100 AS Rolling_Percent
FROM Percent_People_Vaccinated;

SELECT location, date, female_smokers, male_smokers, new_deaths
FROM covid19
WHERE female_smokers IS NOT NULL 
ORDER BY 1,2;


