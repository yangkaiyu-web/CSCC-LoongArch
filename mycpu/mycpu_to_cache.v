module mycpu_to_cache(
    clk              ,//(cpu_clk   ),
    resetn           ,//(cpu_resetn),  //low active
    ext_int          ,//(6'd0      ),  //interrupt,high active
    /*
    inst_sram_en     ,//(cpu_inst_en   ),
    inst_sram_wen    ,//(cpu_inst_wen  ),
    inst_sram_addr   ,//(cpu_inst_addr ),
    inst_sram_wdata  ,//(cpu_inst_wdata),
    inst_sram_rdata  ,//(cpu_inst_rdata),
    
    data_sram_en     ,//(cpu_data_en   ),
    data_sram_wen    ,//(cpu_data_wen  ),
    data_sram_addr   ,//(cpu_data_addr ),
    data_sram_wdata  ,//(cpu_data_wdata),
    data_sram_rdata  ,//(cpu_data_rdata),
    */
    //i cache 
    icache_valid   ,
    icache_index   ,
    icache_tag     ,
    icache_offset  ,
    icache_data_ok ,
    icache_rdata   ,
    
    //d cache 
    dcache_valid   ,
    dcache_op      ,
    dcache_index   ,
    dcache_tag     ,
    dcache_offset  ,
    dcache_wstrb   ,
    dcache_wdata   ,
    dcache_addr_ok ,
    dcache_data_ok ,
    dcache_rdata   ,

    uncache_valid   ,
    uncache_op      ,
    uncache_index   ,
    uncache_tag     ,
    uncache_offset  ,
    uncache_wstrb   ,
    uncache_wdata   ,
    uncache_addr_ok ,
    uncache_data_ok ,
    uncache_rdata   ,

    uncache_arsize  ,
    uncache_awsize  ,

    //debug
    debug_wb_pc      ,//(debug_wb_pc      ),
    debug_wb_rf_wen  ,//(debug_wb_rf_wen  ),
    debug_wb_rf_wnum ,//(debug_wb_rf_wnum ),
    debug_wb_rf_wdata //(debug_wb_rf_wdata)
);
    input clk;
    input resetn;
    input [5:0] ext_int;
    /*
    output inst_sram_en;
    output [3:0] inst_sram_wen;//no idea
    output [31:0] inst_sram_addr;
    output [31:0] inst_sram_wdata;//no idea
    input [31:0] inst_sram_rdata;
    
    output data_sram_en;
    output [3:0] data_sram_wen;
    output [31:0] data_sram_addr;
    output [31:0] data_sram_wdata;
    input [31:0] data_sram_rdata;
    */

//icache
    output         icache_valid   ;
    output  [6 :0] icache_index   ;
    output  [19:0] icache_tag     ;
    output  [4 :0] icache_offset  ;
    input          icache_data_ok ;
    input   [31:0] icache_rdata   ;
    

    
//dcache
    output         dcache_valid   ;
    output         dcache_op      ;
    output  [7 :0] dcache_index   ;
    output  [19:0] dcache_tag     ;
    output  [3 :0] dcache_offset  ;
    output  [3 :0] dcache_wstrb   ;
    output  [31:0] dcache_wdata   ;
    input          dcache_addr_ok ;
    input          dcache_data_ok ;
    input   [31:0] dcache_rdata   ;

//uncache    
    output         uncache_valid   ;
    output         uncache_op      ;
    output  [7:0]  uncache_index   ;
    output  [19:0] uncache_tag     ;
    output  [3:0]  uncache_offset  ;
    output  [3:0]  uncache_wstrb   ;
    output  [31:0] uncache_wdata   ;
    input          uncache_addr_ok ;
    input          uncache_data_ok ;
    input   [31:0] uncache_rdata   ;
    output  [2:0]  uncache_arsize  ;
    output  [2:0]  uncache_awsize  ;


//debug
    output [31:0] debug_wb_pc;
    output [3:0] debug_wb_rf_wen;
    output [4:0] debug_wb_rf_wnum;
    output [31:0] debug_wb_rf_wdata;
