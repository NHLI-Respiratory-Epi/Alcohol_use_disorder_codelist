/*******************************************************************************
	CPRD Medical Code Browser Searching
	23/09/2020	ELA // Updated by Sarah Cook for Alcohol Use Disorder on 09.01.2023
*******************************************************************************/
/*
General running instructions:
	- Make sure you have the indatesave.ado in your personal ado folder
		(if not change to normal save command)
	- Insert your search terms as shown
		- You may want to create one search ter m local for each "category"
			e.g.	searchterms1 --> all apply to ILD
					searchterms2 --> all apply to CF
			At end of each search you have to option to rename the searchterm#
				variables that have been created based on these categories
	- Final local before markers indicates the number of search term locals,
		make sure you replace with the final number
	
	PART 1
	- Code between the markers should not need to be changed as it conducts the
		search using the generic 'searchterms#' locals
		FIRST LOOP: makes descriptions lower case
		SECOND LOOP: Searches for terms contained in the 'searchterm#' locals
		THIRD LOOP: Cuts dataset to only include those terms found in the search
		
	*** Run from first search term local to 'compress' at once,
		so that the locals apply to the loops ***
		
	PART 2
	- Remove irrelevant codes.
	
	PART 3
	- Remerge with SNOMED CT Concept IDs to find any relevant codes that may
	  have been missed.
	
	
	PART 4
	- Compare with previous lists
	
	PART 5
	- Generate .tag file
*/
/*******************************************************************************
	1) Searching CPRD Aurum Medical Browser
*******************************************************************************/
clear all
set more off
macro drop _all


//Enter directory you want to save files in
cd "Z:\Group_work\Sarah\Diabetes and alcohol use disorder\Codelists\Alcohol use disorder\"

//Enter name of do file here
local filename "alcohol_use_disorder"


//Open log file
capture log close
log using `filename', text replace


//Directory of medical dictionary
local browser_dir "Z:\Database guidelines and info\CPRD\CPRD_CodeBrowser_202202_Aurum"

//Directory of label lookups
local lookup_dir "Z:\Database guidelines and info\CPRD\CPRD_Latest_Lookups_Linkages_Denominators\Aurum_Lookups_Feb_2022"


//Import latest medical browser; force medcodeid, SnomedCT to be string
import delimited "`browser_dir'\CPRDAurumMedical.txt", stringcols(1 5 6)

//Drop (currently) unused variables
drop release

//label EMIS code category - **requires cprdlabel ado file**
*cprdlabel emiscodecategoryid, lookup(EMISCodeCat) location(`lookup_dir')

//Save medical code browser to a tempfile
tempfile medical
save `medical'


*Insert your search terms as shown below, do NOT change local names, name any additional grouping of search terms in the same format as shown (searchterms#)
/*These searchterms are taken from Search terms from collat_codelist01v2_SNOMED_ETOH used for project Covid Collateral https://doi.org/10.1016/S2589-7500(21)00017-0 https://github.com/johntaz/COVID-Collateral */

local searchterm1 " "*alcohol*" "

local searchterm2 "`searchterm1' "*intoxication*" "

local searchterm3 "`searchterm1' "*withdrawal*" "

local searchterm4 "`searchterm1' "*delirium tremens*" "

local searchterm6 "`searchterm1' "*drunken*" "

local searchterm7 "`searchterm1' "*hangover*" "

local searchterm8 "`searchterm1' "*acute pancreatitis*" "

local searchterm9 "`searchterm1' "*varices*" "

local searchterm10 "`searchterm1' "*wernicke*" "*korsakoff*" "

/*additional search terms added for alcohol use disorder*/
local searchterm11 " "*alcoholic*" "
local searchterm12 " "*drink*" "
local searchterm13 " "*alcohol dependence*" "
local searchterm14 " "*alcohol use disorder*" "
local searchterm15 " "*harmful alcohol use*" "


*Replace number with total number of locals for search terms
local n = 15

*************************************************************
** You shouldn't need to change code between these markers **
*************************************************************
*Search all search terms in descriptions
forvalues i = 1/`n'{
	
	foreach termgroup in searchterm`i' {
		
		gen byte `termgroup' = .
		
		foreach codeterm in lower(term) {
			
			foreach searchterm in ``termgroup'' {
				
				replace `termgroup' = 1 if strmatch(`codeterm', "`searchterm'")
			}
		}
	}
}

