module RF( rst, clk, RA, RB, RW, DW, RFWr, DRA, DRB);

    input [4:0] RA,RB,RW;
    input [31:0] DW;
    input RFWr;
    input clk,rst;
    output [31:0] DRA,DRB;
//    output [31:0] A0;

    reg[31:0] reg_file [31:0];
//    assign A0 = reg_file[4];

    always @(posedge clk or posedge rst) begin
        if(rst)
            reg_file[0] <= 0;
        else if(RFWr)
            reg_file[RW] <= DW;
    end
        
    
    assign DRA=reg_file[RA];
    assign DRB=reg_file[RB];

endmodule

