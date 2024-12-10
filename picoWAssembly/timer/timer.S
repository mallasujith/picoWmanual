@ Single LED blink using timer interrupts on Raspberry Pi Pico

#include "hardware/regs/addressmap.h"
#include "hardware/regs/sio.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/pads_bank0.h"
#include "hardware/regs/m0plus.h"

	.EQU LED_PIN, 2
	.EQU alarm0_isr_offset, 0x40

.thumb_func
.global main

	.align 4
main:
	BL stdio_init_all    @ Initialize UART or USB

	@ Initialize the LED pin and set it to output
	MOV R0, #LED_PIN
	BL gpioinit

	@ Set the interrupt handler for alarm 0
	BL set_alarm0_isr

	@ Set the first alarm with a 1-second delay (1,000,000 us)
	LDR R0, =3000000
	BL set_alarm0

	@ Main loop
loop:
	B loop            @ Loop forever

set_alarm0:
	@ Sets the next alarm on alarm 0 (R0 is the delay time in microseconds)

	@ Enable timer 0 interrupt
	LDR R2, timerbase
	MOV R1, #1
	STR R1, [R2, #TIMER_INTE_OFFSET]

	@ Set the alarm
	LDR R1, [R2, #TIMER_TIMELR_OFFSET]
	ADD R1, R0
	STR R1, [R2, #TIMER_ALARM0_OFFSET]

	BX LR

.thumb_func
@ Alarm 0 interrupt handler
alarm_isr:
	PUSH {LR}           @ Save return address

	@ Clear the interrupt
	LDR R2, timerbase
	MOV R1, #1
	STR R1, [R2, #TIMER_INTR_OFFSET]

	@ Toggle the LED
	MOV R0, #LED_PIN
	BL gpio_toggle

	@ Set the next alarm with a 1-second delay
	LDR R0, =3000000
	BL set_alarm0

	POP {PC}            @ Return from interrupt

set_alarm0_isr:
	@ Set IRQ Handler to our routine
	LDR R2, ppbbase
	LDR R1, vtoroffset
	ADD R2, R1
	LDR R1, [R2]
	MOV R2, #alarm0_isr_offset
	ADD R2, R1
	LDR R0, =alarm_isr
	STR R0, [R2]

	@ Enable alarm 0 IRQ (clear and set)
	MOV R0, #1
	LDR R2, ppbbase
	LDR R1, clearint
	ADD R1, R2
	STR R0, [R1]
	LDR R1, setint
	ADD R1, R2
	STR R0, [R1]

	BX LR

gpioinit:
	@ Initialize the GPIO
	MOV R3, #1
	LSL R3, R0
	LDR R2, gpiobase
	STR R3, [R2, #SIO_GPIO_OE_SET_OFFSET]
	STR R3, [R2, #SIO_GPIO_OUT_CLR_OFFSET]

	@ Enable input and output for the pin
	LDR R2, padsbank0
	LSL R3, R0, #2
	ADD R2, R3
	MOV R1, #PADS_BANK0_GPIO0_IE_BITS
	STR R1, [R2]

	@ Set the function number to SIO
	LSL R0, #3
	LDR R2, iobank0
	ADD R2, R0
	MOV R1, #IO_BANK0_GPIO3_CTRL_FUNCSEL_VALUE_SIO_3
	STR R1, [R2, #IO_BANK0_GPIO0_CTRL_OFFSET]
	BX LR

gpio_toggle:
	@ Toggle the GPIO pin
	LDR R2, gpiobase
	MOV R3, #1
	LSL R3, R0
	LDR R1, [R2, #SIO_GPIO_OUT_XOR_OFFSET]
	STR R3, [R2, #SIO_GPIO_OUT_XOR_OFFSET]
	BX LR

	.align 4
gpiobase:    .word SIO_BASE
iobank0:     .word IO_BANK0_BASE
padsbank0:   .word PADS_BANK0_BASE
timerbase:   .word TIMER_BASE
ppbbase:     .word PPB_BASE
vtoroffset:  .word M0PLUS_VTOR_OFFSET
clearint:    .word M0PLUS_NVIC_ICPR_OFFSET
setint:      .word M0PLUS_NVIC_ISER_OFFSET

