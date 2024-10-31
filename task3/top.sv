module top (
    input logic en,
    input logic rst,
    input logic clk,
    input logic[15:0] N,
    output logic[7:0] data_out
);

// intermediate signal, output of tick which goes to input of f1_fsm
logic tick;

clktick ticker1s (
    .rst (rst),
    .en (en),
    .clk (clk),
    .N (N),
    .tick (tick)
);

f1_fsm light_fsm (
    .rst (rst),
    .en (tick),
    .clk (clk),
    .data_out (data_out)
);

endmodule
