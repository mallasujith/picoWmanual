.global start
start:

    // Release the peripheral reset for IO_BANK0
    ldr r0, =rst_clr          // Atomic register for clearing reset (0x4000c000 + 0x3000)
    mov r1, #32               // Load a 1 into bit 5 (IO_BANK0 reset clear)
    str r1, [r0, #0]          // Store the bitmask to clear reset

// Check if reset is done
rst:
    ldr r0, =rst_base         // Base address for reset controller
    ldr r1, [r0, #8]          // Offset to read RESET_DONE register
    mov r2, #32               // Load mask for bit 5
    and r1, r1, r2           // Isolate bit 5
    beq rst                   // If bit 5 is 0, check again

// Set the control for GPIO2, GPIO3, GPIO4, and GPIO5
    ldr r0, =ctrl             // GPIO control register for GPIO2
    mov r1, #5                // Function 5: Select SIO
    str r1, [r0]              // Set function for GPIO2
    add r0, r0, #8            // Increment to GPIO3 control register
    str r1, [r0]              // Set function for GPIO3
    add r0, r0, #8            // Increment to GPIO4 control register
    str r1, [r0]              // Set function for GPIO4
    add r0, r0, #8            // Increment to GPIO5 control register
    str r1, [r0]              // Set function for GPIO5

// Enable output for GPIO2, GPIO3, GPIO4, and GPIO5
    ldr r0, =sio_base         // Load SIO base address
    mov r1, #1                // Load 1 into r1
    lsl r1, r1, #2            // Shift to align with GPIO2
    mov r2, r1                // Copy GPIO2 bitmask to r2
    lsl r1, r1, #1            // Shift to align with GPIO3
    orr r2, r2, r1            // Combine GPIO2 and GPIO3 bitmasks
    lsl r1, r1, #1            // Shift to align with GPIO4
    orr r2, r2, r1            // Combine GPIO4 bitmask
    lsl r1, r1, #1            // Shift to align with GPIO5
    orr r2, r2, r1            // Combine GPIO5 bitmask
    str r2, [r0, #36]         // Write to GPIO output enable register

// Initialize SRAM with numbers 0-9
    ldr r0, =ram_start        // Load SRAM base address
    mov r1, #0                // Initialize value to store
    mov r2, #10               // Loop counter for numbers 0-9

init_loop:
    str r1, [r0]              // Store r1 at SRAM address
    add r0, r0, #4            // Increment address by 4
    add r1, r1, #1            // Increment number
    sub r2, r2, #1           // Decrement loop counter
    bne init_loop             // Repeat until all numbers are written

// Start the main loop
main_loop:
    ldr r2, =ram_start        // Reload SRAM base address
    mov r3, #10               // Loop counter for 10 numbers

display_loop:
    ldr r1, [r2]              // Load number from SRAM
    add r2, r2, #4            // Increment address by 4
    lsl r1, r1, #2            // Shift left to align with GPIO 2-5
    str r1, [r0, #0x10]       // Write to GPIO output (GPIO_OUT register)
    bl delay                  // Call delay subroutine
    sub r3, r3, #1           // Decrement loop counter
    bne display_loop          // Repeat for all numbers

    b main_loop               // Repeat forever

// Delay subroutine
delay:
    push {r0, r1, r2}         // Save registers
    ldr r0, =0x100000         // Load delay count
delay_loop:
    sub r0, r0, #1           // Decrement delay counter
    bne delay_loop            // Wait until counter reaches 0
    pop {r0, r1, r2}          // Restore registers
    bx lr                     // Return from subroutine

// Constants
.equ rst_clr, 0x4000f000      // Atomic reset clear register
.equ rst_base, 0x4000c000     // Reset controller base address
.equ ctrl, 0x40014014         // GPIO control register for GPIO2
.equ sio_base, 0xd0000000     // SIO base address
.equ ram_start, 0x20000000    // SRAM base address

