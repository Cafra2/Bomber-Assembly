	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
	.equ BITS_PER_PIXEL, 32

	.equ GPIO_BASE,    0x3f200000
	.equ GPIO_GPFSEL0, 0x00
	.equ GPIO_GPLEV0,  0x34

	.equ BASE, 580
	.equ ALTURA, 390
	.equ X, 20
	.equ Y, 20

	.globl main

main:
	// x0 contiene la direccion base del framebuffer
	mov x20, x0 // Guarda la dirección base del framebuffer en x20
	//---------------- CODE HERE ------------------------------------

	// color w10 //
	//movz x10, 0xFF, lsl 16
	//movk x10, 0xFFFF, lsl 00

	// color random w11 //
	movz x19, 0xFF, lsl 16
	movk x19, 0xFFFF, lsl 00


	//mov x2, SCREEN_HEIGH         // Y Size
//loop1:
	//mov x1, SCREEN_WIDTH         // X Size
//loop0:
	//stur w10,[x0]  // Colorear el pixel N
	//add x0,x0,4    // Siguiente pixel
	//sub x1,x1,1    // Decrementar contador X
	//cbnz x1,loop0  // Si no terminó la fila, salto
	//sub x2,x2,1    // Decrementar contador Y
	//cbnz x2,loop1  // Si no es la última fila, salto

// linea //  


mov x9, 0
mov x10, 0
mov x13, 320
mov x14, 240
// le paso x0,y0 y x1,y1 //

//x9,x10 (primer par) | x13,x14 (segundo par) //

// x11 error , x15 2error | x16 (dx) , x17 (dy) //

sub x16, x13 , x9 // dx en x16

cmp x16,0
	bge no1
	neg x16,x16
	no1:

sub x17, x14, x10 // dy en x17

cmp x17,0
	ble no2
	neg x17,x17
	no2:

add x11, x16, x17 // error -> dx - dy

cmp x9,x13 // x0 < x1 
	mov x0, 1
	blt end1
	neg x0, x0 // sx x0
end1:

cmp x10,x14 // y0 < y1
	mov x1, 1
	blt end2
	neg x1, x1 // sy x1
end2:

	

loop_line:

	bl setpixel

	cmp x9,x13 
	bne continue
	
	cmp x10,x14
	bne continue
	b end_lup

	continue:
	
	mov x15, x11 // err2 = error
	lsl x15,x15,1

	cmp x15, x17 // e2 >= dy (if 1)
	blt c1
	add x11, x11, x17	// err + dy
	add x9,x9,x0 // x0 + sx
	c1: // si no se cumpla la condicion if1


	cmp x15, x16 // e2 <= dx (if 2)
	bgt c2
	add x11, x11, x16	// err + dx
	add x10,x10,x1 // y0 + sy
	c2: // si no se cumpla la condicion if2

b loop_line

end_lup:

b InfLoop



setpixel: 
    // Recibe dos coordenadas y pinta el pixel con el color dado
    // X:x9, Y:x10, COLOR:w19
    sub sp,sp, 24
    stur x9, [sp, 0]
    stur x10, [sp, 8]
    stur x3, [sp, 16]

    coord:
        // x3 = Dirección de inicio + 4 * [x + (y * 640)]
        mov x3, 640    // x3 =   640
        mul x3, x3, x10 // x3 =   640*y
        add x3, x3, x9 // x3 =  (640*y)+x
        lsl x3, x3, 2  // x3 = [(640*y)+x]*4
        add x3, x3, x20 // x3 = [(640*y)+x]*4 + Direccion de inicio
    //

    stur w19, [x3] // Colorea el pixel en la posicion calculada

    ldur x9, [sp, 0]
    ldur x10, [sp, 8]
    ldur x3, [sp, 16]
    add sp,sp, 24
blr x30 // Recibe dos coordenadas y pinta el pixel con el color dado
//-------------------------------------------------------------------------------------------


InfLoop:
	b InfLoop