//my
    wire inst_req;

    wire [31:0] data_to_DCache_EXE,data_to_DCache_EXP;//origin:before shift
    wire [31:0] NPC;
    wire [31:0] PC_IF,PC_ID,PC_EXE,PC_EXP,PC_MEM1,PC_MEM2,PC_WB;
    wire [4:0] RS_ID,RT_ID,RD_ID,RD_EXE,RD_EXP;
    wire [4:0] Shift_ID,Shift_EXE;
    wire [4:0] RA_ID;
    wire [4:0] RB_ID;
    wire [4:0] RW_ID,RW_EXE,RW_EXP,RW_MEM1,RW_MEM2,RW_WB;
    wire [15:0] Imm16_ID;
    wire [31:0] Imm32_ID,Imm32_EXE;
    wire Stall_IF,Stall_ID,Stall_EXE,Stall_EXP,Stall_MEM1,Stall_MEM2;

	wire Branch;
    wire take_pre;
    wire mis_predict;
    wire [31:0] PC_BP;
    wire [31:0] Target_B_EXE;

	wire FlushExc,FlushIF,FlushID,FlushEXE,FlushEXP; //FlushIF_ID：将IF阶段传入ID阶段的相关信号flush�?? ## FlushID:将ID阶段传入EXE阶段的相关信号flush�??
	wire NextIsDelaySlot_ID,IsDelaySlot_ID,IsDelaySlot_EXE,IsDelaySlot_EXP;
	wire[31:0] BadVAddr4Set,EPC4Set;
    wire BadVAddr_Wr,Cause_BD_Wr,Cause_ExcCode_Wr;
	wire Status_EXL4Exc,Status_EXL4Set,Cause_BD4Set;
	wire[4:0] Cause_ExcCode;
	wire PCAddressError_IF,PCAddressError_ID,PCAddressError_EXE,PCAddressError_EXP;
    wire LAddressError_EXP,SAddressError_EXP;
	wire Scall_ID,Scall_EXE,Scall_EXP;
    wire Break_ID,Break_EXE,Break_EXP;
	wire[31:0] CP0_out_EXP,CP0_out_MEM1,CP0_out_MEM2,EPC;
	wire Undef_Instr_ID,Undef_Instr_EXE,Undef_Instr_EXP;
	wire [1:0] Exc4PC;
    wire CP0_wr_ID,CP0_wr_EXE,CP0_wr_EXP;
    wire EPC_Wr;
    wire Eret_ID,Eret_EXE,Eret_EXP;
    wire Soft_Break,Hard_Break;

    wire IType_ID,IType_EXE;
    wire NeedRS_ID,NeedRT_ID;
    wire [1:0] RFDst_ID;
    wire Jump_ID,JR_ID,Jump_EXE,JR_EXE;
    wire [2:0] BrOp_ID,BrOp_EXE;
    wire [1:0] ExtOp_ID;
    wire [3:0] ALUOp_ID,ALUOp_EXE;
    wire DMWr_ID,DMWr_EXE,DMWr_EXP;
    wire [1:0] LenthStore_ID,LenthStore_EXE,LenthStore_EXP;
    wire [1:0] LenthLoad_ID,LenthLoad_EXE,LenthLoad_EXP,LenthLoad_MEM1,LenthLoad_MEM2;
    wire SignLoad_ID,SignLoad_EXE,SignLoad_EXP,SignLoad_MEM1,SignLoad_MEM2;
    wire DM_en_ID,DM_en_EXE,DM_en_EXP;
    wire RFWr_ID,RFWr_EXE,RFWr_EXP,RFWr_MEM1,RFWr_MEM2,RFWr_WB;
    wire [1:0] WBSel_ID,WBSel_EXE,WBSel_EXP,WBSel_MEM1,WBSel_MEM2;

    wire MF_ID,MF_EXE;
    wire [1:0] MDUOp_ID,MDUOp_EXE;
    wire MDU_en_ID,MDU_en_EXE;
    wire MUL_ID,MUL_EXE;
    wire [1:0] MFT_Sel_ID,MFT_Sel_EXE;
    wire MDU_busy;

    wire [31:0] DM_out;
    wire [31:0] DW_MEM2,DW_WB,DW_Forward;
    wire [31:0] DRA_ID,DRA_EXE;
    wire [31:0] DRB_ID,DRB_EXE;

    wire [2:0] ALUSelA_ID,ALUSelB_ID,ALUSelA_EXE,ALUSelB_EXE;
    wire [31:0] ALU_Operand_A,ALU_Operand_B;
    wire [31:0] ALUOut,ALUOut_EXE,ALUOut_EXP,ALUOut_MEM1,ALUOut_MEM2;
    wire Overflow_EXE,Overflow_EXP;
    wire [31:0] MDUOut;

    wire icache_valid_IF; 
    wire ins_valid;
    wire [31:0] Ins_ID;
    wire [31:0] wdata;
    wire dcache_req,dcache_valid_MEM1,dcache_valid_MEM2;
    wire uncache_req,uncache_valid_MEM1;
    wire dcache_op_MEM1,dcache_op_MEM2;
    wire uncache_op_MEM1;
    wire [31:0] uncache_rdata_MEM2;

    assign debug_wb_rf_wen = {4{RFWr_WB}};
    assign debug_wb_rf_wnum = RW_WB;
    assign debug_wb_pc = PC_WB;
    assign debug_wb_rf_wdata = DW_WB;

    //wire [31:0] A0;
    
    // ila_0 U_ila(
    //     .clk(clk), // input wire clk

    //     .probe0(NPC), //32
    //     .probe1(PC_IF), //32
    //     .probe2(PC_ID), //32
    //     .probe3(PC_EXE), //32
    //     .probe4(Cause_ila), //32
    //     .probe5({icache_valid,icache_addr_ok,icache_data_ok,Exc4PC,Stall_IF,Stall_ID,Stall_EXE,icache_valid_IF,rst,
    //     Stall_Hazard,Stall_Daddr,Stall_Ddata,Stall_Udata,Stall_Idata,Eret_EXP,Eret_ID,Eret_EXE,debug_wb_rf_wnum,debug_wb_rf_wen,CP0_wr_EXP,Stall_EXP}), //23
    //     .probe6(icache_rdata), //32
    //     .probe7({uncache_offset,uncache_tag,uncache_index}), //32
    //     .probe8(PC_EXP),//32
    //     .probe9(Ins_ID), //32
    //     .probe10({ext_int,RD_EXP}), //11
    //     .probe11({MUL_ID,MUL_EXE,MDU_busy,MDU_en_EXE}), //4
    //     .probe12(dcache_rdata),//32
    //     .probe13(uncache_rdata), //32
    //     .probe14(A0), //32
    //     .probe15(data_to_DCache_EXP), //32
    //     .probe16(debug_wb_pc), //32
    //     .probe17(debug_wb_rf_wdata) //32
    //     );


