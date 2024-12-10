.global start

start:
    // Release the peripheral reset for iobank_0
    ldr r0, =rst_clr        // Atomic register for clearing reset controller
    mov r1, #32             // Load a 1 into bit 5
    str r1, [r0, #0]        // Store the bitmask into the atomic register to clear reset

rst: // Wait for reset to complete
    ldr r0, =rst_base       // Base address for reset controller
    ldr r1, [r0, #8]        // Offset to the reset_done register
    mov r2, #32             // Load 1 in bit 5
    and r1, r1, r2          // Isolate bit 5
    beq rst                 // If not done, loop

    // Set GPIO2, GPIO3, GPIO4, and GPIO5 to SIO function
    ldr r0, =ctrl           // Base address for GPIO control registers
    mov r1, #5              // Function 5 (SIO)

    str r1, [r0]            // GPIO2 control register
    add r0, #8              // Move to GPIO3 control register
    str r1, [r0]
    add r0, #8              // Move to GPIO4 control register
    str r1, [r0]
    add r0, #8              // Move to GPIO5 control register
    str r1, [r0]

    // Enable output for GPIO2, GPIO3, GPIO4, GPIO5
    ldr r0, =sio_base       // SIO base address
    mov r1, #1              // Load 1 into r1
    lsl r1, r1, #2          // Shift for GPIO2
    mov r2, r1              // Copy GPIO2 bitmask
    lsl r1, #1              // Shift for GPIO3
    orr r2, r2, r1          // Add GPIO3 bitmask
    lsl r1, #1              // Shift for GPIO4
    orr r2, r2, r1          // Add GPIO4 bitmask
    lsl r1, #1              // Shift for GPIO5
    orr r2, r2, r1          // Add GPIO5 bitmask
    str r2, [r0, #36]       // 0x20 GPIO output enable
    
    mov r4,#3     //(0011)
    mov r1,#3     //(0011)
    and r1,r1,r4       //for using compliment use MVN
    mov r3,r1            

led_loop:
    // Set GPIO pins based on input
    mov r1, r3              // Copy input value to r1
    lsl r1, #2              // Align bits with GPIO2 to GPIO5
    str r1, [r0, #20]       // Write to GPIO output value set (0x14)

    b led_loop              // Repeat loop

delay:
    sub r4, #1              // Subtract 1 from delay counter
    bne delay               // If not zero, loop
    bx lr                   // Return from subroutine

data:
.equ rst_clr, 0x4000f000    // Atomic reset clear register
.equ rst_base, 0x4000c000   // Reset controller base
.equ ctrl, 0x40014014       // GPIO2_CTRL (base address for GPIO2)
.equ sio_base, 0xd0000000   // SIO base
.equ big_num, 0x00f00000    // Large delay count

