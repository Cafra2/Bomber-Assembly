.include "graficos.s"
.include "constantes.s"
.globl main

main:
    // x0 contiene la direccion base del framebuffer
	mov x20, x0 // Guarda la dirección base del framebuffer en x20
	//-----------------------------------------------------------------
	movz x10, 0xFF, lsl 16
	movk x10, 0xFFFF, lsl 00
	bl pintarfondo

	mov x1, 200
	mov x2, 300
	mov x3, 80
	mov x4, 50
	movz x10, 0x00, lsl 16
	movk x10, 0x0000, lsl 00

	bl setpixel
	bl cuadrado

InfLoop:
	b InfLoop
