`timescale 1ns / 1ps
module advance_tb;
    reg clk, reset;
    wire max_tick;
    wire lfsr_out;
    wire [12:0] count_zero;
    wire [12:0] count_one;
    
    advance uut ( // Instantiate the Advance module
        .clk(clk),
        .reset(reset),
        .count_zero(count_zero),
        .count_one(count_one),
        .max_tick(max_tick),
        .lfsr_out(lfsr_out)
        );
        
    always
    // oscillate clock 20 ns period
    begin
        clk = 1'b1; //high
        #10;
        clk = 1'b0; //low
        #10;
    end
    initial
    begin
        reset = 1'b1;
        #200; // 10 clock cycles high reset
        reset = 1'b0;
    end
endmodule