//flush

    assign FlushIF = FlushExc | mis_predict | JR_EXE;
    assign FlushID = FlushExc;
    assign FlushEXE = FlushExc;
    assign FlushEXP = FlushExc;
//pre_IF
    ICache_req U_ICache_req(
        .clk(clk), .rst(~resetn), .Stall(Stall_IF), .Flush(FlushIF),
        .icache_valid_in(icache_valid), .NPC(NPC), .ins_valid(ins_valid),
        .icache_valid_out(icache_valid_IF), .icache_index(icache_index), .icache_tag(icache_tag), .icache_offset(icache_offset)
    );

//IF
    PC U_PC( .rst(~resetn), .clk(clk),
        .NPC(NPC), .PCAddressError(PCAddressError_IF),
        .PC(PC_IF), .put_req(inst_req)
    );

    assign icache_valid = resetn & inst_req;//当前指令无效化（不发起请求）

//ID
    IF_to_ID U_IF_to_ID(.clk(clk), .Stall(Stall_ID), .rst(~resetn), .Flush(FlushID),
        .PC_in(PC_IF), .Ins_in(icache_rdata), .PCAddressError_in(PCAddressError_IF), .ins_valid(ins_valid & ~FlushIF),
        .IsDelaySlot_in(NextIsDelaySlot_ID),
        .PC_out(PC_ID), .Ins_out(Ins_ID), .PCAddressError_out(PCAddressError_ID),
        .IsDelaySlot_out(IsDelaySlot_ID)
    );

    BranchPre U_BP (.clk(clk), .rst(~resetn), .Flush(FlushID),
        .PC_IF(PC_IF[31:2]), .Stall_ID(Stall_ID), .Target_out(PC_BP), .take_pre(take_pre),
        .take_EXE(Branch),
        .mis_predict(mis_predict),
        .ins(Ins_ID)
        );

    CTRL U_CTRL(.Nop(~(|Ins_ID)),
        .Ins(Ins_ID), .resetn(resetn),
        .RS(RS_ID), .RT(RT_ID), .RD(RD_ID), .Shift(Shift_ID), .Imm16(Imm16_ID),
        .IType(IType_ID), .NeedRS(NeedRS_ID), .NeedRT(NeedRT_ID), .RFDst(RFDst_ID), .Jump(Jump_ID), .JR(JR_ID),
		.BrOp(BrOp_ID), .ExtOp(ExtOp_ID), .ALUOp(ALUOp_ID), .LenthStore(LenthStore_ID), .LenthLoad(LenthLoad_ID),
		.SignLoad(SignLoad_ID), .DMWr(DMWr_ID), .dm_en(DM_en_ID), .RFWr(RFWr_ID), .WBSel(WBSel_ID), 
        .MFT_Sel(MFT_Sel_ID), .MF(MF_ID), .MDU_en(MDU_en_ID), .MDUOp(MDUOp_ID), .MUL(MUL_ID),
        .NextIsDelaySlot(NextIsDelaySlot_ID),
		.Scall(Scall_ID), .Undef_Instr(Undef_Instr_ID), .Break(Break_ID), . CP0_wr(CP0_wr_ID),
        .Eret(Eret_ID)
    );

    EXT U_EXT(
        .Imm16(Imm16_ID), .EXTOp(ExtOp_ID),
        .Imm32(Imm32_ID)
    );

    //RS-->RA    RT-->RB

    RF U_RF( .clk(clk), .rst(~resetn),
        .RA(RS_ID), .RB(RT_ID), .RW(RW_MEM2), .DW(DW_MEM2), .RFWr(RFWr_MEM2),
        .DRA(DRA_ID), .DRB(DRB_ID)
    );
    
    MUX5bits_OrNot MUX_RA(
        .A(RS_ID), .S(NeedRS_ID),
        .Dout(RA_ID)
    );

    MUX5bits_OrNot MUX_RB(
        .A(RT_ID), .S(NeedRT_ID),
        .Dout(RB_ID)
    );

    MUX5bits_3to1 MUX_RW(
        .A(RT_ID), .B(RD_ID), .S(RFDst_ID),
        .Dout(RW_ID)
    );

    STALL U_STALL(
        .RA_now(RA_ID), .RB_now(RB_ID),
        .RW_L1(RW_EXE), .WBSel_L1(WBSel_EXE), .RFWr_L1(RFWr_EXE),
        .RW_L2(RW_EXP), .WBSel_L2(WBSel_EXP), .RFWr_L2(RFWr_EXP),
        .RW_L3(RW_MEM1), .WBSel_L3(WBSel_MEM1), .RFWr_L3(RFWr_MEM1),
        .icache_valid(icache_valid), .icache_valid_IF(icache_valid_IF), .icache_data_ok(icache_data_ok),
        .dcache_valid(dcache_req), .dcache_valid_MEM2(dcache_valid_MEM2), .dcache_op_MEM2(dcache_op_MEM2), .dcache_addr_ok(dcache_addr_ok), .dcache_data_ok(dcache_data_ok),
        .uncache_valid(uncache_req), .uncache_valid_MEM1(uncache_valid_MEM1), .uncache_op_MEM1(uncache_op_MEM1), .uncache_addr_ok(uncache_addr_ok), .uncache_data_ok(uncache_data_ok),
        .MDU_busy(MDU_busy), .MFT(MF_ID | MFT_Sel_ID[0]),.MUL(MUL_EXE),
        .Stall_IF(Stall_IF), .Stall_ID(Stall_ID), .Stall_EXE(Stall_EXE), .Stall_EXP(Stall_EXP), .Stall_MEM1(Stall_MEM1), .Stall_MEM2(Stall_MEM2)
    );  

    Forward_for_ALU U_Forward_ALU(
        .RA_now(RA_ID), .RB_now(RB_ID),
        .RW_L1(RW_EXE), .WBSel_L1(WBSel_EXE), .RFWr_L1(RFWr_EXE),
        .RW_L2(RW_EXP), .WBSel_L2(WBSel_EXP), .RFWr_L2(RFWr_EXP),
        .RW_L3(RW_MEM1), .WBSel_L3(WBSel_MEM1), .RFWr_L3(RFWr_MEM1),
        .RW_L4(RW_MEM2), .RFWr_L4(RFWr_MEM2),
        .ALUSelA(ALUSelA_ID), .ALUSelB(ALUSelB_ID)
    );
    
