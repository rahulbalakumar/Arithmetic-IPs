package mul_pkg;
    typedef enum logic [1:0] {
        LOAD_CMD, // Capture operands, clear the upper half of the product
        RUN_CMD,  // One add-and-shift step
        HOLD_CMD  // Keep all registers
    } command;
endpackage
