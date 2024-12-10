.global start
start:

// Step 1: Release reset for IO_BANK0 and PWM peripherals
    ldr r0, =rst_clr       // Clear reset for IO_BANK0
    mov r1, #32            // Bit 5 for IO_BANK0
    str r1, [r0, #0]       // Write to reset control register to clear the reset

// Step 2: Wait for reset to complete
rst:
    ldr r0, =rst_base      // Base address of the reset controller
    ldr r1, [r0, #8]       // Load reset_done register
    mov r2, #32            // Check bit 5 (IO_BANK0 reset status)
    and r1, r1, r2         // Isolate bit 5
    beq rst                // If reset not done, loop again

// Step 3: Configure GPIO2 for PWM function (GPIO2_CTRL is set to Function 4 for PWM)
    ldr r0, =ctrl          // GPIO2 control register address
    mov r1, #4             // Function 4 for PWM
    str r1, [r0]           // Set GPIO2 to PWM function

// Step 4: Enable GPIO2 as output in SIO (Serial IO) block
    mov r1, #1             // Load a 1 into register to enable output
    lsl r1, r1, #2         // Shift left by 2 to align with GPIO2 (bit position 2)
    ldr r0, =sio_base      // Load base address for SIO
    str r1, [r0, #36]      // Set GPIO2 to output (bit 2 of the GPIO output enable )

// Step 5: Configure PWM for 50% duty cycle
    ldr r0, =pwm_ch0_top   // PWM CH0_TOP register address
    mov r1, #1000          // Set the TOP value to 1000 (period)
    str r1, [r0]           // Write the period to the TOP register

    ldr r0, =pwm_ch0_cc    // PWM CH0_CC register address
    mov r1, #500           // Set the compare value to 500 (50% of TOP)
    str r1, [r0]           // Write the compare value to the CC register

// Step 6: Enable the PWM channel to start output
    ldr r0, =pwm_ch0_csr   // PWM CH0_CSR register address
    mov r1, #1             // Set bit 0 to enable PWM channel 0
    str r1, [r0]           // Write to CSR register to enable PWM output

// Step 7: Loop indefinitely to keep the PWM running
loop:
    b loop                 // Infinite loop to keep the program running

// Data section
.equ rst_clr, 0x4000f000      // Reset control clear register
.equ rst_base, 0x4000c000     // Reset controller base address
.equ ctrl, 0x40014000         // GPIO2_CTRL register (set GPIO2 to PWM)
.equ sio_base, 0xd0000000     // SIO base address for GPIO output enable
.equ pwm_ch0_top, 0x40050010  // PWM CH0_TOP register address (slice 0)
.equ pwm_ch0_cc, 0x4005000c   // PWM CH0_CC register address (slice 0)
.equ pwm_ch0_csr, 0x40050000  // PWM CH0_CSR register address (slice 0)