*Limit data to those terms that were found
gen foundterm = .

forvalues i = 1/`n'	{
	
	replace foundterm = 1 if searchterm`i' == 1
}

keep if foundterm == 1
drop foundterm
compress
*************************************************************
** You shouldn't need to change code between these markers **
*************************************************************


drop searchterm1-searchterm15


/*

*************************************************************
//2.) Remove any irrelevant codes
*************************************************************

//exclusion terms were not needed as the search terms only brought up relevant codes which should be considered for the codelist*/
/*use exclusion terms from previous search do file from Kate Mansfield collat_codelist01v2_SNOMED_ETOH*/

local exterm " "*family history*" "*fh:*" "

local exterm " `exterm' "*leukaemia*" "*polio*" "*vaccin*" "

local exterm " `exterm' "*bacterial food-borne intoxication*" "

local exterm " `exterm' "*dislocation*" "*genital*" "*perineal*" "*vulval*" "

local exterm " `exterm' "*vaginal*" "*jump/push*" "*wool*" "*navy*" "

local exterm " `exterm' "*blood tube*" "*jobst*" "*pelvic*" "*stargardt*" "

local exterm " `exterm' "*nicotine*" "*newborn*" "*midtarsal*" "

local exterm " `exterm' "*maternal*" "*foodborne*" "*pulmonary*" "

local exterm " `exterm' "*tar distillate*" "*ramstedt*" "*oophoritis*" "

local exterm " `exterm' "*foley*" "*fetal*" "*gerhardt*" "

local exterm " `exterm' "*brandt*" "*caffeine*" "*creutzfeldt*" "*gdth iib*" "

local exterm " `exterm' "*testes*" "*testis*" "*bernhardt*" "

local exterm " `exterm' "dtic" "*dtpa *" "

local exterm " `exterm' "*cows *" "*hypertension,*" "

local exterm " `exterm' "*vioxxacute*" "*nicotinyl alcohol*" "*polyvinyl alcohol*" "

local exterm " `exterm' "*coal tar*" "*durogesic*" "*isopropyl alcohol*" "

local exterm " `exterm' "*uriplan*" "*bard dt*" "*oleyl alcohol*" "

local exterm " `exterm' "*act-hib*" "*lanolin alcohol*" "*cetostearyl alcohol*" "

local exterm " `exterm' "*cetyl alcohol*" "*stearyl alcohol*" "*psychoactive substance-induced*" "

local exterm " `exterm' "*blood glucose*" "*pepcidtwo*" "*tdt cells*" "

local exterm " `exterm' "*dichlorobenzyl alcohol*" "* dtp *" "*booster dt*" "

local exterm " `exterm' "*rhinitis*" "social withdrawal" "*benzyl alcohol*" "

local exterm " `exterm' "*sarstedt*" "*contraception*" "*edta gel tube*" "

local exterm " `exterm' "*dt (double)*" "*ndtms - problem substance*" "*opiate withdrawal*" "

local exterm " `exterm' "*new hiv*" "*adfciedtf*" "*auscdtfour*" "*auscdtone*" "*dtwing*" "

local exterm " `exterm' "*hqdtw*" "*jwdtc*" "*sub suprvn rqurmt cndtn rsdce*" "

local exterm " `exterm' "*red blood cell distribution*" "*dta hscic*" "

local exterm " `exterm' "*eolcc record*" "*child witness*" "pericardial effusion*" "

local exterm " `exterm' "*blood withdrawal*" "*bladder gonorrhea*" "*dementia with delirium*" "

