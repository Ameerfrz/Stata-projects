 
 cd "E:\Economics\Labor\Newfolder\estout"
 clear
 
 set more off
 
  use "mroz.dta", clear


 gen nkids = kidslt6 + kidsge6
 
drop if kidslt6 > 3
drop if kidsge6 > 3

ta kidslt6, gen(kidslt6x)
ta kidsge6, gen(kidsge6x)

gen haskids = kidslt6 > 0 | kidsge6 > 0
gen haskids_educ = haskids*educ
gen haskids_unem = haskids*unem


ta kidslt6
ta kidsge6
  
 label var educ "\\ \hline \\ Years of  education ($\hat{\beta}_{1}$)"
 label var unem "Unemployment rate in the county of residence in \% ($\hat{\beta}_{2}$)"
 label var kidslt6 "Number of children younger than age 6 ($\hat{\beta}_{3}$)"
 label var kidsge6 "Number of children older than age 6  ($\hat{\beta}_{4}$)"
 label var kidslt6x2 "Dummy = 1 if has one child younger than age 6 ($\hat{\beta}_{5}$)"
 label var kidslt6x3 "Dummy = 1 if has two children younger than age 6 ($\hat{\beta}_{6}$)"
 label var kidslt6x4 "Dummy = 1 if has three children younger than age 6 ($\hat{\beta}_{7}$)"
 label var kidsge6x2 "Dummy = 1 if has one child age 6 or older ($\hat{\beta}_{8}$)"
 label var kidsge6x3 "Dummy = 1 if has two children age 6 or older ($\hat{\beta}_{9}$)"
 label var kidsge6x4 "Dummy = 1 if has three children age 6 or older ($\hat{\beta}_{10}$)"
 label var haskids "Dummy = 1 if has at least one child, = 0 if no children ($\hat{\beta}_{11}$)"
 label var haskids_educ "Has at least one child * education ($\hat{\beta}_{12}$)"
 label var haskids_unem "Has at least one child * unemployment rate in county ($\hat{\beta}_{13}$)"
 
 
 
 
 

reg  inlf  educ  unem kidslt6 kidsge6
estimates store m1, title("(1)")
reg  inlf  educ unem kidslt6x2  kidslt6x3  kidslt6x4  kidsge6x2 kidsge6x3 kidsge6x4 
estimates store m2, title("(2)")
reg  inlf  educ  unem 
estimates store m3, title("(3)")
reg  inlf  educ unem haskids haskids_educ haskids_unem
estimates store m4, title("(4)")
test haskids haskids_educ haskids_unem


local tabtitl "Labour force participation among married women"
local tablab  "mroz"
local colslab lcccc
local filtitl "mroz.txt"



 

#delim ;
estout m1 m2 m3 m4  using `filtitl', replace cells(b(fmt(%9.4f)) se(par fmt(%9.4f))) collabels(none)
stats(r2 N, labels("\\ \hline \\ R-squared "Sample Size") fmt(%9.4f %9.0f)) label legend drop(_cons) 
 varlabels( ,  blist(haskids "\\ \hline \\" kidslt6x2 "\\ \hline \\ 	\multicolumn{5}{l}{\textbf{Children younger than age 6, reference category: no children}}  \\ \\ "  kidsge6x2 "\\  	\multicolumn{5}{l}{\textbf{Children 6 and older, reference category: no children}}  \\ \\ ") 
 elist(npvissq "\\ \hline \hline \\" ))
prehead("\begin{table}[h]\centering \caption{`tabtitl' (Standard Errors in Parenthesis)}\label{`tablab'} \scriptsize					
\scriptsize					
\begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}`colslab'}					
\hline \\		") prefoot("") postfoot("\hline\hline					
\end{tabular*}					
\end{table}") varwidth(16)
style(tex) ;

#delim cr
!pdflatex "test.tex" -no-shell-escape  
 