//EXE
    ID_to_EXE U_Reg_ID_to_EXE(.clk(clk), .Stall_ID(Stall_ID) , .Stall_EXE(Stall_EXE), .Flush(FlushEXE), .rst(~resetn),
        .DRA_in(DRA_ID), .DRB_in(DRB_ID), .Shift_in(Shift_ID), .Imm32_in(Imm32_ID), .ALUSelA_in(ALUSelA_ID), .ALUSelB_in(ALUSelB_ID), .IType_in(IType_ID), .ALUOp_in(ALUOp_ID), .Target_in(PC_BP), .JR_in(JR_ID), .Jump_in(Jump_ID), .BrOp_in(BrOp_ID), //for EXE
        .DMWr_in(DMWr_ID), .LenthStore_in(LenthStore_ID), .LenthLoad_in(LenthLoad_ID), .SignLoad_in(SignLoad_ID), //for MEM in advance
        .PC_in(PC_ID), .WBSel_in(WBSel_ID), .Eret_in(Eret_ID), .RD_in(RD_ID),
        .RFWr_in(RFWr_ID), .RW_in(RW_ID), .dm_en_in(DM_en_ID), .CP0_wr_in(CP0_wr_ID),
		.IsDelaySlot_in(IsDelaySlot_ID), .PCAddressError_in(PCAddressError_ID), .Scall_in(Scall_ID), .Undef_Instr_in(Undef_Instr_ID), .Break_in(Break_ID),//for exception
        .MF_in(MF_ID), .MDUOp_in(MDUOp_ID), .MDU_en_in(MDU_en_ID), .MFT_Sel_in(MFT_Sel_ID), .MUL_in(MUL_ID),//for mult and div

        .DRA_out(DRA_EXE), .DRB_out(DRB_EXE), .Shift_out(Shift_EXE), .Imm32_out(Imm32_EXE), .ALUSelA_out(ALUSelA_EXE), .ALUSelB_out(ALUSelB_EXE), .IType_out(IType_EXE), .ALUOp_out(ALUOp_EXE), .Target_out(Target_B_EXE), .JR_out(JR_EXE), .Jump_out(Jump_EXE), .BrOp_out(BrOp_EXE), //for EXE
        .DMWr_out(DMWr_EXE), .LenthStore_out(LenthStore_EXE), .LenthLoad_out(LenthLoad_EXE), .SignLoad_out(SignLoad_EXE), 
        .PC_out(PC_EXE), .WBSel_out(WBSel_EXE), .Eret_out(Eret_EXE), .RD_out(RD_EXE),
        .RFWr_out(RFWr_EXE), .RW_out(RW_EXE), .dm_en_out(DM_en_EXE), .CP0_wr_out(CP0_wr_EXE),
		.IsDelaySlot_out(IsDelaySlot_EXE), .PCAddressError_out(PCAddressError_EXE), .Scall_out(Scall_EXE), .Undef_Instr_out(Undef_Instr_EXE), .Break_out(Break_EXE),
        .MF_out(MF_EXE), .MDUOp_out(MDUOp_EXE), .MDU_en_out(MDU_en_EXE), .MFT_Sel_out(MFT_Sel_EXE), .MUL_out(MUL_EXE)
    );
    
    MUX32bits_5to1 MUX_ALUA(
        .A(ALUOut_EXP), .B(ALUOut_MEM1), .C(ALUOut_MEM2), .D(DW_Forward), .E(DRA_EXE), .S(ALUSelA_EXE),
        .Dout(ALU_Operand_A)
    );

    MUX32bits_5to1 MUX_ALUB1(
        .A(ALUOut_EXP), .B(ALUOut_MEM1), .C(ALUOut_MEM2), .D(DW_Forward), .E(DRB_EXE), .S(ALUSelB_EXE),
        .Dout(data_to_DCache_EXE)
    );

    MUX32bits_2to1 MUX_ALUB(
        .A(data_to_DCache_EXE), .B(Imm32_EXE), .S(IType_EXE),
        .Dout(ALU_Operand_B)
    );

    BranchJudge U_BranchJudge(
		.Operand_A(ALU_Operand_A), .Operand_B(data_to_DCache_EXE), .BrOp(BrOp_EXE), .branch(Branch)
	);

    NEXTPC U_NEXTPC( .clk(clk), .rst(~resetn), .Stall(Stall_IF), 
        .Exc(Exc4PC), .EPC(EPC),
        .JR(JR_EXE), .Operand_A(ALU_Operand_A),
        .take_pre(take_pre), .Pre_Target(PC_BP),
        .mis_predict(mis_predict), .Branch(Branch), .PC_ID(PC_ID), .Target_EXE(Target_B_EXE),
        .PC_IF(PC_IF),
        .NPC(NPC)
    );

    ALU U_ALU(
        .Operand_A(ALU_Operand_A), .Operand_B(ALU_Operand_B), .Shift(Shift_EXE), .ALUOp(ALUOp_EXE),
        .ALUOut(ALUOut), .Overflow(Overflow_EXE)
    );

    MDU U_MDU(.clk(clk), .rst(~resetn), .Flush(FlushEXE),
        .MDU_en(MDU_en_EXE), .MUL(MUL_EXE), .operand_x(ALU_Operand_A), .operand_y(ALU_Operand_B), .MDUOp(MDUOp_EXE), .MFT_Sel(MFT_Sel_EXE),
        .MDUOut(MDUOut), .busy(MDU_busy)
    );

    MUX32bits_2to1 MUX_ALUOut(
        .A(ALUOut), .B(MDUOut), .S(MF_EXE),
        .Dout(ALUOut_EXE)
    );