local exterm " `exterm' "*wood alcohol*" "*bornyl alcohol*" "*scrotal varices*" "

local exterm " `exterm' "*ddt toxicity*" "*platelet distribution width*" " 

local exterm " `exterm' "*[x]delirium, not induced by alcohol+other psychoactive subs*" "

local exterm " `exterm' "*schmidt*" "*heredtry nephrpthy*" "*narcotic withdrawal*" "

local exterm " `exterm' "*amyl alcohol*" "

local exterm " `exterm' "*[x]oth acute+subacute resp condtns/chemical,gas,fume+vapours*" "

local exterm " `exterm' "*[x]oth iodine-deficncy relatd thyroid disordr+allied condtns*" "

local exterm " `exterm' "*fatty alcohol-nicotinamide adenine dinucleotide *" "

local exterm " `exterm' "*gasserian ganglion*" "

local exterm " `exterm' "*accidental poisoning caused by ddt*" "

local exterm " `exterm' "*phenyl*ethyl alcohol*" "*dt immunisation*" "*dt immunization*" "

local exterm " `exterm' "*schuchardt*" "*senile delirium*" "*drug induced delirium*" "

local exterm " `exterm' "*dragstedt*" "*foetal*" "*fetus*" "edta *" "*edta" "*subacute delirium*" "

local exterm " `exterm' "*foetus*" "*methyl alcohol*" "*antritis*" "

local exterm " `exterm' "*denatured alcohol*" "*rubbing alcohol*" "*non-alcoholic*" "

local exterm " `exterm' "*nonalcoholic*" "*photodynamic therapy*" "*coryza*" "

local exterm " `exterm' "*dacryocystitis*" "*deep transverse arrest*" "*dtp20003 - hgv/publ.serv.claim*" "

local exterm " `exterm' "*aortic root width*" "*nasal catarrh*" "*clostridium botulinum*" "

local exterm " `exterm' "*neonatal*" "*iritis*" "*dtap/ipv*" "ndtms*" "

local exterm " `exterm' "*phenethyl alcohol*" "*bladder gonorrhoea*" "*butyl alcohol*" "

local exterm " `exterm' "*propyl alcohol*" "*dtic-dome*" "*knodt spinal*" "

/*plus additional exclusion terms from manually browsing the list*/

local exterm " `exterm' "*vaccination*" "*vaccine*" "*polio*" "*diptheria*" "

//Search for codes to exclude
foreach excludeterm in exclude /**/exterms/**/ {

	gen byte `excludeterm' = .

	foreach codeterm in lower(term) {
		
		foreach searchterm in ``excludeterm'' {		
			
			replace `excludeterm' = 1 if strmatch(`codeterm', "`searchterm'")
		}
	}
}

//Check that nothing important is highlighted for exclusion before dropping
list term if exterm == 1


drop if exterm == 1 ///

count
compress
		

		
		
//3.) Remerge SNOMED CT Concept IDs to find any missed codes
//===========================================================

//check for missing SNOMED CT Concepts
codebook snomedctconceptid
assert !missing(snomedctconceptid)

count

//make a note of current list
preserve

keep medcodeid 
gen byte original = 1
tempfile original
save `original'

restore

//merge SNOMED concepts with medical dictionary
keep snomedctconceptid
bysort snomedctconceptid: keep if _n == 1

merge 1:m snomedctconceptid using `medical', nogenerate keep(match)
merge 1:1 medcodeid using `original', nogenerate
compress
order snomedctconceptid, before(snomedctdescriptionid)

count

//show new codes
list term originalreadcode snomedctconceptid if original != 1

//check new codes in the context of originally included SNOMED CT Concept ID codes
preserve

drop if original == 1
keep snomedctconceptid
bysort snomedctconceptid: keep if _n == 1

count
local obs = r(N)

forvalues i = 1/`obs' {
	
	if `i' == 1 {
		
		local expanded_ids = snomedctconceptid in `i'
	}
	else {
		
		local expanded_ids = "`expanded_ids' " + snomedctconceptid in `i'
	}
}

restore

foreach expanded_id of local expanded_ids {
	
	display "SNOMED CT Concept ID for which additional terms where found: `expanded_id'"
	
	list medcodeid term originalreadcode if snomedctconceptid == "`expanded_id'"
}

