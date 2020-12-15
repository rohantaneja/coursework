// THIS MODULE IMPLEMENTS THE ALU BY CALLING OTHER MODULES FOR EACH FUNCTION
module mini_alu
    (
    input wire [5:0] a, b,	// 6-bit - inputs a,b
    input wire [2:0] fxn,	// 3-bit - input fxn
    output reg [5:0] x		// 6-bit - output x
    );
    
    wire [5:0] invA, invB, AxorB, AplusB, AminusB;	//TEMPORARY 6-BIT WIRES FOR THE OUTPUT OF EACH MODULE
    wire AgreqB;	//TEMPORARY 1-BIT VARIABLE FOR THE 1-BIT OUTPUT OF THE >= CIRCUIT
    
    // instantiation to modules
    not6 inv_A (.x(a), .invx(invA));    // X = -A
    not6 inv_B (.x(b), .invx(invB));    // X = -B   
    geq6 A_greq_B (.i0(a), .i1(b), .two_comp_greq(AgreqB)); // X = A >= B
    xor6 A_xor_B (.x(a), .y(b), .xor_6(AxorB)); // X = A ^ B
    ripple_adder A_plus_B (.in_x(a), .y(b), .sel(0), .sum(AplusB)); // X = A + B
    ripple_adder A_minus_B (.in_x(a), .y(b), .sel(1), .sum(AminusB));   // X = A - B
    
    // control for fxn call
    always @(*)
    begin
        if (fxn == 3'b000)  {x} = {a};						// X = A
        if (fxn == 3'b001)  {x} = {b};						// X = B
        if (fxn == 3'b010)  {x} = {invA};					// X = -A
        if (fxn == 3'b011)  {x} = {invB};					// X = -B
        if (fxn == 3'b100)  {x[5:1], x[0]} = {0, AgreqB};	// X = A >= B - light up lsb
        if (fxn == 3'b101)  {x} = {AxorB};					// X = A ^ B
        if (fxn == 3'b110)  {x} = {AplusB};					// X = A + B
        if (fxn == 3'b111)  {x} = {AminusB};	        	// X = A - B
    end
endmodule