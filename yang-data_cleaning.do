*********************************************************************
* Research Hypotheses, Data Set-up.
*********************************************************************

/*
Dataset:
SSCN.
 */

 
* clean data
* Set working directory

* Clear memory
clear all

* Load and append datasets
use "2014-2015-2017_data_SSCN.dta", clear

keep start finish seqnum ip start finish Q1_141517 Q4_141517 Q5_141517 Q6_141517 Q7_141517 Q15_R10_141517 Q15_R12_141517 Q15_R16_141517 Q15_R5_141517 Q15_R18_141517 Q15_R21_141517 Q15_R20_2017 Q15_R14_2017 Q15_R15_2017 Q16_R8_1417 Q16_R1_141517 Q16_R4_141517 Q16_R5_141517 Q16_R6_141517 Q16_R7_141517 Q60_R3_141517 Q60_R4_1417 Q60_R5_141517 Q60_R6_1417 Q61_141517 Q64_A1_open_2017 Q64_A2_open_2017 Q64_A3_open_2017 Q9_2017 Q18_2014 V431 Q9_2017

* rename DV
rename Q60_R3_141517 trust_central_raw
rename Q60_R4_1417 trust_provincial
rename Q60_R5_141517 trust_town
rename Q60_R6_1417 trust_countryside

* rename IV
rename Q15_R10_141517 media_businessweb
rename Q15_R12_141517 media_international
rename Q15_R16_141517 media_state
rename Q15_R5_141517 media_wechatnews
rename Q15_R18_141517 media_contentcomm
rename Q15_R20_2017 media_selfmedia
rename Q15_R21_141517 media_gossip
rename Q15_R14_2017 media_localtv
rename Q15_R15_2017 media_megazine

* rename Moderating factor
rename Q16_R8_1417 cred_gov
rename Q16_R1_141517 cred_statemedia
rename Q16_R4_141517 cred_selfmedia
rename Q16_R5_141517 cred_businessweb
rename Q16_R6_141517 cred_international
rename Q16_R7_141517 cred_socialnetwork

* rename Control Variables
rename Q61_141517 educ_raw
rename Q1_141517 gender_raw
rename Q4_141517 region_raw
rename Q5_141517 pid_raw
rename Q6_141517 income
rename Q7_141517 job
rename V431 age
rename Q9_2017 interest_5
revrs Q18_2014
rename revQ18_2014 interest_4
capture drop Q18_2014
rename Q64_A1_open_2017 province_raw
rename Q64_A2_open_2017 city_raw
rename Q64_A3_open_2017 county_raw



gen year = year(finish)

save processed_data\renamed_141517.dta, replace

use processed_data\renamed_141517.dta, clear

******** DV - 4 values (ordinal) ********
tab trust_central_raw
tab trust_central_raw, nol

recode trust_central_raw(1=1 "None at all")(2=2 "Not very much")(9=3 "Fifty fifty")(3=4 "A fair amount")(4=5 "A big deal"), gen(trust_central)

recode trust_central_raw(1=1 "None at all")(2=2 "Not very much")(3=3 "A fair amount")(4=4 "A big deal")(9=.), gen(trust_central_4)

label variable trust_central "Trust in central government and party committee"
label values trust_central trust_central 

******** IV - categorization (ordinal) ********

* state media: media_state
label variable media_state "State Media Consumption"
label define media_state 1 "Almost never" 2 "Not very much" 3 "Often" 4 "Almost every day"
label values media_state media_state

* international media: media_international
label variable media_international "International Media Consumption"
label define media_international 1 "Almost never" 2 "Not very much" 3 "Often" 4 "Almost every day"
label values media_international media_international
rename media_international media_intl

* private media:
egen media_private_composite = rowmean(media_businessweb media_wechatnews media_contentcomm media_gossip)
label variable media_private_composite "Private Media Consumption Index"

capture drop media_private_composite_cat
foreach var of varlist media_private_composite {
    generate `var'_cat = .
    replace `var'_cat = 1 if `var' <= 1 
    replace `var'_cat = 2 if `var' > 1 & `var' <= 2 
    replace `var'_cat = 3 if `var' > 2 & `var' <= 3 
    replace `var'_cat = 4 if `var' > 3 & `var' <= 4 
	label define `var'_cat_lbl 1 "Almost never" 2 "Not very much" 3 "Often" 4 "Almost every day"
    label values `var'_cat `var'_cat_lbl
    label variable `var'_cat "`var' consumption"
}

rename media_private_composite_cat media_private
label variable media_private "Private Media Consumption"

******** Moderating Variables (ordinal) ********

recode cred_gov(6=3)
recode cred_statemedia(6=3)
recode cred_selfmedia(6=3)
recode cred_businessweb(6=3)
recode cred_international(6=3)
recode cred_socialnetwork(6=3)

*perceived credibility of state media
capture drop cred_state_index
egen cred_state_index = rowmean(cred_gov cred_statemedia)

*perceived credibility of international media
label variable cred_international "Perceived credibility of international media"
label define cred_international  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values cred_international cred_international
rename cred_international cred_intl

*perceived credibility of private media
egen cred_private_composite = rowmean(cred_selfmedia cred_businessweb cred_socialnetwork)

label variable cred_private_composite "Index of perceived credibility of private media consumption"

