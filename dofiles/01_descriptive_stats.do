clear

/*======================================

En este do file se generan estadísticas descriptivas de los casos y decesos 
por covid-19 en el Estado de México y se contrastan con los del país.

======================================*/






/*======================================

DEFINIR RUTAS DE ARCHIVOS Y DONDE 
VAMOS A GUARDAR LOS RESULTADOS

======================================*/

global main "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\Mexico_data 1"

global graphs "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\avances-estudiantes\Emilio-Ejemplo\graphs"

global tables "D:\Data\Covid\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\avances-estudiantes\Emilio-Ejemplo\tables"

global micpu "C:\Users\fredy\Documents\itam\Investigacion"




*AQUÍ LLAMAMOS A LA BASE DE DATOS MÁS RECIENTE (1 DE SEPTIEMBRE)

import delimited "$main\_4_octubre\201004COVID19MEXICO.csv"


*identificamos a los pacientes con covid
gen covid=resultado==1
label variable covid "Con prueba confirmatoria de COVID-19"

*identificamos a los pacientes que fallecieron
gen deceso=fecha_def!="9999-99-99"
label variable deceso "Con fecha de defuncion registrada"


/*=======================================

CONSTRUIR INDICADORAS DE CARACTERÍSTICAS
OBSERVABLES

========================================*/

* indicador edomex
gen edomex=entidad_res==15
label var edomex "Estado de Mexico=0"

*sexo
gen mujer=sexo==1
label variable mujer "Mujer"


*lengua indigena
gen indigena=habla_lengua_indig==1
label variable indigena "Habla una lengua indigena"


*grupos de edad
gen menora10=edad<=10
gen edad11_20=edad>10 & edad<=20
gen edad21_30=edad>20 & edad<=30
gen edad31_40=edad>30 & edad<=40
gen edad41_50=edad>40 & edad<=50
gen edad51_60=edad>50 & edad<=60
gen edad61_70=edad>60 & edad<=70
gen edad71_80=edad>70 & edad<=80
gen edad81_plus=edad>80 

label variable menora10 "Menor a 11"
label variable edad11_20 "Entre 11 y 20"
label variable edad21_30 "Entre 21 y 30"
label variable edad31_40 "Entre 31 y 40"
label variable edad41_50 "Entre 41 y 50"
label variable edad51_60 "Entre 51 y 60"
label variable edad61_70 "Entre 61 y 70"
label variable edad71_80 "Entre 71 y 80"
label variable edad81_plus "Mayor a 81"


*comorbilidades

gen obeso=obesidad==1
label variable obeso "Obesidad"

gen diab=diabetes==1
label variable diab "Diabetes"

gen fuma=tabaquismo==1
label variable fuma "Tabaquismo"

gen enfisema=epoc==1
label variable enfisema "EPOC"

gen asmatico=asma==1
label variable asmatico "Asma"

gen hipert=hipertension==1
label variable hipert "Hipertension"

gen cardio=cardiovascular==1
label variable cardio "Enfermedades cardiovasculares"

gen renales=renal_cronica==1
label variable renales "Enfermedad renal cronica"

gen imm=inmusupr==1
label variable imm "Inmunosupresion"

gen tot_comorb=obeso+diab+fuma+enfisema+asmatico+hipert+cardio+renales+imm
label variable tot_comorb "Numero de comorbilidades"

gen morethanoneco=tot_comorb>1
label variable morethanoneco "Mas de una comorbilidad"
rename edad age
global descriptives mujer indigena menora10 edad* obeso diab fuma enfisema asmatico hipert cardio renales imm morethanoneco


*si  no han instalado "balancetable" la siguiente línea lo hace

*ssc install balancetable

*esta tabla compara observables entre decesos en edomex y resto del país
balancetable edomex $descriptives using "$micpu\edomex_vs_resto.xls" if covid==1 & deceso==1, varlabels modify ctitles("Resto del Pais" "Estado de Mexico" "Diferencia")

* esta tabla compara observables entre casos positivos en edomex y resto del pais
balancetable edomex $descriptives using "$micpu\edomex_vs_resto_casos.xls" if covid==1, varlabels modify ctitles("Resto del Pais" "Estado de Mexico" "Diferencia")

* esta grafica busca mostrar diferencias de medias entre edomex y resto del pais para casos positivos y para decesos


*esta tabla compara observables entre casos y decesos por covid en cdmx
balancetable deceso $descriptives using "$micpu\casos_vs_decesos.xls" if covid==1 & edomex==1, varlabels modify ctitles("Casos confirmados" "Decesos confirmados" "Diferencia")

// modify para que no mueva formato. verificar y si no cambiar a replace


