// Listing 1.4
module eq2
   (
    input  wire[1:0] a, b,			// a adn b are the two 2-bit numbers to compare
    output wire aeqb				// single bit output. Should be high if a adn b the same
   );

   // internal signal declaration, used to wire outpus of the 1 bit comparators
   wire e0, e1;

   // body
   // instantiate two 1-bit comparators that we already know are tested and work
   // named instantiation allows us to change order of ports.
   eq1 eq_bit0_unit (.i0(a[0]), .i1(b[0]), .eq(e0));
   eq1 eq_bit1_unit (.eq(e1), .i0(a[1]), .i1(b[1])); // rename eq3 -> eq1 and add ';' (semicolon)

   // a and b are equal if individual bits are equal, which comes from the 1-bit comparators
   assign aeqb = e0 & e1; // replace ^ with & for AND operation

endmodule