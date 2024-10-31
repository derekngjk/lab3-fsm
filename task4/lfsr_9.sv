module lfsr_9 (
    input   logic       clk,
    input   logic       rst,
    input   logic       en,
    output  logic [8:0] data_out
);

// initialise 9-bit shift register to 1
logic[8:0] sreg = 9'b1;

always_ff @ (posedge clk, posedge rst)
    // async reset to 1
    if (rst)
        sreg <= 9'b1;
    // else if en, perform shift and pass bit 3 and bit 7 XORed to LSB
    else if (en)
        sreg <= {sreg[7:0], sreg[3] ^ sreg[8]};

assign data_out = sreg;

endmodule
