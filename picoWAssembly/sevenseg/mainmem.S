.global start
start:

// releases the peripheral reset for iobank_0
    ldr r0, =rst_clr        // atomic register for clearing reset controller (0x4000c000+0x3000)
    mov r1, #32             // load a 1 into bit 5
    str r1, [r0, #0]        // store the bitmask into the atomic register to clear register

// check if reset is done
rst:
    ldr r0, =rst_base       // base address for reset controller
    ldr r1, [r0, #8]        // offset to get to the reset_done register
    mov r2, #32             // load 1 in bit 5 of register 2 (...0000000000100000)
    and r1, r1, r2          // isolate bit 5
    beq rst                 // if bit five is 0 then check again, if not, reset is done

// set the control for GPIO2, GPIO3, GPIO4, and GPIO5
    ldr r0, =ctrl           // control register for GPIO2
    mov r1, #5              // Function 5, select SIO
    str r1, [r0]            // Store function_5 in GPIO2 control register

    add r0, #8              // control register for GPIO3
    str r1, [r0]            // Store function_5 in GPIO3 control register

    add r0, #8              // control register for GPIO4
    str r1, [r0]            // Store function_5 in GPIO4 control register

    add r0, #8              // control register for GPIO5
    str r1, [r0]            // Store function_5 in GPIO5 control register

    add r0, #8              // control register for GPIO6
    str r1, [r0]            // Store function_5 in GPIO6 control register

    add r0, #8              // control register for GPIO7
    str r1, [r0]            // Store function_5 in GPIO7 control register

    add r0, #8              // control register for GPIO8
    str r1, [r0]            // Store function_5 in GPIO8 control register

// enable output for GPIO2, GPIO3, GPIO4, and GPIO5,6,7 and 8
    ldr r0, =sio_base       // SIO base
    mov r1, #1              // load a 1 into register 1
    lsl r1, r1, #2          // shift to align with GPIO2
    mov r2, r1              // copy GPIO2 bitmask to r2
    lsl r1, #1              // shift to align with GPIO3
    orr r2, r2, r1          // combine GPIO2 and GPIO3 bitmasks
    lsl r1, #1              // shift to align with GPIO4
    orr r2, r2, r1          // combine GPIO4 bitmask
    lsl r1, #1              // shift to align with GPIO5
    orr r2, r2, r1          // combine GPIO5 bitmask
    lsl r1, #1              // shift to align with GPIO6
    orr r2, r2, r1          // combine GPIO5 and GPIO6 bitmasks
    lsl r1, #1              // shift to align with GPIO7
    orr r2, r2, r1          // combine GPIO7 bitmask
    lsl r1, #1              // shift to align with GPIO8
    orr r2, r2, r1          // combine GPIO8 bitmask
    str r2, [r0, #36]       // 0x20 GPIO output enable for all pins

    led_loop:
   // Set GPIO3, GPIO4, GPIO6, GPIO7, and GPIO8 high, GPIO2 and GPIO5 low
    mov r1, #1              // load 1 into r1
    lsl r1, r1, #3          // bitmask for GPIO3
    mov r3, r1              // copy GPIO3 bitmask to r3
    lsl r1, #1              // bitmask for GPIO4
    orr r3, r3, r1          // combine GPIO3 and GPIO4 bitmasks
    lsl r1, #2              // bitmask for GPIO6
    orr r3, r3, r1          // combine GPIO6 bitmask
    lsl r1, #1              // bitmask for GPIO7
    orr r3, r3, r1          // combine GPIO7 bitmask
    lsl r1, #1              // bitmask for GPIO8
    orr r3, r3, r1          // combine GPIO8 bitmask
    str r3, [r0, #20]       // 0x14 GPIO output value set (set GPIO3, GPIO4, GPIO6, GPIO7, GPIO8 high)

    mov r1, #1              // load 1 into r1
    lsl r1, r1, #2          // bitmask for GPIO2
    mov r4, r1              // copy GPIO2 bitmask to r4
    lsl r1, #3              // bitmask for GPIO5
    orr r4, r4, r1          // combine GPIO2 and GPIO5 bitmasks
    str r4, [r0, #24]       // 0x18 GPIO output value clear (GPIO2 and GPIO5 low)

    ldr r3, =big_num        // load countdown number
    bl delay                // branch to subroutine delay

    b led_loop              // do the loop again
    
delay:
    sub r3, #1              // subtract 1 from register 3
    bne delay               // loop back to delay if not zero
    bx lr                   // return from subroutine
    
data:    

.equ rst_clr, 0x4000f000    // atomic register for clearing reset controller
.equ rst_base, 0x4000c000   // reset controller base
.equ ctrl, 0x40014014       // GPIO2_CTRL (base address for GPIO2)
.equ sio_base, 0xd0000000   // SIO base
.equ big_num, 0x00f00000    // large number for the delay loop

