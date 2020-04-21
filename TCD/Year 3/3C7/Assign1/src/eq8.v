
module eq8
   (
    // a and b are the two 8-bit numbers being compared
    input  wire[7:0] c, d,			
    //single bit output. Should be high if a is greater than or equal to b	
    output wire	greq		
   );

   //signal declarations
   wire e0, e1, e2, e3, g0, g1, g2, g3;
         
   // body
   //2-bit equal to blocks
   eq2 eq_bit0_unit (.a(c[1:0]), .b(d[1:0]), .aeqb(e0));
   eq2 eq_bit1_unit (.aeqb(e1), .a(c[3:2]), .b(d[3:2]));
   eq2 eq_bit2_unit (.aeqb(e2), .a(c[5:4]), .b(d[5:4])); 
   eq2 eq_bit3_unit (.aeqb(e3), .a(c[7:6]), .b(d[7:6]));
   //2-bit greater than blocks
   geq2 gr_bit0_unit (.a(c[1:0]), .b(d[1:0]), .agrb(g0));
   geq2 gr_bit1_unit (.agrb(g1), .a(c[3:2]), .b(d[3:2])); 
   geq2 gr_bit2_unit (.agrb(g2), .a(c[5:4]), .b(d[5:4])); 
   geq2 gr_bit3_unit (.agrb(g3), .a(c[7:6]), .b(d[7:6]));

   //output is high if a is greater than or equal to b
   //Sum of Products expression: GR3 + EQ3.GR2 + EQ3.EQ2.GR1 + EQ3.EQ2.EQ1.GR0 + EQ3.EQ2.EQ1.EQ0
   assign greq = g3 | e3 & g2 | e3 & e2 & g1 | e3 & e2 & e1 & g0 | e3 & e2 & e1 & e0;  
   
endmodule