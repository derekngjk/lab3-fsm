module clktick #(
    parameter WIDTH = 8
)(
  // interface signals
  input  logic             clk,      // clock 
  input  logic             rst,      // reset
  input  logic             en,       // enable signal
  input  logic [WIDTH-1:0] N,     	 // clock divided by N+1
  output logic  		   tick      // tick output
);

logic [WIDTH-1:0] count;

/*
How this works: basically we want a component that takes in a clock,
and produces a pulse lasting for one cycle every N + 1 cycles
Internally, this uses a counter. If reset is high, we set the counter to N
Then, on every rising edge of the clock, we check the value of count.
If count is non-zero, then we keep tick (the output) low, and decrement count by 1 every cycle.
Once count has reached 0, then on the rising edge of the clock, we set the output to 1, and reset count to N
So for example: we set N = 3
So we have a table for the values of N and tick at the start of each cycle
i    | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 
N    | 3 | 2 | 1 | 0 | 3 | 2 | 1 | 0 | 3
tick | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1
So we see that tick becomes 1 every (N + 1) i.e. 4 cycles
Note that there is a delay. i.e. at the begining of cycle 3, N = 0 but tick is still 0.
It is only at the begining of cycle 4 that tick is 1.
*/

always_ff @ (posedge clk, posedge rst)
    if (rst) begin
        tick <= 1'b0;
        count <= N;  
        end
    else if (en) begin
        if (count == 0) begin
            tick <= 1'b1;
            count <= N;
            end
        else begin
            tick <= 1'b0;
            count <= count - 1'b1;
            end
        end
endmodule
