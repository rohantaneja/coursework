module ripple_adder_testbench; 
    
    reg [5:0] test_in0, test_in1;
    reg select; // 1 = subtraction, 0 = addition
    wire [5:0] test_out;
    wire test_overflow;
    wire test_cout;
    
    ripple_adder uut (.x(test_in0),.y(test_in1),.sum(test_out),.sel(select),.overflow(test_overflow),.c_out(test_cout));
    
    initial
    begin
    
        test_in0 = 6'b000001;
        test_in1 = 6'b000100;
        select = 0;
        #200;
        test_in0 = 6'b000000;
        test_in1 = 6'b000000;
        select = 0;
        #200;
        test_in0 = 6'b000000;
        test_in1 = 6'b111111;
        select = 1;
        #200;
        test_in0 = 6'b100001;
        test_in1 = 6'b000001;
        select = 0;
        #200;
        test_in0 = 6'b011111;
        test_in1 = 6'b000001;
        select = 1;
        #200;
        test_in0 = 6'b100000;
        test_in1 = 6'b100000;
        select = 0;
        #200;
    
        $stop;
    end
endmodule
