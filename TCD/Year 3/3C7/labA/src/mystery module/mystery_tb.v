// Listing 1.7
// The `timescale directive specifies that
// the simulation time unit is 1 ns  and
// the simulation timestep is 10 ps
`timescale 1 ns/10 ps

module mystery_testbench;
   // signal declaration
   reg   test_in0, test_in1;
   wire  test_out;

   // instantiate the circuit under test
   mystery_module uut
      (.i0(test_in0), .i1(test_in1), .op(test_out));

   //  test vector generator
   initial
   begin
      // test vector 1
      test_in0 = 1'b0;
      test_in1 = 1'b0;
      # 200;
      // test vector 2
      test_in0 = 1'b1;
      test_in1 = 1'b0;
      # 200;
      // test vector 3
      test_in0 = 1'b0;
      test_in1 = 1'b1;
      # 200;
      // test vector 4
      test_in0 = 1'b1;
      test_in1 = 1'b1;
      # 200;
      
      // stop simulation
      $stop;
   end
   
   initial
    $monitor($stime,, test_in0,, test_in1,,, test_out); 

endmodule