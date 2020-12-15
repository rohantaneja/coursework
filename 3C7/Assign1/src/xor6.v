// THIS MODULE PERFORMS A BITWISE XOR ON TWO 6-BIT INPUTS USING THE 1-BIT XOR MODULES
module xor6
    (
    input wire [5:0] x, y,
    output wire [5:0] xor_6
    );
    // bitwise xor of 6-bit inputs using 1-bit xor modules
    xor1 xor_bit0 (.i0(x[0]), .i1(y[0]), .xor_1(xor_6[0])); 
    xor1 xor_bit1 (.i0(x[1]), .i1(y[1]), .xor_1(xor_6[1])); 
    xor1 xor_bit2 (.i0(x[2]), .i1(y[2]), .xor_1(xor_6[2])); 
    xor1 xor_bit3 (.i0(x[3]), .i1(y[3]), .xor_1(xor_6[3])); 
    xor1 xor_bit4 (.i0(x[4]), .i1(y[4]), .xor_1(xor_6[4])); 
    xor1 xor_bit5 (.i0(x[5]), .i1(y[5]), .xor_1(xor_6[5])); 
    
endmodule