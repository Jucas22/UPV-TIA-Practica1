(deffunction fuzzify (?fztemplate ?value ?delta)

        (bind ?low (get-u-from ?fztemplate))
        (bind ?hi  (get-u-to   ?fztemplate))

        (if (<= ?value ?low)
          then
            (assert-string
              (format nil "(%s (%g 1.0) (%g 0.0))" ?fztemplate ?low ?delta))
          else
            (if (>= ?value ?hi)
              then
                (assert-string
                   (format nil "(%s (%g 0.0) (%g 1.0))"
                               ?fztemplate (- ?hi ?delta) ?hi))
              else
                (assert-string
                   (format nil "(%s (%g 0.0) (%g 1.0) (%g 0.0))"
                               ?fztemplate (max ?low (- ?value ?delta))
                               ?value (min ?hi (+ ?value ?delta)) ))
            )
        )
 )


;--------------------------------
;--------------------------------
;DEFINICION DE VARIABLES DIFUSAS:
;--------------------------------
;--------------------------------

; Definición de los valores difusos del desvío 
(deftemplate desvio 20 210 mm (
    (leve (20 0) (30 1) (50 1) (70 0))
    (moderado (50 0) (90 1) (110 1) (150 0))
    (alto (110 0) (190 1) (210 1))
   )
)

; Definición de los valores difusos de la velocidad 
(deftemplate velocidad 30 200 kmh (
    (baja (30 0) (40 1) (50 0))
    (media (40 0) (60 1) (80 1) (90 0))
    (alta (80 0) (90 1) (100 1) (120 0))
    (excesiva (100 0) (130 1) (200 1))
   )
)

; Definición de los valores difusos de la intensidad de Aviso 
(deftemplate intensidadAviso 0 100 % (
    (baja (30 1) (50 0))
    (estandar (40 0) (50 1) (70 1) (80 0))
    (alta (70 0) (80 1))
   )
)

; Definición de los valores difusos del angulo de giro 
(deftemplate anguloGiro 0 90 grados (
    (suave (0 0) (20 1) (30 0))
    (normal (20 0) (50 1) (60 0))
    (brusco (50 0) (80 1))
   )
)


;--------------------------------
;--------------------------------
;CREACIÓN DE LA CLASE VEHICULO
;--------------------------------
;--------------------------------

; Creación de la clase vehiculo y los atributos asociados
(deftemplate vehiculo
   (slot devioCrisp (type FLOAT))
   (slot velocidadcrisp (type FLOAT))
   (slot momintensidadAvisocrisp (type FLOAT) (default 0.0))
   (slot maxintensidadAvisocrisp (type FLOAT) (default 0.0))
   (slot momanguloGirocrisp (type FLOAT) (default 0.0))
   (slot maxanguloGirocrisp (type FLOAT) (default 0.0))
)

;--------------------------------
;--------------------------------
;SOLICITUD DE LOS IMPUTS
;--------------------------------
;--------------------------------

; función para solicitar los inputs de desvío del vehículo y la velocidad
(defrule solicitarImputs
   (initial-fact)  ; Se ejecuta al inicializar la base de hechos
   =>
   (printout t "Ingrese el desvio del vehículo (en mm): " crlf)
   (bind ?Rde (read))  ; Lee el desvío ingresado por el usuario
   (fuzzify desvio ?Rde 0)   ; Fuzzifica el desvío (lo indica como alto, bajo o medio)

   (printout t "Ingrese la velocidad del vehículo (en km/h): " crlf)
   (bind ?Rve (read))  ; Lee la velocidad ingresada por el usuario
   (fuzzify velocidad ?Rve 0)  ; Fuzzifica la velocidad (lo indica como alto, bajo o medio)

   ; Crear una nueva instancia de Vehículo
   (assert (vehiculo
         (devioCrisp ?Rde)
         (velocidadcrisp ?Rve)
         (momintensidadAvisocrisp 0.0)   ; Inicializa los outputs a 0 para luego poder modificarlos
         (maxintensidadAvisocrisp 0.0)
         (momanguloGirocrisp 0.0)
         (maxanguloGirocrisp 0.0)
      )
   )
   (printout t "Instancia de Vehículo creada con desvío: " ?Rde " y velocidad: " ?Rve crlf)
)

;--------------------------
;--------------------------
;DEFINICIÓN DE LAS REGLAS
;--------------------------
;--------------------------   

;-------------------------------
; REGLAS PARA INTENSIDAD AVISO
;-------------------------------

