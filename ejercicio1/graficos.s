.ifndef __graficos__
.equ __graficos__, 0
.include "constantes.s"
.include "gpiom.s"

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


//----------------------------------------------------------------------------------------//
circulo:
	// x3 = radio
    sub sp, sp, 56
    stur x4, [sp, 0]
    stur x5, [sp, 8]
    stur x6, [sp, 16]
    stur lr, [sp, 24]
    stur x11, [sp, 32]
    stur x12, [sp, 40]
    stur x3, [sp,48]
   
	coord_circ:
    	neg x4, x3 // error = -radio
    	mov x5, x3 // x = radio
    	mov x6, 0 // y = 0
   
	circ_loop:
   	cmp x5,x6 // x>=y

   	blt fin_circulo // si termino voy a fin_circulo

		bl plot8points

		add x4, x4, x6 // error + y
		add x6,x6,1 // y++
		add x4, x4, x6 // error + y

		cmp x4,0 // error >= 0
		blt if1 
		sub x5,x5,1
		sub x4,x4,x5
		sub x4,x4,x5

   if1:

   b circ_loop

   plot8points:
      sub sp,sp,48
      stur x11,[sp,0]
      stur x12,[sp,8]
      stur x5,[sp,16]
      stur x6,[sp,24]
      stur lr,[sp,32]
		stur x2,[sp,40]

      bl plot4points

      cmp x5,x6
      beq not_ifp8
      mov x2,x5
      mov x5,x6
      mov x6,x2 // asignacion multiple
      bl plot4points

      not_ifp8:

      ldr x11,[sp,0]
      ldr x12,[sp,8]
      ldr x5,[sp,16]
      ldr x6,[sp,24]
      ldr lr,[sp,32]
		ldur x2,[sp,40]
      add sp,sp,48

   ret

   	plot4points:
      
			sub sp,sp, 24
			stur x2,[sp,0]
			stur x1,[sp,8]
			stur lr,[sp,16]
			

			add x1, x11, x5 // (cx+x) x1
			add x2, x12, x6 // (cy+y) x2
			bl setpixel // setp(cx+x,cy+y)
			
			cbz x5,notif1 // x!=0
			sub x1, x11, x5 // (cx-x) x1
			add x2, x12, x6 // (cy+y) x2
			bl setpixel // setp(cx-x,cy+y)
			
			notif1:

			cbz x6,notif2 // y!=0
			add x1, x11, x5 // (cx+x) x1
			sub x2, x12, x6 // (cx-x) x1
			bl setpixel // setp(cx+x,cy-y)

			notif2:

			cbz x5,notif3
			cbz x6,notif3 // x!=0 && y!=0
			sub x1, x11, x5 // (cx-x) x1
			sub x2, x12, x6 // (cy-y) x1
			bl setpixel // setp(cx-x,cy-y)

			notif3:

			ldr x2,[sp,0]
			ldr x1,[sp,8]
			ldr lr,[sp,16]
			add sp,sp, 24

   	ret

	fin_circulo:
   ldur x4, [sp, 0]
   ldur x5, [sp, 8]
   ldur x6, [sp, 16]
   ldur lr, [sp, 24]
   ldur x11, [sp, 32]
   ldur x12, [sp, 40]
   ldur x3, [sp,48]
   add sp, sp, 56
   
ret // Recibe (x11,x12) = (x,y) | x3 = radio 

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

backdia:
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
	mov x4, 100
	bl cuadrado

	mov x3, 100
	mov x4, 120
	mov x5, 200
	mov x6, 120
	mov x7, 150
	mov x8, 40
	bl arbol
	bl sol

	add x3, x3, 100
	add x4, x4, 120
	add x5, x5, 200
	add x6, x6, 120
	add x7, x7, 150
	add x8, x8, 40
	bl arbol

    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x10, [sp, 16]
    ldur lr, [sp, 24]
    ldur x3, [sp, 32]
    ldur x4, [sp, 40]
    add sp, sp, 48
ret // Pinta el fondo de dia

