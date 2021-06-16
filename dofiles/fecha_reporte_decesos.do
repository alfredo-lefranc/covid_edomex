


/*======================================

EN ESTE DOFILE,
IDENTIFICAMOS LA PRIMERA FECHA EN QUE 
APARECIÓ REPORTADO CADA DECESO

LOS PASOS QUE SEGUIMOS SON:

1. GENERAR (Y GUARDAR) 
UNA BASE DE DATOS EN STATA 
PARA CADA REPORTE, QUE SOLO INCLUYA LOS 
DECESOS CONFIRMADOS EN ESA FECHA 
(PARA TRABAJAR CON UNA BASE MÁS PEQUEÑA)


ESTE PROCEDIMIENTO SE HIZO POR ULTIMA VEZ EL 24 DE OCT, CON TODAS LAS BASES HASTA EL 4 DE OCTUBRE, ULTIMA FECHA ANTES DEL CAMBIO DE METODOLOGIA. PARA ACTUALIZAR, MODIFICAR EL LOOP DEL PASO 1 Y 2

2. HACER UN "APPEND" DE TODAS
LAS BASES DE DECESOS REPORTADOS
DIARIAS, Y, PARA CADA REGISTRO,
IDENTIFICAR LA PRIMERA FECHA EN QUE 
APARECIÓ


========================================*/

*carpeta donde están los datos en csv
global raw "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\Mexico_data 1"
*carpeta donde guardamos bases temporales
global temp "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\avances-estudiantes\Alfredo Lefranc - EdoMex\temp"
*carpeta dondde guardamos las bases procesadas
global midata "C:\Users\fredy\Documents\itam\Investigacion\data"



*PASO 1. GENERAR BASES DE DECESOS EN STATA


/*
*EJEMPLO
*USAR MAYO COMO EJEMPLO PARA QUE NO PESE TANTO...

clear
import delimited "$raw\_8_septiembre\200908COVID19MEXICO.csv"
gen dead=fecha_def!="9999-99-99"
keep if dead==1
gen reportdate=date( fecha_actualizacion,"YMD")
keep id_registro reportdate

sum reportdate
local d=r(mean)

save "$temp\reportdate_`d'.dta"
*/


*LOOP. QUEREMOS REPETIR ESTOS COMANDOS PARA TODAS LAS BASES DE DATOS QUE TENEMOS...


*definir locals para meses
forval m=4(1)9 {
	if `m'==4 {
		local mes="abril"
	}
	else if `m'==5 {
		local mes="mayo"
	}
	else if `m'==6 {
		local mes="junio"
	}
	else if `m'==7 {
		local mes="julio"
	}
	else if `m'==8 {
		local mes="agosto"
	}
	else if `m'==9 {
		local mes="septiembre"
	}
	
	
*definir locals para el primer dia del mes
	if `m'==4 {
		local firstday=19
	}

	else {
		local firstday=1
	}

*definir locals para el ultimo día del mes
	if `m'==4|`m'==6|`m'==9|`m'==11 {
		local lastday=30
	}
	else {
		local lastday=31
	}
	
	forval k1=`firstday'(1)`lastday' {
		if `k1'<10 {
			local k="0`k1'"
		}
		else if `k1'>=10 {
			local k="`k1'"
		}

	clear
	import delimited "$raw\_`k1'_`mes'\200`m'`k'COVID19MEXICO.csv"
	gen dead=fecha_def!="9999-99-99"
	keep if dead==1
	gen reportdate=date(fecha_actualizacion,"YMD")
	keep id_registro reportdate

	sum reportdate
	local d=r(mean)

	save "$temp\reportdate_`d'.dta", replace

	}
}


*LOOP PARA ACTUALIZAR 14-30 DE SEPTIEMBRE
*(11 al 14 ya estaba con este mismo loop de antes)

*definir locals para meses
local m   = 9
local mes = "septiembre"

*definir locals para el primer dia del mes
local firstday=14

*definir locals para el ultimo día del mes
local lastday=30

	
forval k1=`firstday'(1)`lastday' {
	if `k1'<10 {
		local k="0`k1'"
	}
	else if `k1'>=10 {
		local k="`k1'"
	}

	clear
	import delimited "$raw\_`k1'_`mes'\200`m'`k'COVID19MEXICO.csv"
	gen dead=fecha_def!="9999-99-99"
	keep if dead==1
	gen reportdate=date(fecha_actualizacion,"YMD")
	keep id_registro reportdate

	sum reportdate
	local d=r(mean)

	save "$temp\reportdate_`d'.dta", replace

}




*LOOP PARA ACTUALIZAR 4 OCTUBRE

*definir locals para meses
local m   = 10
local mes = "octubre"

*definir locals para el primer dia del mes
local firstday=1

*definir locals para el ultimo día del mes
local lastday=4

	
forval k1=`firstday'(1)`lastday' {
	if `k1'<10 {
		local k="0`k1'"
	}
	else if `k1'>=10 {
		local k="`k1'"
	}

	clear
	import delimited "$raw\_`k1'_`mes'\20`m'`k'COVID19MEXICO.csv"
	gen dead=fecha_def!="9999-99-99"
	keep if dead==1
	gen reportdate=date(fecha_actualizacion,"YMD")
	keep id_registro reportdate

	sum reportdate
	local d=r(mean)

	save "$temp\reportdate_`d'.dta", replace

}




*PASO 2. APPEND PARA IDENTIFICAR PRIMERA FECHA DE REPORTE

/*La explicación simple es que si pudiéramos
appendear TODas estas bases, si nos quedamos con la observación
de cada deceso con la menor fecha de reporte
tenemos ya la base con, para cada deceso en la última base,
la fecha en que fue reportado por primera vez*/
clear


forvalues x=22024(1)22192 {
	append using "$temp\reportdate_`x'.dta"
}

sort id_registro reportdate
	bysort id_registro: gen n=_n
		keep if n==1

	keep id_registro reportdate

sort id_registro

drop if reportdate==. // 3 obs deleted

save "$midata\reportdate_all.dta", replace
