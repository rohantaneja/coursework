// Listing 1.1
module mystery_module
   // I/O ports
   (
    input wire i0, i1,
    output wire op
   );

   // signal declaration
   wire p0, p1;

   // body
   // sum of two product terms
   assign op = p0 | p1;
   // product terms
   assign p0 = ~i0 & ~i1;
   assign p1 = i0 & i1;

endmodule