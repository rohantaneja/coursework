
module ripple_adder
  //I/O
  (
  //x and y are the 6-bit inputs to add
  //sel is the selection of add or subtract
  input wire [5:0] in_x, y,
  input wire sel,
  
  //sum is the sum of in_x and y. 
  //c_out is the MSB carry out bit
  //overflow is the overflow flag
  output wire[5:0] sum, 
  output wire c_out, overflow
  );
  
  //these are the carry outs of the individual adders
  wire [5:0] carries;
  
  //temp variable for bits in y
  wire [5:0] temp;
  
  //Invert bits in y if sel is high (subtraction)
  assign temp[0] = y[0] ^ sel;
  assign temp[1] = y[1] ^ sel;
  assign temp[2] = y[2] ^ sel;
  assign temp[3] = y[3] ^ sel;
  assign temp[4] = y[4] ^ sel;
  assign temp[5] = y[5] ^ sel;
  
  //body
  //using the full adder for each bit of the 6 bit numbers
  FullAdder add_bit_0 (.a(in_x[0]), .b(temp[0]), .cin(sel), .s(sum[0]), .cout(carries[0]));
  FullAdder add_bit_1 (.a(in_x[1]), .b(temp[1]), .cin(carries[0]), .s(sum[1]), .cout(carries[1]));
  FullAdder add_bit_2 (.a(in_x[2]), .b(temp[2]), .cin(carries[1]), .s(sum[2]), .cout(carries[2]));
  FullAdder add_bit_3 (.a(in_x[3]), .b(temp[3]), .cin(carries[2]), .s(sum[3]), .cout(carries[3]));
  FullAdder add_bit_4 (.a(in_x[4]), .b(temp[4]), .cin(carries[3]), .s(sum[4]), .cout(carries[4]));
  FullAdder add_bit_5 (.a(in_x[5]), .b(temp[5]), .cin(carries[4]), .s(sum[5]), .cout(carries[5]));
  
  //the carry out of the ripple adder
  assign c_out = carries[5];
  
  //overflow is true if MSB(in_x) = MSB(b) and MSB(sum) \= MSB(in_x)
  assign overflow = c_out ^ carries[4];
  
endmodule