// Listing 1.7
// The `timescale directive specifies that
// the simulation time unit is 1 ns  and
// the simulation timestep is 10 ps
`timescale 1 ns/10 ps

module geq2_testbench;
   // signal declaration
   reg  [7:0] test_in0, test_in1;
   wire  test_out;

   // instantiate the circuit under test
   geq2 uut
      (.a(test_in0), .b(test_in1), .ageqb(test_out));

   //  test vector generator
   initial
   begin
    $display ("time e0 e1 ageqb"); 
    $monitor ("%d %b % b %b" , 
        $time, test_in0 , test_in1 , test_out);
      // test vector 1
      // test vector 1
      test_in0 = 8'b00000000; //all changed to random 8-bit values
      test_in1 = 8'b00000000;
      # 200;
      // test vector 2
      test_in0 = 8'b00000101;
      test_in1 = 8'b00000010;
      # 200;
      // test vector 3
      test_in0 = 8'b00000100;
      test_in1 = 8'b00000010;
      # 200;
      // test vector 4
      test_in0 = 8'b00000010;
      test_in1 = 8'b00000101;
      # 200;
      // test vector 5
      test_in0 = 8'b00000100;
      test_in1 = 8'b00000011;
      # 200;
      // test vector 6
      test_in0 = 8'b00011000;
      test_in1 = 8'b01000010;
      # 200;
      // test vector 7
      test_in0 = 8'b01000010;
      test_in1 = 8'b01100101;
      # 200;
      // stop simulation

     $stop;
   end
   

endmodule