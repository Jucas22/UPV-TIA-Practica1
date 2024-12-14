#VARIABLES DIFUSAS:
(deftemplate edad                         ;Variable difusa
 0 120 anos                               ;Universo
 (  (infantil (12 1) (20 0))              ;Valores difusos
    (joven (10 0) (15 1) (25 1) (30 0))
    (adulto (20 0) (30 1) (60 1) (70 0))
    (mayor (60 0) (70 1))
 )
)


#FUNCIONES DE PERTENENCIA:
(deftemplate necesidad-reasfaltado 0 100 unidades
   (  (baja (z 0 25))
      (media (pi 25 50))
      (alta (s 50 100))
   )
)

#MODIFICADORES LINGUISTICOS:
(deftemplate estatura 0 250 cm 
   (  (bajo (0 1) (100 1) (150 0)) 
      (muybajito extremely bajo) 
      (medio (100 0) (150 1) (170 1) (180 0))
      (alto (170 0) (180 1))
      (muy-alto very alto))
   )
)

#HECHOS DIFUSOS
variable difusa + valor difuso  (edad adulta)/(edad adulta OR joven)

DEFFACTS: deffacts ejemplo (edad adulta) (estatura muy bajo)
   declaración de hechos INICIALES

ASSERTS: assert(edad adulta)
   se pueden assertar nuevos hechos difusos mediante estas expresiones

#FUSIFICACIÓN
Podemos fusificar valores exacto con la función fuzzify.
Esta función se puede invocar de la forma (fuzzify edad-difusa 35 0.1) y asertará el valor fusificado en la 
variable difusa edad mediante la expresión:
(assert-string "(edad-difusa (34.9 0) (35 1) (35.1 0))").
El rango de la función de pertenencia del valor asertado se establece en la llamada a la función. 
Particularmente, si queremos definir un valor singleton, será tan sencillo como invocar “(fuzzify edad 35 0)”.