//EXP
    EXE_to_EXP U_Reg_EXE_to_EXP(.clk(clk), .rst(~resetn), .Stall_EXE(Stall_EXE), .Stall_EXP(Stall_EXP), .Flush(FlushEXP),
        .PC_in(PC_EXE), .WBSel_in(WBSel_EXE), .ALUOut_in(ALUOut_EXE), .RFWr_in(RFWr_EXE), .RW_in(RW_EXE), .LenthLoad_in(LenthLoad_EXE), .SignLoad_in(SignLoad_EXE), .LenthStore_in(LenthStore_EXE),
		.IsDelaySlot_in(IsDelaySlot_EXE), .Overflow_in(Overflow_EXE), .PCAddressError_in(PCAddressError_EXE),
		.Scall_in(Scall_EXE), .Undef_Instr_in(Undef_Instr_EXE), .Break_in(Break_EXE), .CP0_wr_in(CP0_wr_EXE), .Eret_in(Eret_EXE), .RD_in(RD_EXE), .data_to_DCache_in(data_to_DCache_EXE),
        .DM_en_in(DM_en_EXE), .DMWr_in(DMWr_EXE),
        .PC_out(PC_EXP), .WBSel_out(WBSel_EXP), .ALUOut_out(ALUOut_EXP), .RFWr_out(RFWr_EXP), .RW_out(RW_EXP), .LenthLoad_out(LenthLoad_EXP), .SignLoad_out(SignLoad_EXP), .LenthStore_out(LenthStore_EXP),
		.IsDelaySlot_out(IsDelaySlot_EXP), .Overflow_out(Overflow_EXP),  .PCAddressError_out(PCAddressError_EXP),
		.Scall_out(Scall_EXP), .Undef_Instr_out(Undef_Instr_EXP), .Break_out(Break_EXP), .CP0_wr_out(CP0_wr_EXP), .Eret_out(Eret_EXP), .RD_out(RD_EXP), .data_to_DCache_out(data_to_DCache_EXP),
        .DM_en_out(DM_en_EXP), .DMWr_out(DMWr_EXP)
    );

    DM_decoder U_DM_decoder(.Flush(FlushEXP),
        .DM_en(DM_en_EXP), .ALUOut(ALUOut_EXP), .Din(data_to_DCache_EXP), .LenthLoad(LenthLoad_EXP), .LenthStore(LenthStore_EXP), .DMWr(DMWr_EXP),
        .SAddressError(SAddressError_EXP), .LAddressError(LAddressError_EXP),
        .Dout(wdata), .dcache_valid(dcache_req), .dcache_index(dcache_index), .dcache_offset(dcache_offset), .dcache_tag(dcache_tag), .dcache_wstrb(dcache_wstrb), .dcache_op(dcache_op),
        .uncache_valid(uncache_req), .uncache_index(uncache_index), .uncache_offset(uncache_offset), .uncache_tag(uncache_tag), .uncache_wstrb(uncache_wstrb), .uncache_op(uncache_op),
        .arsize(uncache_arsize),.awsize(uncache_awsize)
    );

    assign dcache_valid = dcache_req & !Stall_EXP;
    assign uncache_valid = uncache_req ;//& !Stall_EXP;

    assign dcache_wdata = wdata;
    assign uncache_wdata = wdata;

    EXCEPTION U_EXCEPTION(.clk(clk),.Hard_Break(Hard_Break),.Soft_Break(Soft_Break),
		.Status_EXL_in(Status_EXL4Exc),.Overflow(Overflow_EXP), .SAddressError(SAddressError_EXP),
		.LAddressError(LAddressError_EXP), .InDelaySlot(IsDelaySlot_EXP),
		.PCAddressError(PCAddressError_EXP), .PCofThisInstr(PC_EXP), .PCofPreInstr(PC_MEM1), .BadVAddr(ALUOut_EXP),
		.Scall(Scall_EXP), .Exc(Exc4PC), .Undef_Instr(Undef_Instr_EXP), .Break(Break_EXP), .Eret(Eret_EXP),
		.FlushExc(FlushExc), .BadVAddr_Wr(BadVAddr_Wr), .BadVAddr_out(BadVAddr4Set), 
		.Status_EXL_out(Status_EXL4Set), .Cause_BD_out(Cause_BD4Set), .Cause_ExcCode_Wr(Cause_ExcCode_Wr), .Cause_ExcCode_out(Cause_ExcCode),
        .EPC_Wr(EPC_Wr), .EPC_out(EPC4Set), .Cause_BD_Wr(Cause_BD_Wr)
	);
