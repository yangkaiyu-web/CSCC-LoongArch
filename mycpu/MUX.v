module MUX5bits_3to1(A,B,S,Dout);
    input [4:0] A,B;
    input [1:0]S;
    output reg [4:0] Dout;

    always @(A or B or S)
        if(S[1])
            Dout = 5'b11111;//JAL
        else if(S[0])
            Dout = B;
        else
            Dout = A;

endmodule

module MUX5bits_OrNot(A,S,Dout);//register need to use or not
    input [4:0] A;
    input S;
    output reg [4:0] Dout;

    always @(A or S)
        if(S)
            Dout = A;
        else
            Dout = 5'b0;

endmodule 

module MUX32bits_2to1(A,B,S,Dout);
    input [31:0] A,B;
    input S;
    output reg [31:0] Dout;

    always @(A or B or S)
        if(S)
            Dout = B;
        else
            Dout = A;

endmodule

module MUX32bits_4to1(A,B,C,D,S,Dout);
    input [31:0] A,B,C,D;
    input [1:0] S;
    output reg [31:0] Dout;

    always @(A or B or C or D or S)
        case (S)
            2'b00: Dout = A;
            2'b01: Dout = B;
            2'b10: Dout = C;
            2'b11: Dout = D;
        endcase
       
endmodule

module MUX32bits_5to1(A,B,C,D,E,S,Dout);
    input [31:0] A,B,C,D,E;
    input [2:0] S;
    output reg [31:0] Dout;

    always @(A or B or C or D or E or S)
        case (S)
            3'b000: Dout = A;
            3'b001: Dout = B;
            3'b010: Dout = C;
            3'b011: Dout = D;
            default:Dout = E;
        endcase
       
endmodule


module MUX2bits_4to1(A,B,C,D,S,Dout);
    input [1:0] A,B,C,D;
    input [1:0] S;
    output reg [1:0] Dout;

    always @(A or B or C or D or S)
        case (S)
            2'b00: Dout = A;
            2'b01: Dout = B;
            2'b10: Dout = C;
            2'b11: Dout = D;
        endcase
       
endmodule