/***************
Author: Naakorkoi Pappoe
Date: January 11, 2014
Last Revision: January 24, 2014
Purpose: Create Balance Table
****************/

clear all
macro drop _all
capture log close

version 12.0
set more off

global strformat "%9.2f"


*************Balance Table
*********************************************

*code used for previous Balance Table did not allow clustering
**************
*Addapted from Matt Bobymic "sig_p" program from 
*Write program for Balance Test
**************
clear

*Format Output for Tables 
 
	capture program drop balanceMGCubed 
		program balanceMGCubed 
		   args obj_var point_est_var point_sd_var p_val row_id_var row_num 
		   local point_est `point_est_var' 
		   local point_sd `point_sd_var' 
		   if `p_val' > 0.1 { 
			  replace `obj_var' = string(`point_est', "$strformat") if `row_id_var' == `row_num' 
			  } 
		   if `p_val' > 0.05 & `p_val' <= 0.1  { 
			  replace `obj_var' = string(`point_est', "$strformat")+"*" if `row_id_var' == `row_num' 
			  } 
		   if `p_val' > 0.01 & `p_val' <= 0.05  { 
			  replace `obj_var' = string(`point_est', "$strformat")+"**" if `row_id_var' == `row_num' 
			  } 
		   if `p_val' <= 0.01 { 
			  replace `obj_var' = string(`point_est', "$strformat")+"***" if `row_id_var' == `row_num' 
			  } 
		   *replace `obj_var' = "<" + string(`point_sd', "$strformat") + ">" + " " if `row_id_var' == `row_num' + 1 
		   replace `obj_var' = string(`point_sd', "$strformat")  if `row_id_var' == `row_num' + 1 

		end 
		
************************************************
*LOAD DATA
************************************************

global path "C:\Users\npappoe\Dropbox\GEMS\Data\Original\EGRA_EGMA\Dta"

cd "$path"

use "QS_EgraEma_SchList.dta"

bys cmgcubed_code: drop if _n > 1 /* 0 observations deleted*/

*change the values of child_lang to make work easier
forvalues i = 1/23 {
	replace child_lang`i'="TRUE" if child_lang`i'=="True"
	replace child_lang`i'="FALSE" if child_lang`i'=="False"
	}
	
forvalues i = 1/23 {
	replace child_lang`i'="1" if child_lang`i'=="TRUE" 
	replace child_lang`i'="0" if child_lang`i'=="FALSE"
	replace child_lang`i'="" if child_lang`i'=="n/a"
	destring child_lang`i', replace
		}


gen twi = 1 if child_lang1==1 | child_lang2==1
replace twi = 0 if (child_lang1==0 & child_lang2==0) & twi ~=1
gen ewe = 1 if child_lang3==1
replace ewe = 0 if child_lang3==0 & ewe ~=1
gen dangme = child_lang6
replace dangme = 0 if child_lang6==0 & dangme ~=1
gen english = 1 if child_lang22==1
replace english = 0 if (child_lang22==0 | child_lang22==.) & english ~=1

gen likpakpa = 1 if child_lang18==1
replace likpakpa = 0 if (child_lang18==0 | child_lang18==.) & likpakpa ~=1

gen kotokoli = 1 if child_lang_spec == "Kotokoli"
replace kotokoli = 0 if kotokoli ~= 1

*create other language category with rest of languages
gen otherlang = 1 if (twi==0 & ewe==0 & dangme==0 & english==0 & likpakpa==0 & kotokoli==0)
replace otherlang = 0 if otherlang ~=1

*label variables
label define treatment 0 "Control" 1 "Treatment"
label value treatment treatment

foreach x of varlist twi ewe dangme english otherlang {
	label define `x' 0 "Not Spoken" 1 "Spoken"
	label value `x' `x'
}

foreach x of varlist mother_occup father_occup {
	label define `x' -99 "Refuses to Answer" -98 "Does not Know" 1 "Professional" 2 "Government" 3 "Agriculture" 4 "Production" 5 "Sales" 6 "Services" 7 "Homemaker" 8 "Unemployed" 9 "Other"
	label value `x' `x'
}

label define time_domestic_chores -99 "Refuses to answer" -98 "Does not know" 1 "Less than 5 minutes" 2 "15 min" 3 "30 min" 4 "60 min" 5 "90 min" 6 "more than 90 min"


drop if treatment==. /*948 observations deleted*/
	
	******************************************************************
	*Recode variables for analysis 
	******************************************************************
*I will use dummy variables for Table

*Religion
gen catholic = 0
replace catholic = 1 if child_religion == 1
gen presbyterian = 0 
replace presbyterian = 1 if child_religion == 3
gen pentacostalist = 0 
replace pentacostalist = 1 if child_religion == 5
gen charismatic = 0
replace charismatic = 1 if child_religion == 6
gen other_christian = 0
replace other_christian = 1 if child_religion == 8
gen muslim = 0
replace muslim = 1 if child_religion == 9
gen other_religion = 0
replace other_religion = 1 if child_religion == 2 | child_religion == 4 | child_religion == 7 | child_religion == 10 | child_religion == 11 | child_religion == 12

