.ifndef __gpiom__
.equ __gpiom__, 0
.include "constantes.s"
.include "graficos.s"

movimiento:
    sub sp, sp, 40
    stur x14, [sp, 0]
    stur x11, [sp, 8]
    stur x12, [sp, 16]
    stur x13, [sp, 24]
    stur lr, [sp, 32]


    // Lee el estado de los GPIO 0 - 31
	ldr w14, [x9, GPIO_GPLEV0]

	// ---------- W -----------------------------------------------------
	and w11, w14, 0b00000010 // Mascara para w en w11
	cbz w11, end_w 		// Si w fue presionada, imprime a bomber 1 pixel hacia arriba
		cmp x2, -5
        ble end_w 
        bl background
		sub x2, x2, 5
		bl bomber
	end_w:
	// ---------- A -----------------------------------------------------
	and w11, w14, 0b00000100 // Mascara para a en w11
	cbz w11, end_a 		// Si a fue presionada, imprime a bomber 1 pixel hacia la izquierda
		bl background
		sub x1, x1, 5
		bl bomber
	end_a:
	// ---------- S -----------------------------------------------------
	and w11, w14, 0b00001000 // Mascara para s en w11
	cbz w11, end_s 		// Si s fue presionada, imprime a bomber 1 pixel hacia abajo
		bl background
		add x2, x2, 5
		bl bomber
	end_s:
	// ---------- D -----------------------------------------------------
	and w11, w14, 0b00010000 // Mascara para d en w11
	cbz w11, end_d 		// Si d fue presionada, imprime a bomber 1 pixel hacia la derecha
		bl background
		add x1, x1, 5
		bl bomber
	end_d:

	// ---------- ESPACIO -----------------------------------------------------
	and w11, w14, 0b00100000 // Mascara para espacio en w11
	cbz w11, end_espacio 		// Si espacio fue presionado, deja bomba
		bl background
        add x11, x1, 60
        add x12, x2, 120
        bl bomber
        bl bomba
	end_espacio:

	eor x13, x13, x13 // Reseteo x13
	delay2:
		add x13, x13, #1
		cmp x13, x12
	bne delay2

    
    
    ldur x14, [sp, 0]
    ldur x11, [sp, 8]
    ldur x12, [sp, 16]
    ldur x13, [sp, 24]
    ldur lr, [sp, 32]
    add sp, sp, 40
ret

.endif