//MEM1
    EXP_to_MEM1 U_Reg_EXP_to_MEM1(.clk(clk), .rst(~resetn), .Stall_EXP(Stall_EXP), .Stall_MEM1(Stall_MEM1), .Flush(FlushEXP),
        .PC_in(PC_EXP), .WBSel_in(WBSel_EXP), .ALUOut_in(ALUOut_EXP), .RFWr_in(RFWr_EXP), .RW_in(RW_EXP), .LenthLoad_in(LenthLoad_EXP), .SignLoad_in(SignLoad_EXP), .CP0_out_in(CP0_out_EXP), 
        .dcache_valid_in(dcache_valid), .dcache_op_in(dcache_op), .uncache_valid_in(uncache_valid), .uncache_op_in(uncache_op),
        .PC_out(PC_MEM1), .WBSel_out(WBSel_MEM1), .ALUOut_out(ALUOut_MEM1), .RFWr_out(RFWr_MEM1), .RW_out(RW_MEM1), .LenthLoad_out(LenthLoad_MEM1), .SignLoad_out(SignLoad_MEM1), .CP0_out_out(CP0_out_MEM1), 
        .dcache_valid_out(dcache_valid_MEM1), .uncache_valid_out(uncache_valid_MEM1), .dcache_op_out(dcache_op_MEM1), .uncache_op_out(uncache_op_MEM1)
    );
    //exception handler during MEM stage
	

	CP0 U_CP0(.rst(~resetn), .clk(clk),.CP0_Num(RD_EXP), .CP0_WD(data_to_DCache_EXP), .CP0_wr(CP0_wr_EXP & ~Stall_EXP), .int(ext_int),
		.BadVAddr_in(BadVAddr4Set), .SetStatus_EXL(Status_EXL4Set), .ClrStatus_EXL(Eret_EXP), 
        .BadVAddr_Wr(BadVAddr_Wr), .Cause_BD_Wr(Cause_BD_Wr), .Cause_ExcCode_Wr(Cause_ExcCode_Wr), .Cause_ExcCode_in(Cause_ExcCode),
		.Cause_BD(Cause_BD4Set), .EPC_Wr(EPC_Wr),
		.SetEPC(EPC4Set), .CP0_out(CP0_out_EXP), .Status_EXL_out(Status_EXL4Exc), .EPC_out(EPC), .Soft_Break(Soft_Break), .Hard_Break(Hard_Break)
	);