capture drop cred_private_composite_cat 
capture drop cred_state_index_cat
foreach var of varlist cred_state_index cred_private_composite {
    generate `var'_cat = .
    replace `var'_cat = 1 if `var' <= 1 
    replace `var'_cat = 2 if `var' > 1 & `var' <= 2 
    replace `var'_cat = 3 if `var' > 2 & `var' <= 3 
    replace `var'_cat = 4 if `var' > 3 & `var' <= 4 
	replace `var'_cat = 5 if `var' > 4 & `var' <= 5 
	capture label drop `var'_cat_lbl
	label define `var'_cat_lbl 1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
    label values `var'_cat `var'_cat_lbl
    label variable `var'_cat "Perceived credibility of `var'"
}

rename cred_state_index_cat cred_state

label variable cred_state "Perceived credibility of state media"
label define cred_state  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values cred_state cred_state

rename cred_private_composite_cat cred_private

label variable cred_private "Perceived credibility of private media"
label define cred_private  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values cred_private cred_private


******** Control Variables ********

*recode gender into binary
tab gender_raw
tab gender_raw, m nol
recode gender_raw(1=0 "Male")(2=1 "Female"), gen(gender)
label variable gender "Gender"
tab gender

*recode region (nomial) 1=abroad as base 
tab region_raw
tab region_raw, m nol
revrs region_raw
rename revregion_raw region
label variable region "Region"
label define region  1 "Abroad" 2 "Countryside" 3 "Town" 4 "Small city" 5 "Middle city" 6 "Big city"
label values region region
tab region

*recode educ_raw to have increasing value. (ordinal)
tab educ_raw
tab educ_raw, m nol
revrs educ_raw
rename reveduc_raw educ
label variable educ "Education"
label define educ  1 "No school" 2 "Primary school" 3 "Middle school" 4 "High school" 5 "Specialty college" 6 "Bachelor" 7 "Master" 8 "Doctor"
label values educ educ
tab educ

*recode pid into binary
tab pid_raw
tab pid_raw, m nol
recode pid_raw(1=0 "Non-party member")(3=1 "Party member"), gen(pid)
label variable pid "Party Membership"
tab pid

*income(ordinal)
label variable income "Income"

*age(continuous)
label variable age "Age"

*job(nomial)
label variable job "Job"

*interest(ordinal)

gen interest5 = .
replace interest5= interest_5 if year == 2017

replace interest5 = 1 if interest_4 == 1 & year == 2014  /* None at all */
replace interest5 = 2 if interest_4 == 2 & year == 2014  /* Not very much */
replace interest5 = 4 if interest_4 == 3 & year == 2014  /* A fair amount */
replace interest5 = 5 if interest_4 == 4 & year == 2014  /* A big deal */

label define interest5 1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values interest5 interest5

drop seqnum ip gender_raw region_raw pid_raw media_businessweb media_wechatnews media_contentcomm media_gossip cred_gov cred_selfmedia cred_statemedia cred_businessweb cred_socialnetwork trust_provincial trust_town trust_countryside educ_raw media_localtv media_megazine media_selfmedia province_raw city_raw county_raw interest_4 media_private_composite cred_state_index cred_private_composite interest_5

label variable start "Start"
label variable finish "Finish"

order year trust_central trust_central_4 media_state media_private media_intl cred_state cred_private cred_intl gender region educ pid income age job 

drop trust_central_raw

save processed_data\cleaned_141517, replace

*************************************************
*			Clean and Append 2018 data			*
*************************************************

use 2018_data_SSCN.dta, clear

gen year=2018

rename Q45 educ_raw
rename Q1 gender_raw
rename Q2 age_raw
rename Q4 region_raw
rename Q5 pid_raw
rename Q6 income
rename Q7 job
rename Q10 interest5
rename Q11_1 media_businessweb
rename Q11_3 media_international
rename Q11_6 media_state
rename Q11_4 media_localtv
rename Q11_5 media_megazine
rename Q11_7 media_contentcomm
rename Q11_2 media_socialnetwork
rename Q11_8 media_selfmedia
rename Q11_9 media_gossip
rename Q12_1 cred_gov
rename Q12_2 cred_statemedia
rename Q12_3 cred_localcommercial
rename Q12_4 cred_selfmedia
rename Q12_5 cred_businessweb
rename Q12_6 cred_international
rename Q12_7 cred_socialnetwork
rename Q44_3 trust_central_raw
rename Q44_4 trust_provincial_4
rename Q44_5 trust_town_4
rename Q44_6 trust_countryside_4

******** DV - 4 values (ordinal) ********
tab trust_central_raw
tab trust_central_raw, nol

recode trust_central_raw(1=1 "None at all")(2=2 "Not very much")(5=3 "Fifty fifty")(3=4 "A fair amount")(4=5 "A big deal"), gen(trust_central)

recode trust_central_raw(1=1 "None at all")(2=2 "Not very much")(3=3 "A fair amount")(4=4 "A big deal")(5=.), gen(trust_central_4)

label variable trust_central "Trust in central government and party committee (5 levels)"
label values trust_central trust_central 

label variable trust_central_4 "Trust in central government and party committee (4 levels)"
label values trust_central_4 trust_central_4


******** IV - categorization (ordinal) ********

* state media: media_state
egen media_state_composite = rowmean(media_state media_localtv)
label variable media_state_composite "State Media Consumption Index"

