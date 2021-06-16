# covid_edomex
análisis de los retrasos en reportes de decesos por Covid-19 en el Estado de México

Proyecto de la clase de Investigación Aplicada del ITAM, impartida por Emilio Fernández y Tiago Tavares en el semestre de otoño del 2020.

#### Datos
Se usan las cifras de casos y decesos publicadas por la Secretaría de Salud Pública. En estos datos, la fecha de deceso puede no ser definida si el paciente aún vive o si el deceso no ha sido reportado. Por dicha razón, es posible identificar los días de retraso en los reportes al comparar la información 
reportada en días diferentes.

#### Software
El análisis se realiza con Stata, a excepción de las estimaciones de la evolución de la pandemia con el modelo SIR, las cuales se hicieron en Python.

#### Archivos:

* retrasos_edomex: documento final
* dofiles/01_descriptive_stats: Estadísticas descriptivas de casos y decesos en el Estado de México contra el resto del país.
* dofiles/02_descriptive_maps: Mapas descriptivos sobre tasas de mortalidad, letalidad y casos y decesos acumulados por Estado y por municipio del Estado de México.
* dofiles/03_fecha_reporte_decesos: Se realiza el cálculo de los días de retraso en reportes de decesos usando todas las bases reportadas por la SSP de abril a octubre.
* dofiles/04_histograma: Histogramas sobre los días de retraso en reportes de decesos por covid-19 en México y el Estado de México.
* dofiles/05_mapa_delays: Mapas con los retrasos por municipio.
* dofiles/06_evolution_deaths: Comparación de las curvas epidemiológicas de acuerdo a los decesos por fecha de ocurrencia y fecha de reporte.
* dofiles/07_SIR_estimation: generar base con muertes por fecha de ocurrencia y por fecha de reporte por día para poder calibrar el modelo SIR.
* simulaciones_f: simulación de las curvas epidémicas (la calibración de parámetros se hizo previamente).
* data/deaths_sir: archivo resultante del do file 07_SIR_estimation.

#### Algunos resultados

<img src="img/retrasos_poredo.tif" width="1048">

<img src="img/curvas_pais_edo.tif" width="1048">

![img](img/mapdelays_edo2.tif)

<img src="img/Ocurred.png" width="720">

