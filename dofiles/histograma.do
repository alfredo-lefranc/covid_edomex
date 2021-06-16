/*=========================================

ESTE DOFILE
ASIGNAMOS FECHA DE REPORTE A CADA DECESO

HACER HISTOGRAMAS

COLAPSAMOS LA INFORMACIÓN A NIVEL MUNICIPAL
Y POR FECHA PARA PODER HACER MAPAS Y GRÁFICAS
ADICIONALES

==============================================*/
clear 

*carpeta donde están los archivos en .csv
global raw "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\Mexico_data 1"
*carpeta de bases temporales

*carpeta de bases procesadas
global midata "C:\Users\fredy\Documents\itam\Investigacion\data"

*carpeta de imágenes
*ESTA SÍ ESPECIFIQUEN SU CARPETA DENTRO DE LA CARPETA DE LA CLASE
global graphs "C:\Users\fredy\Documents\itam\Investigacion\descstats"

*carpeta de mapas
*global shape "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\shapefiles"


* merge de las fechas de reporte de decesos con decesos de la ultima base disponible

** CAMBIAR FECHA DEL ARCHIVO **
import delimited "$raw\_4_octubre\201004COVID19MEXICO.csv"

gen dead=fecha_def!="9999-99-99"
keep if resultado==1
keep if dead==1
sort id_registro
merge 1:1 id_registro using "$midata\reportdate_all.dta"
drop if _merge==2

* OJO. SE PIERDEN COMO 20 MIL OBSERVACIONES DE muertes que no tienen covid.

gen deaddate=date(fecha_def, "YMD")
gen retraso=reportdate-deaddate
replace retraso=0 if retraso<0

gen retraso_30=retraso
replace retraso_30=30 if retraso>30
label variable retraso_30 "Días de retraso"
twoway (hist retraso_30 if reportdate>22025, percent discrete bcolor(red%30)) ///
(hist retraso_30 if reportdate>22025 & entidad_res==15, percent discrete bcolor(black%30)), ///
xlabel(0 "0" 10 "10" 20 "20" 30 ">30") ///
ytitle(Porcentaje)  legend(order(1 "México" 2 "Estado de México")) ///
title("Retrasos en reportes de decesos por Covid-19")

cd "$graphs"

graph export retrasos_poredo.tif, replace

/* este es el que pidió alejandro fajardo de la distribución para retrasos mayores a 30

label variable retraso "Días de retraso"
twoway (hist retraso if reportdate>22025 & retraso>30, ///
	percent discrete bcolor(red%30)) ///
	(hist retraso if reportdate>22025  & retraso>30 & entidad_res==15, ///
	percent discrete bcolor(black%30)), ///
	ytitle(Porcentaje)  legend(order(1 "México" 2 "Estado de México")) ///
	title("Retrasos mayores a un mes")

graph export retrasos30_poredo.tif, replace

*/

* idea: del porcentaje de retrasos fuertes (mayores a 30), cuantos son en el EdoMex
label var retraso "Días de retraso"
twoway (hist retraso if reportdate>22025 & retraso>30, ///
	frequency discrete bcolor(red%30)) ///
	(hist retraso if reportdate>22025  & retraso>30 & entidad_res==15, ///
	frequency discrete bcolor(black%30)), ///
	xlabel(30(30)150) ///
	ytitle(Frecuencia)  legend(order(1 "México" 2 "Estado de México")) ///
	title("Frecuencia de retrasos mayores a un mes")
	
graph export retrasos30_freq.tif, replace	




/* misma grafica, retrasos mayores a 90
twoway (hist retraso if reportdate>22025 & retraso>100, ///
	frequency discrete bcolor(red%30)) ///
	(hist retraso if reportdate>22025  & retraso>100 & entidad_res==15, ///
	frequency discrete bcolor(black%30)), ///
	ytitle(Frecuencia)  legend(order(1 "México" 2 "Estado de México")) ///
	title("Frecuencia de retrasos mayores a 3 meses")

graph export retrasos90_poredo.tif, replace


*este es para hospitalizados y ambulatorios

twoway (hist retraso_30 if reportdate>22025 & tipo_paciente==1, ///
	percent discrete bcolor(red%30)) ///
	(hist retraso_30 if reportdate>22025 & entidad_res==15  & ///
	tipo_paciente==2, percent discrete bcolor(black%30)), ///
	ytitle(Porcentaje)  legend(order(1 "Ambulatorio" 2 "Hospitalizado"))

// muy parecido
*/


/*========================================
CALCULAR RETRASOS PROMEDIO POR 
MUNICIPIO
==========================================*/
preserve

collapse (mean) retraso retraso_30, by(entidad_res municipio_res)
gen statemun=entidad_res*1000+municipio_res

keep statemun retraso retraso_30
sort statemun

save "$midata\mean_delays.dta", replace


restore

/*=======================================
CALCULEN PARA CADA ESTADO
EL NÚMERO DE DECESOS POR FECHA
1. DE DEFUNCIÓN
2. DE REPORTE
EL CHISTE ES PODER COMPARAR LA
CURVA EPIDÉMICA DE SU ESTADO
CUANDO LA HACEMOS POR FECHA DE REPORTE
O POR FECHA DE DEFUNCIÓN
=========================================*/

*POR FECHA DE DEFUNCIÓN

preserve

*muertes
gen occ_deaths=1
*muertes en mi estado
gen occ_deaths_metro=entidad_res==15

collapse (sum) occ_deaths occ_deaths_metro, by(deaddate)

keep deaddate occ_deaths occ_deaths_metro

label variable occ_deaths "Decesos por fecha de ocurrencia (México)"
label variable occ_deaths_metro "Decesos por fecha de ocurrencia (Estado de México)"

rename deaddate date

sort date
cd "$midata"
save muertes_ocurridas.dta, replace

restore


*POR FECHA DE REPORTE

preserve

*muertes
gen rep_deaths=1
*muertes en mi estado
gen rep_deaths_metro=(entidad_res==15)

collapse (sum) rep_deaths rep_deaths_metro, by(reportdate)

keep reportdate rep_deaths rep_deaths_metro

label variable rep_deaths "Decesos por fecha de reporte (México)"
label variable rep_deaths_metro "Decesos por fecha de reporte (Estado de México)"

rename reportdate date

sort date
cd "$midata"
save muertes_reportadas.dta, replace

restore


* DECESOS POR ESTADO
preserve

gen statemun=entidad_res*1000+municipio_res
collapse (sum) dead, by(statemun)

keep dead statemun

label var dead "Decesos confirmados"

sort statemun
cd "$midata"
save muertes_por_mun.dta, replace

restore

