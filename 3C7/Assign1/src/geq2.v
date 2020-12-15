// Listing 1.1
module geq2
   // I/O ports
   (
    input  wire[1:0] a, b,
    output wire agrb
   );

   // signal declaration
   wire p0, p1, p2;

   // sum of two product terms
   assign agrb = p0 | p1 | p2;
   // product terms
   assign p0 = a[1] & ~b[1];
   assign p1 = a[0] & ~b[1] & ~b[0];
   assign p2 = a[1] & a[0] & ~b[0];

endmodule