backnoche:
    sub sp, sp, 48
    stur x1, [sp, 0]
    stur x2, [sp, 8]
    stur x10, [sp, 16]
    stur lr, [sp, 24]
    stur x3, [sp, 32]
    stur x4, [sp, 40]

	movz x10, 0x26, lsl 16
	movk x10, 0x7F40, lsl 00 // Verde pasto oscuro #5
	bl pintarfondo

    movz x10, 0x3D, lsl 16
	movk x10, 0x4C5E, lsl 00 // azul noche 0x3D4C5E
	mov x1, 0
	mov x2, 0
	mov x3, 640
	mov x4, 100
	bl cuadrado
	mov x3, 100
	mov x4, 120
	mov x5, 200
	mov x6, 120
	mov x7, 150
	mov x8, 40
	bl arbol

	add x3, x3, 100
	add x4, x4, 120
	add x5, x5, 200
	add x6, x6, 120
	add x7, x7, 150
	add x8, x8, 40
	bl arbol

	bl luna
	


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


    // le paso x0,y0 y x1,y1 //

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

triangulo_peri:
   // PARAMETROS:: (x3,x4) esquina inf-izq 
	//				  (x5,x6) esquina inf-der
	//				  (x7,x8) esquina superior
   sub sp, sp, 88
   stur x1, [sp, 0]
   stur x2, [sp, 8]
   stur x3, [sp, 16]
   stur x4, [sp, 24]
   stur x5, [sp, 32]
   stur x6, [sp, 40]
   stur x7, [sp, 48]
	stur x8, [sp, 56]
	stur x13, [sp, 64]
	stur x14, [sp, 72]
	stur lr, [sp, 80]

    //lado de izq->arriba// 

	 mov x1, x3
    mov x2, x4
	 mov x13, x7
	 mov x14, x8
    bl linea
    
	 //lado de arriba->derecha//
    mov x1, x5
    mov x2, x6
    mov x13, x7
	 mov x14, x8
    bl linea
    
    //lado abajo izq -> abajo der//
    mov x1, x3
	 mov x2, x4
	 mov x13, x5
	 mov x14, x6
    bl linea


    ldur x1, [sp, 0]
    ldur x2, [sp, 8]
    ldur x3, [sp, 16]
    ldur x4, [sp, 24]
    ldur x5, [sp, 32]
    ldur x6, [sp, 40]
    ldur x7, [sp, 48]
	 ldur x8, [sp, 56]
	 ldur x13, [sp, 64]
	 ldur x14, [sp, 72]
	 ldur lr, [sp,80]
    add sp, sp, 88
ret

triangulo:
	sub sp,sp, 48
	stur x3, [sp,0]
	stur x4, [sp,8]
	stur x5, [sp,16]
	stur x6, [sp,24]
	stur x9, [sp,32]
	stur lr, [sp,40]

	bl triangulo_peri
	sub x9,x5,x3
	lsr x9,x9,1
	lup:
	add x3,x3,1 // izq +1
	sub x4,x4,1 // arriba - 1
	sub x5,x5,1 // der -1
	sub x6,x6,1 // arriba - 1
	bl triangulo_peri
	sub x9,x9,1
	cbnz x9,lup


	ldur x3, [sp,0]
	ldur x4, [sp,8]
	ldur x5, [sp,16]
	ldur x6, [sp,24]
	ldur x9, [sp,32]
	ldur lr, [sp,40]
	add sp,sp,48

ret
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
    sub sp,sp, 72
	stur x8, [sp, 0]
    stur x7, [sp, 8]
    stur x3, [sp, 16]
	stur x4, [sp, 24]
	stur lr, [sp, 32]
    stur x10, [sp, 40]
    stur x9, [sp, 48]
    stur x5, [sp, 56]
    stur x6, [sp, 64]

    //hojas arbolas
    movz x10, 0x00, lsl 16
	movk x10, 0x8F12, lsl 00 // Verde arboles #008F1
    bl triangulo
	sub x9, x5, x3 //distancia entre x5 y x3
	lsr x9, x9, 3 // divido la distancia por 8

	//tronco
	movz x10, 0x4B, lsl 16
	movk x10, 0x2900, lsl 00 // Marron troncos #4B2900
	add x1, x3, x9
	add x1, x1, x9
	add x1, x1, x9 // x1 = x3+ 3*x9
	mov x2, x4 // x2 = y original del triangulo
	lsl x9, x9, 1
	mov x3, x9
	sub x4, x6, x8
	lsr x4, x4, 1

	bl cuadrado
    
	ldur x8, [sp, 0]
    ldur x7, [sp, 8]
    ldur x3, [sp, 16]
	ldur x4, [sp, 24]
	ldur lr, [sp, 32]
    ldur x10, [sp, 40]
    ldur x9, [sp, 48]
    ldur x5, [sp, 56]
    ldur x6, [sp, 64]
    add sp, sp, 72
ret // Un arbol tranqui

