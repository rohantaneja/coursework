module ripple_adder
    (   input wire [5:0] x, [5:0] y, sel, // x and y are the 6-bit two's complement numbers to be added
                                          // sel = 0 for add || sel = 1 for sub
      
        output wire overflow,[5:0] sum, [6:0] c_out  // overflow flag for output
                                                     // c_out is the MSB carry out from the sum
                                                     // sum is the sum of a and b
    );

    assign overflow = c_out[6] ^ c_out[5] ;
    // Overflow in two's complement addition is defined as
    // XOR of carry_in and carry_out of MSB adder

    // initialise LSB of c_out to 0 (since there is no carry_in on first adder)
    assign c_out[0] = 1'b0;

    FullAdder adder_1(.a(x[0]),.b(y[0] ^ sel), .cin(sel), .s(sum[0]), .cout(c_out[1]));
    FullAdder adder_2(.a(x[1]),.b(y[1] ^ sel), .cin(c_out[1]), .s(sum[1]), .cout(c_out[2]));
    FullAdder adder_3(.a(x[2]),.b(y[2] ^ sel), .cin(c_out[2]), .s(sum[2]), .cout(c_out[3]));
    FullAdder adder_4(.a(x[3]),.b(y[3] ^ sel), .cin(c_out[3]), .s(sum[3]), .cout(c_out[4]));
    FullAdder adder_5(.a(x[4]),.b(y[4] ^ sel), .cin(c_out[4]), .s(sum[4]), .cout(c_out[5]));
    FullAdder adder_6(.a(x[5]),.b(y[5] ^ sel), .cin(c_out[5]), .s(sum[5]), .cout(c_out[6]));
    
    // .b(y[i] ^ sel) - this will negate bits if performing subtraction
endmodule
