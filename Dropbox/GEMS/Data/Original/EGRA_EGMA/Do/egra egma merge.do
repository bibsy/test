/******************
Author: Naakorkoi Pappoe
Date: January 8, 2014
Last revision: January 22, 2013
Purpose: merge egra/egma data        
********************/


clear all
set more off
macro drop _all
capture log close

version 12.0
set more off

global path "C:\Users\npappoe\Dropbox\GEMS\Data"


* Chris
 *global path "C:\Users\cksoll\Dropbox\GEMS\Data"


cd "$path\Original\EGRA_EGMA\Dta"

*************************
* AKUAPEM-TWI
*************************
*check for duplicate ids
use EgraEgma_AKUAPEM-TWI_baseline_all_clean.dta

duplicates report pupil_id
*there are 4 duplicated pupil_id. Have to ask Joyce about this later
*drop for now
duplicates drop pupil_id, force

replace month="11" if month=="November"
destring month, replace

gen languagetest = 1

tempfile akuapentwi
save `akuapentwi', replace

**************************
* DANGME
**************************

use EgraEgma_DANGME_baseline_all_clean.dta

*for class variable there are 2,404 students not a signed to a class

duplicates report pupil_id
*there are duplicate ids. drop for now and ask Joyce about it later
duplicates drop pupil_id, force /*452 observations dropped*/

*destring variables
*variable year has value of 1 which might be a mistake.  Talk to Joyce about it later
*not sure how this year and schoolcode variable was created but I am not able to destring variable
sort year
*when I use replace command does not work so changed directly
destring year, g(year1) force
drop year
rename year1 year

*have to ask Joyce for school code
*since I will not use this variable in table I will replace as missing
replace schoolcode="" if schoolcode=="Joshua Kwenortey"
replace schoolcode="" if schoolcode=="Kadjanya-Dormeliam R/C School"
*destring still does not work
destring schoolcode, g(schoolcode1) force
tab schoolcode1
drop schoolcode
rename schoolcode1 schoolcode

destring class, replace

replace month="11" if month=="November" | month=="nov."
replace month="12" if month=="December"
destring month, replace

gen languagetest = 2

tempfile dangme
save `dangme', replace

********************
* EWE
********************

use EgraEgma_EWE_baseline_all_clean.dta

duplicates report pupil_id
*there are no duplicated observations

gen languagetest = 3

tempfile ewe
save `ewe', replace

use `akuapentwi'
append using `dangme'
append using `ewe'

save EgraEgma_append.dta, replace

sort pupil_id
listtab schoolcode schoolname pupil_id confirm_pup_id pupil_name grade using "information.xls", rstyle(tabdelim) replace

********************
* Create Variables *
********************

use EgraEgma_append.dta, clear

**************AKUEPEM-TWI

rename read_comp1_akuapemtwi read_comp_akuapemtwi1
rename read_comp2_akuapemtwi read_comp_akuapemtwi2
rename read_comp3_akuapemtwi read_comp_akuapemtwi3
rename read_comp4_akuapemtwi read_comp_akuapemtwi4
rename read_comp5_akuapemtwi read_comp_akuapemtwi5

rename list_comp1_akuapemtwi list_comp_akuapemtwi1
rename list_comp2_akuapemtwi list_comp_akuapemtwi2
rename list_comp3_akuapemtwi list_comp_akuapemtwi3

*create aggregate score for each quesetion

egen total_letter_sound_akuapemtwi = rowtotal(letter_sound_akuapemtwi1- letter_sound_akuapemtwi100), missing
egen total_invent_word_akuapemtwi = rowtotal(invent_word_akuapemtwi1- invent_word_akuapemtwi50), missing
egen total_oral_read_akuapemtwi = rowtotal(oral_read_akuapemtwi1- oral_read_akuapemtwi60), missing

