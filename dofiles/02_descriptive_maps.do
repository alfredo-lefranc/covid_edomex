clear


/*===================================================

ESTE DO-FILE GENERA MAPAS CON
LA DISTRIBUCIÓN GEOGRÁFICA (POR MUNICIPIO)
DE LOS CASOS Y DECESOS POR COVID 

=====================================================*/

set scheme s1color

*aquí llamamos a las rutas donde están los archivos

global main "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\Mexico_data 1"
global shape "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\shapefiles"
global graphs "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\avances-estudiantes\Emilio-Ejemplo\graphs"
global micpu "C:\Users\fredy\Documents\itam\Investigacion\descstats"


/*=================================================
Primero calculamos las medidas de lo que
queremos mapear para cada municipio

==================================================*/

*esta es la base de datos correspondiente al 1 de septiembre
import delimited "$main\_4_octubre\201004COVID19MEXICO.csv"

*casos
gen covid=resultado==1

*decesos
gen deceso=(fecha_def!="9999-99-99" & covid==1)


*sumamos casos y decesos dentro de cada municipio
collapse (sum) covid deceso, by(entidad_res municipio_res)
drop if municipio_res==999
gen statemun=entidad_res*1000+municipio_res

sort statemun

save "$micpu\casos_decesos_mpio.dta", replace

/*=================================================
CREAMOS Y LLAMAMOS AL MAPA DE MUNICIPIOS
==================================================*/

*ESTOS SON LOS PROGRAMAS QUE TIENEN QUE INSTALAR EN STATA PARA PODER HACER MAPAS
*ssc install spmap
*ssc install shp2dta

cd "$shape\"

shp2dta using national_municipal, data(munsmex) coor(coordmuns) genid(id) replace


/*================================================
LLAMAMOS AL MAPA EN FORMATO STATA
==================================================*/
clear
use munsmex.dta, clear
destring CVEGEO, gen(statemun) force

sort statemun
merge 1:1 statemun using $micpu\casos_decesos_mpio.dta

drop if _merge==2
drop _merge

gen edo=floor(statemun/1000)
replace covid=0 if covid==.
*spmap covid using coordmuns, id(id)
*spmap covid using coordmuns, id(id) clmethod(custom) clbreaks(0 50 100 1000 2500 5000 7500 10000 20000)

// creamos tasa de letalidad (decesos/casos positivos) y mortalidad (decesos/poblacion)
sum POB1 if entidad_res==15
gen let= (deceso/covid)*100
gen mort= (deceso/POB1)*100000
la var let "Tasa de letalidad %"
la var mort "Decesos por cada 100,000 habitantes"

// tasas de contagio: casos positivos por cada 100,000 habitantes
gen tasa_contagio = (covid/POB1)*100000
la var tasa_contagio "Casos positivos por cada 100,000 habitantes"
order OID id entidad_res municipio_res covid deceso ///
edo let mort tasa_contagio, before(POB1)
la var POB1 "poblacion por municipio"

/*================================================
MAPAS MUNICIPALES
==================================================*/


/* casos estado
spmap covid using coordmuns if edo==15, id(id) ///
clmethod(custom) clbreaks(0 50 100 1000 2500 5000 7500 10000)  ///
legtitle("Casos confirmados") legend(size(vsmall)) legorder(lohi) ///
legend(position(5)) fcolor(Greens) ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin) 
graph save "$micpu\casos_estado.gph",  replace 
*/

//decesos estado
spmap deceso using coordmuns if edo==15, id(id) clmethod(custom) clbreaks(0 5 10 100 250 500 750 1000 2000) ///
legtitle("") legend(size(vsmall)) legorder(lohi) legend(position(5)) fcolor(Greens) ///
note("B", size(* 1.2) position(6)) ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin)
graph save "$micpu\decesos_estado.gph",  replace 

/*
//decesos estado con titulo
spmap deceso using coordmuns if edo==15, id(id) ///
clmethod(custom) clbreaks(0 5 10 100 250 500 750 1000 2000) ///
legtitle("Decesos confirmados") legend(size(vsmall)) legorder(lohi) ///
legend(position(5)) title("Estado de Mexico") fcolor(Greens) ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin)
graph save "$micpu\decesos_estado_con_tit.gph",  replace 
*/

// letalidad estado
*sum let if edo==15
spmap let using coordmuns if edo==15, id(id) ///
clmethod(custom) ///
clbreaks(0 4 8 12 16 20 24 28 32) ///
legtitle("% de decesos por contagios") legend(size(vsmall)) legorder(lohi) ///
legend(position(5)) fcolor(Greens) ///
note("A", size(* 1.2) position(6)) ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin)
graph save "$micpu\letalidad_estado.gph",  replace 


