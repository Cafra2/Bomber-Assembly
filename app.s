.include "graficos.s"
.include "constantes.s"
.include "gpiom.s"
.globl main

main:
    // x0 contiene la direccion base del framebuffer
	mov x20, x0 // Guarda la dirección base del framebuffer en x20
	//-----------------------------------------------------------------
	

	bl background
	
	mov x1, 200
	mov x2, 200
	bl bomber
	

	// Ejemplo de uso de gpios
	mov x9, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// indica que los registros que estamos leyendo y escribiendo son de 32 bits

	// Setea gpios 0 - 9 como lectura
	str wzr, [x9, GPIO_GPFSEL0]
	ldr x12, =0x800000


// w, a, s, d, espacio
InfLoop:
	bl movimiento
	
	b InfLoop
