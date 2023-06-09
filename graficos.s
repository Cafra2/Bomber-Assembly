.ifndef __graficos__
.equ __graficos__, 0
.include "constantes.s"

//-------------------------------------------------------------------------------------------

cuadrado:
	// Recibe dos coordenadas que seran la posicion de inicio del cuadrado junto con ancho y alto
	// PARAMETROS::  X:x1, Y:x2, Ancho:x3, Alto:x4, Color:x10
	sub sp,sp, 40
	stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x3, [sp, 16]
	stur x4, [sp, 24]
	stur lr, [sp, 32]

	loopcuad0:
		bl setpixel
		add x1, x1, 1   		// Siguiente coordenada en X
		sub x3, x3, 1			// Falta un pixel menos para llegar al ancho
		cbnz x3, loopcuad0		// Si el ancho que falta no es 0, sigue pintando   
		ldur x3, [sp, 16]		// Si el contador de ancho llego a 0, lo resetea
		ldur x1, [sp, 0] 		// Tambien resetea la coord X
		sub x4, x4, 1			// Falta una fila menos para llegar a la altura
		add x2, x2, 1			// Siguiente coordenada en Y
		cbz x4, cuadrado_end	// Si el alto que falta es 0, ya pinto todo
		b loopcuad0

	cuadrado_end:
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x3, [sp, 16]
	ldur x4, [sp, 24]
	ldur lr, [sp, 32]
	add sp,sp, 40
ret // Recibe dos coordenadas que seran la posicion de inicio del cuadrado junto con ancho y alto

//-------------------------------------------------------------------------------------------

setpixel: 
    // Recibe dos coordenadas y pinta el pixel con el color dado
    // PARAMETROS::  X:x1, Y:x2, COLOR:w10
    sub sp,sp, 32
    stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x3, [sp, 16]
    stur lr, [sp, 24]

    coord:
        // x3 = Dirección de inicio + 4 * [x + (y * 640)]
        mov x3, 640    // x3 =   640
        mul x3, x3, x2 // x3 =   640*y
        add x3, x3, x1 // x3 =  (640*y)+x
        lsl x3, x3, 2  // x3 = [(640*y)+x]*4
        add x3, x3, x20 // x3 = [(640*y)+x]*4 + Direccion de inicio
    //

    stur w10, [x3] // Colorea el pixel en la posicion calculada

    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x3, [sp, 16]
    ldur lr, [sp, 24]
    add sp,sp, 32
ret // Recibe dos coordenadas y pinta el pixel con el color dado

//-------------------------------------------------------------------------------------------

pintarfondo:
    // Pinta el fondo con un color dado
    // PARAMETROS::  Color:x10 
    sub sp, sp, 32
    stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x20, [sp, 16]
    stur lr, [sp, 24]

	mov x2, SCREEN_HEIGH         // Y Size
    loop1:
        mov x1, SCREEN_WIDTH         // X Size
    loop0:
        stur w10,[x20]  // Colorear el pixel N
        add x20,x20,4    // Siguiente pixel
        sub x1,x1,1    // Decrementar contador X
        cbnz x1,loop0  // Si no terminó la fila, salto
        sub x2,x2,1    // Decrementar contador Y
        cbnz x2,loop1  // Si no es la última fila, salto

    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x20, [sp, 16]
    ldur lr, [sp, 24]
    add sp, sp, 32
ret // Pinta el fondo con un color dado

background:
    sub sp, sp, 48
    stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x10, [sp, 16]
    stur lr, [sp, 24]
    stur x3, [sp, 32]
    stur x4, [sp, 40]

	movz x10, 0x76, lsl 16
	movk x10, 0xD14D, lsl 00 // Verde pasto #76D14D
	bl pintarfondo

    movz x10, 0x6C, lsl 16
	movk x10, 0xEFF0, lsl 00 // Celeste cielo #6CEFF0
	mov x1, 0
	mov x2, 0
	mov x3, 640
	mov x4, 70
	bl cuadrado

	bl arbol	


    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x10, [sp, 16]
    ldur lr, [sp, 24]
    ldur x3, [sp, 32]
    ldur x4, [sp, 40]
    add sp, sp, 48
ret // Pinta el fondo con cualquier agregado

