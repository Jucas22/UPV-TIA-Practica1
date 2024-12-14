;definicion de variables difusas

(deftemplate Temp 5 50 Celsius
    (   (frio (z 10 20))
        (templado (pi 5 25))
        (calor (s 30 40))
    )
)

(deftemplate valvula 0 90 grados-apertura
    (   (poco (z 10 30))
        (medio (pi 30 45))
        (mucho (s 70 80))
    )
)


;rules

(defrule hace_frio
    (Temp frio) => (assert (valvula mucho))
)

(defrule temperatura_buena
    (Temp templado) => (assert (valvula medio))
)

(defrule hace_calor
    (Temp calor) => (assert (valvula poco))
)


;hechos iniciales

(deffacts ejemplo
    (Temp very templado))

(defrule defuzzufucar
    (valvula ?val) => 
    (printout t "Apertura Valvula por moment: " (moment-defuzzify ?val) crlf))
    (printout t "Apertura Valvula por maximum: " (maximum-defuzzify ?val) crlf)
)