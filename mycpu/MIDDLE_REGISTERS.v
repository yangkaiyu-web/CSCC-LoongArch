module IF_to_ID(clk,Stall, rst,Flush,ins_valid,
    PC_in,Ins_in,PCAddressError_in,IsDelaySlot_in,
    PC_out,Ins_out,PCAddressError_out,IsDelaySlot_out
);
    input clk,Stall,rst;
    input [31:0]PC_in;
    input PCAddressError_in;
    input ins_valid;
    input Flush;
    input [31:0] Ins_in;
    input IsDelaySlot_in;
    output reg [31:0] PC_out;
    output reg PCAddressError_out;
    output reg [31:0] Ins_out;
    output reg IsDelaySlot_out;

    always @(posedge clk) 
    begin
        if(rst | Flush)
            IsDelaySlot_out <= 0;
        else if(Stall)
            IsDelaySlot_out <= IsDelaySlot_out;
        else
            IsDelaySlot_out <= IsDelaySlot_in;
    end
    
    always @(posedge clk) begin
        if(Stall)
            PC_out <= PC_out;
        else
            PC_out <= PC_in;

    end
    always @(posedge clk or posedge rst) begin
        if(rst | Flush)
            PCAddressError_out <= 0;
        else if(Stall)
            PCAddressError_out <= PCAddressError_out;
        else
            PCAddressError_out <= PCAddressError_in;
    end

    always @(posedge clk) begin
        if(rst|Flush)
            Ins_out <= 0;
        else if(Stall)
            Ins_out <= Ins_out;
        else if(!ins_valid)
            Ins_out <= 0;
        else
            Ins_out <= Ins_in;

    end
endmodule

