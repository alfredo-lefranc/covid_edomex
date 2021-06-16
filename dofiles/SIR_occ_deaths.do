/***********************
Obtener series de decesos por fecha de ocurrencia para tres fechas de corte:
31 agosto
31 julio
30 junio

Copio el do file histograma
*/


clear 

*carpeta donde están los archivos en .csv
global raw "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\Mexico_data 1"
*carpeta de bases temporales

*carpeta de bases procesadas
global midata "C:\Users\fredy\Documents\itam\Investigacion\data"


// 31 agosto
import delimited "$raw\_31_agosto\200831COVID19MEXICO.csv"

// 31 julio
import delimited "$raw\_31_julio\200731COVID19MEXICO.csv"

// 30 junio
import delimited "$raw\_30_junio\200630COVID19MEXICO.csv"



gen dead=fecha_def!="9999-99-99"
keep if resultado==1
keep if dead==1

// dejo fechas en formato texto para que Python pueda leerlas
gen date=fecha_def
cd "$midata"


/*=======================================
CALCULEN PARA CADA ESTADO
EL NÚMERO DE DECESOS POR FECHA DE DEFUNCIÓN
=========================================*/

// 31 agosto
gen occ_deaths_ago=entidad_res==15
collapse (sum) occ_deaths_ago, by(date)
// formato de fecha para hacer merge con serie de fechas completa
gen fecha=date(date, "YMD")
label variable occ_deaths_ago "Decesos por fecha de ocurrencia, ago-31"
sort date
save occ_deaths_ago.dta, replace


// 31 julio
gen occ_deaths_jul=entidad_res==15
collapse (sum) occ_deaths_jul, by(date)
// formato de fecha para hacer merge con serie de fechas completa
gen fecha=date(date, "YMD")
label variable occ_deaths_jul "Decesos por fecha de ocurrencia, jul-31"
sort date
save occ_deaths_jul.dta, replace


// 30 junio
gen occ_deaths_jun=entidad_res==15
collapse (sum) occ_deaths_jun, by(date)
// formato de fecha para hacer merge con serie de fechas completa
gen fecha=date(date, "YMD")
label variable occ_deaths_jun "Decesos por fecha de ocurrencia, jun-30"
sort date
save occ_deaths_jun.dta, replace


/* PASO 2

puede que no tengan todas las fechas
*/
clear
set obs 250
gen n=_n
gen fecha=n+21980 // el primer dia debe ser 
drop n
sort fecha

// agosto
merge 1:1 fecha using "$midata\occ_deaths_ago.dta"
drop _merge

// julio
merge 1:1 fecha using "$midata\occ_deaths_jul.dta"
drop _merge

// jun
merge 1:1 fecha using "$midata\occ_deaths_jun.dta"
drop _merge

drop if fecha<21992
drop if fecha>22158

replace occ_deaths_jun = 0 if occ_deaths_jun==.
replace occ_deaths_jul = 0 if occ_deaths_jul==.
replace occ_deaths_ago = 0 if occ_deaths_ago==.

format fecha %tdYY-nn-dd

// exportarlo a formato csv
export delimited using "occ_deaths_cut", replace
