module CP0(rst,clk,int,CP0_Num,CP0_WD,CP0_wr,BadVAddr_in,Cause_ExcCode_in,SetStatus_EXL,ClrStatus_EXL,
BadVAddr_Wr,Cause_BD_Wr,Cause_ExcCode_Wr,Cause_BD,
EPC_Wr,SetEPC,CP0_out,Status_EXL_out,EPC_out,Soft_Break,Hard_Break);

input rst,clk;
input CP0_wr;
input[4:0] CP0_Num;
input[5:0] int;
input[4:0] Cause_ExcCode_in;
input BadVAddr_Wr,SetStatus_EXL,ClrStatus_EXL,Cause_BD_Wr,Cause_ExcCode_Wr,EPC_Wr;
input Cause_BD;
input[31:0] SetEPC,BadVAddr_in;
input[31:0] CP0_WD;

output [31:0] EPC_out;
output reg[31:0] CP0_out;
output Status_EXL_out;
output Soft_Break,Hard_Break;

reg cnt;
reg[31:0] BadVAddr;
reg[31:0] Cause;
reg[31:0] Status;
reg[31:0] EPC;
reg[31:0] Compare;
reg[31:0] Count;
reg[31:0] Ebase; //15.1

wire [1:0] Cause1_0;
reg [6:2] Cause6_2;
wire Cause7;
reg [9:8] Cause9_8;
reg [15:10] Cause15_10;
wire [29:16] Cause29_16;
reg Cause31,Cause30;


wire [31:23] Status31_23;
reg Status22;
reg Status1,Status0;
wire [21:16] Status21_16;
reg [15:8] Status15_8;
wire [7:2] Status7_2;


assign Status_EXL_out=Status[1];
//assign Count_out=Count;
//assign Compare_out=Compare;
assign EPC_out=EPC;


assign Soft_Break = (|(Cause[9:8]&Status[9:8])) & (~Status[1]) & Status[0];


assign Hard_Break = (|(Cause[15:10]&Status[15:10])) & (~Status[1]) & Status[0];


always @(posedge clk) 
begin
    if(rst)
        cnt<=0;
    else
        cnt<=~cnt;
end

always @(CP0_Num or BadVAddr or Count or Compare or Status or Cause or EPC or Ebase) 
case(CP0_Num)
    5'b01000:CP0_out=BadVAddr;
    5'b01001:CP0_out=Count;
    5'b01011:CP0_out=Compare;
    5'b01100:CP0_out=Status;
    5'b01101:CP0_out=Cause;
    5'b01110:CP0_out=EPC;
    5'b01111:CP0_out=Ebase;
    default:CP0_out=32'b0;
endcase

//BadVAddr
always @(posedge clk) 
begin
    if(BadVAddr_Wr)
        BadVAddr<=BadVAddr_in;
end

//Count
always @(posedge clk) 
begin
    if(rst)
        Count<=32'b0;
    else if(CP0_wr&&CP0_Num==5'b01001)
        Count<=CP0_WD;
    else if(cnt)
        Count<=Count+1;    
end

//Compare
always @(posedge clk) 
begin
    if(CP0_wr&&CP0_Num==5'b01011)
        Compare<=CP0_WD;
end

//Status[31:23]
assign Status31_23 = 9'b0;


//Status.Bev
always @(rst or CP0_wr or CP0_Num or CP0_WD or Status)
begin
    if(rst)
        Status22 = 1'b1;
    else if(CP0_wr&&CP0_Num==5'b01100)
        Status22 = CP0_WD[22];
    else
        Status22 = Status[22];
end

//Status[21:16]
assign Status21_16 = 6'b0;

//Status.IM
always @(CP0_wr or CP0_Num or CP0_WD or Status) 
begin
    if(CP0_wr&&CP0_Num==5'b01100)
        Status15_8 = CP0_WD[15:8];
    else
        Status15_8 = Status[15:8];
end

assign Status7_2 = 6'b0;

//Status.EXL
always @(rst or SetStatus_EXL or ClrStatus_EXL or CP0_wr or CP0_Num or CP0_WD or Status) 
begin
    if(rst)
        Status1 = 1'b0;
    else if(SetStatus_EXL)
        Status1 = 1'b1;
    else if(ClrStatus_EXL)
        Status1 = 1'b0;
    else if(CP0_wr&&CP0_Num==5'b01100)
        Status1 = CP0_WD[1];
    else 
        Status1 = Status[1];
end

//Status.IE
always @(rst or CP0_wr or CP0_Num or CP0_WD or Status)
begin
    if(rst)
        Status0 = 1'b0;
    else if(CP0_wr&&CP0_Num==5'b01100)
        Status0 = CP0_WD[0];
    else
        Status0 = Status[0];
end

always @(posedge clk) 
begin
    Status <= {Status31_23,Status22,Status21_16,Status15_8,Status7_2,Status1,Status0};
end


//Cause
always @(rst or Cause_BD_Wr or CP0_wr or CP0_Num or CP0_WD or Cause_BD or Cause) 
begin
    if(rst)
        Cause31 = 0;
    else if(Cause_BD_Wr)
        Cause31 = Cause_BD;
    else if(CP0_wr&&CP0_Num==5'b01101)
        Cause31 = CP0_WD[31];
    else 
        Cause31 = Cause[31];
end

always @(rst or Compare or Count) 
begin
    if(rst)
        Cause30 = 1'b0;
    else if(Compare==Count)
        Cause30 = 1'b1;
    else
        Cause30 = 1'b0;
end

assign Cause29_16 = 14'b0;

always @(rst or int) 
begin
    if(rst)
        Cause15_10 = 0;
//    else if(CP0_wr&&CP0_Num==5'b01101)
//        Cause[15:10]<=CP0_WD[15:10];
    else
        Cause15_10 = int;
end

always @(rst or CP0_wr or CP0_Num or CP0_WD or Cause) 
begin
    if(rst)
        Cause9_8 = 2'b0; 
    else if(CP0_wr&&CP0_Num==5'b01101) 
        Cause9_8 = CP0_WD[9:8];
    else
        Cause9_8 = Cause[9:8];
end

assign Cause7 = 1'b0;

always @(rst or CP0_wr or CP0_Num or Cause_ExcCode_Wr or Cause_ExcCode_in or CP0_WD or Cause) 
begin
    if(rst)
        Cause6_2 = 5'b0;
    else if(CP0_wr && CP0_Num==5'b01101)
        Cause6_2 = CP0_WD[6:2];
    else if(Cause_ExcCode_Wr)
        Cause6_2 = Cause_ExcCode_in;
    else
        Cause6_2 = Cause[6:2];
end

assign Cause1_0 = 2'b0;

always @(posedge clk) 
    Cause <= {Cause31,Cause30,Cause29_16,Cause15_10,Cause9_8,Cause7,Cause6_2,Cause1_0};


//EPC
always @(posedge clk) 
begin
    if(CP0_wr&&CP0_Num==5'b01110)
        EPC <= CP0_WD;
    else if(EPC_Wr)
        EPC <= SetEPC;
end

//Ebase
always @(posedge clk)
begin
    if(rst)
        Ebase <= 32'h8000_1000;
    else if(CP0_wr && CP0_Num == 5'b01111)
        Ebase<={2'b10,CP0_WD[29:12],2'b0,CP0_WD[9:0]};
end

endmodule