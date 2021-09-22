

clear all
set more off

*You have to replace the path with your path
cd  "E:\Economics\809\projects\IV\stata"
use IV.DTA, clear

egen tt = seq(), from (1960) to (2001)



xtset ID tt, yearly


* Pooled OLS estimator
eststo: reg Trade Gdp Sim Rlf Rer Cee Emu Dist Bor Lan RERT 


* Between estimator
xtreg Trade Gdp Sim Rlf Rer Cee Emu Dist Bor Lan RERT Ftrade Fgdp Fsim Frlf Frer, be

* Fixed effects or within estimator
eststo: xtreg Trade Gdp Sim Rlf Rer Cee Emu Dist Bor Lan RERT Ftrade Fgdp Fsim Frlf Frer, fe

* First-differences estimator
reg D.(Trade Gdp Sim Rlf Rer Cee Emu Dist Bor Lan RERT Ftrade Fgdp Fsim Frlf Frer), noconstant

* Random effects estimator
eststo: xtreg Trade Gdp Sim Rlf Rer Cee Emu Dist Bor Lan RERT Ftrade Fgdp Fsim Frlf Frer, re 

* Hausman test for fixed versus random effects model
quietly xtreg Trade Gdp Sim Rlf Rer Cee Emu Dist Bor Lan RERT Ftrade Fgdp Fsim Frlf Frer, fe
estimates store fixed
quietly xtreg Trade Gdp Sim Rlf Rer Cee Emu Dist Bor Lan RERT Ftrade Fgdp Fsim Frlf Frer, re
estimates store random
hausman fixed random

* Breusch-Pagan LM test for random effects versus OLS
quietly xtreg Trade Gdp Sim Rlf Rer Cee Emu Dist Bor Lan RERT Ftrade Fgdp Fsim Frlf Frer, re
xttest0

* Recovering indivIDual-specific effects
quietly xtreg Trade Gdp Sim Rlf Rer Cee Emu Dist Bor Lan RERT Ftrade Fgdp Fsim Frlf Frer, fe
predict alphafehat, u
sum alphafehat

* Table export for Latex
esttab using IV.tex, se mtitle("OLS" "Population-averaged" "Between" "Fixed effect" "Randome effects") noobs nostar r2 replace
