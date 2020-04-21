// THIS MODULE INVERTS THE 1-BIT INPUT

module not1
    (   input wire i,
        output wire noti
    );
    assign noti = ~i;
endmodule