;intensidad leve
(defrule intensidadAviso-leve-baja
   (desvio leve) (velocidad baja)
   =>
   (assert (intensidadAviso extremely baja))
)
(defrule intensidadAviso-leve-media
   (desvio leve) (velocidad media)
   =>
   (assert (intensidadAviso baja))
)
(defrule intensidadAviso-leve-alta
   (desvio leve) (velocidad alta)
   =>
   (assert (intensidadAviso very estandar))
)
(defrule intensidadAviso-leve-excesiva
   (desvio leve) (velocidad excesiva)
   =>
   (assert (intensidadAviso alta))
)

; intensidad moderada
(defrule intensidadAviso-moderado-baja
   (desvio moderado) (velocidad baja)
   =>
   (assert (intensidadAviso baja))
)
(defrule intensidadAviso-moderado-media
   (desvio moderado) (velocidad media)
   =>
   (assert (intensidadAviso estandar))
)
(defrule intensidadAviso-moderado-alta
   (desvio moderado) (velocidad alta)
   =>
   (assert (intensidadAviso very estandar))
)
(defrule intensidadAviso-moderado-excesiva
   (desvio moderado) (velocidad excesiva)
   =>
   (assert (intensidadAviso very alta))
)

; intensidad alta
(defrule intensidadAviso-alto-baja
   (desvio alto) (velocidad baja)
   =>
   (assert (intensidadAviso somewhat estandar))
)
(defrule intensidadAviso-alto-media
   (desvio alto) (velocidad media)
   =>
   (assert (intensidadAviso estandar))
)
(defrule intensidadAviso-alto-alta
   (desvio alto) (velocidad alta)
   =>
   (assert (intensidadAviso alta))
)
(defrule intensidadAviso-alto-excesiva
   (desvio alto) (velocidad excesiva)
   =>
   (assert (intensidadAviso extremely alta))
)

;-------------------------------
; REGLAS PARA ANGULO DE GIRO
;-------------------------------

; giro leve
(defrule angulo-giro-leve-baja
   (desvio leve) (velocidad baja)
   =>
   (assert (anguloGiro very suave))
)
(defrule angulo-giro-leve-media
   (desvio leve) (velocidad media)
   =>
   (assert (anguloGiro suave))
)
(defrule angulo-giro-leve-alta
   (desvio leve) (velocidad alta)
   =>
   (assert (anguloGiro suave))
)
(defrule angulo-giro-leve-excesiva
   (desvio leve) (velocidad excesiva)
   =>
   (assert (anguloGiro normal))
)

; giro moderado
(defrule angulo-giro-moderado-baja
   (desvio moderado) (velocidad baja)
   =>
   (assert (anguloGiro somewhat suave))
)
(defrule angulo-giro-moderado-media
   (desvio moderado) (velocidad media)
   =>
   (assert (anguloGiro suave))
)
(defrule angulo-giro-moderado-alta
   (desvio moderado) (velocidad alta)
   =>
   (assert (anguloGiro more-or-less normal))
)
(defrule angulo-giro-moderado-excesiva
   (desvio moderado) (velocidad excesiva)
   =>
   (assert (anguloGiro brusco))
)

; giro alto
(defrule angulo-giro-alto-baja
   (desvio alto) (velocidad baja)
   =>
   (assert (anguloGiro plus suave))
)
(defrule angulo-giro-alto-media
   (desvio alto) (velocidad media)
   =>
   (assert (anguloGiro normal))
)
(defrule angulo-giro-alto-alta
   (desvio alto) (velocidad alta)
   =>
   (assert (anguloGiro somewhat brusco))
)
(defrule angulo-giro-alto-excesiva
   (desvio alto) (velocidad excesiva)
   =>
   (assert (anguloGiro very brusco))
)

;------------------------------------
;------------------------------------
; FUNCION MOSTRAR RESULTADOS
;------------------------------------
;------------------------------------

(defrule mostrar-resultados
   (declare (salience -2))
   (anguloGiro ?angulo_difuso)
   (intensidadAviso ?intesidad_difusa)
   ?vh <- (vehiculo 
            (maxintensidadAvisocrisp ?maxIntensidad) 
            (momintensidadAvisocrisp ?momIntensidad) 
            (maxanguloGirocrisp ?maxGiro) 
            (momanguloGirocrisp ?momGiro))
   =>
   (bind ?a (maximum-defuzzify ?intesidad_difusa))
   (bind ?b (moment-defuzzify ?intesidad_difusa))
   (bind ?c (maximum-defuzzify ?angulo_difuso))
   (bind ?d (moment-defuzzify ?angulo_difuso))
   (modify ?vh 
      (maxintensidadAvisocrisp ?a)
      (momintensidadAvisocrisp ?b)
      (maxanguloGirocrisp ?c)
      (momanguloGirocrisp ?d)
   )
   (printout t "Intensidad aviso (max): " ?a " .Intensidad aviso (mom):" ?b "%" crlf)
   (printout t "Angulo de giro (max): " ?c " .Angulo de giro (mom):" ?d " grados" crlf)
   (halt)
)