module ID_to_EXE(clk,rst,Stall_ID,Stall_EXE,Flush,
    DRA_in,DRB_in,Shift_in,Imm32_in,ALUSelA_in,ALUSelB_in,IType_in,ALUOp_in,DMWr_in,LenthStore_in,LenthLoad_in,Target_in,JR_in,Jump_in,BrOp_in,
	SignLoad_in,IsDelaySlot_in,PC_in,WBSel_in,RFWr_in,RW_in,dm_en_in,Scall_in,PCAddressError_in,Eret_in,
    CP0_wr_in,RD_in,Undef_Instr_in,Break_in,
    MF_in,MDUOp_in,MDU_en_in,MFT_Sel_in,MUL_in,

    DRA_out,DRB_out,Shift_out,Imm32_out,ALUSelA_out,ALUSelB_out,IType_out,ALUOp_out,DMWr_out,LenthStore_out,LenthLoad_out,Target_out,JR_out,Jump_out,BrOp_out,
	SignLoad_out,IsDelaySlot_out,PC_out,WBSel_out,RFWr_out,RW_out,dm_en_out,Scall_out,PCAddressError_out,
    Eret_out,CP0_wr_out,RD_out,Undef_Instr_out,Break_out,
    MF_out,MDUOp_out,MDU_en_out,MFT_Sel_out,MUL_out
);

    input clk,rst,Stall_ID,Stall_EXE,Flush;
    input [31:0] DRA_in,DRB_in,Imm32_in;
    input [4:0] Shift_in;
    input DMWr_in;
    input [2:0] ALUSelA_in,ALUSelB_in;
    input IType_in;
    input [3:0] ALUOp_in;
    input [1:0] LenthStore_in;
    input [31:0] PC_in;
    input [1:0] WBSel_in;
    input [1:0] LenthLoad_in;
    input SignLoad_in;
	input IsDelaySlot_in;
    input RFWr_in;
    input [4:0] RW_in,RD_in;
	input PCAddressError_in;
	input Scall_in;
    input dm_en_in;
    input Eret_in;
    input CP0_wr_in;
    input Undef_Instr_in,Break_in;
    input MF_in;
    input [1:0] MDUOp_in;
    input MDU_en_in;
    input MUL_in;
    input [1:0] MFT_Sel_in;
    input [31:0] Target_in;
    input JR_in;
    input Jump_in;
    input [2:0]BrOp_in;
    
    output reg [31:0] DRA_out,DRB_out,Imm32_out;
    output reg [4:0] Shift_out;
    output reg DMWr_out;
    output reg [2:0] ALUSelA_out,ALUSelB_out;
    output reg IType_out;
    output reg [3:0] ALUOp_out;
    output reg [1:0] LenthStore_out;
    output reg [31:0] PC_out;
    output reg [1:0] WBSel_out;
    output reg [1:0] LenthLoad_out;
    output reg SignLoad_out;
	output reg IsDelaySlot_out;
    output reg RFWr_out;
    output reg [4:0] RW_out,RD_out;
	output reg Scall_out;
    output reg dm_en_out;
    output reg Eret_out;
    output reg CP0_wr_out;
    output reg PCAddressError_out;
    output reg Undef_Instr_out,Break_out;
    output reg MF_out;
    output reg MUL_out;
    output reg [1:0] MDUOp_out;
    output reg MDU_en_out;
    output reg [1:0] MFT_Sel_out;
    output reg [31:0] Target_out;
    output reg JR_out;
    output reg Jump_out;
    output reg [2:0]BrOp_out;
    

    always @(posedge clk)
        if(Flush|PCAddressError_in|rst)        
            dm_en_out <= 0;
        else if(Stall_EXE)
            dm_en_out <= dm_en_out;
        else if(Stall_ID)
            dm_en_out <= 0;
        else
            dm_en_out <= dm_en_in;

    always @(posedge clk)
        if(Flush|PCAddressError_in|rst)        
            BrOp_out <= 3'b011;
        else if(Stall_EXE)
            BrOp_out <= BrOp_out;
        else if(Stall_ID)
            BrOp_out <= 3'b011;
        else
            BrOp_out <= BrOp_in;

    always @(posedge clk)
        if(Flush|PCAddressError_in|rst)        
            JR_out <= 0;
        else if(Stall_EXE)
            JR_out <= JR_out;
        else if(Stall_ID)
            JR_out <= 0;
        else
            JR_out <= JR_in;

    always @(posedge clk)
        if(Flush|PCAddressError_in|rst)        
            Jump_out <= 0;
        else if(Stall_EXE)
            Jump_out <= Jump_out;
        else if(Stall_ID)
            Jump_out <= 0;
        else
            Jump_out <= Jump_in;

    always @(posedge clk)
        if(!Stall_EXE)
            Target_out <= Target_in;

    always @(posedge clk)
        if(!Stall_EXE)
            DRA_out <= DRA_in;

    always @(posedge clk)
        if(!Stall_EXE)
            DRB_out <= DRB_in;

    always @(posedge clk)
        if(!Stall_EXE)
            Shift_out <= Shift_in;

    always @(posedge clk)
        if(!Stall_EXE)
            Imm32_out <= Imm32_in;
    
    always @(posedge clk)
    begin
        if(Flush|rst|PCAddressError_in)
            DMWr_out <= 0;
        else if(Stall_EXE)
            DMWr_out <= DMWr_out;
        else if(Stall_ID)
            DMWr_out <= 0;
        else
            DMWr_out <= DMWr_in;
    end
    
    always @(posedge clk)
    begin
        if(!Stall_EXE) 
            ALUSelA_out <= ALUSelA_in;
    end
        

    always @(posedge clk)
    begin
        if(!Stall_EXE) 
            ALUSelB_out <= ALUSelB_in;
    end

    always @(posedge clk)
        if(!Stall_EXE)
            IType_out <= IType_in;

    always @(posedge clk)
    begin
        if(Flush|rst|PCAddressError_in)
            ALUOp_out <= 4'b0001;
        else if(Stall_EXE)
            ALUOp_out <= ALUOp_out;
        else if(Stall_ID)
            ALUOp_out <= 4'b0001;
        else
            ALUOp_out <= ALUOp_in;
    end
 
    
    always @(posedge clk)
        if(!Stall_EXE)
            LenthStore_out <= LenthStore_in;
		
	always @(posedge clk)
        if(!Stall_EXE)
		    IsDelaySlot_out<=IsDelaySlot_in;
    
    always @(posedge clk)
        if(!Stall_EXE)
            PC_out <= PC_in;
    
    always @(posedge clk)
        if(!Stall_EXE)
            WBSel_out <= WBSel_in;

    always @(posedge clk)
        if(!Stall_EXE)
            LenthLoad_out <= LenthLoad_in;

    always @(posedge clk)
        if(!Stall_EXE)
            SignLoad_out <= SignLoad_in;

    always @(posedge clk)
    begin
        if(Flush|rst|PCAddressError_in)
            RFWr_out <= 0;
        else if(Stall_EXE)
            RFWr_out <= RFWr_out;
        else if(Stall_ID)
            RFWr_out <= 0;
        else
            RFWr_out <= RFWr_in;
    end
    
    always @(posedge clk)
        if(!Stall_EXE)
            RW_out <= RW_in; 
		
	always @(posedge clk)
    begin
        if(Flush|rst)
            PCAddressError_out<=1'b0;
        else if(Stall_EXE)
    		PCAddressError_out<=PCAddressError_out;
        else if(Stall_ID)
            PCAddressError_out <= 0;
        else
            PCAddressError_out <= PCAddressError_in;
    end

	always @(posedge clk)
        if(Stall_ID|Flush|rst|PCAddressError_in)
            Scall_out<=1'b0;
        else if(Stall_EXE)
		    Scall_out<=Scall_out;
        else if(Stall_ID)
            Scall_out<=1'b0;
        else
            Scall_out<=Scall_in;

    always @(posedge clk)
        if(Flush|rst|PCAddressError_in)
            Eret_out<=1'b0;
        else if(Stall_EXE)
            Eret_out<=Eret_out;
        else if(Stall_ID)
            Eret_out<=1'b0;
        else
            Eret_out<=Eret_in;

    always @(posedge clk)
        if(Flush|rst|PCAddressError_in)
            CP0_wr_out<=1'b0;
        else if(Stall_EXE)
            CP0_wr_out<=CP0_wr_out;
        else if(Stall_ID)
            CP0_wr_out<=1'b0;
        else
            CP0_wr_out<=CP0_wr_in;

    always @(posedge clk)        
        if(!Stall_EXE)
            RD_out<=RD_in;

    always @(posedge clk)
        if(Flush|rst|PCAddressError_in)
            Undef_Instr_out<=1'b0;
        else if(Stall_EXE)
            Undef_Instr_out<=Undef_Instr_out;
        else if(Stall_ID)
            Undef_Instr_out<=1'b0;
        else
            Undef_Instr_out<=Undef_Instr_in;

    always @(posedge clk)
        if(Flush|rst|PCAddressError_in)
            Break_out<=1'b0;
        else if(Stall_EXE)
            Break_out<=Break_out;
        else if(Stall_ID)
            Break_out<=1'b0;
        else
            Break_out<=Break_in;
            
    always @(posedge clk)        
        if(!Stall_EXE)
            MF_out<=MF_in;

    always @(posedge clk) 
        if(!Stall_EXE)
            MDUOp_out<=MDUOp_in;

    always @(posedge clk)
        if(Flush|PCAddressError_in|rst)        
            MUL_out <= 0;
        else if(Stall_EXE)
            MUL_out <= MUL_out;
        else if(Stall_ID)
            MUL_out <= 0;
        else
            MUL_out <= MUL_in;

    always @(posedge clk)        
        if(Flush | rst | PCAddressError_in | Stall_ID)
            MDU_en_out<=1'b0;
        else
            MDU_en_out<=MDU_en_in;

    always @(posedge clk)        
        if(Flush | rst | PCAddressError_in)
            MFT_Sel_out<=2'b00;
        else if(Stall_EXE)
            MFT_Sel_out<=MFT_Sel_out;
        else if(Stall_ID)
            MFT_Sel_out<=2'b00;
        else
            MFT_Sel_out<=MFT_Sel_in;