linea:
    sub sp, sp, 80
    stur lr, [sp,0]
    stur x16, [sp,8]
    stur x17, [sp,16]
    stur x0, [sp,24]
    stur x9, [sp,32]
    stur x15, [sp, 40]
    stur x13, [sp, 48]
    stur x1, [sp, 56]
    stur x2, [sp, 64]
	stur x14, [sp, 72]


    // le paso x0,y0 y x9,y1 //

    //x1,x2 (primer par) | x13,x14 (segundo par) //

    // x11 error , x15 2error | x16 (dx) , x17 (dy) //

    sub x16, x13 , x1 // dx en x16

    cmp x16,0
        bge no1
        neg x16,x16
    no1:

    sub x17, x14, x2 // dy en x17

    cmp x17,0
        ble no2
        neg x17,x17
        no2:

    add x11, x16, x17 // error -> dx - dy

    cmp x1,x13 // x0 < x9 
        mov x0, 1
        blt end1
        neg x0, x0 // sx x0
    end1:

    cmp x2,x14 // y0 < y1
        mov x9, 1
        blt end2
        neg x9, x9 // sy x9
    end2:

        

    loop_line:

        bl setpixel
        cmp x1,x13 
        bne continue
        
        cmp x2,x14
        bne continue
        b end_lup

        continue:
        
        mov x15, x11 // err2 = error
        lsl x15,x15,1
        cmp x15, x17 // e2 >= dy (if 1)
        blt c1
        add x11, x11, x17	// err + dy
        add x1,x1,x0 // x0 + sx
        c1: // si no se cumpla la condicion if1
            cmp x15, x16 // e2 <= dx (if 2)
            bgt c2
            add x11, x11, x16	// err + dx
            add x2,x2,x9 // y0 + sy
        c2: // si no se cumpla la condicion if2

    b loop_line

    end_lup:
        ldur lr, [sp,0]
        ldur x16, [sp,8]
        ldur x17, [sp,16]
        ldur x0, [sp,24]
        ldur x9, [sp,32]
        ldur x15, [sp, 40]
        ldur x13, [sp, 48]
        ldur x1, [sp, 56]
        ldur x2, [sp, 64]
		ldur x14, [sp, 72]
        add sp, sp ,80

ret // linea

/* 
trianguloEQ:
    // PARAMETROS:: x1:X, x2:Y, x3:Ancho, x4:Alto, x10:Color
    // Pinta un triangulo relleno
    sub sp, sp, 48
    stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x3, [sp, 16]
    stur x4, [sp, 24]
    stur x13, [sp, 32]
    stur x14, [sp, 40]
	
	// x1, x2, x e y iniciales
	mov x13, x1
    sub x14, x2, x4
	bl linea

	mov x1, x13
    mov x2, x14
    ldur x13, [sp, 0]
    add x13, x13, x3
    ldur x14, [sp, 8]
    bl linea
    
    mov x1, x13
    mov x2, x14
    ldur x13, [sp, 0]
    ldur x14, [sp, 8]
    bl linea

    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x3, [sp, 16]
    ldur x4, [sp, 24]
    ldur x13, [sp, 32]
    ldur x14, [sp, 40]
    add sp, sp, 48
ret // Dibuja un triangulo EQ

triangulo:
    // PARAMETROS:: x1:X, x2:Y, x3:MITAD del Ancho, x4:Alto, x10:Color
    // Dibuja un triangulo. ATENCION: El ancho dado sera duplicado
    sub sp, sp, 56
    stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x3, [sp, 16]
    stur x4, [sp, 24]
    stur x13, [sp, 32]
    stur x14, [sp, 40]
    stur lr, [sp, 48]

    // x1, x2, x e y iniciales ----------------
	mov x13, x1
    sub x14, x2, x4
	

	mov x1, x13
    mov x2, x14
    ldur x13, [sp, 0]
    add x13, x13, x3
    ldur x14, [sp, 8]
    bl linea
    
    mov x1, x13
    mov x2, x14
    ldur x13, [sp, 0]
    ldur x14, [sp, 8]
    bl linea
    //------------------------------------------
    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x3, [sp, 16]
    ldur x4, [sp, 24]

    // x1, x2, x e y iniciales ----------------
    sub x13, x1, x3
    mov x14, x2
    bl linea

    mov x1, x13
    mov x2, x14
    ldur x13, [sp, 0]
    ldur x14, [sp, 8]
    sub x14, x14, x4
    bl linea

    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x3, [sp, 16]
    ldur x4, [sp, 24]
    ldur x13, [sp, 32]
    ldur x14, [sp, 40]
    add sp, sp, 48
ret

trianguloPint:
    // PARAMETROS:: x1:X, x2:Y, x3:MITAD del Ancho, x4:Alto, x10:Color
    // Dibuja un triangulo. ATENCION: El ancho dado sera duplicado
    sub sp, sp, 64
    stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x3, [sp, 16]
    stur x4, [sp, 24]
    stur x13, [sp, 32]
    stur x14, [sp, 40]
    stur lr, [sp, 48]
    stur x5, [sp, 56]

    loop_triangulopint:
        cbz x4, end_triangulopint
        bl triangulo
        sub x4, x4, 1

    b loop_triangulopint

    end_triangulopint:
        ldur x1, [sp, 0]
        ldur x2, [sp, 8]
        ldur x3, [sp, 16]
        ldur x4, [sp, 24]
        ldur x13, [sp, 32]
        ldur x14, [sp, 40]
        ldur lr, [sp, 48]
        ldur x5, [sp, 56]
        add sp, sp, 64
ret
*/

