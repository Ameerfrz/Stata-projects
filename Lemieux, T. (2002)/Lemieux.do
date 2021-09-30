



// PUT YOUR DIRECTORY HERE
cd  "E:\Economics\Labor\Newfolder"




use "lfs2000.dta", clear



***alb_bc1m: Analyse wage distribution in Alberta and BC
***Women


// double check what the units are in the 2019 data
gen lwage = ln(hrlyearn/100)


// Lemieux looks at women's wages. 
keep if sex==2

// Imposing restrictions 
drop if age_12<=2 & educ90==6
drop if age_12==1 & educ90==5
drop if educ90==0

//create a categorical variable that is the interaction of education and age categories


egen edage = group(educ90 age_12)


// NOTE: the weight was called fweight in the 2000 data. 


//First deal with the xbeta side of things
//ALBERTA

reg lwage i.edage [aweight=fweight] if prov==48
// collected the fitted value
predict x1b1 if prov==48
// collected the residual
predict r1 if prov==48, resid
// collected the counterfactual fitted value BC X's, ALTA betas
predict x2b1 if prov==59


//ALBERTA

reg lwage i.edage [aweight=fweight] if prov==59
// collected the fitted value
predict x2b2 if prov==59
// collected the residual
predict r2 if prov==59, resid
// collected the counterfactual fitted value ALTA'S X's, BC betas
predict x1b2 if prov==48


*****Second get reweighting factors*****

// dummy variable for BC
gen byte bc=(prov==59)
// run the logit
logit bc i.edage [pweight=fweight]
predict prob2, p
// make the weights for re-weighting (also have to use survey weight)
gen rw1to2=fweight*prob2/(1-prob2) if prov==48
gen rw2to1=fweight*(1-prob2)/prob2 if prov==59



// create Alberta with BC prices
gen y1=x1b2+r1 if prov==48
// create BC with Alberta prices
gen y2=x2b1+r2 if prov==59

label var lwage "log hourly wage"
label var y1 "Alberta wage with BC prices"
label var y2 "BC wage with ALberta prices"

mat table2 = J(8,7,0)

***Alberta***
//wage
summ lwage [aweight=fweight] if prov==48, detail

mat table2[1,1] = r(mean)
mat table2[1,2] = r(Var)
mat table2[1,5] = r(p90)-r(p10)
mat table2[1,6] = r(p50)-r(p10)
mat table2[1,7] = r(p90)-r(p50)

//fitted value
summ  x1b1  [aweight=fweight] if prov==48, detail
mat table2[1,3] = r(Var)

//residual
summ  r1  [aweight=fweight] if prov==48, detail
mat table2[1,4] = r(Var)
mat table2[2,4] = r(Var)



***Alberta with BC prices***
summ y1  [aweight=fweight] if prov==48, detail
mat table2[2,1] = r(mean)
mat table2[2,2] = r(Var)
mat table2[2,5] = r(p90)-r(p10)
mat table2[2,6] = r(p50)-r(p10)
mat table2[2,7] = r(p90)-r(p50)

summ x1b2 [aweight=fweight] if prov==48, detail
mat table2[2,3] = r(Var)


***Alberta with BC prices and quantities***
summ y1 [aweight=rw1to2] if prov==48, detail
mat table2[3,1] = r(mean)
mat table2[3,2] = r(Var)
mat table2[3,5] = r(p90)-r(p10)
mat table2[3,6] = r(p50)-r(p10)
mat table2[3,7] = r(p90)-r(p50)

summ  x1b2 [aweight=rw1to2] if prov==48, detail
mat table2[3,3] = r(Var)

summ r1 [aweight=rw1to2] if prov==48, detail
mat table2[3,4] = r(Var)

***BC***
summ lwage [aweight=fweight] if prov==59, detail
mat table2[4,1] = r(mean)
mat table2[4,2] = r(Var)
mat table2[4,5] = r(p90)-r(p10)
mat table2[4,6] = r(p50)-r(p10)
mat table2[4,7] = r(p90)-r(p50)

summ  x2b2  [aweight=fweight] if prov==59, detail
mat table2[4,3] = r(Var)

summ  r2 [aweight=fweight] if prov==59, detail
mat table2[4,4] = r(Var)

//Rows 5-8
mat table2[5,1] = table2[1,1..7]-table2[4,1..7]
mat table2[6,1] = table2[1,1..7]-table2[2,1..7]
mat table2[7,1] = table2[2,1..7]-table2[3,1..7]
mat table2[8,1] = table2[3,1..7]-table2[4,1..7]

mat table2[6,4]  = .
mat table2[8,1]  = .
mat table2[8,3]  = .

// THIS IS THE RESULTS FROM TABLE 2, the columns and rows match the paper's columns and rows

mat list table2





// DENSITIES IN FIGURE 2
****Estimate kernel densities

gen kwage=1.1+(_n-1)*.02 if _n<=151


// estimate the densities
qui kdensity lwage [aweight=fweight] if prov==48, at(kwage) width(0.06) generate(kwa kda)  nodraw
qui kdensity lwage [aweight=fweight] if prov==59, at(kwage) width(0.06) generate(kwd kdd) nodraw
qui kdensity y1 [aweight=fweight] , at(kwage) width(0.06) generate(kwb kdb) nodraw
qui kdensity y1 [aweight=rw1to2] , at(kwage) width(0.06) generate(kwc kdc) nodraw
qui kdensity y2 [aweight=fweight] , at(kwage) width(0.06) generate(kwe kde) nodraw
qui kdensity y2 [aweight=rw2to1] , at(kwage) width(0.06) generate(kwf kdf) nodraw


// plot the densities

tw line  kda kwa, lcolor(black) lpattern(dash)|| line  kdd kwd, lcolor(black) legend(label(1 "Alberta") label(2 "BC") size(medium) region(lcolor(white))) graphr(color(white)) name(g1, replace) xtitle("") ytitle("") title("a. Raw Densities", size(medium))
 

tw line kdb kwb , lcolor(black) lpattern(dash)|| line  kdd kwd, lcolor(black) legend(label(1 "Alberta counterfactual") label(2 "BC") size(medium)  region(lcolor(white))) graphr(color(white)) name(g2, replace) xtitle("") ytitle("") title("b. Alberta with BC regr. coefficients", size(medium))


tw line kdc kwc  , lcolor(black) lpattern(dash)|| line  kdd kwd, lcolor(black) legend(label(1 "Alberta counterfactual") label(2 "BC") size(medium)  region(lcolor(white))) graphr(color(white)) name(g3, replace) xtitle("") ytitle("") title("c. Alberta with BC coeff. and distr. of covariates", size(medium))


tw line  kda kwa , lcolor(black) || line  kdf kwf , lcolor(black) lpattern(dash) legend(label(1 "Alberta") label(2 "BC counterfactual") size(medium)  region(lcolor(white))) graphr(color(white)) name(g4, replace) xtitle("") ytitle("") title("d. BC with Alberta coeff. and distr. of covariates", size(medium))

graph combine g1 g2 g3 g4,  graphr(color(white))