* international media: media_international
label variable media_international "International Media Consumption"
label define media_international 1 "Almost never" 2 "Not very much" 3 "Often" 4 "Almost every day"
label values media_international media_international
rename media_international media_intl

* private media:
egen media_private_composite = rowmean(media_businessweb media_socialnetwork media_contentcomm media_selfmedia media_gossip)

label variable media_private_composite "Private Media Consumption Index"

capture drop media_private_composite_cat media_state_composite_cat
foreach var of varlist media_private_composite media_state_composite  {
    generate `var'_cat = .
    replace `var'_cat = 1 if `var' <= 1 
    replace `var'_cat = 2 if `var' > 1 & `var' <= 2 
    replace `var'_cat = 3 if `var' > 2 & `var' <= 3 
    replace `var'_cat = 4 if `var' > 3 & `var' <= 4 
	label define `var'_cat_lbl 1 "Almost never" 2 "Not very much" 3 "Often" 4 "Almost every day"
    label values `var'_cat `var'_cat_lbl
    label variable `var'_cat "`var' consumption"
}

rename media_private_composite_cat media_private
label variable media_private "Private Media Consumption"

rename media_state media_state_raw
rename media_state_composite_cat media_state, replace
label variable media_state "State Media Consumption"


******** Moderating Variables (ordinal) ********

*perceived credibility of state media
capture drop cred_state_index
egen cred_state_index = rowmean(cred_gov cred_statemedia)

*perceived credibility of international media
label variable cred_international "Perceived credibility of international media"
label define cred_international  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values cred_international cred_international
rename cred_international cred_intl

*perceived credibility of private media
egen cred_private_composite = rowmean(cred_selfmedia cred_businessweb cred_socialnetwork cred_localcommercial)

label variable cred_private_composite "Index of perceived credibility of private media consumption"

capture drop cred_private_composite_cat cred_state_index_cat

foreach var of varlist cred_state_index cred_private_composite {
    generate `var'_cat = .
    replace `var'_cat = 1 if `var' <= 1 
    replace `var'_cat = 2 if `var' > 1 & `var' <= 2 
    replace `var'_cat = 3 if `var' > 2 & `var' <= 3 
    replace `var'_cat = 4 if `var' > 3 & `var' <= 4 
	replace `var'_cat = 5 if `var' > 4 & `var' <= 5 
	capture label drop `var'_cat_lbl
	label define `var'_cat_lbl 1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
    label values `var'_cat `var'_cat_lbl
    label variable `var'_cat "Perceived credibility of `var'"
}

rename cred_state_index_cat cred_state

label variable cred_state "Perceived credibility of state media"
label define cred_state  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values cred_state cred_state

rename cred_private_composite_cat cred_private

label variable cred_private "Perceived credibility of private media"
label define cred_private  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values cred_private cred_private

******** Control Variables ********

*recode gender into binary
tab gender_raw
tab gender_raw, m nol
recode gender_raw(1=0 "Male")(2=1 "Female"), gen(gender)
label variable gender "Gender"
tab gender

*recode region (nomial) 1=abroad as base 
tab region_raw
tab region_raw, m nol
revrs region_raw
rename revregion_raw region
label variable region "Region"
label define region  1 "Abroad" 2 "Countryside" 3 "Town" 4 "Small city" 5 "Middle city" 6 "Big city"
label values region region
tab region

*recode educ_raw to have increasing value. (ordinal)
tab educ_raw
tab educ_raw, m nol
revrs educ_raw
recode educ_raw (1/2=1 "Primary school or lower")(3=2 "Middle school")(4=3 "High school")(5=4 "Specialty college")(6=5 "Bachelor") (7/8=6 "Master or higher"), gen(educ)
label variable educ "Education"
tab educ

*recode pid into binary
tab pid_raw
tab pid_raw, m nol
recode pid_raw(2/3=0 "Non-party member")(1=1 "Party member"), gen(pid)
label variable pid "Party Membership"
tab pid

*income(ordinal)
label variable income "Income"

*age(ordinal)

label variable age "Age"
rename age_raw age

*job(nomial)
label variable job "Job"

*interest(ordinal)
label variable interest5 "Interest in Political News"

keep year start finish trust_central trust_central_4 media_state media_private media_intl cred_state cred_private cred_intl gender region educ pid income age job interest5

order year trust_central trust_central_4 media_state media_private media_intl cred_state cred_private cred_intl gender region educ pid income age job 

save processed_data\cleaned_18.dta, replace




*************************************************
*	  Clean 2019 & 2020-1 data		*
*************************************************

use 2019+2020-1_data_SSCN.dta, clear

gen year = year(dofc(finish))

rename Q2 age_raw
rename Q5 educ
rename Q3 gender_raw
rename Q9 region_raw
rename Q4 pid_raw
rename Q8 income_raw
rename Q7 job
rename Q13 interest_5
rename Q41_R3 trust_central_raw
rename Q41_R4 trust_countryside_raw
rename Q15_A3 media_businessweb_bi
rename Q15_A8 media_intl_bi
rename Q15_A9 media_newsapp_bi
rename Q15_A5 media_localtv_bi
rename Q15_A4 media_paper_bi
rename Q15_A6 media_socialnetwork_bi
rename Q15_A7 media_selfmedia_bi
rename Q15_A10 media_intlCN_bi
rename Q15_A11 media_HKTW_bi
rename Q38_R3 cred_statemedia
rename Q38_R4 cred_xinhuashe
rename Q38_R5 cred_huanqiu
rename Q38_R6 cred_peopledaily
rename Q38_R7 cred_international
rename Q38_R8 cred_HKTW
rename Q38_R9 cred_internationalCN
rename Q38_R10 cred_otherinternational
rename Q35_R3 media_cctv
rename Q35_R5 media_huanqiu
rename Q35_R6 media_statemedia
rename Q35_R7 media_international
rename Q35_R8 media_HKTW
rename Q35_R9 media_intlCN
rename Q35_R10 media_foreign