//-------------------------------------------------------------------------------------------
// Sprites
bomber:
    sub sp,sp, 48
	stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x3, [sp, 16]
	stur x4, [sp, 24]
	stur lr, [sp, 32]
    stur x10, [sp, 40]

    // Cabeza
	movz x10, 0xFF, lsl 16
	movk x10, 0xFFFF, lsl 00 // Blanco #FFFFFF
    add x1, x1, 24
	add x2, x2, 16
	mov x3, 64
	mov x4, 72
	bl cuadrado
	
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 8
	add x2, x2, 24
	mov x3, 16
	mov x4, 56
	bl cuadrado
	
	add x1, x1, 80
	bl cuadrado

	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 0
	add x2, x2, 32
	mov x3, 8
	mov x4, 40
	bl cuadrado

	add x1, x1, 104
	bl cuadrado

	// Antena
	movz x10, 0xFF, lsl 16
	movk x10, 0x1048, lsl 00 // Rojo-Rosado #FF1048
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 48
	add x2, x2, 0
	mov x3, 16
	mov x4, 16
	bl cuadrado

	// Manos
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 8
	add x2, x2, 96
	mov x3, 16
	mov x4, 16
	bl cuadrado

	add x1, x1, 80
	bl cuadrado

	// Patas
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 16
	add x2, x2, 128
	mov x3, 32
	mov x4, 16
	bl cuadrado

	add x1, x1, 48
	bl cuadrado

	// Cara
	movz x10, 0xFF, lsl 16
	movk x10, 0xE0CB, lsl 00 // Piel #FFE0CB
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 16
	add x2, x2, 32
	mov x3, 80
	mov x4, 40
	bl cuadrado
	
	// Ojos
	movz x10, 0 // Negro #000000
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 32
	add x2, x2, 40
	mov x3, 8
	mov x4, 24
	bl cuadrado

	add x1, x1, 40
	bl cuadrado

	// Cuerpo
	movz x10, 0x42, lsl 16
	movk x10, 0x36ED, lsl 00 // Azul #4236ED
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 32
	add x2, x2, 88
	mov x3, 48
	mov x4, 40
	bl cuadrado

    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
	add x1, x1, 24
	add x2, x2, 96
	mov x3, 8
	mov x4, 24
	bl cuadrado

	add x1, x1, 56
	bl cuadrado

	// Cinturon
	movz x10, 0 // Negro #000000
    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
	add x1, x1, 24
	add x2, x2, 112
	mov x3, 24
	mov x4, 8
	bl cuadrado

	add x1, x1, 40
	bl cuadrado

	movz x10, 0xEE, lsl 16
	movk x10, 0xDC00, lsl 00 // Dorado #EEDC00
	sub x1, x1, 16
	sub x3, x3, 8
	bl cuadrado

    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x3, [sp, 16]
	ldur x4, [sp, 24]
	ldur lr, [sp, 32]
    ldur x10, [sp, 40]
	add sp,sp, 48