// mortalidad estado
sum mort if edo==15
spmap mort using coordmuns if edo==15, id(id) ///
clmethod(custom) ///
clbreaks(0 15 30 45 60 90 150 300 600) ///
legtitle("Decesos por cada 100,000 hab.") legend(size(vsmall)) ///
legorder(lohi) ///
legend(position(5)) fcolor(Greens) ///
note("B", size(* 1.2) position(6)) ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin)
graph save "$micpu\mortalidad_estado.gph",  replace 

/*
// tasa de contagios estado
*sum tasa_contagio
spmap tasa_contagio using coordmuns if edo==15, id(id) ///
clmethod(custom) ///
clbreaks(0 150 300 450 600 750 1000 2500) ///
legtitle("Casos por cada 100,000 habitantes") legend(size(vsmall)) /// 
legorder(lohi) ///
legend(position(5)) title("Tasa de contagios") fcolor(Greens) ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin)
graph save "$micpu\tasa_contagio_estado.gph",  replace 


// casos mexico, absoluto
spmap covid using coordmuns, id(id) clmethod(custom) ///
clbreaks(0 50 100 1000 2500 5000 7500 10000 20000) ///
legend(off) title("México") fcolor(Greens) ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)
graph save "$micpu\mexico_casos.gph", replace 


// decesos mexico, absoluto
spmap deceso using coordmuns, id(id) clmethod(custom) clbreaks(0 5 10 100 250 500 750 1000 2000)  legend(off) title("México") fcolor(Greens) ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)
graph save "$micpu\mexico_decesos.gph", replace 

*/

/*================================================
MAPAS ESTATALES
==================================================*/

* primero generamos la informacion a nivel estatal
bysort NOM_ENT: egen covid_ent=total(covid)
la var covid_ent "Casos positivos niv. estatal"
bysort NOM_ENT: egen deceso_ent=total(deceso)
la var deceso_ent "Decesos confirmados niv. estatal"

table NOM_ENT, contents(mean covid_ent mean deceso_ent) // control

/*
// casos mexico, absoluto
spmap covid_ent using coordmuns, id(id)  clnumber(8) ///
legend(position(7)) title("México") fcolor(Greens) ///
legtitle("Casos confirmados") legend(size(small)) legorder(lohi) ///
osize(vvthin vvvthin vvvthin vvvthin vvvthin vvvthin vvvthin vvvthin vvvthin)
graph save "$micpu\mexico__est_casos.gph", replace 

// decesos mexico, absoluto
spmap deceso_ent using coordmuns, id(id)  clnumber(8) ///
legend(position(7)) fcolor(Greens) ///
legtitle("Decesos confirmados") legend(size(small)) legorder(lohi) ///
note("A", size(* 1.2) position(6)) ///
osize(vvthin vvvthin vvvthin vvvthin vvvthin vvvthin vvvthin vvvthin vvvthin)
graph save "$micpu\mexico_est_decesos.gph", replace 
*/

// decesos mexico, absoluto
spmap deceso_ent using coordmuns, id(id) ///
clmethod(custom) ///
clbreaks(0 1000 1500 2000 2500 3000 4000 5000 12000) ///
legend(position(7)) fcolor(Greens) ///
legtitle("Decesos confirmados") legend(size(small)) legorder(lohi) ///
note("A", size(* 1.2) position(6)) ///
osize(vvthin vvvthin vvvthin vvvthin vvvthin vvvthin vvvthin vvvthin vvvthin)
graph save "$micpu\mexico_est_decesos.gph", replace 


/*================================================
COMBINAR MAPAS
==================================================*/


// grafica decesos mexico vs estado
graph combine "$micpu\mexico_est_decesos.gph" "$micpu\decesos_estado.gph", plotregion(color(white)) ///
graphregion(margin(zero)) ///
col(1) row(2) ysize(5) iscale(* 0.75) ///
title("Decesos confirmados en México y el Estado de México", size(* 0.7)) 
graph export "$micpu\decesos_pais_edo.tif", as(tif) replace


// grafica estado, casos y decesos
graph combine "$micpu\casos_estado.gph" "$micpu\decesos_estado.gph", plotregion(color(white)) title("Estado de México")
graph export "$micpu\map2.tif", as(tif) replace

// grafica estado, letalidad y mortalidad
graph combine "$micpu\letalidad_estado.gph" "$micpu\mortalidad_estado.gph", ///
plotregion(color(white)) ///
graphregion(margin(zero)) ///
iscale(* 0.9) ///
title("Tasas de letalidad y mortalidad en el Estado de México", size(* 0.7))
graph export "$micpu\letvsmort_estado.tif", as(tif) replace




