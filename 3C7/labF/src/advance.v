`timescale 1ns / 1ps
module advance (
    input wire clk, reset,
    output wire [12:0] lfsr_out,
    output reg [12:0] count_one,
    output reg [12:0] count_zero,
    output reg max_tick
    );
    localparam lfsr_seed = 13'b1000000001101; // a seed value
    //signal declaration
    reg [12:0] lfsr_reg; // register storage
    reg [12:0] lfsr_next; // next value
    reg lfsr_tap; // to hold feedback
    
    integer cycle_ctr; // count the number of lfsr cycles
    
    always @(posedge clk, posedge reset) // always run on pos clk and reset
        if (reset)
            begin
                lfsr_reg <= lfsr_seed;
                max_tick <= 1'b0; // reset max_tick
                count_zero <= 13'b0000000000000;
                count_one <= 13'b0000000000000;
                cycle_ctr <= 0; // reset cycle counter
            end
        else
            begin
                lfsr_reg <= lfsr_next;
                cycle_ctr <= cycle_ctr + 1;
                if (cycle_ctr == 2**13 - 1) // max_tick goes high after 2^N -1 cycles
                    begin
                    max_tick <= 1'b1;
                    count_zero <= 13'b0000000000000;
                    count_one <= 13'b0000000000000;
                    end
                else
                    max_tick <= 1'b0;
                    begin
                        if (lfsr_out == 1'b1)
                        count_one = count_one + 1;
                    else if (lfsr_out == 1'b0)
                        count_zero = count_zero + 1;
                    end
            end

    // next-state logic
    always @*
    begin
        lfsr_tap = lfsr_reg[0] ^ lfsr_reg[2] ^ lfsr_reg[3] ^ lfsr_reg[12];
        // For 13 bit lfsr, generate the feedback by XOR of tap 1st, 3rd, 4th, 13th bits
        // refer from XAPP 052, 1996 issue
        
        lfsr_next = {lfsr_reg[11:0],lfsr_tap}; 
        // tap feedback goes at 0 position. other goes shift up
    end 
    
    // output logic
    assign lfsr_out = lfsr_reg[12];
    
endmodule