
*****************************************************
*				Data Analysis (Results)				*
*****************************************************

/*
Research Question:

This study addresses a central question: how does consumption of state, private, and international media impact trust in central government?


Hypotheses:

	H1: state media has strongly positive effects on trust in government.
	H2: private media has moderately positive effects on trust in government.
	H3: international media has negative effects on trust in government.


Data:
	
Source: Social Survey on Chinese Netizens (SSCN) from 2014 to 2021
8 waves, online national survey, N = 29,839
wave 1: 2014 (4-scale DV, 4-scale IVs)
wave 2: 2015 (4-scale DV, 4-scale IVs)
wave 3: 2017 (4-scale DV, 4-scale IVs)
wave 4: 2018 (4-scale DV, 4-scale IVs)
wave 5: 2019 (5-scale DV, binary IV)
wave 6: 2020_Jan-Feb (5-scale DV, 5-scale IVs)
wave 7: 2020_Nov-Dec (5-scale DV, binary IV)
wave 8: 2021 (5-scale DV, 5-scale IVs)
	
	
Methods:

(1) 3 Ordered Logistic Regression models:

	* Model 1: for 4-scale DV & 4-scale IV, 2014-2018
		*ologit trust_central_4 media_state media_private  media_intl female educ pid income age year interest5

	* Model 2: for 5-scale DV & 5-scale IV, 2019-2021
		*ologit trust_central media_state media_private media_intl female educ pid income age year interest5
		
	* Model 3: for 5-scale DV & binary IV, 2019-2021
		*ologit trust_central media_state_any media_private_any media_intl_any female educ pid income age year interest5


(2) Logistic Regression Model

	Model 4: for binary DV & binary IV, 2014-2021
		*logit hightrust media_state media_private media_intl female pid income age year educ interest5 gdp_std liberal_std


Techniques:

	Monte Carlo Simulations	(Line 787)	
		

****** tries for Multilevel Model (how media consumption influences trust in central government over time) ******

* (I eventually decide not to use this model as the groups are too few)

	* identifier variables:
		* individual "id": level 1 identifier
		* "year": level 2 identifier

	* DV: Trust in central government
	* level 1 predictor: same as ologit model (media_state, media_private, media_intl, educ, age, income, pid, female, interest5)
	* level 2 predictor: GDP, liberal level	

*/




use wave\wave1-4, clear


* hist
hist trust_central_4, norm bin(4) ///
title("") ///
ytitle("") ///
xtitle("") ///
normopts(lcolor(red)) ///
xsize(4.5) ysize(4) ///
name(hist1, replace)


graph export graph/wave1-4/hist-dv.png, replace

kdensity trust_central_4, norm ///
bwidth(0.22) ///
title("") ///
ytitle("") ///
xtitle("") ///
legend(pos(10) ring(0) row(2) size(2) region(lcolor(black))) ///
note("kernel = epanechnikov, bandwidth = 0.3500", size(small) pos(6) ring(0)) ///
xsize(4.5) ysize(4) ///
name(kden1, replace)

graph export graph/wave1-4/kdensity-dv.png, replace


graph combine hist1 kden1, xsize(7) ///
ycommon iscale(1.2) altshrink ///
title("Histogram and Kernal Density of Trust in Central Government", size(medlarge)) ///
b1title("Trust in Central Government") ///
l1title("Density") ///
note("Data source: SSCN 2014-2018", size(2)) 

graph export graph/wave1-4/combined_hist_kden.png, replace


egen mean_gdp = mean(gdp)
egen sd_gdp = sd(gdp)
gen gdp_std = (gdp - mean_gdp)/sd_gdp

egen mean_liberal = mean(liberal)
egen sd_liberal = sd(liberal)
gen liberal_std = (liberal - mean_liberal)/sd_liberal



* ologit

/*
ologit trust_central_4 media_state cred_state media_private cred_private media_intl cred_intl i.female educ i.pid income age i.region year interest5
*/
ologit trust_central_4 media_state media_private media_intl female pid income age year educ interest5 

estimates store ologit_model1

esttab ologit_model1 ologit_model1 using table/wave1-4/ologit_model1.rtf, b(3) compress replace ///
se label eform(0 1) stats(N ll r2_p chi2 p, ///
labels(Observations Log-likelihood Pseudo-rsquared Wald-chi2 Prob>chi2) ) ///
cells(b(fmt(4)star) se(par)) ///
varwidth(30) collabels(, none) ///
nobase ///
title ("Model 1: Ordered Logistic Regression (2014-2018)") ///
nonumbers mtitles("Coefficient" "Odds ratio")

/*
ologit trust_central_4 i.media_state_bi i.media_private_bi i.media_intl_bi i.female educ i.pid income age year interest5
*/

* coef
coefplot ologit_model1, ///
eform drop(_cons) ///
legend(off) ///
xscale(range(0.8 1.5)) omitted title("Coefficient Plot of Model 1", size(medlarge)) subtitle("Trust in Central Government", size(medium)) ///
xline(1, lcolor(red) lpattern(solid)) xtitle("Odds ratio", size(2.5)) ///
note("Data source: SSCN 2014-2018" "N=14,677", span size(2.2)) ///
graphregion(fcolor(white)) ///
xsize(7) ysize(5) ///
xlabel(,valuelabels labsize(2.2)) ylabel(,valuelabels labsize(2.2)) ///
name(coefplot_ologit1, replace)

graph export graph/wave1-4/coefplot_ologit.png, replace

* margins

	* state media
ologit trust_central_4 media_state media_private media_intl female pid income age year educ interest5 