ret // Literalmente Bomberman!

bomberquemado:
    sub sp,sp, 48
	stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x3, [sp, 16]
	stur x4, [sp, 24]
	stur lr, [sp, 32]
    stur x10, [sp, 40]

    // Cabeza
	movz x10, 0x9E, lsl 16
	movk x10, 0x9E9E, lsl 00 // Blanco #9E9E9E
    add x1, x1, 24
	add x2, x2, 16
	mov x3, 64
	mov x4, 72
	bl cuadrado
	
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 8
	add x2, x2, 24
	mov x3, 16
	mov x4, 56
	bl cuadrado
	
	add x1, x1, 80
	bl cuadrado

	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 0
	add x2, x2, 32
	mov x3, 8
	mov x4, 40
	bl cuadrado

	add x1, x1, 104
	bl cuadrado

	// Antena
	movz x10, 0x6C, lsl 16
	movk x10, 0x0013, lsl 00 // Rojo-Rosado #6C0013
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 48
	add x2, x2, 0
	mov x3, 16
	mov x4, 16
	bl cuadrado

	// Manos
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 8
	add x2, x2, 96
	mov x3, 16
	mov x4, 16
	bl cuadrado

	add x1, x1, 80
	bl cuadrado

	// Patas
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 16
	add x2, x2, 128
	mov x3, 32
	mov x4, 16
	bl cuadrado

	add x1, x1, 48
	bl cuadrado

	// Cara
	movz x10, 0x80, lsl 16
	movk x10, 0x7068, lsl 00 // Piel #807068
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 16
	add x2, x2, 32
	mov x3, 80
	mov x4, 40
	bl cuadrado
	
	// Ojos
    movz x10, 0xFF, lsl 16
	movk x10, 0xFFFF, lsl 00 // Blanco #FFFFFF
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 24
	add x2, x2, 40
	mov x3, 24
	mov x4, 24
	bl cuadrado
    add x1, x1, 40
	bl cuadrado

	movz x10, 0 // Negro #000000
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 32
	add x2, x2, 48
	mov x3, 8
	mov x4, 8
	bl cuadrado

	add x1, x1, 40
	bl cuadrado

	// Cuerpo
	movz x10, 0x21, lsl 16
	movk x10, 0x2471, lsl 00 // Azul #212471
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    add x1, x1, 32
	add x2, x2, 88
	mov x3, 48
	mov x4, 40
	bl cuadrado

    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
	add x1, x1, 24
	add x2, x2, 96
	mov x3, 8
	mov x4, 24
	bl cuadrado

	add x1, x1, 56
	bl cuadrado

	// Cinturon
	movz x10, 0 // Negro #000000
    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
	add x1, x1, 24
	add x2, x2, 112
	mov x3, 24
	mov x4, 8
	bl cuadrado

	add x1, x1, 40
	bl cuadrado

	movz x10, 0xAF, lsl 16
	movk x10, 0xA30E, lsl 00 // Dorado #AFA30E
	sub x1, x1, 16
	sub x3, x3, 8
	bl cuadrado

    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x3, [sp, 16]
	ldur x4, [sp, 24]
	ldur lr, [sp, 32]
    ldur x10, [sp, 40]
	add sp,sp, 48
ret // Literalmente Bomberman!(Pero quemado)

arbol:
    sub sp,sp, 48
	stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x3, [sp, 16]
	stur x4, [sp, 24]
	stur lr, [sp, 32]
    stur x10, [sp, 40]

    // Hojas
	movz x10, 0x00, lsl 16
	movk x10, 0x8F12, lsl 00 // Verde arboles #008F12
    add x1, x1, 24
	add x2, x2, 16
	mov x3, 64
	mov x4, 80
	bl cuadrado

    // Tronco
	movz x10, 0x4B, lsl 16
	movk x10, 0x2900, lsl 00 // Marron troncos #4B2900
    add x1, x1, 22
	add x2, x2, 80
	mov x3, 20
	mov x4, 30
	bl cuadrado

    
	ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x3, [sp, 16]
	ldur x4, [sp, 24]
	ldur lr, [sp, 32]
    ldur x10, [sp, 40]
    add sp, sp, 48
ret // Un arbol tranqui

.endif
