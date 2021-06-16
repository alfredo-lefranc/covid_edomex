clear

/*======================================

En este do file se exploran discrepancias entre los decesos de covid-19 por fecha
de ocurrencia contra los decesos por fecha de reporte. Esto se realiza por día y por 
semana epidemiológica.

======================================*/


* carpeta de graficas
global graphs "C:\Users\fredy\Documents\itam\Investigacion\descstats"

*carpeta de bases procesadas
global midata "C:\Users\fredy\Documents\itam\Investigacion\data"

cd "$graphs"


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

for varlist occ* rep*: replace X=0 if X==.
drop if date>= 22193	
* pendiente: cambiar formato fechas a semanas
* semana epidemiológica 35: 23 al 29 de agosto
format date %tdnn/dd/YY



twoway (bar occ_deaths date, bcolor(red%30)) ///
	(bar rep_deaths date, bcolor(black%30)) if date>22024, ///
	note("A", size(* 1.2) position(12)) ///
	legend(off) ytitle(Decesos) ///
	title(Panel A: México) xtitle(Fecha) ///
	ylabel(0 "0" 400 "400" 800 "800")
graph save "$graphs\curva_pais.gph", replace 
graph export "$graphs\curva_pais.tif", replace

twoway (bar occ_deaths_metro date, bcolor(red%30)) ///
	(bar rep_deaths_metro date, bcolor(black%30)) if date>22024, ///
	note("B", size(* 1.2) position(12)) ///
	ylabel(0 "0" 200 "200" 600 "600") ///
	title(Panel B: Estado de México) xtitle(Fecha) ///
	legend(order(1 "Por fecha de ocurrencia" 2 "Por fecha de reporte"))
graph save "$graphs\curva_edo.gph", replace 
graph export "$graphs\curva_edo.tif", replace

graph combine "$graphs\curva_pais.gph" "$graphs\curva_edo.gph", ///
plotregion(color(white)) ///
graphregion(margin(zero)) ///
col(1) row(2) iscale(* 1.15) 
graph export "$graphs\curvas_pais_edo_day.tif", as(tif) replace



// curvas por semana epidemiológica

* fecha por semana epidemiológica (35 = 23 al 29 de agosto)
gen week= wofd(date)
format week %tw

scalar dif = week[157]-35
gen epiweek=week- dif
la var epiweek "Semana epidemiológica"

* curva epidemica por semana epidemiológica
collapse (sum) occ_* rep_*, by(epiweek)



twoway (bar occ_deaths epiweek, bcolor(red%30)) ///
	(bar rep_deaths epiweek, bcolor(black%30)) if epiweek>16, ///
	note("A", size(* 1.2) position(12)) ///
	legend(off) ytitle(Decesos) ///
	ylabel(0 "0" 2000 "2000" 4000 "4000")
graph save "$graphs\curva_weeks_pais.gph", replace 
graph export "$graphs\curva_weeks_pais.tif", replace


twoway (bar occ_deaths_metro epiweek, bcolor(red%30)) ///
	(bar rep_deaths_metro epiweek, bcolor(black%30)) if epiweek>16, ///
	xtitle(Semana epidemiológica) ytitle(Decesos) ///
	note("B", size(* 1.2) position(12)) ///
	ylabel(0 "0" 500 "500" 1500 "1500") ///
	legend(order(1 "Por fecha de ocurrencia" 2 "Por fecha de reporte"))
graph save "$graphs\curva_weeks_edo.gph", replace
graph export "$graphs\curva_weeks_edo.tif", replace

graph combine "$graphs\curva_weeks_pais.gph" "$graphs\curva_weeks_edo.gph", ///
plotregion(color(white)) ///
graphregion(margin(zero)) ///
col(1) row(2) iscale(* 1.15) ///
title("Curva epidémica en México y el Estado de México", size(* 0.7)) 
graph export "$graphs\curvas_pais_edo.tif", as(tif) replace




