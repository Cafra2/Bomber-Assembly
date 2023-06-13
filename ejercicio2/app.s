.include "graficos.s"
.include "constantes.s"
.include "gpiom.s"
.globl main

main:
    // x0 contiene la direccion base del framebuffer
	mov x20, x0 // Guarda la dirección base del framebuffer en x20
	//-----------------------------------------------------------------
	

	bl background // Imprime el fondo
	
	mov x1, 200 // x1 es la coordenada x del personaje
	mov x2, 200 // x2 es la coordenada y del personaje
	bl bomber // imprime al personaje

	// Ejemplo de uso de gpios
	mov x9, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// indica que los registros que estamos leyendo y escribiendo son de 32 bits

	// Setea gpios 0 - 9 como lectura
	str wzr, [x9, GPIO_GPFSEL0]

// w, a, s, d, espacio
InfLoop:
	bl movimiento // checkea si se esta apretando w,a,s,d para mover el personaje
	bl ponerbomba // checkea si se esta apretando el espacio para poner la bomba

	b InfLoop

	