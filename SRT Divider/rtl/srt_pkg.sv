package srt_pkg;
    typedef enum logic [2:0] {
        LOAD_CMD, // Loading when start is high
        NORM_CMD, // store s (number of leading zeros), D = b << s, R = a, clear Qp and Qm
        RUN_CMD, // one SRT step
        FIX_CMD, // final quotient, corrected remainder (registered, not yet shifted)
        SHIFT_CMD, // remainder = corrected remainder >> s
        HOLD_CMD // keep all registers
    } srt_command_t;
endpackage
