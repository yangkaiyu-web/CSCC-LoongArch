module BranchPre(clk,rst,Flush,PC_IF,take_EXE,Stall_ID,Target_out,take_pre,mis_predict,
ins//trigger

);
    input clk,rst,Flush;
    input [31:2] PC_IF;//read
    input take_EXE;
    input Stall_ID;
    output [31:0] Target_out;
    output take_pre;
    output mis_predict;

    input [31:0] ins;
//记得考虑IF单独flush情况
    wire [8:0] read_index;
    reg [8:0] write_index;
    wire J_ID,B_ID;
    wire B_EXE;
    wire take_pre_EXE;
    wire [31:0] Target_pre;
    reg [31:2] PC_ID;
    wire [5:0] OP;


    reg [31:0] cnt_Pre,cnt_misPre,cnt_take;

    wire [1:0] history,S0,S1,S2,S3;
    wire [1:0] history_EXE,S0_EXE,S1_EXE,S2_EXE,S3_EXE;
    wire [1:0] State_EXE;
    reg [1:0] Next_State;
    wire [1:0] State;
    reg [9:0] BHT_in;
    wire [9:0] State_pre;
    wire hazard;
    reg [8:0] index_ID;

    wire [31:2] offset;
    wire [31:2] branch_target;
    wire [31:2] jump_target;

    assign OP = ins[31:26];
    assign offset = {{14{ins[15]}},ins[15:0]};
    assign branch_target = PC_IF[31:2] + offset;
    assign jump_target = {PC_ID[31:28],ins[25:0]};

    assign hazard = (read_index == write_index) & B_EXE;

    parameter [1:0] SN = 2'b00;//Strongly not taken
    parameter [1:0] WN = 2'b01;//weakly not taken
    parameter [1:0] WT = 2'b10;//weakly taken
    parameter [1:0] ST = 2'b11;//strongly taken

//命中率
/*
    always @(posedge clk or posedge rst) begin
        if(rst)
            cnt_Pre <= 0;
        else if (BJ_EXE) begin
            cnt_Pre = cnt_Pre+1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            cnt_misPre <= 0;
        else if (mis_predict) begin
            cnt_misPre = cnt_misPre+1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if(rst)
            cnt_take <= 0;
        else if (take_EXE) begin
            cnt_take = cnt_take+1;
        end
    end
    */
    
/*
ila_0 your_instance_name (
	.clk(clk), // input wire clk


	.probe0(cnt_Pre), // input wire [9:0]  probe0  
	.probe1(cnt_misPre), // input wire [9:0]  probe1
    .probe2(PC_IF),
    .probe3(cnt_take)
);
*/


    always @(posedge clk) begin
        if(~Stall_ID)
            PC_ID <= PC_IF;
    end
    always @(posedge clk) begin
        if(~Stall_ID)
            index_ID <= read_index;
    end

    always @(posedge clk) begin
        if(~Stall_ID)
            write_index <= index_ID;
    end
    assign read_index =PC_IF[10:2];

    assign J_ID = OP==6'b000011 //JAL
                    | OP==6'b000010;//J
    assign B_ID = OP==6'b000001//BLTZAL BGEZAL BLTZ BGEZ
                    | OP==6'b000110//BLEZ
                    | OP==6'b000111//BGTZ
                    | OP==6'b000101//BNE
                    | OP==6'b000100;//BEQ

    assign Target_out = {J_ID? jump_target:branch_target,2'b0};

    BHT U_BHT (
        .clka(clk),    // input wire clka
        .ena(B_EXE),      // input wire ena
        .wea(1'b1),      // input wire [0 : 0] wea
        .addra(write_index),  // input wire [8 : 0] addra
        .dina(BHT_in),    // input wire [9 : 0] dina
        .clkb(clk),    // input wire clkb
        .enb(!hazard & !Stall_ID),      // input wire enb
        .addrb(read_index),  // input wire [8 : 0] addrb
        .doutb(State_pre)  // output wire [9 : 0] doutb
    );

    assign{history,S0,S1,S2,S3} = State_pre;

    MUX2bits_4to1 U_MUX_historyState(
        .A(S0), .B(S1), .C(S2), .D(S3), .S(history),
        .Dout(State)
    );

    PIP_in_BP U_PIP(.clk(clk), .Stall(Stall_ID),
    .history_in(history), .S0_in(S0), .S1_in(S1), .S2_in(S2), .S3_in(S3), .B_in(B_ID), .take_pre_in(take_pre), .State_in(State), .Target_in(Target_out[31:0]),
    .history_out(history_EXE), .S0_out(S0_EXE), .S1_out(S1_EXE), .S2_out(S2_EXE), .S3_out(S3_EXE), .B_out(B_EXE), .take_pre_out(take_pre_EXE), .State_out(State_EXE), .Target_out(Target_pre)
    );

//FSM    
    
    assign take_pre = (J_ID | ((State[1] & B_ID) & ~hazard)) & ~Flush;

    always @(State_EXE,take_EXE) begin
        case (State_EXE)
        SN:Next_State = take_EXE?WN:SN;
        WN:Next_State = take_EXE?WT:SN;
        WT:Next_State = take_EXE?ST:WN;
        ST:Next_State = take_EXE?ST:WT;
        endcase
    end

    always @(Next_State, S0_EXE,S1_EXE,S2_EXE,S3_EXE,history_EXE,take_EXE) begin
        case(history_EXE)
        2'b00:BHT_in = {history_EXE[0],take_EXE,Next_State,S1_EXE,S2_EXE,S3_EXE};
        2'b01:BHT_in = {history_EXE[0],take_EXE,S0_EXE,Next_State,S2_EXE,S3_EXE};
        2'b10:BHT_in = {history_EXE[0],take_EXE,S0_EXE,S1_EXE,Next_State,S3_EXE};
        2'b11:BHT_in = {history_EXE[0],take_EXE,S0_EXE,S1_EXE,S2_EXE,Next_State};
        endcase
    
    //BHT_in = {history_EXE[0],take_EXE,Next_State,Next_State,Next_State,Next_State};
    end

    assign mis_predict = (take_EXE ^ take_pre_EXE) & B_EXE;
endmodule

module PIP_in_BP(clk, Stall,
    history_in,S0_in,S1_in,S2_in,S3_in,B_in,State_in,take_pre_in,Target_in,
    history_out,S0_out,S1_out,S2_out,S3_out,B_out,State_out,take_pre_out,Target_out
    );
    input clk;
    input Stall;
    input [1:0] history_in,S0_in,S1_in,S2_in,S3_in,State_in;
    input B_in;
    input take_pre_in;
    input [31:0] Target_in;
    output reg take_pre_out;
    output reg B_out;
    output reg [1:0] history_out,S0_out,S1_out,S2_out,S3_out,State_out;
    output reg [31:0] Target_out;

    always @(posedge clk) begin
        history_out <= history_in;
    end

    always @(posedge clk) begin
        Target_out <= Target_in;
    end

    always @(posedge clk) begin
        S0_out <= S0_in;
    end

    always @(posedge clk) begin
        S1_out <= S1_in;
    end

    always @(posedge clk) begin
        S2_out <= S2_in;
    end

    always @(posedge clk) begin
        S3_out <= S3_in;
    end

    always @(posedge clk) begin
        State_out <= State_in;
    end

    always @(posedge clk)
        if(Stall)
            B_out <= 0;
        else
            B_out <= B_in;

    always @(posedge clk) begin
        take_pre_out <= take_pre_in;
    end
endmodule