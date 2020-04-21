`timescale 1ns / 1ps

module lfsr_tb;
    reg clk, reset;
    wire max_tick;
    wire lfsr_out;
    
    lfsr uut(
        .clk(clk),
        .reset(reset),
        .lfsr_out(lfsr_out),
        .max_tick(max_tick)
    );
    // oscillate clock 20 ns period
    always
    begin
        clk = 1'b1; //high
        #10;
        clk = 1'b0; //low
        #10;
    end
    
    // reset for first 2 clock cycles
    initial
    begin
        reset = 1'b1;
        #200; // 10 clock cycles high reset
        reset = 1'b0;
    end
endmodule