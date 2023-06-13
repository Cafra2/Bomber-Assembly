.ifndef __constantes__
.equ __constantes__, 0

// Pantalla, GPIO -----------------------------------------------------------------
.equ SCREEN_WIDTH,   640
.equ SCREEN_HEIGH,   480
.equ BITS_PER_PIXEL, 32

.equ GPIO_BASE,    0x3f200000
.equ GPIO_GPFSEL0, 0x00
.equ GPIO_GPLEV0,  0x34
.equ DELAY, 0xFFF// delay base
.equ CUENTAREG, 1 // para lsl
.equ ONDEXPAN, 5 // delay de onda expansiva
.equ HUMO, 1000 // radio del humo
.equ TECLAD, 6 // delay de la tecla
//---------------------------------------------------------------------------------

.endif
