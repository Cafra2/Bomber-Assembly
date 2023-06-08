.include "graficos.s"
.include "constantes.s"
.globl main

main:
    // x0 contiene la direccion base del framebuffer
	mov x20, x0 // Guarda la dirección base del framebuffer en x20
	//-----------------------------------------------------------------
	movz x10, 0x76, lsl 16
	movk x10, 0xD14D, lsl 00
	bl pintarfondo

	mov x1, 200
	mov x2, 200
	bl bomber
	
InfLoop:
	b InfLoop