foreach x of varlist read_comp_akuapemtwi* {
	replace `x'="" if `x'=="notAsked"
	destring `x', replace
	}
	
recode read_comp_akuapemtwi1- read_comp_akuapemtwi5 (3 = .)
	
egen total_read_comp_akuapemtwi = rowtotal(read_comp_akuapemtwi1- read_comp_akuapemtwi5), missing

recode list_comp_akuapemtwi1- list_comp_akuapemtwi3 (3 = .)

egen total_list_comp_akuapemtwi = rowtotal(list_comp_akuapemtwi1- list_comp_akuapemtwi3), missing


**********DANGME

rename read_comp1_dangme read_comp_dangme1
rename read_comp2_dangme read_comp_dangme2
rename read_comp3_dangme read_comp_dangme3
rename read_comp4_dangme read_comp_dangme4
rename read_comp5_dangme read_comp_dangme5

rename list_comp1_dangme list_comp_dangme1
rename list_comp2_dangme list_comp_dangme2
rename list_comp3_dangme list_comp_dangme3

*create aggregate score for each quesetion

egen total_letter_sound_dangme = rowtotal(letter_sound_dangme1- letter_sound_dangme100), missing
egen total_invent_word_dangme = rowtotal(invent_word_dangme1- invent_word_dangme50), missing
egen total_oral_read_dangme = rowtotal(oral_read_dangme1- oral_read_dangme65), missing

foreach x of varlist read_comp_dangme* {
	replace `x'="" if `x'=="notAsked"
	destring `x', replace
	}
	
recode read_comp_dangme1- read_comp_dangme5 (3 = .)
	
egen total_read_comp_dangme = rowtotal(read_comp_dangme1- read_comp_dangme5), missing

recode list_comp_dangme1- list_comp_dangme3 (3 = .)

egen total_list_comp_dangme = rowtotal(list_comp_dangme1- list_comp_dangme3), missing

*************EWE

rename read_comp1_ewe read_comp_ewe1
rename read_comp2_ewe read_comp_ewe2
rename read_comp3_ewe read_comp_ewe3
rename read_comp4_ewe read_comp_ewe4
rename read_comp5_ewe read_comp_ewe5

rename list_comp1_ewe list_comp_ewe1
rename list_comp2_ewe list_comp_ewe2
rename list_comp3_ewe list_comp_ewe3

*create aggregate score for each quesetion

egen total_letter_sound_ewe = rowtotal(letter_sound_ewe1- letter_sound_ewe100), missing
egen total_invent_word_ewe = rowtotal(invent_word_ewe1- invent_word_ewe50), missing
egen total_oral_read_ewe = rowtotal(oral_read_ewe1- oral_read_ewe59), missing

foreach x of varlist read_comp_ewe* {
	replace `x'="" if `x'=="notAsked"
	destring `x', replace
	}
	
recode read_comp_ewe1- read_comp_ewe5 (3 = .)
	
egen total_read_comp_ewe = rowtotal(read_comp_ewe1- read_comp_ewe5), missing

recode list_comp_ewe1- list_comp_ewe3 (3 = .)

egen total_list_comp_ewe = rowtotal(list_comp_ewe1- list_comp_ewe3), missing

**************LOCAL LANGUAGE

/*
total_letter_sound_akuapemtwi 
total_invent_word_akuapemtwi 
total_oral_read_akuapemtwi 
total_read_comp_akuapemtwi 
total_list_comp_akuapemtwi

total_letter_sound_dangme
total_invent_word_dangme 
total_oral_read_dangme 
total_read_comp_dangme 
total_list_comp_dangme 

total_letter_sound_ewe 
total_invent_word_ewe 
total_oral_read_ewe 
total_read_comp_ewe 
total_list_comp_ewe 
*/

gen letter_sound_aku = 100
gen invent_word_aku = 50
gen oral_read_aku = 60
gen read_comp_aku = 5
gen list_comp_aku = 3

gen letter_sound_dan = 100
gen invent_word_dan = 50
gen oral_read_dan = 65
gen read_comp_dan = 5
gen list_comp_dan = 3

gen letter_sound_ewe = 100
gen invent_word_ewe = 50
gen oral_read_ewe = 60
gen read_comp_ewe = 5
gen list_comp_ewe = 3

gen toral_vocab_c = 8
gen tletter_sound = 100
gen tinvent_word = 50
gen toral_read = 60
gen tread_comp = 5
gen tlist_comp = 3

recode oral_vocab_c_1- oral_vocab_c_8 (999 = .)
recode oral_vocab_c_5- oral_vocab_c_8 (1 = 0) (2 = 1) 

forval i=1/5 {
	replace read_comp`i'="" if read_comp`i'=="notAsked"
	destring read_comp`i', replace
	}
	
recode read_comp1- read_comp5 (3 = .)

recode list_comp1- list_comp3 (3 = .)

sort pupil_id

egen local_letter_sound = rowtotal(total_letter_sound_akuapemtwi total_letter_sound_dangme total_letter_sound_ewe)
egen local_invent_word = rowtotal(total_invent_word_akuapemtwi total_invent_word_dangme total_invent_word_ewe)
egen local_oral_read = rowtotal(total_oral_read_akuapemtwi total_oral_read_dangme total_oral_read_ewe) 
egen local_read_comp = rowtotal(total_read_comp_akuapemtwi total_read_comp_dangme total_read_comp_ewe)
egen local_list_comp = rowtotal(total_list_comp_akuapemtwi total_list_comp_dangme total_list_comp_ewe)
egen total_oral_vocab_c = rowtotal(oral_vocab_c_1 - oral_vocab_c_8)
egen total_letter_sound = rowtotal(letter_sound1- letter_sound100)
egen total_invent_word = rowtotal(invent_word1- invent_word50)
egen total_oral_read = rowtotal(oral_read1- oral_read60)
egen total_read_comp = rowtotal(read_comp1- read_comp5)
egen total_list_comp = rowtotal(list_comp1- list_comp3)

destring grade, g(grade_clean) force

gen p_letter_soundl = (local_letter_sound/letter_sound_aku)*100
gen p_invent_wordl = (local_invent_word/invent_word_aku)*100
gen p_oral_readl = (local_oral_read/oral_read_aku)*100 if languagetest == 1
replace p_oral_readl = (local_oral_read/oral_read_dan)*100 if languagetest == 2
replace p_oral_readl = (local_oral_read/oral_read_ewe)*100 if languagetest == 3
gen p_read_compl = (local_read_comp/read_comp_aku)*100
gen p_list_compl = (local_list_comp/list_comp_aku)*100
gen p_oral_vocab_c = (total_oral_vocab_c/toral_vocab_c)*100
gen p_letter_sound = (total_letter_sound/tletter_sound)*100
gen p_invent_word = (total_invent_word/tinvent_word)*100
gen p_oral_read =  (total_oral_read/toral_read)*100
gen p_read_comp = (total_read_comp/tread_comp)*100
gen p_list_comp = (total_list_comp/tlist_comp)*100


*create variable for class and gender

gen class_gender1 = 0 if grade_clean == 1 & female == 0
replace class_gender1 = 1 if grade_clean == 1 & female == 1

gen class_gender2 = 0 if grade_clean == 2 & female == 0
replace class_gender2 = 1 if grade_clean == 2 & female == 1

gen class_gender3 = 0 if grade_clean == 3 & female == 0
replace class_gender3 = 1 if grade_clean == 3 & female == 1

gen class_gender4 = 0 if grade_clean == 4 & female == 0
replace class_gender4 = 1 if grade_clean == 4 & female == 1

gen class_gender5 = 0 if grade_clean == 5 & female == 0
replace class_gender5 = 1 if grade_clean == 5 & female == 1

gen class_gender6 = 0 if grade_clean == 6 & female == 1
replace class_gender6 = 1 if grade_clean == 6 & female == 0

gen class_gender7 = 0 if grade_clean == 7 & female == 1
replace class_gender7 = 1 if grade_clean == 7 & female == 0

gen class_gender8 = 0 if grade_clean == 8 & female == 1
replace class_gender8 = 1 if grade_clean == 8 & female == 0


***************
*   TABLES    *
***************

tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender1)  statistics(p10) save nototal
	tabstatmat A
	matrix TAB1 = A'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender1) statistics(p25) save nototal
	tabstatmat B
	matrix TAB2 = B'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender1) statistics(p50) save nototal
	tabstatmat C
	matrix TAB3 = C'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender1) statistics(p75) save nototal
	tabstatmat D
	matrix TAB4 = D'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender1) statistics(p90) save nototal
	tabstatmat E
	matrix TAB5 = E'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender2)  statistics(p10) save nototal
	tabstatmat A1
	matrix TAB6 = A1'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender2) statistics(p25) save nototal
	tabstatmat B1
	matrix TAB7 = B1'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender2) statistics(p50) save nototal
	tabstatmat C1
	matrix TAB8 = C1'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender2) statistics(p75) save nototal
	tabstatmat D1
	matrix TAB9 = D1'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender2) statistics(p90) save nototal
	tabstatmat E1
	matrix TAB10 = E1'
	tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender3)  statistics(p10) save nototal
	tabstatmat A2
	matrix TAB11 = A2'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender3) statistics(p25) save nototal
	tabstatmat B2
	matrix TAB12 = B2'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender3) statistics(p50) save nototal
	tabstatmat C2
	matrix TAB13 = C2'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender3) statistics(p75) save nototal
	tabstatmat D2
	matrix TAB14 = D2'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender3) statistics(p90) save nototal
	tabstatmat E2
	matrix TAB15 = E2'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender4)  statistics(p10) save nototal
	tabstatmat A3
	matrix TAB16 = A3'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender4) statistics(p25) save nototal
	tabstatmat B3
	matrix TAB17 = B3'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender4) statistics(p50) save nototal
	tabstatmat C3
	matrix TAB18 = C3'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender4) statistics(p75) save nototal
	tabstatmat D3
	matrix TAB19 = D3'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender4) statistics(p90) save nototal
	tabstatmat E3
	matrix TAB20 = E3'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender5)  statistics(p10) save nototal
	tabstatmat A4
	matrix TAB21 = A4'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender5) statistics(p25) save nototal
	tabstatmat B4
	matrix TAB22 = B4'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender5) statistics(p50) save nototal
	tabstatmat C4
	matrix TAB23 = C4'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender5) statistics(p75) save nototal
	tabstatmat D4
	matrix TAB24 = D4'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender5) statistics(p90) save nototal
	tabstatmat E4
	matrix TAB25 = E4'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender6)  statistics(p10) save nototal
	tabstatmat A5
	matrix TAB26 = A5'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender6) statistics(p25) save nototal
	tabstatmat B5
	matrix TAB27 = B5'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender6) statistics(p50) save nototal
	tabstatmat C5
	matrix TAB28 = C5'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender6) statistics(p75) save nototal
	tabstatmat D5
	matrix TAB29 = D5'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender6) statistics(p90) save nototal
	tabstatmat E5
	matrix TAB30 = E5'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender7)  statistics(p10) save nototal
	tabstatmat A6
	matrix TAB31 = A6'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender7) statistics(p25) save nototal
	tabstatmat B6
	matrix TAB32 = B6'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender7) statistics(p50) save nototal
	tabstatmat C6
	matrix TAB33 = C6'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender7) statistics(p75) save nototal
	tabstatmat D6
	matrix TAB34 = D6'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender7) statistics(p90) save nototal
	tabstatmat E6
	matrix TAB35 = E6'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender8)  statistics(p10) save nototal
	tabstatmat A7
	matrix TAB36 = A7'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender8) statistics(p25) save nototal
	tabstatmat B7
	matrix TAB37 = B7'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender8) statistics(p50) save nototal
	tabstatmat C7
	matrix TAB38 = C7'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender8) statistics(p75) save nototal
	tabstatmat D7
	matrix TAB39 = D7'
tabstat p_letter_soundl p_invent_wordl p_oral_readl p_read_compl p_list_compl p_oral_vocab_c p_letter_sound p_invent_word p_oral_read p_read_comp p_list_comp, by(class_gender8) statistics(p90) save nototal
	tabstatmat E7
	matrix TAB40 = E7'
	xml_tab TAB1 TAB2 TAB3 TAB4 TAB5 TAB6 TAB7 TAB8 TAB9 TAB10 TAB11 TAB12 TAB13 TAB14 TAB15 TAB16 TAB17 TAB18 TAB19 TAB20 TAB21 TAB22 TAB23 TAB24 TAB25 TAB26 TAB27 TAB28 TAB29 TAB30 TAB31 TAB32 TAB33 TAB34 TAB35 TAB36 TAB37 TAB38 TAB39 TAB40, ///
	rname("Letter Sound" "Invent Word" "Oral Reading" "Reading Comprehension" "Listening Comprehension" "Oral Vocabulary" "Letter Sound" "Invent Word" "Oral Reading" "Reading Comprehension" "Listening Comprehension") ///
	format((s2110 s2101 s2101 s2101 s2101 s2101 s2101 s2101 s2101 s2101 s2101),(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201)) ///
	rblanks(COL_NAMES "EGRA - Local Language " s2210, p_oral_vocab_c "EGRA - English" s2210) ///
	title("EGRA by Class and Gender (%)") notes("NOTE: Maximum score obtainable on EGRA test is 444: Letter Sound (100) Invent Word (50) Oral Reading (60) Reading Comprehension (5) Listening Comprehension (3) Oral Vocabulary (8)") cblanks(10 20 30 40 50 60 70) ///
	save("../Tables/EGRA_EGMA.xls") replace sheet(EGRA)
	
	label define CLASS 1 "Grade 1" 2 "Grade 2"	3 "Grade 3" 4 "Grade 4" 5 "Grade 5" 6 "Grade 6" 7 "Grade 7 level" 8 "Grade 8 level"
		label values class CLASS

*	local varlist "local_letter_sound local_invent_word local_oral_read local_read_comp local_list_comp total_oral_vocab_c total_letter_sound total_invent_word total_oral_read total_read_comp total_list_comp"
	local varlist2 "local_letter_sound local_invent_word local_oral_read total_letter_sound total_invent_word total_oral_read"
*	local pvarlist2 "p_letter_soundl p_invent_wordl p_oral_readl p_letter_sound p_invent_word p_oral_read"

	tabstat `varlist2', by(class)
	tabstat `varlist2' if district==22, by(class)

	label define female1 0 "Male" 1 "Female"
	label values female female1
	
	destring grade, replace
	
	tab female grade 
	
**************************
* AKUAPEMTWI EGMA        *
**************************

********************
* Create Variables *
********************

use EgraEgma_append.dta, clear

egen total_num_id = rowtotal(num_id1 - num_id20)

recode quant_comp1-quant_comp10 (999=.)
egen total_quant_comp = rowtotal(quant_comp1 - quant_comp10)

recode miss_num1-miss_num10 (999=.)
egen total_miss_num = rowtotal(miss_num1 - miss_num10)

egen total_miss_num_lang = rowtotal(miss_num_lang_1 - miss_num_lang_99)

egen total_add = rowtotal(add1 - add20)

recode we_add1-we_add5 (999=.)
egen total_we_add = rowtotal(we_add1 - we_add5)

egen total_add_lvl2_lang = rowtotal(add_lvl2_lang_1 - add_lvl2_lang_99)

egen total_sub = rowtotal(sub1 - sub20)

recode we_sub1-we_sub5 (999=.)
egen total_we_sub = rowtotal(we_sub1 - we_sub5)

egen total_sub_lvl2_lang = rowtotal(sub_lvl2_lang_1 - sub_lvl2_lang_99)

recode word_prob1-word_prob6 (999=.)
egen total_word_prob = rowtotal(word_prob1 - word_prob6)

egen total_word_prob_lang = rowtotal(word_prob_lang_1 - word_prob_lang_99)

gen num_idt = 20
gen quant_compt = 10
gen miss_numt = 10
gen miss_num_langt = 12 if languagetest == 1 | languagetest == 3
gen addt = 20
gen we_addt = 5
gen add_lvl2_langt = 12
gen subt = 20
gen we_subt = 5
gen sub_lvl2_langt = 12
gen word_probt = 6
gen word_prob_langt = 12

gen p_num_id = (total_num_id/num_idt)*100
gen p_quant_comp = (total_quant_comp/quant_compt)*100
gen p_miss_num = (total_miss_num/miss_numt)*100
gen p_miss_num_lang = (total_miss_num_lang/miss_num_langt)*100
gen p_add = (total_add/addt)*100
gen p_we_add = (total_we_add/we_addt)*100
gen p_add_lvl2_lang = (total_add_lvl2_lang/add_lvl2_langt)*100
gen p_sub = (total_sub/subt)*100
gen p_we_sub = (total_we_sub/we_subt)*100
gen p_sub_lvl2_lang = (total_sub_lvl2_lang/sub_lvl2_langt)*100
gen p_word_prob = (total_word_prob/word_probt)*100
gen p_word_prob_lang = (total_word_prob_lang/word_prob_langt)*100



* short version of EGMA
local varlistp "p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang"
local varlist "total_num_id total_quant_comp total_miss_num total_miss_num_lang total_add total_we_add total_add_lvl2_lang total_sub total_we_sub total_sub_lvl2_lang total_word_prob total_word_prob_lang"

egen totalEGMA = rowtotal(`varlist')

su `varlist' totalEGMA
	*tabstat `varlist' totalEGMA, by(class)
	*tabstat `varlist' totalEGMA if district==22, by(class)

		tabstat totalEGMA, by(class)
	tabstat totalEGMA if district==22, by(class)


destring grade, g(grade_clean) force

*create variable for class and gender

gen class_gender1 = 0 if grade_clean == 1 & female == 0
replace class_gender1 = 1 if grade_clean == 1 & female == 1

gen class_gender2 = 0 if grade_clean == 2 & female == 0
replace class_gender2 = 1 if grade_clean == 2 & female == 1

gen class_gender3 = 0 if grade_clean == 3 & female == 0
replace class_gender3 = 1 if grade_clean == 3 & female == 1

gen class_gender4 = 0 if grade_clean == 4 & female == 0
replace class_gender4 = 1 if grade_clean == 4 & female == 1

gen class_gender5 = 0 if grade_clean == 5 & female == 0
replace class_gender5 = 1 if grade_clean == 5 & female == 1

gen class_gender6 = 0 if grade_clean == 6 & female == 1
replace class_gender6 = 1 if grade_clean == 6 & female == 0

gen class_gender7 = 0 if grade_clean == 7 & female == 1
replace class_gender7 = 1 if grade_clean == 7 & female == 0

gen class_gender8 = 0 if grade_clean == 8 & female == 1
replace class_gender8 = 1 if grade_clean == 8 & female == 0




***************
*   TABLES    *
***************

tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender1)  statistics(p10) save nototal
	tabstatmat A
	matrix TAB1 = A'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender1) statistics(p25) save nototal
	tabstatmat B
	matrix TAB2 = B'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender1) statistics(p50) save nototal
	tabstatmat C
	matrix TAB3 = C'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender1) statistics(p75) save nototal
	tabstatmat D
	matrix TAB4 = D'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender1) statistics(p90) save nototal
	tabstatmat E
	matrix TAB5 = E'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender2)  statistics(p10) save nototal
	tabstatmat A1
	matrix TAB6 = A1'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender2) statistics(p25) save nototal
	tabstatmat B1
	matrix TAB7 = B1'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender2) statistics(p50) save nototal
	tabstatmat C1
	matrix TAB8 = C1'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender2) statistics(p75) save nototal
	tabstatmat D1
	matrix TAB9 = D1'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender2) statistics(p90) save nototal
	tabstatmat E1
	matrix TAB10 = E1'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender3)  statistics(p10) save nototal
	tabstatmat A2
	matrix TAB11 = A2'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender3) statistics(p25) save nototal
	tabstatmat B2
	matrix TAB12 = B2'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender3) statistics(p50) save nototal
	tabstatmat C2
	matrix TAB13 = C2'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender3) statistics(p75) save nototal
	tabstatmat D2
	matrix TAB14 = D2'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender3) statistics(p90) save nototal
	tabstatmat E2
	matrix TAB15 = E2'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender4)  statistics(p10) save nototal
	tabstatmat A3
	matrix TAB16 = A3'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender4) statistics(p25) save nototal
	tabstatmat B3
	matrix TAB17 = B3'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender4) statistics(p50) save nototal
	tabstatmat C3
	matrix TAB18 = C3'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender4) statistics(p75) save nototal
	tabstatmat D3
	matrix TAB19 = D3'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender4) statistics(p90) save nototal
	tabstatmat E3
	matrix TAB20 = E3'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender5)  statistics(p10) save nototal
	tabstatmat A4
	matrix TAB21 = A4'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender5) statistics(p25) save nototal
	tabstatmat B4
	matrix TAB22 = B4'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender5) statistics(p50) save nototal
	tabstatmat C4
	matrix TAB23 = C4'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender5) statistics(p75) save nototal
	tabstatmat D4
	matrix TAB24 = D4'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender5) statistics(p90) save nototal
	tabstatmat E4
	matrix TAB25 = E4'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender6)  statistics(p10) save nototal
	tabstatmat A5
	matrix TAB26 = A5'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender6) statistics(p25) save nototal
	tabstatmat B5
	matrix TAB27 = B5'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender6) statistics(p50) save nototal
	tabstatmat C5
	matrix TAB28 = C5'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender6) statistics(p75) save nototal
	tabstatmat D5
	matrix TAB29 = D5'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender6) statistics(p90) save nototal
	tabstatmat E5
	matrix TAB30 = E5'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender7)  statistics(p10) save nototal
	tabstatmat A6
	matrix TAB31 = A6'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender7) statistics(p25) save nototal
	tabstatmat B6
	matrix TAB32 = B6'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender7) statistics(p50) save nototal
	tabstatmat C6
	matrix TAB33 = C6'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender7) statistics(p75) save nototal
	tabstatmat D6
	matrix TAB34 = D6'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender7) statistics(p90) save nototal
	tabstatmat E6
	matrix TAB35 = E6'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender8)  statistics(p10) save nototal
	tabstatmat A7
	matrix TAB36 = A7'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender8) statistics(p25) save nototal
	tabstatmat B7
	matrix TAB37 = B7'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender8) statistics(p50) save nototal
	tabstatmat C7
	matrix TAB38 = C7'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender8) statistics(p75) save nototal
	tabstatmat D7
	matrix TAB39 = D7'
tabstat p_num_id p_quant_comp p_miss_num p_miss_num_lang p_add p_we_add p_add_lvl2_lang p_sub p_we_sub p_sub_lvl2_lang p_word_prob p_word_prob_lang, by(class_gender8) statistics(p90) save nototal
	tabstatmat E7
	matrix TAB40 = E7'
	xml_tab TAB1 TAB2 TAB3 TAB4 TAB5 TAB6 TAB7 TAB8 TAB9 TAB10 TAB11 TAB12 TAB13 TAB14 TAB15 TAB16 TAB17 TAB18 TAB19 TAB20 TAB21 TAB22 TAB23 TAB24 TAB25 TAB26 TAB27 TAB28 TAB29 TAB30 TAB31 TAB32 TAB33 TAB34 TAB35 TAB36 TAB37 TAB38 TAB39 TAB40, ///
	rname("Number Identification" "Number Discrimination" "Missing Number" "Missing Number - Local Language" "Addition" "We Add" "Add - Level 2" "Subtraction" "We Subtract" "Subtraction - Level 2" "Word Prolem" "Word Problem - Local Language") ///
	format((s2110 s2101 s2101 s2101 s2101 s2101 s2101 s2101 s2101 s2101 s2101 s2101),(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), ///
	(s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201), (s2110 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201 n2201)) ///
	rblanks(COL_NAMES "General" s2210, p_miss_num_lang "Addition " s2210, p_sub "Subtraction" s2210, p_sub_lvl2_lang "Word Problems" s2210) ///
	title("EGMA by Class and Gender (%)") notes("NOTE: Maximum score obtainable on EGMA test is 150: Number Identification (20) Number Discrimination (10) Missing Number (10) Missing Number - Local Language (12) Addition(20) We Add (5) Add - Level 2 (12) Subtraction(20) We Subtract (5) Subtraction - Level 2 (12) Word Prolem (6) Word Problem - Local Language (12)") cblanks(10 20 30 40 50 60) ///
	save("../Tables/EGRA_EGMA.xls") append sheet(EGMA)








