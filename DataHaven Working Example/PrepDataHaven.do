set type double

import delimited using "C:\Temp\new_haven_nhood_2022_acs_health_comb-1.csv", case(preserve) clear
rename Totalpopulation_2022 TotPop
rename Populationunderage18_2022 Children
rename Percentunderage18_2022 pChildren
rename Populationages18_2022 Adults
rename Percentages18_2022 pAdults
rename Populationages65_2022 Seniors
rename Percentages65_2022 pSeniors
rename Whitepopulation_2022 White
rename Percentwhite_2022 pWhite
rename Blackpopulation_2022 Black
rename PercentBlack_2022 pBlack
rename Latinopopulation_2022 Latino
rename PercentLatino_2022 pLatino
rename Otherracepopulation_2022 OthRace
rename Percentotherrace_2022 pOthRace
rename Foreignbornpopulation_2022 ForBorn
rename Percentforeignborn_2022 pForBorn
rename Totalhouseholds_2022 TotalHH
rename Owneroccupiedhouseholds_2022 OwnOcc
rename Homeownershiprate_2022 pHomeOwner
rename Costburdenedhouseholds_2022 CostBurdHH
rename Costburdenrate_2022 pCostBurdHH
rename Povertystatusknown_2022 PopPovStatKnown
rename Populationinpoverty_2022 PopPov
rename Povertyrate_2022 pPopPov
rename Lowincomepopulation_2022 PopLowInc
rename Lowincomerate_2022 pPopLowinc
rename Under18povertystatusknown_2022 ChildPovStatKnown
rename Childreninpoverty_2022 ChildPov
rename Childpovertyrate_2022 pChildPov
rename Lowincomechildren_2022 ChildLowInc
rename Childlowincomerate_2022 pChildLowInc
rename Ages65povertystatusknown_2022 SrPovStatknown
rename Seniorsinpoverty_2022 SrPov
rename Seniorpovertyrate_2022 pSrPov
rename Lowincomeseniors_2022 SrLowInc
rename Seniorlowincomerate_2022 pSrLowInc
rename Lifeexpectancyinyears_20102015 LifeExpectancy
rename Percentadultswithcoronaryheartdi pCoronary
rename Currentasthmarateadults_2021 rAsthma
rename Diabetesrateadults_2021 rDiabetes
rename Percentadultswithhighbloodpressu pHighBloodPress
rename Percentadultswithanydisability_2 pAnyDisability
rename Percentadultswithmobilitydisabil pMobilityDisability
rename Annualcheckuprateadults_2021 rCheckup
rename Annualdentalvisitrateadults_2020 rDentalVisit
rename Ages1864nohealthinsurance_2021 pNoHealthInsurance
rename Currentsmokingrateadults_2021 rSmoking
rename Percentadultssleepingunder7hours pSleepingLt7

* Take New Haven citywide data by itself, append "town" to the front of each variable name (to distinguish from the neighborhood variables), then save to a separate file
preserve
keep if level == "town"
drop level name
foreach var of varlist * {
	rename `var' town`var'
}
gen level = "neighborhood"
save c:\temp\town.dta, replace
restore

* Join the citywide data to each neighborhood
keep if level == "neighborhood"
merge m:1 level using "c:\temp\town.dta", nogenerate

* "Downtown New Haven" makes for an ugly table header due to length:
replace name = "Downtown" if name == "Downtown New Haven"

save "c:\temp\DataHavenData.dta", replace




