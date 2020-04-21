// Listing 1.4
module geq2
   (
    input  wire[1:0] a, b,			// a adn b are the two 2-bit numbers to compare
    output wire ageqb				// single bit output. Should be high if a adn b the same
   );

   // internal signal declaration, used to wire outpus of the 1 bit comparators
   wire e0, e1, e2;

   // body
   // instantiate two 1-bit comparators that we already know are tested and work
   // named instantiation allows us to change order of ports.
   geq1 geq_bit_unit (.i0(a[0]), .i1(b[0]), .j0(a[1]), .j1(b[1]), .eq(e0), .gt(e1)); // geq1 bit takes input and set output into e0 and e1

   // a and b are greater than OR equal, which comes from the 1-bit comparators
   assign ageqb = e0 | e1; // replace & with | for OR operation

endmodule