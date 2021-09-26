// Change it to your own directory
use "E:\Economics\Econometrics\PersonalProjects\LFS-71M0001-E-2019-June_F1.dta", clear

***** modifying Data *****

// Creating the female variable
gen female=1 if SEX==2
replace female=0 if SEX==1


// Produces sorted frequencies by province and generates indicator variables 
tab PROV, gen(province) sort


// Droping individuals who are not employed
drop if LFSSTAT==3
drop if LFSSTAT==4
drop if LFSSTAT==5
drop if LFSSTAT==6


// Droping individuals who are above 65 YO
drop if AGE_12==11
drop if AGE_12==12


// Droping individuals who are not an emplyee
drop if COWMAIN==3
drop if COWMAIN==4
drop if COWMAIN==5
drop if COWMAIN==6
drop if COWMAIN==7

// These commands produces sorted frequencies by firm size, age group, education, and industry and generate respective indicator variables 
tab FIRMSIZE, gen(firm_size) sort
tab AGE_12, gen(age) sort
tab EDUC, gen(educ) sort
tab AGYOWNK, gen(youngest_child) sort
tab NAICS_21, gen(industry) sort


// Creating the marriage status variable
gen married=1 if MARSTAT==1
replace married=0 if MARSTAT!=1


// Creating the worker's union status variables and naming them
gen union_membership = 1 if UNION==1
replace union_membership = 0 if UNION !=1
gen union_membership1 = 1 if UNION==1
replace union_membership1 = 0 if UNION !=1
recode union_membership1 ( 0 = 1 "not member") ( 1 = 2 "member"), gen(Union)


// Produces sorted frequencies and generates indicator variables 
tab EFAMTYPE, gen(economic_family) sort
tab COWMAIN, gen(class_worker) sort
tab IMMIG,gen(immigration_status) sort


// Creating the immigrant variables 
egen immigrant = rowtotal( immigration_status1 immigration_status2)

// Actual hours worked per week at main job - 
tabstat AHRSMAIN,  s(n p25 p50 p75 iqr) 
egen iqr = iqr( AHRSMAIN )
scalar a = iqr

// Produces sorted frequencies family type (dual earner or not) and generates indicator variables 
tab EFAMTYPE, gen(family)


// Generate  economic family ( the individual is in a dual earner family or not)
egen dual_earner= rowtotal( family2 family3 family4 )
egen dual_earner1 = rowtotal( family2 family3 family4 )
recode dual_earner1 ( 0 = 1 "Not dual earner") ( 1 = 2 "dual earner"), gen (Dual_earner)
la var Dual_earner "Being dual earner or not"


***** Naming variables based on Data handbook *****

