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
	
	movz x10, 0x00, lsl 16
	movk x10, 0x0000, lsl 00
	mov x1, 200
	mov x2, 200
	mov x3, 50
	mov x4, 50
	bl trianguloEQ
	movz x10, 0x00, lsl 16
	movk x10, 0x0000, lsl 00
	mov x1, 200
	mov x2, 200
	mov x3, 50
	mov x4, 10
	bl trianguloEQ

	
	// Ejemplo de uso de gpios
	mov x9, GPIO_BASE

	// Atención: se utilizan registros w porque la documentación de broadcom
	// indica que los registros que estamos leyendo y escribiendo son de 32 bits

	// Setea gpios 0 - 9 como lectura
	str wzr, [x9, GPIO_GPFSEL0]
	ldr x12, =0x800000


// w, a, s, d, espacio
InfLoop:
	//------------------------------------------------------------------
	// And bit a bit mantiene el resultado del bit 2 en w10 (notar 0b... es binario)
	// al inmediato se lo refiere como "máscara" en este caso:
	// - Al hacer AND revela el estado del bit 2
	// - Al hacer OR "setea" el bit 2 en 1
	// - Al hacer AND con el complemento "limpia" el bit 2 (setea el bit 2 en 0)

	//mov x20, x0 // Guarda la dirección base del framebuffer en x20
	
	// Lee el estado de los GPIO 0 - 31
	ldr w14, [x9, GPIO_GPLEV0]
	eor x13, x13, x13
	delay1:
		add x13, x13, #1
		cmp x13, x12
		bne delay1
    movz x10, 0x00, lsl 16
	movk x10, 0x0000, lsl 00 //color del fondo
	and w11, w14, 0b00000010
	cbnz w11, bomber
	// si w11 es 0 entonces el GPIO 1 estaba liberado
	// de lo contrario será distinto de 0, (en este caso particular 2)
	// significando que el GPIO 1 fue presionado
	eor x13, x13, x13
	delay2:
		add x13, x13, #1
		cmp x13, x12
		bne delay2
	b InfLoop
