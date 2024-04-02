Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1, 2

-- SA death probability
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%south Africa%'
Order By 1, 2

--percentage of SA population with covid
Select location, date, total_cases, population, (total_cases/population)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%south africa%'
Order By 1, 2

--Country with the heightest infection rate compare to its population
Select location, Population, Max(total_cases) As Infected, 
		Max((total_cases/population))*100 As InfectedPercentage
From PortfolioProject..CovidDeaths
Group By location, population
Order By InfectedPercentage desc

--Country with the hightest death rate compare to its population
Select location, Max(Cast(total_deaths As int)) As HighDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
Order By HighDeathCount desc

-- By Continent
Select continent, Max(Cast(total_deaths As int)) As HighDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By HighDeathCount desc

-- Global numbers - New cases and New deaths
Select Sum(new_cases) As TotalCases, Sum(Cast(new_deaths As Int)) As TotalDeaths, 
			(Sum(Cast(new_deaths As Int))/Sum(new_cases))*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group By date
Order By 1, 2

--Join and CTE Option01
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, VaccinatedCount)
As
(
Select cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations,
		Sum(Convert(Int, cv.new_vaccinations)) Over (Partition By cd.location 
		Order By cd.location, cd.date) As VaccinatedCount
From PortfolioProject..CovidDeaths As cd
Join PortfolioProject..CovidVaccinations As cv
	On cd.location = cv.location And cd.date = cv.date
Where cd.continent is not null And cv.new_vaccinations is not null
--Order By 2, 3
)

Select *, (VaccinatedCount/Population)*100 As GlobalRatio
From PopVsVac

--temp table Option02
Drop Table if exists #VacVsPop
Create table #VacVsPop
(
Continent varchar(255), 
Location varchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
VaccinatedCount numeric
)

Insert Into #VacVsPop
Select cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations,
		Sum(Convert(Int, cv.new_vaccinations)) Over (Partition By cd.location 
		Order By cd.location, cd.date) As VaccinatedCount
From PortfolioProject..CovidDeaths As cd
Join PortfolioProject..CovidVaccinations As cv
	On cd.location = cv.location And cd.date = cv.date
Where cd.continent is not null And cv.new_vaccinations is not null
--Order By 2, 3

Select *, (VaccinatedCount/Population)*100 As GlobalRatio
From #VacVsPop

View for Visualisation
View01
Create View ContinentalDeathCount As
Select cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations,
		Sum(Convert(Int, cv.new_vaccinations)) Over (Partition By cd.location 
		Order By cd.location, cd.date) As VaccinatedCount
From PortfolioProject..CovidDeaths As cd
Join PortfolioProject..CovidVaccinations As cv
	On cd.location = cv.location And cd.date = cv.date
Where cd.continent is not null And cv.new_vaccinations is not null

View02
Create View TotalDeathsByContinent As
Select continent, Max(Cast(total_deaths As int)) As HighDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent

View03
Create View InfactionsByCountry As
Select location, Population, Max(total_cases) As Infected, 
		Max((total_cases/population))*100 As InfectedPercentage
From PortfolioProject..CovidDeaths
Where continent is not null and location is not null
Group By location, population

View04
Create View DeathCountByCountry As
Select location, Max(Cast(total_deaths As int)) As DeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By location