//MEM2
    MEM1_to_MEM2 U_Reg_MEM1_to_MEM2(.clk(clk), .rst(~resetn), .Stall_MEM1(Stall_MEM1), .Stall_MEM2(Stall_MEM2),
        .PC_in(PC_MEM1), .WBSel_in(WBSel_MEM1), .ALUOut_in(ALUOut_MEM1), .RFWr_in(RFWr_MEM1), .RW_in(RW_MEM1), .LenthLoad_in(LenthLoad_MEM1), .SignLoad_in(SignLoad_MEM1), .CP0_out_in(CP0_out_MEM1), 
        .dcache_valid_in(dcache_valid_MEM1), .dcache_op_in(dcache_op_MEM1), .uncache_rdata_in(uncache_rdata),
        .PC_out(PC_MEM2), .WBSel_out(WBSel_MEM2), .ALUOut_out(ALUOut_MEM2), .RFWr_out(RFWr_MEM2), .RW_out(RW_MEM2), .LenthLoad_out(LenthLoad_MEM2), .SignLoad_out(SignLoad_MEM2), .CP0_out_out(CP0_out_MEM2), 
        .dcache_valid_out(dcache_valid_MEM2), .dcache_op_out(dcache_op_MEM2), .uncache_rdata_out(uncache_rdata_MEM2)
    );

    wire [31:0] DM_rdata;