/*additional codes added*/



//4.) Compare with previous list(s) and add missing codes
//==================================


//compare with previous codelists

/*1) previous codelist produced by the same search terms used in Covid collateral*/
merge 1:1 medcodeid using  "Z:\Group_work\Sarah\Diabetes and alcohol use disorder\Codelists\Alcohol Use Disorder\From others\aurum_alc_alcohol.dta" , force

rename _merge covid_collateral
/*51 additional codes added from using*/

/*2) Codelist for any alcohol use code from Herrett, E, Cook, S, Mansfield, KE, Crellin, E, Smeeth, L, Quint, JK and Denholm, R (2019). Code lists for "Completeness and validity of alcohol recording in general practice within the UK: a cross-sectional study". [Project]. London School of Hygiene & Tropical Medicine, London, United Kingdom. https://doi.org/10.17037/data.00001071.
This is from GOLD therefore uses READ code*/
merge m:1 cleansedreadcode using  "Z:\Group_work\Sarah\Diabetes and alcohol use disorder\Codelists\Alcohol Use Disorder\From others\any_alcohol_code.dta" , force

/*261 matched codes, 37 additional codes- read code only*/

rename _merge alcohol_project_Herrett

/*drop codes with no medcodeid as GOLD only*/
drop if medcodeid==""

/*generate variables*/

gen alcohol_variable_sc=.
label define alcohol_variable_sc 1"AUD diagnosis" 2"alcohol withdrawal" 3"alcohol-related harm" 4"management of alcohol use" 5" AUD-related e.g symptom but not diagnosis" 6"drinking status" 7"drinking level" 8"AUDIT or AUDIT-C" 9"FAST" 10"other screening tool" 11"alcohol poisoning/intoxication" 97"Not alcohol related" 98"not clear" 99"code used less than 10 times" 

label values alcohol_variable_sc alcohol_variable_sc

replace alcohol_variable_sc=99 if observations<10

gen alcohol_variable_sc_2=.
label define alcohol_variable_sc_2 1"AUD diagnosis" 2"alcohol withdrawal" 3"alcohol-related harm physical" 4"alcohol-related harm mental" 5"management of alcohol use" 6" AUD-related e.g symptom but not diagnosis" 7"drinking status"  8"AUDIT or AUDIT-C" 9"other screening tool" 10"alcohol poisoning/intoxication" 97"Not alcohol related" 98"not clear" 99"code used less than 10 times" 





//5.) Generate tag file
//======================

//= Update details here, everything else is automated ==========================
local description "Alcohol Use Disorder"
local author "Sarah Cook"
local date "January 2023"
local code_type "SNOMED CT"
local database "CPRD Aurum"
local database_version "February 2022"
local keywords "Alcohol use disorder"
local notes "Codelist for SCook project "Type 2 Diabetes and Alcohol Use Disorder" Categories 1,2,3 & 4 were classed as AUD"
local date_JKQ_approved "All codes in this codelist were independently reviewed by team of 5 GPs (100-200 codes each) and consensus on disagreeing codes reached by discussion with at least 3 of the coding team - process completed October 2023" 
//==============================================================================

clear
gen v1 = ""
set obs 9

replace v1 = "`description'" in 1
replace v1 = "`author'" in 2
replace v1 = "`date'" in 3
replace v1 = "`code_type'" in 4
replace v1 = "`database'" in 5
replace v1 = "`database_version'" in 6
replace v1 = "`keywords'" in 7
replace v1 = "`notes'" in 8
replace v1 = "`date_JKQ_approved'" in 9

export delimited "`filename'.tag", replace novarnames delimiter(tab)


use "`filename'", clear  //so that you can see results of search after do file run


log close

*/