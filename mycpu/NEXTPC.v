module NEXTPC(clk, rst, Stall, 
    Exc, EPC ,
    JR, Operand_A,
    take_pre, Pre_Target,
    mis_predict, Branch, PC_ID, Target_EXE,
    PC_IF,
    NPC );

    input clk,rst;
    input [31:0] PC_ID,PC_IF,EPC;
    input [31:0] Operand_A;
    input [31:0] Pre_Target,Target_EXE;
    input Stall;
    input take_pre;
    input mis_predict;
    input JR;//j jr jal jalr
	input Branch;
	input [1:0] Exc;
//    input Status_bev;
//    input [31:12] Exc_base;
    output reg [31:0] NPC;
    reg saved_exc,saved_Flush;

   // reg saved_exc;

    always @(rst,rst, Stall, 
    Exc, EPC , 
    JR, Operand_A,
    mis_predict, Branch, PC_ID, Target_EXE,
    take_pre, Pre_Target,
    saved_exc, saved_Flush, PC_IF)
    begin
        if(rst)
            NPC = 32'hbfc0_0000;
        else if(Exc == 2'b01)
            NPC = 32'hbfc0_0380;
//			NPC = Status_bev ? 32'hbfc00380 : {Exc_base,12'h180};
        else if(Exc == 2'b10)
            NPC = EPC;
        else if(JR)
            NPC = Operand_A;
        else if(mis_predict & Branch)
            NPC = Target_EXE;
        else if(mis_predict)
            NPC = PC_ID+4;
        else if(Stall | saved_exc | saved_Flush)
            NPC = PC_IF;  
        else if(take_pre)
            NPC = Pre_Target;
        else
            NPC = PC_IF + 4;
    end
    
    always @(posedge clk)
    begin
        if((|Exc)&&Stall)
            saved_exc <= 1'b1;
        
        else if(!Stall)
            saved_exc <= 1'b0;
    end
    
    always @(posedge clk)
    begin
        if(JR & ~(|Exc) & Stall)
            saved_Flush <= 1'b1;
        else if(mis_predict & ~(|Exc) & Stall)
            saved_Flush <= 1'b1;
        else if(!Stall | (|Exc))
            saved_Flush <= 1'b0;
    end
endmodule

