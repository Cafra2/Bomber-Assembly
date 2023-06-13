.include "graficos.s"
.include "constantes.s"
.include "gpiom.s"
.globl main

main:
    // x0 contiene la direccion base del framebuffer
	mov x20, x0 // Guarda la dirección base del framebuffer en x20
	//-----------------------------------------------------------------
	
	mov x1, 200
	mov x2, 200
	bl backdia
	bl bomber

	// Ejemplo de uso de gpios
	mov x9, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// Indica que los registros que estamos leyendo y escribiendo son de 32 bits

	// Setea gpios 0 - 9 como lectura
	str wzr, [x9, GPIO_GPFSEL0]

InfLoop:
	// Pulsar W para que se haga de dia y S para noche
	bl cambiafondosWS

b InfLoop

	