rename industry1 Agriculture
rename industry2 Forestry_logging
rename industry3 Fish_hunt_trap
rename industry4 Mine_oil_gas
rename industry5 Utilities
rename industry6 Construction
rename industry7 Manu_durable
rename industry8 Manu_non_durable
rename industry9 Wholesale_trade
rename industry10 Retail_trade
rename industry11 Transport_warehouse
rename industry12 Finance_insurance
rename industry13 Realestate_rentals
rename industry14 Professional_scientific
rename industry15 Business_building
rename industry16 Educational
rename industry17 Healthcare_social_assistance
rename industry18 Information_culture_recreation
rename industry19 Accommodation_food_services
rename industry20 Other_services
rename industry21 Public_administration
rename age1 Age15_19
rename age2 Age20_24
rename age3 Age24_29
rename age4 Age30_34
rename age5 Age35_39
rename age6 Age40_44
rename age7 Age45_49
rename age8 Age50_54
rename age9 Age55_59
rename age10 Age60_64
rename educ1 edu0_8
rename educ2 some_highschool
rename educ3 highschool_graduate
rename educ4 some_postsecondary
rename educ5 postsecondary_certificate
rename educ6 bachelor_degree
rename educ7 above_bachelor
rename youngest_child1 child_0_6
rename youngest_child2 child_6_12
rename youngest_child3 child_13_17
rename youngest_child4 child_18_24
rename class_worker1 Public_sector
rename class_worker2 Private_sector
rename province1 Newfoundland
rename province2 Prince_edward
rename province3 Nova_scotia
rename province4 New_brunswick
rename province5 Quebec
rename province6 Ontario
rename province7 Manitoba
rename province8 Saskatchewan
rename province9 Alberta
rename province10 British_columbia
rename firm_size1 firm0_20
rename firm_size2 firm20_99
rename firm_size3 firm100_500
rename firm_size4 firm500_
recode NAICS_21 (1 = 1 "Agriculture") (2 = 2 "Forestry/logging") ///
(3 = 3 "Fish/Hunt/Trap") (4 = 4 "Mine/oil/gas") (5 = 5 "Utilities") (6 =6 "Construction") ///
(7 = 7 "Manu_durable") (8 = 8 "Manu_non durable") (9 = 9 "Wholesale") (10 = 10 "Retail") ///
(11 = 11 "Transport/Warehouse") (12 = 12 "Finance/Insurance") (13 = 13 "Realstate/Rentals") ///
(14 = 14 "Professional/scientific") (15 = 15 "Business/Building") (16 = 16 "Education service") ///
(17 = 17 "Healthcare/Social Assistance") (18 = 18 "Information/Culture/Recreation") ///
(19 = 19 "Accommodation/Food services") (20 = 20 "Other services") (21 = 21 "Public administration"), gen (Industry)
gen Male_hours = AHRSMAIN if female==0
gen Female_hours = AHRSMAIN if female==1
la var Industry Industry



***** Regression *****

// OLS regression for females
reg AHRSMAIN i.AGE_12 i.EDUC i.AGYOWNK i.NAICS_21 married Public_sector ///
immigrant union_membership dual_earner i.PROV i.FIRMSIZE if female==1


// Joint test that all coefficients on the indicators are zero
testparm i.AGE_12 i.EDUC i.AGYOWNK i.NAICS_21 married Public_sector ///
immigrant union_membership dual_earner i.PROV i.FIRMSIZE 


// OLS regression for males
reg AHRSMAIN i.AGE_12 i.EDUC i.AGYOWNK i.NAICS_21 married Public_sector ///
immigrant union_membership dual_earner i.PROV i.FIRMSIZE if female==0, cluster(PROV)


// Joint test that all coefficients on the indicators are zero
testparm i.AGE_12 i.EDUC i.AGYOWNK i.NAICS_21 married Public_sector ///
immigrant union_membership dual_earner i.PROV i.FIRMSIZE 


***** Decomposition *****

//Blinder-Oaxaca decomposition
oaxaca AHRSMAIN normalize(Age15_19 Age20_24 Age24_29 Age30_34 Age35_39 ///
Age40_44 Age45_49 Age50_54 Age55_59 Age60_64) ///
normalize(edu0_8 some_highschool highschool_graduate some_postsecondary postsecondary_certificate ///
bachelor_degree above_bachelor) ///
normalize(child_0_6 child_6_12 child_13_17 child_18_24) ///
normalize(Agriculture Forestry_logging Fish_hunt_trap Mine_oil_gas ///
Utilities Construction Manu_durable Manu_non_durable ///
Wholesale_trade Retail_trade Transport_warehouse Finance_insurance ///
Realestate_rentals Professional_scientific  ///
Business_building Educational Healthcare_social_assistance ///
Information_culture_recreation Accommodation_food_services ///
Other_services Public_administration) married ///
Public_sector immigrant union_membership normalize(Newfoundland Prince_edward Nova_scotia New_brunswick Ontario Quebec ///
Manitoba Saskatchewan Alberta British_columbia) dual_earner normalize(firm0_20 firm20_99 firm100_500 firm500_) ///
, by( female ) cluster(PROV) pooled
