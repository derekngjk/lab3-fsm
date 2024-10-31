module lfsr(
    input   logic       clk,
    input   logic       rst,
    input   logic       en,
    output  logic [3:0] data_out
);

/*
First, the line logic[3:0] sreg = 4'b1 declares the sreg variable and assigns it a value of 1
This is an initialisation step which is performed once upon initialisation
This is an important step because otherwise if we just enter the always_ff loop, sreg will be undefined
So the initialisation step helps to ensure that the sreg starts out with value 1
Then, we have an async reset such that whenever rst goes high, we set the sreg back to 1
Otherwise if we have en high, then during a clock rising edge we do the shifts accordingly.
*/

logic[3:0] sreg = 4'b1;

always_ff @ (posedge clk, posedge rst)
    if (rst)
        sreg <= 4'b1;
    else if (en) begin
        sreg <= {sreg[2:0], sreg[3] ^ sreg[2]};
    end

assign data_out = sreg;

endmodule
