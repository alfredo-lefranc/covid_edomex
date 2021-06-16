clear

/*======================================

En este do file se generan mapas con los retrasos en reportes de decesos
por covid-19 en los estados de México y en los municipios del Estado de México.

======================================*/



*carpeta para guardar mapas
global graphs "C:\Users\fredy\Documents\itam\Investigacion\descstats"

* carpeta shapefiles
global shape "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\shapefiles"

*carpeta de bases procesadas
global midata "C:\Users\fredy\Documents\itam\Investigacion\data"

cd "$shape"



/*================================================
LLAMAMOS AL MAPA EN FORMATO STATA
==================================================*/
clear
use munsmex.dta
cap drop _merge
destring CVEGEO, gen(statemun)
gen entidad_res=floor(statemun/1000)
sort statemun
merge 1:1 statemun using "$midata\mean_delays.dta"

keep if _merge==3
drop _merge

order id entidad_res retraso retraso_30 CVEGEO

merge 1:1 statemun using "$midata\muertes_por_mun.dta"
keep if _merge==3

order dead CVEGEO



/*================================================
MAPAS
==================================================*/

* retrasos en el pais
spmap retraso_30 using coordmuns, id(id) ///
clmethod(custom) clbreaks(0 3 5 10 15 30) ///
legtitle("Retrasos promedio") legend(size(vsmall)) ///
legorder(lohi) legend(position(7)) fcolor(Greens) ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin) title("Mexico")

graph save "$graphs\mapdelays_tot.gph", replace

* retrasos hasta 1 mes en el Edomex
spmap retraso_30 using coordmuns if entidad_res==15, id(id) ///
clmethod(custom) clbreaks(0 3 5 10 15 30) fcolor(Greens) legend(position(4)) ///
legtitle("Días de retraso") legend(size(vsmall)) legorder(lohi) ///
osize(vthin vthin vthin vthin vthin vthin) title("Estado de México")
*graph save "$graphs\mapdelays_edo.gph", replace
graph export "$graphs\mapdelays_edo.tif", as(tif) replace


* Retrasos sin restricciones en el edomex
spmap retraso using coordmuns if entidad_res==15, id(id) ///
clmethod(custom) clbreaks(0 5 10 15 20 25 30 35) ///
fcolor(Greens) legend(position(4)) ///
legtitle("Días de retraso") legend(size(vsmall)) legorder(lohi) ///
osize(vthin vthin vthin vthin vthin vthin) ///
title("Retrasos promedio en el Estado de México")
graph export "$graphs\mapdelays_edo2.tif", as(tif) replace


/*
graph combine "$graphs\mapdelays_tot.gph" "$graphs\mapdelays_edo.gph", plotregion(color(white))
graph export "$graphs\mapdelays.tif", as(tif) replace
*/