//try
    MUX32bits_2to1 MUX_DM(
        .A(uncache_rdata_MEM2), .B(dcache_rdata), .S(dcache_valid_MEM2),//选择信号有待改动
        .Dout(DM_rdata)
    );

    DM_EXT U_DM_EXT(
        .Addr_Last(ALUOut_MEM2[1:0]), .Din(DM_rdata), .LenthLoad(LenthLoad_MEM2), .Sign(SignLoad_MEM2), 
        .Dout(DM_out)
    );

    MUX32bits_4to1 MUX_DW(
        .A(ALUOut_MEM2), .B(DM_out), .C(PC_MEM2+8), .D(CP0_out_MEM2), .S(WBSel_MEM2),
        .Dout(DW_MEM2)
    );

//WB
    MEM_to_WB U_Reg_MEM_to_WB(.clk(clk), .Stall_MEM2(Stall_MEM2), .Stall_Forward(Stall_EXE),
    .RFWr_in(RFWr_MEM2), .RW_in(RW_MEM2), .PC_in(PC_MEM2), 
    .DW_in(DW_MEM2),
    .RFWr_out(RFWr_WB), .RW_out(RW_WB), .PC_out(PC_WB), 
    .DW_out(DW_WB),.DW_Forward(DW_Forward)
    );
    
endmodule
