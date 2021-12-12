%%bash
#!/usr/bin/env bash
clear


#	Definir variables del mapa
#	-----------------------------------------------------------------------------------------------------------
#	Titulo del mapa
    title=07_Topografico_Examen
	echo $title

#	Region: Argentina
    REGION=-72/-65/-40/-35

#	Proyeccion Mercator (M)
	PROJ=M15c

#	Resoluciones grillas: 01d, 30m, 20m, 15m, 10m, 06m, 05m, 04m, 03m, 02m, 01m, 30s, 15s, 03s, 01s.
	RES=15s

#	Fuente a utilizar
	GRD=@earth_relief_$RES

	gmt set GMT_VERBOSE debug

#	Dibujar mapa
#	-----------------------------------------------------------------------------------------------------------
#	Iniciar sesion y tipo de figura
	gmt begin $title png
	
#	Setear la region y proyeccion
	gmt basemap -R$REGION -J$PROJ -B+n
  
#	Crear Imagen a partir de grilla. Usa el CPT por defecto y la ajusta al rango de valores de alturas automaticamente.
#	gmt grdimage $GRD

#	Idem y agrega efecto de sombreado. a= azimut. nt1=metodo de ilumninacion
	gmt grdimage $GRD -I+a45+nt1ls

# ------------------------------------------------------------------------------
# Dibujar Bordes Administrativos. N1: paises. N2: Provincias, Estados, etc. N3: limites marítimos (Nborder[/pen])
    gmt coast -Df -N1/1.25
	gmt coast -Df -N2/0.75,-.

# ------------------------------------------------------------------------------
#	Dibujar rios -Iriver[/pen] 
#	0 = Double-lined rivers (river-lakes)
#	1 = Permanent major rivers
#	2 = Additional major rivers
#	3 = Additional rivers
#	4 = Minor rivers
#	gmt coast -Df -I0/thin,$color
#	color=dodgerblue2
#  gmt coast -Df -I0/2,$color,..-
#	gmt coast -Df -I1/1.5,$color
#	gmt coast -Df -I2/1,$color,-
#	gmt coast -Df -I3/thinnest,$color,-
#	gmt coast -Df -I2/1,$color
#	gmt coast -Df -I3/thinnest,$color
#	gmt coast -Df -I4/thinnest,$color,4_1:0p

# ------------------------------------------------------------------------------
#	Cursos y Cuerpos de Agua
	gmt plot "IGN/lineas_de_aguas_continentales_perenne/lineas_de_aguas_continentales_perenne.shp" -Wfaint,dodgerblue2  # Descargar archivo desde el IGN	

# ------------------------------------------------------------------------------
#	Asentamientos
	gmt plot "IGN/puntos_de_asentamientos/puntos_de_asentamientos_y_edificios_localidad.shp" -Sc0.1 -Gyellow  # Descargar archivo desde el IGN	


# ------------------------------------------------------------------------------  

#	Agregar escala de colores a partir de CPT (-C). Posición (x,y) +wlargo/ancho. Anotaciones (-Ba). Leyenda (+l). 
	gmt colorbar -DjRM -I -Baf -By+l"km" -W0.001 -F+gwhite+p+i+s
	

# ------------------------------------------------------------------------------
#	Dibujar Norte (-Td). Ubicacion definida por coordenads geograficas (g) centrado en Lon0/Lat0, ancho (+w). Opcionalmente se pueden definir el nivel (+f), puntos cardinales (+l)
    gmt basemap -Tdg-66.2/-35.5+w2c	          --FONT_TITLE=8p,4,Black

# ------------------------------------------------------------------------------
#	Dibujar Escala en el mapa centrado en -Lg Lon0/Lat0, calculado en el meridiano (+c) y de ancho (+w). Opcionalmente se puede elegir un estilo elegante(+f), agregar las unidades arriba de escala (+l) o con los valores (+u).
#	-Fl: Agrega fondo a la escala. +gfill: color fondo. +p(pen): borde principal. +i(pen): borde interno. +r(radio): borde redondeado. +s: sombra   
    gmt basemap -Lg-66/-39:40+c-51:45+w50k+f+l
   

#	-----------------------------------------------------------------------------------------------------------
#	Dibujar frame
	gmt basemap -Bxaf -Byaf

#	Dibujar Linea de Costa (W1)
	gmt coast -Da -W1/faint

#	-----------------------------------------------------------------------------------------------------------

#	Dibujar leyenda
#	-----------------------------------------------------------------------------------------------------------
#	Crear archivo para hacer la leyenda
#	Leyenda. H: Encabezado. D: Linea horizontal. N: # columnas verticales. V: Linea Vertical. S: Símbolo. M: Escala
	cat > tmp_leyenda <<- END
	H 10 Times-Roman Referencias
	N 2   
	S 0.25c -     0.5c -     1.5p,dodgerblue2       0.75c R\355os permanentes
	S 0.25c c 0.25c yellow   0.40p     0.5c localidades
	G 0.075c
	G 0.075c
	S 0.25c - 0.5c - 1.5p,black 0.75c L\355mite internacional
	S 0.25c - 0.5c - 0.5p,black,-. 0.75c L\355mite provincial
	G 0.075c
	M -72 -55 50+u f
	END

#	Graficar leyenda
    gmt legend tmp_leyenda -DJBC+o0/1c+w15c/0c    -F+p+i+r


#	-----------------------------------------------------------------------------------------------------------
#	Mapa de Ubicacion (INSET)
#	Crear archivo con recuadro de zona de estudio
	gmt basemap -A > tmp_area

#	Extraer coordenadas del centro del mapa	(CM) y crear variables
	gmt mapproject -WjCM 
	Lon=$(gmt mapproject -WjCM -o0)
	Lat=$(gmt mapproject -WjCM -o1)

#	Dibujar mapa de ubicacion
#	w: tamaño. M: Margen. D: ubicacion
	gmt inset begin -DjTL+w3.0c+o-0.3c
		gmt coast -Rg -JG$Lon/$Lat/? -Gwhite -Slightblue3 -C- -Bg
		gmt coast -W1/faint -N1
		gmt plot tmp_area -Wthin,darkred
	gmt inset end



# ------------------------------------------------------------------------------  
#	Cerrar el archivo
gmt end

rm gmt.conf
