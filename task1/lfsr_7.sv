module lfsr_7 (
    input   logic       clk,
    input   logic       rst,
    input   logic       en,
    output  logic [6:0] data_out
);

// initialise 7-bit shift register to 1
logic[6:0] sreg = 7'b1;

always_ff @ (posedge clk, posedge rst)
    // async reset to 1
    if (rst)
        sreg <= 7'b1;
    // else if en, perform shift and pass bit 3 and bit 7 XORed to LSB
    else if (en)
        sreg <= {sreg[5:0], sreg[2] ^ sreg[6]};

assign data_out = sreg;

endmodule
