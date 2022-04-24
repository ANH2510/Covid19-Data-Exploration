Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 3,4

--Select Data to starting with
Select continent,location, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order by 1,2

--Breaking things down by continent
--Continent with the highest death count

Select continent, sum(total_cases) as TotalCase
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By continent
Order By TotalCase Desc

Select continent, sum(total_cases)*100/(
	Select sum(total_cases) as totalcasescont
	From PortfolioProject.dbo.CovidDeaths
	Where continent is not NULL) as casepercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not NULL
Group By continent
Order by casepercentage DESC

-- Highest infection cases count is recorded in Europe accounts for 30% total cases in the world, following by Asia with 28%
-- Oceania is continent with the least infection cases (0.3%)

Select continent, sum(cast(total_deaths as int)) as TotalDeath
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeath Desc

Select continent, sum(cast(total_deaths as bigint))*100/(
	Select sum(cast(total_deaths as bigint)) as totaldeath
	From PortfolioProject.dbo.CovidDeaths
	Where continent is not NULL) as deathpercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not NULL
Group By continent
Order by deathpercentage DESC


-- Highest death count is recorded in Europe with nearly 64 millions cases (28% total death globally), following by North America with 54 Million cases (23%).
-- Oceania is continent with the least death cases



--Global number
Select sum(total_cases) as total_cases, (sum(total_cases)/sum(population))*100 as InfectionPercentage,
sum(cast(total_deaths as bigint)) as total_deaths, (sum(cast(total_deaths as bigint))/sum(total_cases))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
--Until April 2022, there are 120 billions infection cases (2% population) in the world, 2 billions recorded deaths 


--Total Cases vs Total Death 
Select continent, AVG((total_deaths/total_cases)*100) as AverageDeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent
Order by AverageDeathPercentage DESC
--On average, South America is the continent with the highest average death rate with 3.5%

--Total Cases vs Total Deaths in Germany
Select date, max(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
Where location like 'Germany'
Group by date
Order by DeathPercentage DESC
--In Germany, there is most people die because of Covid 19 in June 2020 with highest Deathrate is 4.5%

--Total Cases vs Population
--Infection percentage among continents, countries
Select continent, location, (max(total_cases/population))*100 as InfectedPopulationPercentage
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group by continent, date, location
Order by InfectedPopulationPercentage DESC
--Until April 2022, in 100 people in Europe, there are 70 people get infection from Covid 19. 
--The top 3 countries with highest infection rate in Europe is Faereo Island, Denmark and Andorra


--Countries with Highest Death cases
Select continent, location, max(cast(total_deaths as int)) as TotalDeath
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By continent, location
Order By TotalDeath Desc
--United State have the highest number of death case with 989 thousand cases, following by Brazil with 662 thousand cases
-- In Asia and Europe, highest reported death cases are recorded in India and Russia



--Total Population vs Vaccination
--Percentage of population that has been vaccinated
 Select dea.continent, sum(cast(vac.new_vaccinations as bigint)) as PeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Group by dea.continent
Order by PeopleVaccinated DESC
--At the first place, there are 6,7 billions vaccine doses are given in Asia, on the second position is Europe with 1 billion doses.


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and new_vaccinations is not null
order by 2,3

--Using CTE to perform Calculation on Partition By 

with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and new_vaccinations is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From PopvsVac


--Using Temp table to perform Calculation

Drop Table if exists #VaccinatedPopulationPercentage
Create Table #VaccinatedPopulationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #VaccinatedPopulationPercentage
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 RollingPeopleVaccinatedPercentage
From #VaccinatedPopulationPercentage


