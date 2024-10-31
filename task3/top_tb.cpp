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
    vbdHeader("L3T2:Clktick");

    // initialize simulation inputs
    top->clk = 1;
    top->rst = 1;  // force reset on first 2 cycles
    top->en = 0;  // set en to constant 1
    top->N = vbdValue();  // vbdValue() = 42 gives approx 1s tick

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

        // internally, the top module will perform the necessary evaluation
        // so that whenever tick goes high on cycle i, the fsm will change state on cycle i + 1, thus changing data_out
        // so all we need to do is to simply read data out and pass it to vbdBar to toggle the lights
        vbdBar(top -> data_out & 0xFF);

        // set up input signals of testbench
        top->rst = (simcyc < 2); // assert reset for 1st cycle
        top->en = 1;
        top->N = vbdValue();
        vbdCycle(simcyc);

        if (Verilated::gotFinish() || vbdGetkey() == 'q')
            exit(0);
    }

    vbdClose(); // ++++
    tfp->close();
    exit(0);
}
