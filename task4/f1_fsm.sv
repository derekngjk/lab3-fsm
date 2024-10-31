module f1_fsm (
    input   logic       rst,
    input   logic       en,
    input   logic       clk,
    input   logic       trigger,
    output  logic [7:0] data_out,
    output  logic       cmd_delay,
    output  logic       cmd_seq
);

typedef enum {S0, S1, S2, S3, S4, S5, S6, S7, S8} light_state;
light_state curr_state, next_state;

// initialise cmd_seq and cmd_delay to 0
assign cmd_seq = 0;
assign cmd_delay = 0;

// update the states on each clock cycle or async reset or async trigger
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

/*
We make the modification such that initially cmd_seq and cmd_delay are set to 0, and we are in state 0
When we push the switch and set trigger = 1, we asynchronously update cmd_seq = 1
This will allow the 1s ticks from clktick.sv to enable the FSM such that the FSM will start changing states every second
Note that when we are in S0, we update cmd_seq = 1 if trigger = 1, else we leave cmd_seq alone.
This means that once we set cmd_seq = 1 due to the trigger, we do not reset it back to 0 and block the en signal from clktick
Instead even after the trigger goes low, cmd_seq remains high so that the en signal from clktick can come in and update the FSM
Note also that trigger only has an effect when we are in S0. If we are in other states, the trigger doesn't do anything
Then once we are in the other states, we also do not update cmd_seq so it remains high
It is only once we are in S8, we set cmd_seq = 0 so that we transmit the time_out signal as the enable
Whereas for cmd_delay, once we are in S8, we set cmd_delay = 1, to wait for the en signal time_out
Then once the signal comes and we go back to S0, we set cmd_delay back to 0
In between on other states, we also do not update cmd_delay
*/

// output logic
always_comb
    case (curr_state)
        S0: begin
            data_out = 8'b00000000;
            if (trigger) cmd_seq = 1'b1;
            cmd_delay = 1'b0;
        end
        S1: data_out = 8'b00000001;
        S2: data_out = 8'b00000011;
        S3: data_out = 8'b00000111;
        S4: data_out = 8'b00001111;
        S5: data_out = 8'b00011111;
        S6: data_out = 8'b00111111;
        S7: data_out = 8'b01111111;
        S8: begin
            data_out = 8'b11111111;
            cmd_seq = 1'b0;
            cmd_delay = 1'b1;
        end
        default: begin
            data_out = 8'b00000000;
            cmd_seq = 1'b0;
            cmd_delay = 1'b0;
        end
    endcase

endmodule