endmodule


//forward for alu and store

module EXE_to_EXP(clk,rst,Stall_EXE,Stall_EXP,Flush,
    PC_in,WBSel_in,ALUOut_in,RFWr_in,RW_in,IsDelaySlot_in,Overflow_in,PCAddressError_in,Scall_in,Eret_in,CP0_wr_in,RD_in,Undef_Instr_in,Break_in,LenthStore_in,LenthLoad_in,SignLoad_in,data_to_DCache_in,DM_en_in,DMWr_in,
    PC_out,WBSel_out,ALUOut_out,RFWr_out,RW_out,IsDelaySlot_out,Overflow_out,PCAddressError_out,Scall_out,Eret_out,CP0_wr_out,RD_out,Undef_Instr_out,Break_out,LenthStore_out,LenthLoad_out,SignLoad_out,data_to_DCache_out,DM_en_out,DMWr_out
);

    input clk,rst;
    input Stall_EXE,Stall_EXP,Flush;

    input [31:0] PC_in;
    input [1:0] WBSel_in;
    input [1:0] LenthLoad_in,LenthStore_in;
    input SignLoad_in;
    input [31:0] ALUOut_in;
    input RFWr_in;
    input [4:0] RW_in,RD_in;
	input IsDelaySlot_in;
	input Overflow_in;
	input PCAddressError_in;
    input Eret_in;
    input CP0_wr_in;
    input Scall_in;
    input Undef_Instr_in,Break_in;
    input DM_en_in;
    input[31:0] data_to_DCache_in;
    input DMWr_in;

    output reg [31:0] PC_out;
    output reg [1:0] WBSel_out;
    output reg [1:0] LenthLoad_out,LenthStore_out;
    output reg SignLoad_out;
    output reg [31:0] ALUOut_out;
    output reg RFWr_out;
    output reg [4:0]RW_out,RD_out;
	output reg IsDelaySlot_out;
	output reg Overflow_out;
	output reg PCAddressError_out;
    output reg Eret_out;
    output reg CP0_wr_out;
    output reg Scall_out;
    output reg Undef_Instr_out,Break_out;
    output reg DM_en_out;
    output reg[31:0] data_to_DCache_out;
    output reg DMWr_out;

    always @(posedge clk)        
        if(Flush|rst)
            DM_en_out<=1'b0;
        else if(Stall_EXP)
            DM_en_out<=DM_en_out;
        else if(Stall_EXE)
            DM_en_out<=1'b0;
        else
            DM_en_out<=DM_en_in;
    
    always @(posedge clk)
        if (!Stall_EXP)
            DMWr_out <= DMWr_in;

    always @(posedge clk)
        if (!Stall_EXP)
            data_to_DCache_out <= data_to_DCache_in;
  
    always @(posedge clk)
        if (!Stall_EXP)
            PC_out <= PC_in;
    
	always @(posedge clk)
		if (!Stall_EXP)
            IsDelaySlot_out<=IsDelaySlot_in;
	
    always @(posedge clk)
        if (!Stall_EXP)
            WBSel_out <= WBSel_in;
    
    always @(posedge clk)
        if (!Stall_EXE)
            ALUOut_out <= ALUOut_in;

    always @(posedge clk)        
        if(Flush|rst)
            Overflow_out<=1'b0;
        else if(Stall_EXP)
            Overflow_out<=Overflow_out;
        else if(Stall_EXE)
            Overflow_out<=1'b0;
        else
            Overflow_out<=Overflow_in;

    always @(posedge clk)        
        if(Flush|rst)
            RFWr_out<=1'b0;
        else if(Stall_EXP)
            RFWr_out<=RFWr_out;
        else if(Stall_EXE)
            RFWr_out<=1'b0;
        else
            RFWr_out<=RFWr_in;

    always @(posedge clk)
        if (!Stall_EXP)
            RW_out <= RW_in; 

    always @(posedge clk)        
        if(Flush|rst)
            PCAddressError_out<=1'b0;
        else if(Stall_EXP)
            PCAddressError_out<=PCAddressError_out;
        else if(Stall_EXE)
            PCAddressError_out<=1'b0;
        else
            PCAddressError_out<=PCAddressError_in;

    always @(posedge clk)        
        if(Flush | rst)
            Scall_out<=1'b0;
        else if(Stall_EXP)
            Scall_out<=Scall_out;
        else if(Stall_EXE)
            Scall_out<=1'b0;
        else
            Scall_out<=Scall_in;

    always @(posedge clk)        
        if(Flush | rst)
            Eret_out<=1'b0;
        else if(Stall_EXP)
            Eret_out<=Eret_out;
        else if(Stall_EXE)
            Eret_out<=1'b0;
        else
            Eret_out<=Eret_in;

    always @(posedge clk)        
        if(Flush | rst)
            CP0_wr_out<=1'b0;
        else if(Stall_EXP)
            CP0_wr_out<=CP0_wr_out;
        else if(Stall_EXE)
            CP0_wr_out<=1'b0;
        else
            CP0_wr_out<=CP0_wr_in;

    always @(posedge clk)        
        if (!Stall_EXP)
            RD_out<=RD_in;

    always @(posedge clk)        
        if(Flush | rst)
            Undef_Instr_out<=1'b0;
        else if(Stall_EXP)
            Undef_Instr_out<=Undef_Instr_out;
        else if(Stall_EXE)
            Undef_Instr_out<=1'b0;
        else
            Undef_Instr_out<=Undef_Instr_in;

    always @(posedge clk)        
        if(Flush | rst)
            Break_out<=1'b0;
        else if(Stall_EXP)
            Break_out<=Break_out;
        else if(Stall_EXE)
            Break_out<=1'b0;
        else
            Break_out<=Break_in;

    always @(posedge clk)
        if (!Stall_EXP) 
            LenthStore_out<=LenthStore_in;
    
    always @(posedge clk)
        if (!Stall_EXP) 
            LenthLoad_out<=LenthLoad_in;

    always @(posedge clk)
        if (!Stall_EXP)
            SignLoad_out<=SignLoad_in;

