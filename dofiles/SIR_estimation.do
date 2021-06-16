/*=========================================

DOFILE PARA MODELO SIR. 

generar base con casos y decesos por fecha de reporte y fecha de ocurrencia

==============================================*/


clear 

*carpeta donde están los archivos en .csv
global raw "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\Mexico_data 1"
*carpeta de bases temporales

*carpeta de bases procesadas
global midata "C:\Users\fredy\Documents\itam\Investigacion\data"



import delimited "$raw\_30_septiembre\200930COVID19MEXICO.csv"

keep if fecha_ingreso!="9999-99-99"
keep if resultado==1

gen cases=(entidad_res==15)
gen date=date(fecha_ingreso, "YMD")
collapse (sum) cases, by(date)

cd "$midata"
save confirmed_cases.dta, replace


clear



// creo todas las fechas 
set obs 200
gen n=_n
gen date=n+22024 // empezamos en el segundo dia de la base. evitamos tope a la izq
drop n

sort date

merge 1:1 date using "$midata\muertes_ocurridas.dta"
drop _merge

sort date
merge 1:1 date using "$midata\muertes_reportadas.dta"
drop _merge

sort date
merge 1:1 date using "$midata\confirmed_cases.dta"
drop _merge

sort date
for varlist occ* rep* cases: replace X=0 if X==.


* acotar fechas
gen date1 = date
format date %tdYY-nn-dd

// un día después de que empezara a reportarse la base
drop if date1 > 22188
// hasta 30 sept

* formato como el de Tiago que vimos en Python para que haga match

keep date occ_deaths_metro rep_deaths_metro cases
rename occ_deaths_metro deaths_occurred
rename rep_deaths_metro deaths_reported


export delimited using "$midata\deaths_sir", replace
* --------------------------------------------------------------