margins, at(media_state=(1(1)4)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(1 "Never" 2 "Seldom" 3 "Often" 4 "Every Day", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("State Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
	legend(order(1 "None at all" 2 "Not very much" 3 "A fair amount" 4 "A big deal") size(2.5) rows(1) symxsize(7)) ///
	xscale(range(1 4.15)) /// 
    name(margins_state1, replace)
	
graph export graph/wave1-4/margins_state.png, replace width(3000)

	* private media

margins, at(media_private=(1(1)4)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(1 "Never" 2 "Seldom" 3 "Often" 4 "Every Day", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("Private Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
    legend(off) ///
	xscale(range(1 4.15)) /// 
    name(margins_private1, replace)
	
graph export graph/wave1-4/margins_private.png, replace width(3000)

	* international media

margins, at(media_intl=(1(1)4)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(1 "Never" 2 "Seldom" 3 "Often" 4 "Every Day", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("International Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
    legend(off) ///
	xscale(range(1 4.15)) /// 
    name(margins_intl1, replace)

	
graph export graph/wave1-4/margins_intl.png, replace width(3000)


	* combined marginsplot

grc1leg margins_state1 margins_private1 margins_intl1, legendfrom(margins_state1) ///
    ycommon iscale(1.2) altshrink ///
    title("Model 1: Predicted Probability of Trust in Central Government by Media Consumption", size(3.5)) ///
    l1title("Predicted Probability of Trust in Central Government", size(3)) /// // Left title for y-axis
    note("Note: 95% confidence interval. Values are predicted probabilities. Other variables in the model held constant at their means.", size(2)) ///
    xsize(16) ysize(8) row(1)


graph export graph/wave1-4/combined_marginsplot.png, replace




/*
The main effects (first two coefficients) represent the relationship when the other variable is zero:


When credibility is 0, high state media use increases trust by 3.459 (log odds)
When state media use is low (0), a one-unit increase in credibility increases trust by 1.023


The negative interaction term (-0.868) indicates that the effect of one variable becomes less positive as the other variable increases. This is actually a common pattern in social science research called a "substitution effect" or "compensating effect."

*/

/*
use processed_data\cleaned_19_20_1,clear
use processed_data\cleaned_20_2,clear
use processed_data\cleaned_21,clear
*/


/*
***************************************************
MODEL 2: Wave 5-8 (2019-2021)
***************************************************
*/

use wave\wave5-8, clear

label var media_state "State Media Use"
label var media_state_any "State Media Use"
label var cred_state "State Media Cred."
label var media_private "Private Media Use"
label var media_private_any "Private Media Use"
label var media_intl "Int'l Media Use"
label var media_intl_any "Intl. Media Use"
label var cred_intl "Int'l Media Cred."

* Histogram & Kernal Density Plot for DV

		* histogram

hist trust_central, norm bin(5) ///
title("") ///
ytitle("") ///
xtitle("") ///
normopts(lcolor(red)) ///
xsize(4.5) ysize(4) ///
name(hist2, replace)


graph export graph/wave5-8/hist-dv.png, replace

		* kdensity

kdensity trust_central, norm ///
bwidth(0.35) ///
title("") ///
ytitle("") ///
xtitle("") ///
legend(pos(10) ring(0) row(2) size(small) region(lcolor(black))) ///
note("kernel = epanechnikov, bandwidth = 0.3500", size(2) pos(5) ring(0)) ///
xsize(4.5) ysize(4) ///
name(kden2, replace)

graph export graph/wave5-8/kdensity-dv.png, replace


graph combine hist2 kden2, xsize(7) ///
ycommon iscale(1.2) altshrink ///
title("Histogram and Kernal Density of Trust in Central Government", size(medlarge)) ///
b1title("Trust in Central Government") ///
l1title("Density") ///
note("Data source: SSCN 2019-2021") 


graph export graph/wave5-8/combined_hist_kden.png, replace



*** split wave5-8 into 2 datasets (binary and ordinal)
// First, save a copy of the original dataset
use wave/wave5-8, clear
save "wave/wave5-8_original.dta", replace

// Create first dataset without media_state, media_private, media_intl
use "wave/wave5-8_original.dta", clear
drop media_state media_private media_intl
save "wave/wave5-8_binary.dta", replace

// Create second dataset without media_state_any, media_private_any, media_intl_any
use "wave/wave5-8_original.dta", clear
drop media_state_any media_private_any media_intl_any
save "wave/wave5-8_ordinal.dta", replace




***********Model 2, Ordinal IVs, 2019-2021************

* Ordered Logistic Regression (Model 2)
use wave/wave5-8_ordinal, clear

label variable interest5 "Interest in politics"
label variable income "Income (CNY)"

ologit trust_central media_state media_private media_intl female pid income age year educ interest5 

estimates store ologit_model2

esttab ologit_model2 ologit_model2 using table/wave5-8/ologit_model2.rtf, b(3) compress replace ///
se label eform(0 1) stats(N ll r2_p chi2 p, ///
labels(Observations Log-likelihood Pseudo-rsquared Wald-chi2 Prob>chi2) ) ///
cells(b(fmt(4)star) se(par)) ///
varwidth(30) collabels(, none) ///
nobase ///
title ("Model 2: Ordered Logistic Regression (2019-2021)") ///
nonumbers mtitles("Coefficient" "Odds ratio")



***coefficient plot

* model2(ordered IV)
coefplot ologit_model2 ///
, eform drop(_cons) ///
legend(off) ///
xscale(range(0.5 2.5)) omitted title("Trust in Central Government", size(medium)) ///
xline(1, lcolor(red) lpattern(solid)) xtitle("Odds ratio", size(2.5)) ///
note("Data source: SSCN 2019-2021" "N=3,651", span size(2.2)) ///
graphregion(fcolor(white)) ///
xsize(7) ysize(5) ///
xlabel(,valuelabels labsize(2.2)) ylabel(,valuelabels labsize(2.2)) ///
name(coefplot_ologit2, replace)

graph export graph/wave5-8/coefplot_ologit2.png, replace



***margins and marginsplot

* Model 2 (ordered IV)

	* state media
	
ologit trust_central media_state media_private media_intl female pid income age year educ interest5 

margins, at(media_state=(1(1)5)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4"A fair amount" 5 "A big deal", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("State Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
	legend(order(1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal") size(2.5) rows(1) symxsize(7)) ///
	xscale(range(1 5.1)) /// 
    name(margins_state2, replace)
	
graph export graph/wave5-8/margins_state2.png, replace width(3000)

	* private media

margins, at(media_private=(1(1)5)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("Private Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
    legend(off) ///
	xscale(range(1 5.1)) /// 
    name(margins_private2, replace)
	
graph export graph/wave5-8/margins_private2.png, replace width(3000)


	* international media

margins, at(media_intl=(1(1)5)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("International Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
    legend(off) ///
	xscale(range(1 5.1)) /// 
    name(margins_intl2, replace)

	
graph export graph/wave5-8/margins_intl2.png, replace width(3000)






***********Model 3, Binary IVs, 2019-2021************

use wave/wave5-8_binary, clear

label variable interest5 "Interest in politics"
label variable income "Income (CNY)"

rename media_state_any media_state
rename media_private_any media_private
rename media_intl_any media_intl
label var media_state "State Media Use"
label var media_private "Private Media Use"
label var media_intl "Intl Media Use"


* Ordered Logistic Regression (Model 3)

ologit trust_central media_state media_private media_intl female pid income age year educ interest5 


estimates store ologit_model3


esttab ologit_model3 ologit_model3 using table/wave5-8/ologit_model3.rtf, b(3) compress replace ///
se label eform(0 1) stats(N ll r2_p chi2 p, ///
labels(Observations Log-likelihood Pseudo-rsquared Wald-chi2 Prob>chi2) ) ///
cells(b(fmt(4)star) se(par)) ///
varwidth(30) collabels(, none) ///
nobase ///
title ("Model 3: Ordered Logistic Regression (2019-2021)") ///
nonumbers mtitles("Coefficient" "Odds ratio")

* Coefficient Plot for Model3 (binary IV)

coefplot ologit_model3 ///
, eform drop(_cons) ///
legend(off) ///
xscale(range(0.5 2.5)) omitted title("Trust in Central Government", size(medium)) ///
xline(1, lcolor(red) lpattern(solid)) xtitle("Odds ratio", size(2.5)) ///
note("Data source: SSCN 2019-2021" "N=10,528", span size(2.2)) ///
graphregion(fcolor(white)) ///
xsize(7) ysize(5) ///
xlabel(,valuelabels labsize(2.2)) ylabel(,valuelabels labsize(2.2)) ///
name(coefplot_ologit3, replace)

graph export graph/wave5-8/coefplot_ologit3.png, replace



* Margins and Marginsplot

	* state
ologit trust_central media_state media_private media_intl female pid income age year educ interest5 

margins, at(media_state=(0(1)1)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(0 "No" 1 "Yes", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("State Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
	legend(order(1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal") size(2.5) rows(1) symxsize(7)) ///
	xscale(range(0 1)) /// 
    name(margins_state3, replace)
	
graph export graph/wave5-8/margins_state3.png, replace width(3000)


	* private

margins, at(media_private=(0(1)1)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(0 "No" 1 "Yes", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("Private Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
	legend(off) ///
	xscale(range(0 1)) /// 
    name(margins_private3, replace)
	
graph export graph/wave5-8/margins_private3.png, replace width(3000)


	* international 
	
margins, at(media_intl=(0(1)1)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(0 "No" 1 "Yes", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("International Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
	legend(off) ///
	xscale(range(0 1)) /// 
    name(margins_intl3, replace)
	
graph export graph/wave5-8/margins_intl3.png, replace width(3000)



*******************Combination and Comparison***************

* combined coefplots of model2 and model3

graph combine coefplot_ologit2 coefplot_ologit3, ///
xcommon iscale(1.2) altshrink ///
title("Coefficient Plots of Model 2 and Model 3", size(medlarge)) ///
xsize(8)

graph export graph/wave5-8/combined_coefplot_model2_model3.png, replace



* combined marginsplot

	* Model 2 (ordered IV)
	
grc1leg margins_state2 margins_private2 margins_intl2, legendfrom(margins_state2) ///
    ycommon iscale(1.2) altshrink ///
    title("Model 2: Predicted Probability of Trust in Central Government by Media Consumption", size(3.5)) ///
    l1title("Predicted Probability of Trust in Central Government", size(3)) /// // Left title for y-axis
    note("Note: 95% confidence interval. Values are predicted probabilities. Other variables in the model held constant at their means.", size(2)) ///
    xsize(16) ysize(8) row(1)


graph export graph/wave5-8/combined_marginsplot2.png, replace

	* Model 3 (binary IV)
	
grc1leg margins_state3 margins_private3 margins_intl3, legendfrom(margins_state3) ///
    ycommon iscale(1.2) altshrink ///
    title("Model 3: Predicted Probability of Trust in Central Government by Media Consumption", size(3.5)) ///
    l1title("Predicted Probability of Trust in Central Government", size(3)) /// // Left title for y-axis
    note("Note: 95% confidence interval. Values are predicted probabilities. Other variables in the model held constant at their means.", size(2)) ///
    xsize(16) ysize(8) row(1)


graph export graph/wave5-8/combined_marginsplot3.png, replace



* combined coefficient plot for Model 1, 2, 3

coefplot (ologit_model1, eform label("Model 1")) ///
    (ologit_model2, eform label("Model 2")) ///
    (ologit_model3, eform label("Model 3")), ///
    xline(1, lcolor(grey%50) lpattern(dash)) ///
    title("Media Effects on Trust in Central Government") ///
    xtitle("Odds Ratio") ///
	keep(media_state media_private media_intl)

graph export graph/combined_coefplot_model123.png, replace

**********************************************************
			*Binary DV for all data*

**********************************************************

use wave/wave1-4, clear

tab trust_central, m
tab trust_central, m nol
recode trust_central(5=1 "Yes")(1/4=0 "No"), gen(hightrust)
label variable hightrust "A big deal of trust"
tab hightrust

capture drop media_state_bi media_private_bi media_intl_bi
tab media_state
tab media_state, m nol
recode media_state(1/2=0 "Not often")(3/4=1 "Often"), gen(media_state_bi)
recode media_private(1/2=0 "Not often")(3/4=1 "Often"), gen(media_private_bi)
recode media_intl(1/2=0 "Not often")(3/4=1 "Often"), gen(media_intl_bi)
label variable media_state_bi "State Media Use"
label variable media_private_bi "Private Media Use"
label variable media_intl_bi "International Media Use"

save wave/wave1-4_biDV, replace


use wave/wave5-8, clear

tab trust_central, m
tab trust_central, m nol
recode trust_central(5=1 "Yes")(1/4=0 "No"), gen(hightrust)
label variable hightrust "A big deal of trust"
recode media_state(1/3=0 "Not often")(4/5=1 "Often"), gen(media_state_bi)
recode media_private(1/3=0 "Not often")(4/5=1 "Often"), gen(media_private_bi)
recode media_intl(1/3=0 "Not often")(4/5=1 "Often"), gen(media_intl_bi)
label variable media_state_bi "State Media Use"
label variable media_private_bi "Private Media Use"
label variable media_intl_bi "International Media Use"

replace media_state_bi = media_state_any if !missing(media_state_any)
replace media_private_bi = media_private_any if !missing(media_private_any)
replace media_intl_bi = media_intl_any if !missing(media_intl_any)

save wave/wave5-8_biDV, replace


******wave1-8******

use wave/wave1-4_biDV, clear
append using wave/wave5-8_biDV

capture drop media_state media_private media_intl cred_state cred_private cred_intl media_state_any media_private_any media_intl_any trust_central trust_central_4

order hightrust media_state_bi media_private_bi media_intl_bi female pid income age year educ interest5 gdp liberal

rename media_state_bi media_state
rename media_private_bi media_private
rename media_intl_bi media_intl

	* Standardize GDP & liberal
	
egen mean_gdp = mean(gdp)
egen sd_gdp = sd(gdp)
gen gdp_std = (gdp - mean_gdp)/sd_gdp

egen mean_liberal = mean(liberal)
egen sd_liberal = sd(liberal)
gen liberal_std = (liberal - mean_liberal)/sd_liberal


* Logit Model

logit hightrust media_state media_private media_intl female pid income age year educ interest5 gdp_std liberal_std

estimates store logit_biDV

esttab logit_biDV logit_biDV using table/logit_biDV.rtf, b(3) compress replace ///
se label eform(0 1) stats(N ll r2_p chi2 p, ///
labels(Observations Log-likelihood Pseudo-rsquared Wald-chi2 Prob>chi2) ) ///
cells(b(fmt(4)star) se(par)) ///
varwidth(30) collabels(, none) ///
nobase ///
title ("Model 4: Logistic Regression (2014-2021)") ///
nonumbers mtitles("Coefficient" "Odds ratio")


* Coefficient Plot for Model 4 (binary IV)

coefplot logit_biDV ///
, eform drop(_cons) ///
legend(off) ///
omitted title("Coefficient Plot of Model 4", size(medlarge)) subtitle("Trust in Government", size(medium)) ///
xline(1, lcolor(red) lpattern(solid)) xtitle("Odds ratio", size(2.5)) ///
note("Data source: SSCN 2014-2021" "N=25,959", span size(2.2)) ///
graphregion(fcolor(white)) ///
xsize(7) ysize(5) ///
xlabel(,valuelabels labsize(2.2)) ylabel(,valuelabels labsize(2.2)) ///
name(coefplot_logit, replace)

graph export graph/coefplot_logit.png, replace


* combined coefficient plot for Model 1, 2, 3, and 4

coefplot (ologit_model1, eform label("Model 1")) ///
    (ologit_model2, eform label("Model 2")) ///
    (ologit_model3, eform label("Model 3")) ///
	(logit_biDV, eform label("Model 4")), ///
    xline(1, lcolor(grey%50) lpattern(dash)) ///
    title("Media Effects on Trust in Central Government") ///
    xtitle("Odds Ratio") ///
	keep(media_state media_private media_intl)

graph export graph/combined_coefplot_model1234.png, replace


* Margins and Marginsplot

	* state
logit hightrust media_state media_private media_intl female pid income age year educ interest5 gdp_std liberal_std

margins, at(media_state=(0(1)1)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(0 "No" 1 "Yes", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("State Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
	legend(order(1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal") size(2.5) rows(1) symxsize(7)) ///
	xscale(range(0 1)) /// 
    name(margins_logit_state, replace)


	* private

margins, at(media_private=(0(1)1)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(0 "No" 1 "Yes", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("Private Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
	legend(off) ///
	xscale(range(0 1)) /// 
    name(margins_logit_private, replace)


	* international 
	
margins, at(media_intl=(0(1)1)) atmeans vsquish

marginsplot, scheme(s1color) ///
    xsize(6) ysize(4.5) ///
    xlabel(0 "No" 1 "Yes", labsize(small)) ///
    ylabel(#5, grid labsize(small)) ///
    xtitle("International Media Consumption", size(3) margin(t=3)) ///
	ytitle("") /// 
    title("") ///  
	plotopts(msize(small)) ///
	legend(off) ///
	xscale(range(0 1)) /// 
    name(margins_logit_intl, replace)
	

*******************marginsplots of model 4***************

* marginsplots of model 4

graph combine margins_logit_state margins_logit_private margins_logit_intl, row(1) ///
ycommon iscale(1.2) altshrink ///
title("Model 4: Predicted Probability of Trust in Central Government by Media Consumption", size(medlarge)) ///
xsize(8) ///
l1title("Predicted Probability of Trust in Central Government", size(3)) /// 
note("Note: 95% confidence interval. Values are predicted probabilities. Other variables in the model held constant at their means.", size(2))

graph export graph/combined_marginsplot_logit.png, replace


save wave/wave1-8_biDV, replace

	
*********************************************		
		*******simulation*********
*********************************************

* Now I am trying to reduce some measurement error: based on assumptions that younger and more educated respondents are more likely to underreport their international media use, I generate adjusted international media use based on age and education. 

* I will change the parameters for educ_adjust and age_adjust to see how change in parameters leads to change in how much the adjusted international media move from original one, and lead to change in how much the effect of media_intl_adj different from the impact of media_intl on trust_central. The comparison also shows the proportion of distribution of t versus 1.96.  The change of the parameters for educ_adjust and age_adjust includes extreme and moderate cases. 

* For the extreme and moderate cases, I use the scatterplot and crosstab to compare adjusted one to original one, to show meaningful difference. Changing jitter size and transparency of dots in the scatterplot can show the difference more clearly.

clear all
set more off

use wave/wave1-4, clear

program define sim_trust, rclass
    args adjustment_type
    
    * Generate adjusted education based on case
    if  "`adjustment_type'" == "moderate" {
        gen educ_adj = (educ/6) * 0.3 * (1 + rnormal(0, 0.2))
        gen age_adj = (1 - age/9) * 0.2 * (0.8 + rnormal(0, 0.2))
    }
    else if "`adjustment_type'" == "extreme" {
        gen educ_adj = (educ/6) * 0.6 * (2 + rnormal(0, 0.4))
        gen age_adj = (1 - age/9) * 0.4 * (1.5 + rnormal(0, 0.4))
    }
    
    * Clean adjustments
    replace educ_adj = 0 if educ_adj < 0
    replace age_adj = 0 if age_adj < 0
    
    * Generate adjusted media use
    gen media_intl_adj = media_intl * (1 + educ_adj + age_adj)
    
    * Round and constrain to valid categories
    replace media_intl_adj = round(media_intl_adj)
    replace media_intl_adj = 1 if media_intl_adj < 1
    replace media_intl_adj = 4 if media_intl_adj > 4
    
    * Run ordered logit
    quietly ologit trust_central_4 media_state media_private media_intl_adj female educ pid income age year interest5
    
    * Store results
    local coef = _b[media_intl_adj]
    local t = _b[media_intl_adj]/_se[media_intl_adj]
    local odds = exp(_b[media_intl_adj])
    
    * Clean up
    drop educ_adj age_adj media_intl_adj
    
    * Return results
    return scalar coef = `coef'
    return scalar t = `t'
    return scalar odds = `odds'
end

// Set up matrices to store results for each case
matrix results_moderate = J(1000, 3, .)
matrix results_extreme = J(1000, 3, .)
matrix colnames results_moderate = coef t odds
matrix colnames results_extreme = coef t odds

// Run simulations for moderate case
forvalues i = 1/1000 {
    quietly sim_trust moderate
    matrix results_moderate[`i',1] = r(coef)
    matrix results_moderate[`i',2] = r(t)
    matrix results_moderate[`i',3] = r(odds)
    if mod(`i',100)==0 {
        display "Completed `i' moderate iterations"
    }
}

* Run simulations for extreme case
forvalues i = 1/1000 {
    quietly sim_trust extreme
    matrix results_extreme[`i',1] = r(coef)
    matrix results_extreme[`i',2] = r(t)
    matrix results_extreme[`i',3] = r(odds)
    if mod(`i',100)==0 {
        display "Completed `i' extreme iterations"
    }
}

* Convert matrices to datasets and analyze results

svmat results_moderate
rename (results_moderate1 results_moderate2 results_moderate3) (coef_mod t_mod odds_mod)

svmat results_extreme
rename (results_extreme1 results_extreme2 results_extreme3) (coef_ext t_ext odds_ext)

* Summary statistics
foreach case in mod ext {
    display _n "Results for `case' case:"
    summarize coef_`case' t_`case' odds_`case', detail
    
    // Calculate proportion of significant t-values
    generate sig_`case' = abs(t_`case') > 1.96
    summarize sig_`case'
    drop sig_`case'
}		
		
		
	* Compare with original model results
	* Run original model without bias adjustment
ologit trust_central_4 media_state media_private media_intl i.female educ i.pid income age year interest5

	* Store original coefficient
	scalar orig_coef = _b[media_intl]
	display orig_coef
	
	* compare odds ratio
	gen orig_or = exp(orig_coef)
	sum orig_or odds_mod odds_ext
	

*****************************************************************
/*
 Compare the adjusted and original international media consumption by educ and age
*/
*****************************************************************     
        // Generate adjusted international media use

		gen educ_moderate = (educ/6) * 0.3 * (1 + rnormal(0, 0.2))   // Adjusted education (moderate case)
		gen educ_extreme = (educ/6) * 0.6 * (2 + rnormal(0, 0.4))   // Adjusted education (extreme case)	
		
		gen age_moderate = (1 - age/9) * 0.2 * (0.8 + rnormal(0, 0.2))  // Adjusted age (moderate case)
		gen age_extreme = (1 - age/9) * 0.4 * (1.5 + rnormal(0, 0.4))  // Adjusted age (extreme case)	

		
		replace educ_moderate = 0 if educ_moderate < 0
		replace educ_extreme = 0 if educ_extreme < 0

		replace age_moderate = 0 if age_moderate < 0
		replace age_extreme = 0 if age_extreme < 0
		
		* change weight
		gen media_intl_moderate = media_intl * (1 + educ_moderate + age_moderate)
		gen media_intl_extreme = media_intl * (1 + educ_extreme + age_extreme)

        
        // Round to valid categories (1-4)        
		replace media_intl_moderate = round(media_intl_moderate)
        replace media_intl_moderate = 1 if media_intl_moderate < 1
        replace media_intl_moderate = 4 if media_intl_moderate > 4
      
	    replace media_intl_extreme = round(media_intl_extreme)
        replace media_intl_extreme = 1 if media_intl_extreme < 1
        replace media_intl_extreme = 4 if media_intl_extreme > 4		

		
********* Compare media_intl_moderate & media_intl*********

	* crosstab
tab media_intl_moderate media_intl, nol

	* scatterplot		
graph twoway scatter media_intl_moderate media_intl, jitter(5) by(educ)
graph export graph/wave1-4/scatterplot_mod_org_educ.png, replace

graph twoway scatter media_intl_moderate media_intl, jitter(5) by(age)
graph export graph/wave1-4/scatterplot_mod_org_age.png, replace


* Compare media_intl_extreme & media_intl

	* crosstab
tab media_intl_extreme media_intl, nol

	* scatterplot		
graph twoway scatter media_intl_extreme media_intl, jitter(5) by(educ)
graph export graph/wave1-4/scatterplot_ext_org_educ.png, replace

graph twoway scatter media_intl_extreme media_intl, jitter(5) by(age)
graph export graph/wave1-4/scatterplot_ext_org_age.png, replace



* Histogram of odds ratio of moderate ajustment

quietly summarize odds_mod
local mean_odds_mod = r(mean)
	
histogram odds_mod, ///
    normal /// 
    title("Distribution of Moderately Simulated Odds Ratios of International Media Use (Model 1)", size(medium)) /// subtitle("Comparing Original vs. Adjusted Effects")
    xtitle("Odds Ratio") ///
    ytitle("Density") ///
	yscale(range(0 175)) ///
    name(hist_or, replace) /// xline(`=orig_or', lcolor(black) lwidth(thick) lpattern(solid))
    xline(`mean_odds_mod', lcolor(red) lwidth(thick) lpattern(dash)) ///
    note("Mean Adjusted OR (Red dashed line) = `=string(`mean_odds_mod', "%9.3f")'; Original OR: `=string(orig_or, "%9.3f")'")

graph export graph/wave1-4/hist_odds_mod.png, replace


* Histogram of odds ratio of extreme ajustment

quietly summarize odds_ext
local mean_odds_ext = r(mean)
	
histogram odds_ext, ///
    normal /// 
    title("Distribution of Extremely Simulated Odds Ratios of International Media Use (Model 1)", size(medium)) /// subtitle("Comparing Original vs. Adjusted Effects")
    xtitle("Odds Ratio") ///
    ytitle("Density") ///
	yscale(range(0 80)) ///
    name(hist_or, replace) /// xline(`=orig_or', lcolor(black) lwidth(thick) lpattern(solid))
    xline(`mean_odds_ext', lcolor(red) lwidth(thick) lpattern(dash)) ///
    note("Mean Adjusted OR (Red dashed line) = `=string(`mean_odds_ext', "%9.3f")'; Original OR: `=string(orig_or, "%9.3f")'")

graph export graph/wave1-4/hist_odds_ext.png, replace
	

	
save wave/wave1-4_sim, replace	

*******************************************************************************

// Program for wave5-8_ordinal (2019-2021, 5-level ordinal)
use wave\wave5-8_ordinal, clear

capture program drop sim_trust_wave5_8_ordinal

program define sim_trust_wave5_8_ordinal, rclass
    args adjustment_type
    
    * Generate adjusted education based on case
    if  "`adjustment_type'" == "moderate" {
        gen educ_adj = (educ/6) * 0.3 * (1 + rnormal(0, 0.2))
        gen age_adj = (1 - age/9) * 0.2 * (0.8 + rnormal(0, 0.2))
    }
    else if "`adjustment_type'" == "extreme" {
        gen educ_adj = (educ/6) * 0.6 * (2 + rnormal(0, 0.4))
        gen age_adj = (1 - age/9) * 0.4 * (1.5 + rnormal(0, 0.4))
    }
    
    * Clean adjustments
    replace educ_adj = 0 if educ_adj < 0
    replace age_adj = 0 if age_adj < 0
    
    * Generate adjusted media use
    gen media_intl_adj = media_intl * (1 + educ_adj + age_adj)
    
    * Round and constrain to valid categories
    replace media_intl_adj = round(media_intl_adj)
    replace media_intl_adj = 1 if media_intl_adj < 1
    replace media_intl_adj = 5 if media_intl_adj > 5
    
    * Run ordered logit
    quietly ologit trust_central media_state media_private media_intl_adj female educ pid income age year interest5
                
    * Store results
    local coef = _b[media_intl_adj]
    local t = _b[media_intl_adj]/_se[media_intl_adj]
    local odds = exp(_b[media_intl_adj])
    
    * Clean up
    drop educ_adj age_adj media_intl_adj
    
    * Return results
    return scalar coef = `coef'
    return scalar t = `t'
    return scalar odds = `odds'
end

// Set up matrices to store results for each case
matrix results_moderate = J(1000, 3, .)
matrix results_extreme = J(1000, 3, .)
matrix colnames results_moderate = coef t odds
matrix colnames results_extreme = coef t odds

// Run simulations for moderate case
forvalues i = 1/1000 {
    quietly sim_trust_wave5_8_ordinal moderate
    matrix results_moderate[`i',1] = r(coef)
    matrix results_moderate[`i',2] = r(t)
    matrix results_moderate[`i',3] = r(odds)
    if mod(`i',100)==0 {
        display "Completed `i' moderate iterations"
    }
}

* Run simulations for extreme case
forvalues i = 1/1000 {
    quietly sim_trust_wave5_8_ordinal extreme
    matrix results_extreme[`i',1] = r(coef)
    matrix results_extreme[`i',2] = r(t)
    matrix results_extreme[`i',3] = r(odds)
    if mod(`i',100)==0 {
        display "Completed `i' extreme iterations"
    }
}

* Convert matrices to datasets and analyze results

svmat results_moderate
rename (results_moderate1 results_moderate2 results_moderate3) (coef_mod t_mod odds_mod)

svmat results_extreme
rename (results_extreme1 results_extreme2 results_extreme3) (coef_ext t_ext odds_ext)

* Summary statistics
foreach case in mod ext {
    display _n "Results for `case' case:"
    summarize coef_`case' t_`case' odds_`case', detail
    
    // Calculate proportion of significant t-values
    generate sig_`case' = abs(t_`case') > 1.96
    summarize sig_`case'
    drop sig_`case'
}		
		
		
	* Compare with original model results
	* Run original model without bias adjustment
ologit trust_central media_state media_private media_intl female educ pid income age year interest5

	* Store original coefficient
	scalar orig_coef = _b[media_intl]
	display orig_coef
	
	* compare odds ratio
	gen orig_or = exp(orig_coef)
	sum orig_or odds_mod odds_ext
	

*****************************************************************
/*
 Compare the adjusted and original international media consumption by educ and age
*/
*****************************************************************     
        // Generate adjusted international media use

		gen educ_moderate = (educ/6) * 0.3 * (1 + rnormal(0, 0.2))   // Adjusted education (moderate case)
		gen educ_extreme = (educ/6) * 0.6 * (2 + rnormal(0, 0.4))   // Adjusted education (extreme case)	
		
		gen age_moderate = (1 - age/9) * 0.2 * (0.8 + rnormal(0, 0.2))  // Adjusted age (moderate case)
		gen age_extreme = (1 - age/9) * 0.4 * (1.5 + rnormal(0, 0.4))  // Adjusted age (extreme case)	

		
		replace educ_moderate = 0 if educ_moderate < 0
		replace educ_extreme = 0 if educ_extreme < 0

		replace age_moderate = 0 if age_moderate < 0
		replace age_extreme = 0 if age_extreme < 0
		
		* change weight
		gen media_intl_moderate = media_intl * (1 + educ_moderate + age_moderate)
		gen media_intl_extreme = media_intl * (1 + educ_extreme + age_extreme)

        
        // Round to valid categories (1-4)        
		replace media_intl_moderate = round(media_intl_moderate)
        replace media_intl_moderate = 1 if media_intl_moderate < 1
        replace media_intl_moderate = 5 if media_intl_moderate > 5
      
	    replace media_intl_extreme = round(media_intl_extreme)
        replace media_intl_extreme = 1 if media_intl_extreme < 1
        replace media_intl_extreme = 5 if media_intl_extreme > 5		

		
********* Compare media_intl_moderate & media_intl*********

	* crosstab
tab media_intl_moderate media_intl, nol

	* scatterplot		
graph twoway scatter media_intl_moderate media_intl, jitter(5) by(educ)
graph export graph/wave5-8/scatterplot_ordinal_mod_org_educ.png, replace

graph twoway scatter media_intl_moderate media_intl, jitter(5) by(age)
graph export graph/wave5-8/scatterplot_ordinal_mod_org_age.png, replace


* Compare media_intl_extreme & media_intl

	* crosstab
tab media_intl_extreme media_intl, nol

	* scatterplot		
graph twoway scatter media_intl_extreme media_intl, jitter(5) by(educ)
graph export graph/wave5-8/scatterplot_ordinal_ext_org_educ.png, replace

graph twoway scatter media_intl_extreme media_intl, jitter(5) by(age)
graph export graph/wave5-8/scatterplot_ordinal_ext_org_age.png, replace



* Histogram of odds ratio of moderate ajustment

quietly summarize odds_mod
local mean_odds_mod = r(mean)
	
histogram odds_mod, ///
    normal /// 
    title("Distribution of Moderately Simulated Odds Ratios of International Media Use (Model 2)", size(medium)) /// subtitle("Comparing Original vs. Adjusted Effects")
    xtitle("Odds Ratio") ///
    ytitle("Density") ///
	yscale(range(0 175)) ///
    name(hist_or, replace) /// xline(`=orig_or', lcolor(black) lwidth(thick) lpattern(solid))
    xline(`mean_odds_mod', lcolor(red) lwidth(thick) lpattern(dash)) ///
    note("Mean Adjusted OR (Red dashed line) = `=string(`mean_odds_mod', "%9.3f")'; Original OR: `=string(orig_or, "%9.3f")'")

graph export graph/wave5-8/hist_ordinal_odds_mod.png, replace


* Histogram of odds ratio of extreme ajustment

quietly summarize odds_ext
local mean_odds_ext = r(mean)
	
histogram odds_ext, ///
    normal /// 
    title("Distribution of Extremely Simulated Odds Ratios of International Media Use (Model 2)", size(medium)) /// subtitle("Comparing Original vs. Adjusted Effects")
    xtitle("Odds Ratio") ///
    ytitle("Density") ///
	yscale(range(0 80)) ///
    name(hist_or, replace) /// xline(`=orig_or', lcolor(black) lwidth(thick) lpattern(solid))
    xline(`mean_odds_ext', lcolor(red) lwidth(thick) lpattern(dash)) ///
    note("Mean Adjusted OR (Red dashed line) = `=string(`mean_odds_ext', "%9.3f")'; Original OR: `=string(orig_or, "%9.3f")'")

graph export graph/wave5-8/hist_ordinal_odds_ext.png, replace


save wave/wave5-8_ordinal_sim, replace	



********************************************************************************

// Program for wave5-8_binary (2019-2021, binary)

use wave\wave5-8_binary, clear

capture program drop sim_trust_wave5_8_binary

program define sim_trust_wave5_8_binary, rclass
    args adjustment_type
    
    * Generate adjusted education based on case
    if  "`adjustment_type'" == "moderate" {
        gen underreport_prob = (educ/6) * 0.3 + (1 - age/9) * 0.2		
    
	}
    else if "`adjustment_type'" == "extreme" {
        gen underreport_prob = (educ/6) * 0.6 + (1 - age/9) * 0.4

		}
    
    * Clean adjustments
    replace educ_adj = 0 if educ_adj < 0
    replace age_adj = 0 if age_adj < 0
    
    * Generate adjusted media use
    gen media_intl_adj = media_intl_any
    replace media_intl_adj = 1 if media_intl_any == 0 & runiform() < underreport_prob
        
    * Run ordered logit
	quietly ologit trust_central media_state_any media_private_any media_intl_adj female educ pid income age year interest5
                
    * Store results
    local coef = _b[media_intl_adj]
    local t = _b[media_intl_adj]/_se[media_intl_adj]
    local odds = exp(_b[media_intl_adj])
    
    * Clean up
    drop educ_adj age_adj media_intl_adj
    
    * Return results
    return scalar coef = `coef'
    return scalar t = `t'
    return scalar odds = `odds'
end

// Set up matrices to store results for each case
matrix results_moderate = J(1000, 3, .)
matrix results_extreme = J(1000, 3, .)
matrix colnames results_moderate = coef t odds
matrix colnames results_extreme = coef t odds

// Run simulations for moderate case
forvalues i = 1/1000 {
    quietly sim_trust_wave5_8_ordinal moderate
    matrix results_moderate[`i',1] = r(coef)
    matrix results_moderate[`i',2] = r(t)
    matrix results_moderate[`i',3] = r(odds)
    if mod(`i',100)==0 {
        display "Completed `i' moderate iterations"
    }
}

* Run simulations for extreme case
forvalues i = 1/1000 {
    quietly sim_trust_wave5_8_ordinal extreme
    matrix results_extreme[`i',1] = r(coef)
    matrix results_extreme[`i',2] = r(t)
    matrix results_extreme[`i',3] = r(odds)
    if mod(`i',100)==0 {
        display "Completed `i' extreme iterations"
    }
}

* Convert matrices to datasets and analyze results

svmat results_moderate
rename (results_moderate1 results_moderate2 results_moderate3) (coef_mod t_mod odds_mod)

svmat results_extreme
rename (results_extreme1 results_extreme2 results_extreme3) (coef_ext t_ext odds_ext)

* Summary statistics
foreach case in mod ext {
    display _n "Results for `case' case:"
    summarize coef_`case' t_`case' odds_`case', detail
    
    // Calculate proportion of significant t-values
    generate sig_`case' = abs(t_`case') > 1.96
    summarize sig_`case'
    drop sig_`case'
}		
		
		
	* Compare with original model results
	* Run original model without bias adjustment
ologit trust_central media_state_any media_private_any media_intl_any female educ pid income age year interest5

	* Store original coefficient
	scalar orig_coef = _b[media_intl]
	display orig_coef
	
	* compare odds ratio
	gen orig_or = exp(orig_coef)
	sum orig_or odds_mod odds_ext
	

*****************************************************************
/*
 Compare the adjusted and original international media consumption by educ and age
*/
*****************************************************************     
        // Generate adjusted international media use

gen underreport_prob_mod = (educ/6) * 0.3 + (1 - age/9) * 0.2		
    
gen underreport_prob_ext = (educ/6) * 0.6 + (1 - age/9) * 0.4
    
* Generate adjusted media use
gen media_intl_moderate = media_intl_any
gen media_intl_extreme = media_intl_any
replace media_intl_moderate = 1 if media_intl_any == 0 & runiform() < underreport_prob_mod
replace media_intl_extreme = 1 if media_intl_any == 0 & runiform() < underreport_prob_ext

		
		
********* Compare media_intl_moderate & media_intl*********

	* crosstab
tab media_intl_moderate media_intl_any, nol

	* scatterplot		
graph twoway scatter media_intl_moderate media_intl_any, jitter(5) by(educ)
graph export graph/wave5-8/scatterplot_binary_mod_org_educ.png, replace

graph twoway scatter media_intl_moderate media_intl_any, jitter(5) by(age)
graph export graph/wave5-8/scatterplot_binary_mod_org_age.png, replace


********* Compare media_intl_extreme & media_intl*********

	* crosstab
tab media_intl_extreme media_intl_any, nol

	* scatterplot		
graph twoway scatter media_intl_extreme media_intl_any, jitter(5) by(educ)
graph export graph/wave5-8/scatterplot_binary_ext_org_educ.png, replace

graph twoway scatter media_intl_extreme media_intl_any, jitter(5) by(age)
graph export graph/wave5-8/scatterplot_binary_ext_org_age.png, replace


* Histogram of odds ratio of moderate ajustment

quietly summarize odds_mod
local mean_odds_mod = r(mean)
	
histogram odds_mod, ///
    normal /// 
    title("Distribution of Moderately Simulated Odds Ratios of International Media Use (Model 3)", size(medium)) /// subtitle("Comparing Original vs. Adjusted Effects")
    xtitle("Odds Ratio") ///
    ytitle("Density") ///
    name(hist_or, replace) /// xline(`=orig_or', lcolor(black) lwidth(thick) lpattern(solid))
    xline(`mean_odds_mod', lcolor(red) lwidth(thick) lpattern(dash)) ///
    note("Mean Adjusted OR (Red dashed line) = `=string(`mean_odds_mod', "%9.3f")'; Original OR: `=string(orig_or, "%9.3f")'")

graph export graph/wave5-8/hist_binary_odds_mod.png, replace


* Histogram of odds ratio of extreme ajustment

quietly summarize odds_ext
local mean_odds_ext = r(mean)
	
histogram odds_ext, ///
    normal /// 
    title("Distribution of Extremely Simulated Odds Ratios of International Media Use (Model 3)", size(medium)) /// subtitle("Comparing Original vs. Adjusted Effects")
    xtitle("Odds Ratio") ///
    ytitle("Density") ///
    name(hist_or, replace) /// xline(`=orig_or', lcolor(black) lwidth(thick) lpattern(solid))
    xline(`mean_odds_ext', lcolor(red) lwidth(thick) lpattern(dash)) ///
    note("Mean Adjusted OR (Red dashed line) = `=string(`mean_odds_ext', "%9.3f")'; Original OR: `=string(orig_or, "%9.3f")'")

graph export graph/wave5-8/hist_binary_odds_ext.png, replace
	
	
save wave/wave5-8_binary_sim, replace	

compress

clear