endmodule


module EXP_to_MEM1(clk,rst,Stall_EXP,Stall_MEM1,Flush,
    PC_in,WBSel_in,ALUOut_in,RFWr_in,RW_in,LenthLoad_in,SignLoad_in,CP0_out_in,
    dcache_valid_in,uncache_valid_in,dcache_op_in,uncache_op_in,
    PC_out,WBSel_out,ALUOut_out,RFWr_out,RW_out,LenthLoad_out,SignLoad_out,CP0_out_out,
    dcache_valid_out,uncache_valid_out,dcache_op_out,uncache_op_out
);

    input clk,rst;
    input Stall_EXP,Stall_MEM1,Flush;

    input [31:0] PC_in;
    input [1:0] WBSel_in;
    input [1:0] LenthLoad_in;
    input SignLoad_in;
    input [31:0] ALUOut_in;
    input RFWr_in;
    input [4:0] RW_in;
    input [31:0] CP0_out_in;
    input dcache_valid_in,uncache_valid_in;
    input dcache_op_in,uncache_op_in;

    output reg [31:0] PC_out;
    output reg [1:0] WBSel_out;
    output reg [1:0] LenthLoad_out;
    output reg SignLoad_out;
    output reg [31:0] ALUOut_out;
    output reg RFWr_out;
    output reg [4:0]RW_out;
    output reg [31:0] CP0_out_out;
    output reg dcache_valid_out,uncache_valid_out;
    output reg dcache_op_out,uncache_op_out;
    
    always @(posedge clk)
        if (!Stall_MEM1)
            dcache_op_out <= dcache_op_in;

    always @(posedge clk)
        if (!Stall_MEM1)
            uncache_op_out <= uncache_op_in;
  
    always @(posedge clk)
        if (!Stall_MEM1)
            PC_out <= PC_in;
    
    always @(posedge clk)
        if (!Stall_MEM1)
            CP0_out_out <= CP0_out_in;

    always @(posedge clk)
        if (!Stall_MEM1)
            WBSel_out <= WBSel_in;
    
    always @(posedge clk)
        if (!Stall_MEM1)
            ALUOut_out <= ALUOut_in;

    always @(posedge clk)        
        if(Flush|rst)
            RFWr_out<=1'b0;
        else if(Stall_MEM1)
            RFWr_out<=RFWr_out;
        else if(Stall_EXP)
            RFWr_out<=1'b0;
        else
            RFWr_out<=RFWr_in;

    always @(posedge clk)
        if (!Stall_MEM1)
            RW_out <= RW_in; 

    always @(posedge clk)
        if (!Stall_MEM1) 
            LenthLoad_out<=LenthLoad_in;

    always @(posedge clk)
        if (!Stall_MEM1)
            SignLoad_out<=SignLoad_in;

    always @(posedge clk) begin
        if(Flush | rst)
            dcache_valid_out<=1'b0;
        else if(Stall_MEM1)
            dcache_valid_out <= dcache_valid_out;
        else if(Stall_EXP)
            dcache_valid_out <= 1'b0;
        else
            dcache_valid_out <= dcache_valid_in;
    end

    always @(posedge clk) begin
        if(Flush | rst)
            uncache_valid_out<=1'b0;
        else if(Stall_MEM1)
            uncache_valid_out <= uncache_valid_out;
        else if(Stall_EXP)
            uncache_valid_out <= 1'b0;
        else
            uncache_valid_out <= uncache_valid_in;
    end