keep year start finish age_raw gender_raw pid_raw educ job income_raw region_raw interest_5 media_businessweb_bi media_paper_bi media_localtv_bi media_socialnetwork_bi media_selfmedia_bi media_intl_bi media_newsapp_bi media_intlCN_bi media_HKTW_bi cred_statemedia cred_xinhuashe cred_huanqiu cred_peopledaily cred_international cred_HKTW cred_internationalCN cred_otherinternational trust_central_raw media_cctv media_huanqiu media_state media_international media_HKTW media_intlCN media_foreign 


save renamed_1920-1, replace

******** DV - 5 values (ordinal) ********

use renamed_1920-1, clear

tab trust_central_raw
tab trust_central_raw, nol

recode trust_central_raw(8=5)

recode trust_central_raw(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(trust_central)

label variable trust_central "Trust in central government and party committee"

******** IV - categorization (binary) ********


* state media: media_state
egen media_state_index = rowtotal(media_paper_bi media_localtv)

recode media_statemedia(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(media_state_recoded)

recode media_cctv(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(media_cctv_recoded)

recode media_huanqiu(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(media_huanqiu_recoded)

egen media_state_index2 = rowmean(media_state_recoded media_cctv_recoded media_huanqiu_recoded)

* international media: media_international
egen media_international_index = rowtotal(media_intl_bi media_intlCN_bi media_HKTW_bi)

recode media_international(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(media_international_recoded)

recode media_HKTW(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(media_HKTW_recoded)

recode media_intlCN (3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(media_intlCN_recoded)

recode media_foreign (3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(media_foreign_recoded)

egen media_intl_index2 = rowmean(media_international_recoded media_HKTW_recoded media_intlCN_recoded media_foreign_recoded)

* private media:
egen media_private_index = rowtotal(media_businessweb_bi media_socialnetwork_bi media_selfmedia_bi media_newsapp_bi)

* Create binary indicators for using any media in each category
generate media_state_any = (media_state_index > 0)
generate media_private_any = (media_private_index > 0)
generate media_intl_any = (media_international_index > 0)

label variable media_state_any "Uses any state media"
label variable media_private_any "Uses any private media"
label variable media_intl_any "Uses any international media"

foreach var of varlist media_state_index2 media_intl_index2 {
    generate `var'_cat = .
    replace `var'_cat = 1 if `var' <= 1 
    replace `var'_cat = 2 if `var' > 1 & `var' <= 2 
    replace `var'_cat = 3 if `var' > 2 & `var' <= 3 
    replace `var'_cat = 4 if `var' > 3 & `var' <= 4 
	replace `var'_cat = 5 if `var' > 4 & `var' <= 5 
	capture label drop `var'_cat_lbl
	label define `var'_cat_lbl 1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
    label values `var'_cat `var'_cat_lbl
    label variable `var'_cat "`var' Consumption"
}

rename media_state_index2_cat media_state

label variable media_state "Perceived credibility of state media"
label define media_state  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values media_state media_state

rename media_intl_index2_cat media_intl

label variable media_intl "Perceived credibility of private media"
label define media_intl  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values media_intl media_intl



******** Moderating Variables (ordinal) ********

*perceived credibility of state media
capture drop cred_state_index

recode cred_statemedia(8=5)

recode cred_statemedia(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(cred_cctv)

recode cred_xinhuashe(8=5)

recode cred_xinhuashe(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(cred_xinhuanews)

recode cred_huanqiu(8=5)

recode cred_huanqiu(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(cred_globaltimes)

recode cred_peopledaily(8=5)

recode cred_peopledaily(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(cred_ppldaily)

egen cred_state_index = rowmean(cred_cctv cred_xinhuanews cred_globaltimes cred_ppldaily)

*perceived credibility of international media
recode cred_international(8=5)

recode cred_international(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(cred_international2)

recode cred_HKTW(8=5)

recode cred_HKTW(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(cred_hktw)

recode cred_internationalCN(8=5)

recode cred_internationalCN(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(cred_intlCN)

recode cred_otherinternational(8=5)

recode cred_otherinternational(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(cred_otherintl)

egen cred_intl_index = rowmean(cred_international2 cred_hktw cred_intlCN cred_otherintl)

*****categorize credibility index*******

foreach var of varlist cred_state_index cred_intl_index {
    generate `var'_cat = .
    replace `var'_cat = 1 if `var' <= 1 
    replace `var'_cat = 2 if `var' > 1 & `var' <= 2 
    replace `var'_cat = 3 if `var' > 2 & `var' <= 3 
    replace `var'_cat = 4 if `var' > 3 & `var' <= 4 
	replace `var'_cat = 5 if `var' > 4 & `var' <= 5 
	capture label drop `var'_cat_lbl
	label define `var'_cat_lbl 1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
    label values `var'_cat `var'_cat_lbl
    label variable `var'_cat "Perceived credibility of `var'"
}

rename cred_state_index_cat cred_state

label variable cred_state "Perceived credibility of state media"
label define cred_state  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values cred_state cred_state

rename cred_intl_index_cat cred_intl

label variable cred_intl "Perceived credibility of private media"
label define cred_intl  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values cred_intl cred_intl


******** Control Variables ********

*recode gender into binary
tab gender_raw
tab gender_raw, m nol
recode gender_raw(1=0 "Male")(2=1 "Female"), gen(gender)
label variable gender "Gender"
tab gender

*recode region (nomial) 1=abroad as base 
/*
tab region_raw
tab region_raw, m nol
revrs region_raw
rename revregion_raw region
label variable region "Region"
label define region  1 "Abroad" 2 "Countryside" 3 "Town" 4 "Small city" 5 "Middle city" 6 "Big city"
label values region region
tab region
*/

*recode educ_raw to have increasing value. (ordinal - 6 levels)

label variable educ "Education"
label define educ  1 "Primary school or lower" 2 "Middle school" 3 "High school" 4 "Specialty college" 5 "Bachelor" 6 "Master or higher"
label values educ educ
tab educ

*recode pid into binary
tab pid_raw
tab pid_raw, m nol
recode pid_raw(1=0 "Non-party member")(2=1 "Party member")(3=0)(4=1), gen(pid)
label variable pid "Party Membership"
tab pid

*income(ordinal)
recode income_raw(3=1 "Less than 20k")(4=2 "20-50k")(5=3 "50-100k")(6=4 "100-150k")(7=5 "150-200k")(8=6 "200-400k")(9=7 "400-600k")(10=8 "600k-1m")(11=9 "More than 1m"), gen(income)
label variable income "Income (CNY)"

*age(ordinal)
recode age_raw(4=1 "18-24")(5=2 "25-29")(6=3 "30-34")(7=4 "35-39")(8=5 "40-44")(9=6 "45-49")(10=7 "50-54")(11=8 "55-59")(12=9 "60+"), gen(age)
label variable age "Age"

*job(nomial)
label variable job "Job"

*interest(ordinal)
recode interest_5(3=1 "None at all")(4=2 "Not very much")(5=3 "Fifty Fifty")(6=4 "A fair amount")(7=5 "A big deal"), gen(interest5)


keep start finish trust_central media_state_any media_private_any media_intl_any media_state media_intl cred_state cred_intl educ job gender pid income age interest5 year


save processed_data\cleaned_19_20_1.dta, replace

use processed_data\cleaned_19_20_1, clear

ologit trust_central i.media_state_any##c.cred_state i.media_private_any i.media_intl_any##c.cred_intl i.gender c.educ i.pid c.income c.age




*************************************************
*		Clean and Append 2020-2 data			*
*************************************************

use 2020-2_data_SSCN, clear

rename 开始时间 start
rename 提交时间 finish
rename Q2 age_raw
rename Q32 educ_raw
rename Q30 gender_raw
rename Q31 pid_raw
rename Q33 income_raw
rename Q34 job
rename Q3 interest_5
rename Q29_R1 trust_central_raw
rename Q29_R2 trust_county_raw
rename Q6_1 media_businessweb_bi
rename Q6_6 media_intl_bi
rename Q6_7 media_newsapp_bi
rename Q6_3 media_localtv_bi
rename Q6_2 media_paper_bi
rename Q6_4 media_socialnetwork_bi
rename Q6_5 media_selfmedia_bi
rename Q6_8 media_contentcomm
rename Q29_R7 cred_cctv

gen year=2020

keep year start finish trust_central_raw media_businessweb_bi media_paper_bi media_localtv_bi media_socialnetwork_bi media_selfmedia_bi media_intl_bi media_newsapp_bi media_contentcomm cred_cctv age_raw interest_5 gender_raw pid_raw educ_raw income_raw job 

******** DV - 5 values (ordinal) ********

tab trust_central_raw
tab trust_central_raw, nol

recode trust_central_raw(6=3)

recode trust_central_raw(1=1 "None at all")(2=2 "Not very much")(3=3 "Fifty Fifty")(4=4 "A fair amount")(5=5 "A big deal"), gen(trust_central)

label variable trust_central "Trust in central government and party committee"


******** IV - categorization (binary) ********

capture drop media_private_composite_cat media_state_composite_cat media_intl_composite_cat

* state media: media_state
egen media_state = rowtotal(media_paper_bi media_localtv)

* international media: media_international
rename media_intl_bi media_intl_any

* private media:
egen media_private = rowtotal(media_businessweb_bi media_socialnetwork_bi media_selfmedia_bi media_newsapp_bi media_contentcomm)

* Create binary indicators for using any media in each category
generate media_state_any = (media_state > 0)
generate media_private_any = (media_private > 0)

label variable media_state_any "Uses any state media"
label variable media_private_any "Uses any private media"
label variable media_intl_any "Uses any international media"


******** Moderating Variables (ordinal) ********

*perceived credibility of state media
capture drop cred_state

recode cred_cctv (6=3)

label define cred_cctv 1 "None at all" 2 "Not very much" 3 "Fifty Fifty" 4 "A fair amount" 5 "A big deal"

rename cred_cctv cred_state

label values cred_state cred_cctv

label variable cred_state "Perceived credibility of State Media"

******** Control Variables ********

*recode gender into binary
tab gender_raw
tab gender_raw, m nol
recode gender_raw(1=0 "Male")(2=1 "Female"), gen(gender)
label variable gender "Gender"
tab gender

*recode region (nomial) 1=abroad as base 
/*
tab region_raw
tab region_raw, m nol
revrs region_raw
rename revregion_raw region
label variable region "Region"
label define region  1 "Abroad" 2 "Countryside" 3 "Town" 4 "Small city" 5 "Middle city" 6 "Big city"
label values region region
tab region
*/

*recode educ_raw to have increasing value. (ordinal - 6 levels)
tab educ_raw
tab educ_raw, nol
recode educ_raw(7=6)
label define educ_raw  1 "Primary school or lower" 2 "Middle school" 3 "High school" 4 "Specialty college" 5 "Bachelor" 6 "Master or higher"
label values educ_raw educ_raw
rename educ_raw educ
label variable educ "Education"

tab educ

*recode pid into binary
tab pid_raw
tab pid_raw, m nol
recode pid_raw(1=0 "Non-party member")(2=1 "Party member")(3=0)(4=1), gen(pid)
label variable pid "Party Membership"
tab pid

*income(ordinal)
tab income_raw
tab income_raw, nol
label define income_raw 1 "Less than 20k" 2 "20-49.9k" 3 "50-99.9k" 4 "100-149.9k" 5 "150-199.9k" 6 "200-399.9k" 7 "400-599.9k" 8 "600-999.9k" 9 "1m+"
label values income_raw income_raw
rename income_raw income
label variable income "Income (CNY)"
tab income

*age(ordinal)
tab age_raw
tab age_raw, nol
recode age_raw(2=1 "18-24")(3=2 "25-29")(4=3 "30-34")(5=4 "35-39")(6=5 "40-44")(7=6 "45-49")(8=7 "50-54")(9=8 "55-59")(10=9 "60+"), gen(age)
label variable age "Age"
tab age

*job(nomial)
label variable job "Job"

*interest(ordinal)
tab interest_5
tab interest_5, nol
rename interest_5 interest5
label define interest5 1 "None at all" 2 "Not very much" 3 "Fifty Fifty" 4 "A fair amount" 5 "A big deal"
label values interest5 interest5
label variable interest5 "Interest in Political News"
tab interest5

keep year start finish trust_central media_state_any media_private_any media_intl_any cred_state age pid job educ gender income interest5

save processed_data\cleaned_20_2.dta, replace

use processed_data\cleaned_20_2, clear


****************ologit***************************


/*
ologit trust_central_4 c.media_state##c.cred_state c.media_private##c.cred_private c.media_international##c.cred_international i.gender i.region c.educ i.pid c.income c.age i.job
*/

ologit trust_central i.media_state_any##c.cred_state i.media_private_any i.media_intl_any i.gender c.educ i.pid c.income c.age


estimates store ologit2020_2

esttab ologit2020_2 ologit2020_2 using table/table2020-2-ologit.rtf, b(3) compress replace ///
se label eform(0 1) stats(N ll r2_p chi2 p, ///
labels(Observations Log-likelihood Pseudo-rsquared Wald-chi2 Prob>chi2) ) ///
cells(b(fmt(4)star) se(par)) ///
varwidth(30) collabels(, none) ///
nobase ///
title ("Table 1: Ordered Logistic regression (2019)") ///
nonumbers mtitles("Coefficient" "Odds ratio")

***margins and marginsplot

ologit trust_central i.media_state_any##c.cred_state i.media_private_any i.media_intl_any i.gender c.educ i.pid c.income c.age

margins, at(media_state=(0(1)1)) atmeans vsquish

marginsplot, title("Predicted Probability of State Media Consumption on Trust in Central Government and Party", size(3.9))
 
 
*************************************************
*		Clean and Append 2021 data			*
*************************************************
use 2021_data_SSCN, clear

rename V135 start
rename V136 finish
rename Q2 age_raw
rename Q42 educ_raw
rename Q40 gender_raw
rename V194 pid
rename Q43 income_raw
rename Q46 job
rename Q3 interest_5
rename Q39_R3 trust_central_raw
rename Q39_R4 trust_county_raw
rename Q6_R3 media_businessweb
rename Q6_R8 media_international
rename Q6_R9 media_newsapp
rename Q6_R5 media_localtv
rename Q6_R4 media_paper
rename Q6_R6 media_socialnetwork
rename Q6_R7 media_selfmedia
rename Q6_R10 media_contentcomm
rename Q6_R11 media_shortvideo
rename Q6_R12 media_videoweb
rename Q6_R13 media_intlCN
rename Q7_R14 cred_statemedia
rename Q7_R15 cred_ngo
rename Q7_R16 cred_intlnews
rename Q7_R17 cred_intlsocialmedia
rename Q7_R18 cred_intlCN

gen year=2021 

keep age_raw interest_5 media_businessweb media_paper media_localtv media_socialnetwork media_selfmedia media_international media_newsapp media_contentcomm media_shortvideo media_videoweb media_intlCN cred_statemedia cred_ngo cred_intlnews cred_intlsocialmedia cred_intlCN educ_raw trust_central_raw gender_raw income_raw job start finish pid

save processed_data\renamed_21, replace

use processed_data\renamed_21, clear

******** DV - 5 values (ordinal) ********

tab trust_central_raw
tab trust_central_raw, nol

recode trust_central_raw(6=3)

recode trust_central_raw(1=1 "None at all")(2=2 "Not very much")(3=3 "Fifty Fifty")(4=4 "A fair amount")(5=5 "A big deal"), gen(trust_central)

drop trust_central_raw

label variable trust_central "Trust in central government and party committee"

******** IV - categorization (binary) ********

capture drop media_private_composite_cat media_state_composite_cat media_intl_composite_cat

* state media: media_state
egen media_state_index = rowmean(media_paper media_localtv)

* private media:
egen media_private_index = rowmean(media_businessweb media_socialnetwork media_selfmedia media_newsapp media_contentcomm media_shortvideo media_videoweb)

* international media: media_international
egen media_intl_index = rowmean(media_international media_intlCN)

* categorize index
foreach var of varlist media_state_index media_private_index media_intl_index {
    generate `var'_cat = .
    replace `var'_cat = 1 if `var' <= 1 
    replace `var'_cat = 2 if `var' > 1 & `var' <= 2 
    replace `var'_cat = 3 if `var' > 2 & `var' <= 3 
    replace `var'_cat = 4 if `var' > 3 & `var' <= 4 
	replace `var'_cat = 5 if `var' > 4 & `var' <= 5 
	capture label drop `var'_cat_lbl
	label define `var'_cat_lbl 1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
    label values `var'_cat `var'_cat_lbl
    label variable `var'_cat "`var' Consumption"
}

rename media_state_index_cat media_state

label variable media_state "State Media Consumption"
label define media_state  1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values media_state media_state

rename media_private_index_cat media_private

label variable media_private "Private Media Consumption"
label define media_private 1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values media_private media_private

rename media_intl_index_cat media_intl

label variable media_intl "International Media Consumption"
label define media_intl 1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
label values media_intl media_intl

drop media_businessweb media_paper media_localtv media_socialnetwork media_selfmedia media_international media_newsapp media_contentcomm media_shortvideo media_videoweb media_intlCN

drop media_state_index media_private_index media_intl_index

******** Moderating Variables (ordinal) ********

*perceived credibility of state media
capture drop cred_state_index

recode cred_statemedia(6=3)

recode cred_statemedia(1=1 "None at all")(2=2 "Not very much")(3=3 "Fifty Fifty")(4=4 "A fair amount")(5=5 "A big deal"), gen(cred_state)

*perceived credibility of international media

recode cred_ngo(6=3)

recode cred_ngo(1=1 "None at all")(2=2 "Not very much")(3=3 "Fifty Fifty")(4=4 "A fair amount")(5=5 "A big deal"), gen(cred_private)


*perceived credibility of international media

recode cred_intlnews(6=3)

recode cred_intlnews(1=1 "None at all")(2=2 "Not very much")(3=3 "Fifty Fifty")(4=4 "A fair amount")(5=5 "A big deal"), gen(cred_intlNEWS)

recode cred_intlsocialmedia(6=3)

recode cred_intlsocialmedia(1=1 "None at all")(2=2 "Not very much")(3=3 "Fifty Fifty")(4=4 "A fair amount")(5=5 "A big deal"), gen(cred_intlSM)

recode cred_intlCN(6=3)

recode cred_intlCN(1=1 "None at all")(2=2 "Not very much")(3=3 "Fifty Fifty")(4=4 "A fair amount")(5=5 "A big deal"), gen(cred_intlCHN)

egen cred_intl_index = rowmean(cred_intlNEWS cred_intlSM cred_intlCHN)

*****categorize credibility index*******

foreach var of varlist cred_intl_index {
    generate `var'_cat = .
    replace `var'_cat = 1 if `var' <= 1 
    replace `var'_cat = 2 if `var' > 1 & `var' <= 2 
    replace `var'_cat = 3 if `var' > 2 & `var' <= 3 
    replace `var'_cat = 4 if `var' > 3 & `var' <= 4 
	replace `var'_cat = 5 if `var' > 4 & `var' <= 5 
	capture label drop `var'_cat_lbl
	label define `var'_cat_lbl 1 "None at all" 2 "Not very much" 3 "Fifty fifty" 4 "A fair amount" 5 "A big deal"
    label values `var'_cat `var'_cat_lbl
    label variable `var'_cat "Perceived credibility of `var'"
}

rename cred_intl_index_cat cred_intl

label variable cred_intl "Perceived Credibility of International Media"

drop cred_statemedia cred_ngo cred_intlnews cred_intlsocialmedia cred_intlCN cred_state cred_intlNEWS cred_intlSM cred_intlCHN cred_private cred_intl_index 


******** Control Variables ********

*recode gender into binary
tab gender_raw
tab gender_raw, m nol
recode gender_raw(1=0 "Male")(2=1 "Female"), gen(gender)
label variable gender "Gender"
tab gender

*recode region (nomial) 1=abroad as base 
/*
tab region_raw
tab region_raw, m nol
revrs region_raw
rename revregion_raw region
label variable region "Region"
label define region  1 "Abroad" 2 "Countryside" 3 "Town" 4 "Small city" 5 "Middle city" 6 "Big city"
label values region region
tab region
*/

*recode educ_raw to have increasing value. (ordinal - 6 levels)

recode educ_raw(1=1 "Primary school or lower")(2=2 "Middle school")(3=3 "High school")(4=4 "Specialty college")(5=5 "Bachelor")(6=6 "Master or higher")(7=6), gen(educ)
label values educ educ
label variable educ "Education"
tab educ

*pid
tab pid
tab pid, m nol
label define pid 0 "Non-party member" 1 "Party member"
label values pid pid
label variable pid "Party Membership"
tab pid

*income(ordinal)
tab income_raw
tab income_raw, nol
label define income_raw 1 "Less than 20k" 2 "20-49.9k" 3 "50-99.9k" 4 "100-149.9k" 5 "150-199.9k" 6 "200-399.9k" 7 "400-599.9k" 8 "600-999.9k" 9 "1m+"
label values income_raw income_raw
rename income_raw income
label variable income "Income (CNY)"
tab income

*age(ordinal)
tab age_raw
tab age_raw, nol
recode age_raw(2=1 "18-24")(3=2 "25-29")(4=3 "30-34")(5=4 "35-39")(6=5 "40-44")(7=6 "45-49")(8=7 "50-54")(9=8 "55-59")(10=9 "60+"), gen(age)
label variable age "Age"

*job(nomial)
label variable job "Job"

*interest(ordinal)
tab interest_5
tab interest_5, nol
recode interest_5(1=1 "None at all")(2=2 "Not very much")(3=3 "Fifty Fifty")(4=4 "A fair amount")(5=5 "A big deal"), gen(interest5)
label variable interest5 "Interest in Political News"

drop age_raw interest_5 gender_raw educ_raw

gen year=2021

save processed_data\cleaned_21, replace






*********************************************************
* Combine all data*
*********************************************************

* wave1-4 (4-level DV, 4-level IV)

use processed_data\cleaned_141517, clear
tab income
tab income, nol
rename income income_raw
recode income_raw (1/3=1 "Less than 20k")(4/5=2 "20-49.9k")(6=3 "50-99.9k")(7=4 "100-199.9k")(8/11=5 "200k+"), gen(income)
label variable income "Income (CNY)"
save processed_data\cleaned_141517, replace

use processed_data\cleaned_18, clear
tab income
rename income income1
recode income1(0/1.8=1 "Less than 20k")(2/4.8 =2 "20-49.9k")(5/9.9=3 "50-99.9k")(10/19.5=4 "100-199.9k")(20/1000=5 "200k+"), gen(income)
label variable income "Income (CNY)"
drop income1
save processed_data\cleaned_18, replace

use processed_data\cleaned_141517, clear
append using processed_data\cleaned_18
rename age age_raw
recode age_raw(2=1 "18-24")(3=2 "25-29")(4=3 "30-34")(5=4 "35-39")(6=5 "40-44")(7=6 "45-49")(8=7 "50-54")(9=8 "55-59")(10=9 "60+"),gen(age)
label variable age "Age"
drop age_raw

save processed_data\cleaned_14_18, replace

use processed_data\cleaned_14_18, clear

gen wave = .
replace wave = 1 if year == 2014
replace wave = 2 if year == 2015
replace wave = 3 if year == 2017
replace wave = 4 if year == 2018

save processed_data\cleaned_14_18, replace

* aggregated predictor: GDP, liberal score	

	* GDP source: Chinese Statistics Bureau
		*https://data.stats.gov.cn/easyquery.htm?cn=C01

	* Liberal score source: V-Dem
		*https://www.v-dem.net/data_analysis/CountryGraph/

/*
	*   Year   GDP (unit: 100 million)  Liberal Component Index	
		
		2021 1149237.0 0.15
		2020 1013567.0 0.15
		2019 986515.2 0.17
		2018 919281.1 0.17
		2017 832035.9 0.18
		2015 688858.2 0.18
		2014 643563.1 0.18
*/

* year-level vars

clear

input   year gdp liberal 
		2018 919281.1 0.17
		2017 832035.9 0.18
		2015 688858.2 0.18
		2014 643563.1 0.18
end

save wave\wave1-4_yearvar.dta, replace

use processed_data\cleaned_14_18, clear
merge m:1 year using wave\wave1-4_yearvar
drop _merge
rename gender female
label variable female "Female"
save wave\wave1-4, replace



* wave5-8

use processed_data\cleaned_19_20_1, clear
* 2019: binary media consumption (6.9k obs)
* 2020-1: 5-level media consumption (2k obs) 
gen wave = .
replace wave = 5 if year == 2019
replace wave = 6 if year == 2020

append using processed_data\cleaned_20_2
* 2020-2: binary media consumption (3.6k obs)
replace wave = 7 if year == 2020

append using processed_data\cleaned_21
* 2021: 5-level media consumption (3.8k obs)
replace wave = 8 if year == 2021


save processed_data\cleaned_19_21, replace

clear

input   year gdp liberal 
		2021 1149237.0 0.15
		2020 1013567.0 0.15
		2019 986515.2 0.17
end

save wave\wave5-8_yearvar, replace

use processed_data\cleaned_19_21, clear
merge m:1 year using wave\wave5-8_yearvar
drop _merge

capture drop income1

rename gender female
label variable female "Female"

save wave\wave5-8, replace

compress

save yang-data_cleaning.dta, replace

clear
