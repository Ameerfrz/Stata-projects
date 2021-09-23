
else {


// PUT YOUR DIRECTORY HERE
cd  "E:\Economics\Labor\assignments"

}


//	COMPLETE YOUR ASSIGNMENT BELOW, BE SURE TO INDICATE WHICH QUESTION YOUR CODE IS ANSWERING
// USING COMMENTS


use minimumwage_data.DTA, clear

// creating the full meal pre-treatment variable
g fmeal =  psoda + pentree + pfry

// creating the full meal post-treatment  variable
g empfte=empft + .5*emppt + nmgrs

// creating the full employment pre-treatment variable

g empfte2=empft2+.5*emppt2+nmgrs2

// creating the full employment post-treatment  variable

g fmeal2 =  psoda2 + pentree2 + pfry2

// labelling newly created variables

label variable fmeal "full meal pre"
label variable fmeal2 "full meal post"
label variable empft "full employment pre"
label variable empft2 "full employment post"

//  frequency  of chains in each stata

tabulate state chain, row


// labelling states

label define state 1 "NJ" 0 "PA"
label val state state

// generating pre and post-treatment minimum wage variables in each stata

gen minwNJ = (wage_st==4.25) if stater == 1
gen minwP = (wage_st==4.25) if stater == 0
gen minwNJP = 100*minwNJ 
gen minwPP= 100*minwP
gen minwNJ2 = (wage_st2==4.25) if stater == 1
gen minwP2 = (wage_st2==4.25) if stater == 0
gen minwNJP2 = 100*minwNJ2 
gen minwPP2= 100*minwP2
gen minwNJ3 = (wage_st2>5.0499 & wage_st2<5.051) if stater == 1
gen minwP3 = (wage_st2>5.0499 & wage_st2<5.051) if stater == 0
gen minwNJP3 = 100*minwNJ3 
gen minwPP3= 100*minwP3

// summary of each newly variable in two states

tabstat empfte wage_st minwPP minwNJP fmeal hrsopen bonus empfte2 wage_st2 minwPP2 minwNJP2 minwPP3 minwNJP3 fmeal2 hrsopen2 special2, by(state)

// allow for heteroskedasticity in ttest

ttest empfte, by(state) unequal
ttest empfte2, by(state) unequal

gen dempfte= empfte2-empfte if status2 != 0 
ttest dempfte, by(state) unequal 
