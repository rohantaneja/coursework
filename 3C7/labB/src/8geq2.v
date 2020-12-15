// Listing 1.4
module geq2
   (
    input  wire[7:0] a, b,			// a adn b are the two 2-bit numbers to compare
    output wire ageqb				// single bit output. Should be high if a adn b the same
   );

   // internal signal declaration, used to wire outpus of the 1 bit comparators
   wire e0, e1, e2, e3, e4, e5, e6, e7;
   wire m0, m1, m2, m3; // misc possibility check
   // body
   // instantiate two 1-bit comparators that we already know are tested and work
   // named instantiation allows us to change order of ports.
   geq1 geq_67bit_unit (.i0(a[6]), .i1(b[6]), .j0(a[7]), .j1(b[7]), .eq(e0), .gt(e1));
   geq1 geq_45bit_unit (.i0(a[4]), .i1(b[4]), .j0(a[5]), .j1(b[5]), .eq(e2), .gt(e3));
   geq1 geq_23bit_unit (.i0(a[2]), .i1(b[2]), .j0(a[3]), .j1(b[3]), .eq(e4), .gt(e5));
   geq1 geq_01bit_unit (.i0(a[0]), .i1(b[0]), .j0(a[1]), .j1(b[1]), .eq(e6), .gt(e7));

   assign m0 = e0 & e3;
   assign m1 = e0 & e2 & e5;
   assign m2 = e0 & e2 & e4 & e6;
   assign m3 = e0 & e2 & e4 & e7;
   
   // a and b are greater than OR equal, which comes from the 1-bit comparators
   assign ageqb = e1 | m0 | m1 | m2 | m3;

endmodule