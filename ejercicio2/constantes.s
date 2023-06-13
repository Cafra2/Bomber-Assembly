.ifndef __constantes__
.equ __constantes__, 0

// Pantalla, GPIO -----------------------------------------------------------------
.equ SCREEN_WIDTH,   640
.equ SCREEN_HEIGH,   480
.equ BITS_PER_PIXEL, 32

.equ GPIO_BASE,    0x3f200000
.equ GPIO_GPFSEL0, 0x00
.equ GPIO_GPLEV0,  0x34
//----------------DELAY----------------------------------------------------------
.equ DELAY, 0xAA
.equ CUENTAREG, 11 // para lsl
.equ ONDEXPAN, 13 
.equ HUMO, 900 //
.equ TECLAD, 12 
//---------------------------------------------------------------------------------

.endif
