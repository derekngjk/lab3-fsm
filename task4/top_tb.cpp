#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../vbuddy.cpp" // include vbuddy code
#define MAX_SIM_CYC 100000


int main(int argc, char **argv, char **env)
{
    int simcyc;     // simulation clock count
    int tick;       // each clk cycle has two ticks for two edges

    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    Vtop *top = new Vtop;
    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("top.vcd");

    // init Vbuddy
    if (vbdOpen() != 1)
        return (-1);
    vbdHeader("L3T3:FullF1");

    vbdSetMode(1);

    // initialize simulation inputs
    top->clk = 1;
    top->rst = 1;  // force reset on first 2 cycles
    top->N = vbdValue();  // vbdValue() = 42 gives approx 1s tick
    top->trigger = vbdFlag();

    // boolean to keep track of whether the stopwatch has been started
    bool is_timing = false;
    // boolean to keep track of whether we are in the midst of a sequence
    bool in_sequence = false;

    // run simulation for MAX_SIM_CYC clock cycles
    for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++)
    {
        // dump variables into VCD file and toggle clock
        for (tick = 0; tick < 2; tick++)
        {
            tfp->dump(2 * simcyc + tick);
            top->clk = !top->clk;
            top->eval();
        }

        vbdBar(top -> data_out & 0xFF);

        // set up input signals of testbench
        top->rst = (simcyc < 2); // assert reset for 1st cycle
        top->N = vbdValue();
        vbdCycle(simcyc);

        // suppose initially data_out is 0. Thus in_sequence is False
        // once the fsm starts counting up, then we set in_sequence to True, and it stays true while it counts up
        if (top -> data_out) {
            in_sequence = true;
        }
        int flag_val = vbdFlag();
        // if we are not currently timing, we can just set top -> trigger = flag_val which has the same behaviour as before
        // if we are at S0, this will kick off the sequence, else if we are not in S0, pressing the button doesn't do anything
        if (!is_timing) {
            top -> trigger = flag_val;
        }
        // else if we are timing, then we want the button press to just stop the stopwatch
        // we do not set top -> trigger = flag_val because we do not want this button press to trigger another sequence
        else if (flag_val) {
            is_timing = false;
            in_sequence = false;
            int rxntime = vbdElapsed();
            vbdHex(4, (rxntime >> 12) & 0xF);
            vbdHex(3, (rxntime >> 8) & 0xF);
            vbdHex(2, (rxntime >> 4) & 0xF);
            vbdHex(1, (rxntime) & 0xF);
        }
        // if the data_out is 0 (i.e. we are in S0), we first check if we are in_sequence
        // i.e. did the lights just go off. If so, we start timing
        if (top -> data_out == 0) {
            if (in_sequence) {
                is_timing = true;
                // very important to set this to false
                // because otherwise we will keep on entering here and resetting the start time
                in_sequence = false;
                vbdInitWatch();
            }
        }

        if (Verilated::gotFinish() || vbdGetkey() == 'q')
            exit(0);
    }

    vbdClose(); // ++++
    tfp->close();
    exit(0);
}
