// include header files
#include "Vf1_fsm.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "vbuddy.cpp"


// purpose of the test bench is to simulate the behaviour of the module under specified input conditions
int main(int argc, char **argv, char **env) {
    // i is number of cycles to simulate. clk varies between 0 and 1 to emulate the clock signal on each cycle
    int i;
    int clk;

    Verilated::commandArgs(argc, argv);
    // create top verilog instance which is the device under test (DUT)
    Vf1_fsm* top = new Vf1_fsm;
    // turn on signal tracing, and tell verilator to dump the waveform data to counter.cvd
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top -> trace(tfp, 99);
    tfp -> open("f1_fsm.vcd");

    // initialise vbuddy connection. port path is in vbuddy.cfg
    if (vbdOpen() != 1) return (-1);
    // note: will have error if the header name is too long
    vbdHeader("Lab 3: F1 light");

    // set the initial conditions of the top-level module
    top -> clk = 1;
    top -> rst = 1;
    top -> en = vbdFlag();
    vbdSetMode(1);

    // i is the index showing which clock cycle we are currently on
    for (i = 0; i < 30000; i++) {
        
        // on each cycle, we toggle clock two times so that clock switches between 0 and 1 on each cycle
        for (clk = 0; clk < 2; clk++) {
            // dump the variables into the vcd file
            tfp -> dump(2 * i + clk);  // units in ps
            top -> clk = !top -> clk;
            // eval basically sends the corresponding input signals into the module to update the output
            top -> eval();
        }

        // on cycle i = 2, we then set rst = 0 so that on cycle i = 3, we dump top -> rst = 0 into the vcd file
        // so only on cycle i = 4 (one cycle delay), then the fsm changes state (assuming en = 1)
        top -> rst = i < 2;
        // on each cycle, we set top -> en to be vbdFlag()
        // so that if we happen to press it on cycle i, then top -> en will be set to 1 on cycle i
        // then, on cycle i + 1, when we evaluate, the fsm will change state, and this change will be observed on cycle i + 2
        // but right after we read vbdFlag(), it goes back to 0 so en is only high for one cycle
        // so the fsm will change state then stay in its new state until we press the switch again
        top -> en = vbdFlag();
        // lastly, display the data_out using the light strip
        vbdBar(top -> data_out & 0xFF);
        vbdCycle(i + 1);

        if (Verilated::gotFinish() || vbdGetkey() == 113) exit(0);  // exit if completed or 'q' key pressed

    }

    tfp -> close();
    exit(0);

}