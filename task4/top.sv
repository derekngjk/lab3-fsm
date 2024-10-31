module top (
    input logic[7:0] N,   // for clktick
    input logic rst,      // reset
    input logic clk,
    input logic trigger,  // trigger for f1_fsm
    output logic[7:0] data_out
);

// intermediate signals
// the output of f1_fsm fed back into clktick and delay
// both default to 0
logic cmd_seq;
logic cmd_delay;

// intermediate signal
logic tick;  // output of clktick
logic[6:0] prbs;  // output of pseudo random binary module
logic time_out;

clktick ticker1s (
    .rst (rst),
    .clk (clk),
    .en (cmd_seq),
    .N (N),
    .tick (tick)
);

lfsr_7 prb_generator(
    .clk (clk),
    .rst (rst),
    .en (1'b1),  // always enable random generator
    .data_out (prbs)
);

delay delay_random(
    .clk (clk),
    .rst (rst),
    .trigger (cmd_delay),
    .n (prbs),
    .time_out (time_out)
);

f1_fsm light_fsm(
    .rst (rst),
    .en (cmd_seq ? tick : time_out),
    .clk (clk),
    .trigger (trigger),
    .data_out (data_out),
    .cmd_delay (cmd_delay),
    .cmd_seq (cmd_seq)
);

endmodule
