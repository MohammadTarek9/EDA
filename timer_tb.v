`timescale 100ms/100ms
module timer_tb;

//Ports declaration
reg clk, reset, enable;
reg[15:0] clk_freq, timer_period;
wire done;

// Design instantiation
timer dut(clk, reset, enable, clk_freq, timer_period, done);

//Creating clock
initial begin
    clk = 0;
    forever begin
        #5 clk = ~clk;
    end
end

// driving dut inputs
initial begin
    enable = 1'b1;
    reset = 1'b0;
    clk_freq = 'd1;
    timer_period = 'd3;
end

endmodule