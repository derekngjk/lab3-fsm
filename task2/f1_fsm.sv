module f1_fsm (
    input   logic       rst,
    input   logic       en,
    input   logic       clk,
    output  logic [7:0] data_out
);


// Define states: this means that light_state can take on S0, S1, S2 ... S8
// We map S0 as the state will all 0s (i.e. 0 ones), S1 be 00000001, S8 be 8 1s i.e. 11111111 etc
typedef enum {S0, S1, S2, S3, S4, S5, S6, S7, S8} light_state;
// we keep track of two states, the current state and the next state
light_state curr_state, next_state;

// update the states on each clock cycle or async reset
always_ff @ (posedge clk, posedge rst)
    if (rst) curr_state <= S0;  // if reset, set back to 00000000
    else if (en) curr_state <= next_state;  // if en, set curr state to next state, else leave curr state alone

// logic to decide what is the next state
// so this combinational logic will update the next_state,
// but the next state will only be assigned to the curr state on a posedge clk when en is high
always_comb begin
    case (curr_state)
        S0: next_state = S1;
        S1: next_state = S2;
        S2: next_state = S3;
        S3: next_state = S4;
        S4: next_state = S5;
        S5: next_state = S6;
        S6: next_state = S7;
        S7: next_state = S8;
        S8: next_state = S0;
        default: next_state = S0;
    endcase
end

// output logic
always_comb
    case (curr_state)
        S0: data_out = 8'b00000000;
        S1: data_out = 8'b00000001;
        S2: data_out = 8'b00000011;
        S3: data_out = 8'b00000111;
        S4: data_out = 8'b00001111;
        S5: data_out = 8'b00011111;
        S6: data_out = 8'b00111111;
        S7: data_out = 8'b01111111;
        S8: data_out = 8'b11111111;
        default: data_out = 8'b00000000;
    endcase

endmodule