bomba:
		sub sp,sp,48
		stur x10,[sp,0]
		stur x17,[sp,8]
		stur x18,[sp,16]
		stur x19,[sp,24]
		stur x3,[sp,32]
		stur lr,[sp,40]
		//negro//
		movz x10,0x00,lsl 16
		movk x10,0x0000,lsl 00
		//unidad de rojo//
		movz x17, 0x01, lsl 16
		movk x17, 0x0000, lsl 00
		//rojo//
		movz x18, 0xFF, lsl 16
		movk x18, 0x0000, lsl 00
	radiobomba:
		mov x3, 30
	bombini:
		bl circulo
		sub x3,x3,1
		cbnz x3,bombini
		//delay//
		mov x19, DELAY
		lsl x19,x19,CUENTAREG
		delaybombi:
		sub x19,x19,1
		cbnz x19,delaybombi
      bl movimiento
		//delay end//
		add x10,x10,x17
		cmp x18,x10
		bgt radiobomba	
		//FFF000//
		mov x17,0
		movz x10, 0xFF, lsl 16
		movk x10, 0xF000, lsl 00
		mov x3, 1
	ondaexpansiva:
		bl circulo
		//delay//
		mov x19, DELAY
		lsl x19,x19,ONDEXPAN
	delayexp:
		sub x19,x19,1
        
		cbnz x19,delayexp
		//delayend//

		add x17,x17,1
		cmp x17,0xFF
		bgt nosuma
		add x10,x10,1
		nosuma:
		add x3,x3,1
		cmp x3,HUMO // radio
		ble ondaexpansiva
      bl backdia
		bl bomberquemado
	
		ldur x10,[sp,0]
		ldur x17,[sp,8]
		ldur x18,[sp,16]
		ldur x19,[sp,24]
		ldur x3,[sp,32]
		ldur lr,[sp,40]
		add sp,sp,48
ret // bomba //

sol:
	//sol fijo
	sub sp, sp, 72
    stur x3, [sp, 0]
    stur x11, [sp, 8]
    stur x12, [sp, 16]
    stur x10, [sp, 24]
    stur lr, [sp, 32]
    stur x1, [sp, 40]
    stur x2, [sp, 48]
    stur x13, [sp, 56]
    stur x14, [sp, 64]
    

	mov x3, 25
	mov x11, 450
	mov x12, 50
	movz x10, 0xFF, lsl 16
	movk x10, 0xB900, lsl 0
	mov x17, 25
	mov x1, x11
	sub x1, x1, x17
	mov x2, x12
	add x2, x2, x17
	mov x13, x11
	add x13, x13, x17
	mov x14, x12
	sub x14, x14, x17
	bl linea

	sub x1, x1, 15
	sub x2, x2, x17
	add x13, x13, 15
	add x14, x14, x17

	bl linea

	add x1, x1, 15
	sub x2, x2, x17
	sub x13, x13, 15
	add x14, x14, x17
	bl linea

	add x1, x1, x17
	sub x2, x2, 15
	sub x13, x13, x17
	add x14, x14, 15
	bl linea
	
	mov x3, 25
	mov x11, 450
	mov x12, 50
	sol_loop: 
		bl circulo
		sub x3,x3,1
		add x10, x10, 0x0200
	cbnz x3,sol_loop
	

    ldur x3, [sp, 0]
    ldur x11, [sp, 8]
    ldur x12, [sp, 16]
    ldur x10, [sp, 24]
    ldur lr, [sp, 32]
    ldur x1, [sp, 40]
    ldur x2, [sp, 48]
    ldur x13, [sp, 56]
    ldur x14, [sp, 64]
    add sp, sp, 72
ret //sol

luna:
	//luna fija
	sub sp, sp, 48
    stur x3, [sp, 0]
    stur x11, [sp, 8]
    stur x12, [sp, 16]
    stur x10, [sp, 24]
    stur x17, [sp, 32]
    stur lr, [sp, 40]
    
	mov x3, 25
	mov x11, 450
	mov x12, 50
	movz x10, 0xFE, lsl 16
	movk x10, 0xFDED, lsl 0
	mov x17, 25
	luna_loop: 
		bl circulo
		sub x3,x3,1
		sub x10, x10, 0x0101
	cbnz x3,luna_loop
	

    ldur x3, [sp, 0]
    ldur x11, [sp, 8]
    ldur x12, [sp, 16]
    ldur x10, [sp, 24]
    ldur x17, [sp, 32]
    ldur lr, [sp, 40]
    add sp, sp, 48
    ret
.endif
