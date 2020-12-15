//SETTING TIMESCALE
`timescale 1 ns/10 ps

module mini_alu_tb;
    reg [5:0] A, B;
    reg [2:0] fxn;
    wire [5:0] X;
        
    mini_alu uut (.a(A), .b(B), .fxn(fxn), .x(X));
    
    //TEST VECTORS
    initial
    begin
    // initialize selected fxn
    fxn = 3'b111;
    
    //test vector 1
    A = 6'b000100;
    B = 6'b001000;
    # 100;
    //test vector 2
    A = 6'b000110;
    B = 6'b010001;
    # 100;
    //test vector 3
    A = 6'b110010;
    B = 6'b000000;
    # 100;
    //test vector 4
    A = 6'b010010;
    B = 6'b001000;
    # 100;
    //test vector 5
    A = 6'b001000;
    B = 6'b000110;
    # 100;
    //test vector 6
    A = 6'b011000;
    B = 6'b000100;
    # 100;
    
          //STOP
          $stop;
       end
    
endmodule
