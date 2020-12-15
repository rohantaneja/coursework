// THIS MODULE CALCULATES THE 2'S COMPLEMENT INVERSE OF THE 6-BIT INPUT

module not6
    // I/O:
    (   input wire [5:0] x,
        output wire [5:0] notx,
        output wire [5:0] invx
    );
    wire p = 000001;
    not1 not1_bit0 (.i(x[0]), .noti(notx[0]));
    not1 not1_bit1 (.i(x[1]), .noti(notx[1]));
    not1 not1_bit2 (.i(x[2]), .noti(notx[2]));
    not1 not1_bit3 (.i(x[3]), .noti(notx[3]));
    not1 not1_bit4 (.i(x[4]), .noti(notx[4]));
    not1 not1_bit5 (.i(x[5]), .noti(notx[5]));
    assign invx = notx + p;
endmodule