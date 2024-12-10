.global start
start:

// releases the peripheral reset for iobank_0
    ldr r0, =rst_clr    // atomic register for clearing reset controller (0x4000c000+0x3000)
    mov r1, #32         // load a 1 into bit 5
    str r1, [r0, #0]    // store the bitmask into the atomic register to clear register

// check if reset is done
rst:
    ldr r0, =rst_base   // base address for reset controller
    ldr r1, [r0, #8]    // offset to get to the reset_done register
    mov r2, #32         // load 1 in bit 5 of register 2 (...0000000000100000)
    and r1, r1, r2      // isolate bit 5
    beq rst              // if bit five is 0 then check again, if not, reset is done

// set the control for GPIO2 (instead of GPIO25)
    ldr r0, =ctrl        // control register for GPIO2
    mov r1, #5           // Function 5, select SIO for GPIO2
    str r1, [r0]         // Store function_5 in GPIO2 control register

// shifts over "1" the number of bits of GPIO pin (for GPIO2)
    mov r1, #1           // load a 1 into register 1
    lsl r1, r1, #2       // move the bit over to align with GPIO2 (shift by 2, as GPIO2 is at bit position 2)
    ldr r0, =sio_base    // SIO base
    str r1, [r0, #36]    // 0x20 GPIO output enable

led_loop:
    
    str r1, [r0, #20]    // 0x14 GPIO output value set
    ldr r3, =delay_cycles     // load countdown number
    bl delay                   // Branch to delay function
    
    // Turn LED OFF (GPIO2)
    str r1, [r0, #24]    // 0x18 GPIO output value clear
    ldr r3, =delay_cycles     // load countdown number
    bl delay                   // Branch to delay function 
    b led_loop                 // Repeat the loop

// Delay function for 133 MHz clock (approximate time delay)
delay:
    sub r3, #1           // subtract 1 from register 3
    bne delay            // loop back to delay if not zero
    bx lr                 // Return from function

// Data section for delay cycles (for 1-second delay)
data:
    .equ rst_clr, 0x4000f000   // atomic register for clearing reset controller 2.1.2
    .equ rst_base, 0x4000c000  // reset controller base 2.14.3
    .equ ctrl, 0x40014014      // GPIO2_CTRL (correct address for GPIO2)
    .equ sio_base, 0xd0000000  // SIO base 2.3.1.7
    .equ delay_cycles, 44000000   // large number for the delay loop 
