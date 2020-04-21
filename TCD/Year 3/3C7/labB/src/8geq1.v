module geq1
   // I/O ports
   (
    //2 inputs and a wire for each bit (4)
    input wire i0, i1, j0, j1,
    //3 outputs for the 3 different cases
    output wire eq, gt
   );
   
   //all the wires used for each situation, before entering OR gates
   wire p0, p1, p2, p3, p4, p5, p6;

   // a = b stored in eq
   assign eq = p0 | p1 | p2 | p3; 
   assign p0 = i0 & ~j0 & i1 & ~j1;
   assign p1 = i0 & j0 & i1 & j1;
   assign p2 = ~i0 & j0 & ~i1 & j1;
   assign p3 = ~i0 & ~j0 & ~i1 & ~j1;
   
   // a > b logic stored in gt
   assign gt = p4 | p5 | p6;
   assign p4 = j0 & ~j1;
   assign p5 = i0 & j0 & ~i1;
   assign p6 = i0 & ~i1 & ~j1;

endmodule