endmodule

module MEM1_to_MEM2(clk,rst,Stall_MEM1,Stall_MEM2,
    PC_in,WBSel_in,ALUOut_in,RFWr_in,RW_in,LenthLoad_in,SignLoad_in,CP0_out_in,
    dcache_valid_in,dcache_op_in,uncache_rdata_in,
    PC_out,WBSel_out,ALUOut_out,RFWr_out,RW_out,LenthLoad_out,SignLoad_out,CP0_out_out,
    dcache_valid_out,dcache_op_out,uncache_rdata_out
);

    input clk,rst;
    input Stall_MEM2,Stall_MEM1;

    input [31:0] PC_in;
    input [1:0] WBSel_in;
    input [1:0] LenthLoad_in;
    input SignLoad_in;
    input [31:0] ALUOut_in;
    input RFWr_in;
    input [4:0] RW_in;
    input [31:0] CP0_out_in;
    input dcache_valid_in;
    input dcache_op_in;
    input [31:0] uncache_rdata_in;

    output reg [31:0] PC_out;
    output reg [1:0] WBSel_out;
    output reg [1:0] LenthLoad_out;
    output reg SignLoad_out;
    output reg [31:0] ALUOut_out;
    output reg RFWr_out;
    output reg [4:0]RW_out;
    output reg [31:0] CP0_out_out;
    output reg dcache_valid_out;
    output reg dcache_op_out;
    output reg [31:0] uncache_rdata_out;
    
    always @(posedge clk)
        if (!Stall_MEM2)
            dcache_op_out <= dcache_op_in;

    always @(posedge clk)
        if (!Stall_MEM2)
            uncache_rdata_out <= uncache_rdata_in;
  
    always @(posedge clk)
        if (!Stall_MEM2)
            PC_out <= PC_in;
    
    always @(posedge clk)
        if (!Stall_MEM2)
            CP0_out_out <= CP0_out_in;

    always @(posedge clk)
        if (!Stall_MEM2)
            WBSel_out <= WBSel_in;
    
    always @(posedge clk)
        if (!Stall_MEM1)//保证exe级旁路数据
            ALUOut_out <= ALUOut_in;

    always @(posedge clk)        
        if(rst)
            RFWr_out<=1'b0;
        else if(Stall_MEM2)
            RFWr_out<=RFWr_out;
        else if(Stall_MEM1)
            RFWr_out<=1'b0;
        else
            RFWr_out<=RFWr_in;

    always @(posedge clk)
        if (!Stall_MEM2)
            RW_out <= RW_in; 

    always @(posedge clk)
        if (!Stall_MEM2) 
            LenthLoad_out<=LenthLoad_in;

    always @(posedge clk)
        if (!Stall_MEM2)
            SignLoad_out<=SignLoad_in;

    always @(posedge clk) begin
        if(rst)
            dcache_valid_out<=1'b0;
        else if(Stall_MEM2)
            dcache_valid_out <= dcache_valid_out;
        else if(Stall_MEM1)
            dcache_valid_out <= 1'b0;
        else
            dcache_valid_out <= dcache_valid_in;
    end


endmodule

module MEM_to_WB(clk,Stall_MEM2,Stall_Forward,
    RFWr_in,RW_in,PC_in,DW_in,
    RFWr_out,RW_out,PC_out,
    DW_out,DW_Forward
);
    input clk;
    input Stall_MEM2;
    input Stall_Forward;
    input [31:0] PC_in;
    input RFWr_in;
    input [4:0] RW_in;
    input [31:0] DW_in;

    output reg [31:0] PC_out;
    output reg RFWr_out;
    output reg [4:0]RW_out;
    output reg [31:0] DW_out;
    output reg [31:0] DW_Forward;


    always @(posedge clk)
        if(!Stall_Forward)
            DW_Forward <= DW_in;

    always @(posedge clk)
        DW_out <= DW_in;

    always @(posedge clk)
        if(Stall_MEM2)
            RFWr_out <= 0;
        else
            RFWr_out <= RFWr_in;

    always @(posedge clk)
        RW_out <= RW_in; 

    always @(posedge clk)
        PC_out <= PC_in;

endmodule