*Mother Occupation
 gen Professionalm = 1 if mother_occup==1
	 replace Professionalm = 0 if Professionalm ~=1 & mother_occup == .
	 gen Governmentm = 1 if mother_occup==2
	 replace Governmentm = 0 if Governmentm ~=1 & mother_occup == .
	 gen Agriculturem = 1 if mother_occup==3
	 replace Agriculturem = 0 if Agriculturem ~=1 & mother_occup == .
	 	 gen Productionm = 1 if mother_occup==4
	 replace Productionm = 0 if Productionm ~=1 & mother_occup == .
	 	 gen Salesm = 1 if mother_occup==5
	 replace Salesm = 0 if Salesm ~=1 & mother_occup == .
	 	 gen Servicesm = 1 if mother_occup==6
	 replace Servicesm = 0 if Servicesm ~=1 & mother_occup == .
	 	 gen Homemakerm = 1 if mother_occup==7
	 replace Homemakerm = 0 if Homemakerm ~=1 & mother_occup == .
	 	 gen Unemployedm = 1 if mother_occup==8
	 replace Unemployedm = 0 if Unemployedm ~=1 & mother_occup == .
	 	 gen Otherm = 1 if mother_occup==9
	 replace Otherm = 0 if Otherm ~=1 & mother_occup == .
	 
	 
*Father Occupation
 gen Professionalf = 1 if mother_occup==1
	 replace Professionalf = 0 if Professionalf ~=1 & mother_occup == .
	 gen Governmentf = 1 if mother_occup==2
	 replace Governmentf = 0 if Governmentf ~=1 & mother_occup == .
	 gen Agriculturef = 1 if mother_occup==3
	 replace Agriculturef = 0 if Agriculturef ~=1 & mother_occup == .
	 	 gen Productionf = 1 if mother_occup==4
	 replace Productionf = 0 if Productionf ~=1 & mother_occup == .
	 	 gen Salesf = 1 if mother_occup==5
	 replace Salesf = 0 if Salesf ~=1 & mother_occup == .
	 	 gen Servicesf = 1 if mother_occup==6
	 replace Servicesf = 0 if Servicesf ~=1 & mother_occup == .
	 	 gen Homemakerf = 1 if mother_occup==7
	 replace Homemakerf = 0 if Homemakerf ~=1 & mother_occup == .
	 	 gen Unemployedf = 1 if mother_occup==8
	 replace Unemployedf = 0 if Unemployedf ~=1 & mother_occup == .
	 	 gen Otherf = 1 if mother_occup==9
	 replace Otherf = 0 if Otherf ~=1 & mother_occup == .
	 
#delimit ;

global balancevars

twi
ewe
dangme
english
likpakpa
kotokoli
otherlang

catholic
presbyterian
pentacostalist
charismatic
other_christian
muslim
other_religion

Professionalm 
Governmentm 
Agriculturem 
Productionm 
Salesm 
Servicesm 
Homemakerm 
Unemployedm 
Otherm

Professionalf 
Governmentf 
Agriculturef 
Productionf 
Salesf 
Servicesf 
Homemakerf 
Unemployedf 
Otherf;

#delimit cr

*Make dummy variable coefficents into percentages for easier interpretation
	
	foreach x of global balancevars {
		replace `x'=`x'*100
		}
	
	
recode 	number_siblings 94=. 98=. 42=. -99=. -98=. -97=./* these answers do not make sense*/
recode  approx_time -99=. -98=.
recode  mother_hgrade -99=. -98=.
recode  father_hgrade -99=. -98=.
recode  time_domestic_chores -99=. -98=.
recode  tot_perm_hh_mem -99=. -98=. -97=. -95=. 120=. 99=. 98=. 75=.
recode  child_miss_sch -99=. -98=. -97=. -94=. -67=. -3=. 97=. 98=. 99=. 94=.

gen child_miss_school = child_miss_sch if (child_miss_sch <= 15 & child_miss_sch ~=.)
#delimit ;

global allbalancevars	
twi
ewe
dangme
english
likpakpa
kotokoli
otherlang

catholic
presbyterian
pentacostalist
charismatic
other_christian
muslim
other_religion

Professionalm 
Governmentm 
Agriculturem 
Productionm 
Salesm 
Servicesm 
Homemakerm 
Unemployedm 
Otherm

Professionalf 
Governmentf 
Agriculturef 
Productionf 
Salesf 
Servicesf 
Homemakerf 
Unemployedf 
Otherf

number_siblings
approx_time
mother_hgrade
father_hgrade
time_domestic_chores
tot_perm_hh_mem
child_age
child_miss_school

local_letter_sound 
local_invent_word 
local_oral_read  
local_read_comp 
local_list_comp 
total_oral_vocab_c 
total_letter_sound 
total_invent_word 
total_oral_read 
total_read_comp 
total_list_comp

total_num_id
total_quant_comp
total_miss_num 
total_miss_num_lang 
total_add 
total_we_add 
total_add_lvl2_lang 
total_sub 
total_we_sub 
total_sub_lvl2_lang 
total_word_prob
total_word_prob_lang;

#delimit cr

*check which ones exist

foreach x of global allbalancevars {
		cap confirm var `x'
		if _rc!=0 di "`var' does not exist"
		}

			
*****************************************
*Run the balance test regressions
*****************************************


	set more off 
	local row = 1 
	forvalues var = 0(1)3 { 
		cap drop col`var' 
	   qui gen col`var' = "" 
	   } 
	cap drop row_num 
	gen row_num=_n 


	
	set more off
	foreach x of global allbalancevars {
	
		qui replace col0 = "`x'" if row_num == `row' 
		
		qui summ `x'
		qui replace col1 = string(r(mean), "$strformat") if row_num == `row' 

		qui reg `x' treatment i.int_district , vce(cluster cmgcubed_schcode)  
		qui test treatment 
		qui balanceMGCubed col2 _b[treatment] _se[treatment] r(p) row_num `row' 

		local row = `row' + 2 
	}
	

	rename col0 Variables
	rename col1 Mean_Control_Group
	rename col2 Difference
	
	sort row_num 
	outsheet Variables Mean_Control_Group Difference using "C:\Users\npappoe\Dropbox\GEMS\Data\Final\BalanceTable.csv" if row_num < `row', comma replace

			
				
