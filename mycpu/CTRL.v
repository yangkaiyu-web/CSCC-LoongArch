module CTRL(resetn,Nop,Ins,IType,NeedRS,NeedRT,RFDst,Jump,JR,BrOp,
        ExtOp,ALUOp,LenthStore,LenthLoad,SignLoad,DMWr,dm_en,RFWr,WBSel,MFT_Sel,MUL,
        MF,MDU_en,MDUOp,NextIsDelaySlot,Scall,Undef_Instr,Break,CP0_wr,Eret,RS,RT,RD,Shift,Imm16);
    input Nop;
    input resetn;
    input [31:0] Ins;

    output reg IType;
    output reg NeedRS,NeedRT;
    output reg [1:0] RFDst;
    output reg Jump,JR;
    output reg [2:0] BrOp;
    output reg [1:0] ExtOp;
    output reg [3:0] ALUOp;
    output reg [1:0] LenthLoad,LenthStore;
    output reg SignLoad;
    output reg DMWr;
    output reg RFWr;
    output reg [1:0] WBSel;
    output reg [1:0] MFT_Sel;
    output reg MF;
    output reg MDU_en;
    output reg [1:0] MDUOp;
    output reg MUL;
	output reg NextIsDelaySlot;
	output reg Scall,Break;
	output reg Undef_Instr;
    output reg dm_en;
    output reg CP0_wr;
    output reg Eret;
    output [4:0] RS, RT, RD;
    output [4:0] Shift;
    output [15:0] Imm16;

    wire [5:0] op,func;

    assign op = Ins[31:26];
    assign func = Ins[5:0];
    assign RS = Ins[25:21];
    assign RT = Ins[20:16];
    assign RD = Ins[15:11];
    assign Shift = Ins[10:6];
    assign Imm16 = Ins[15:0];

    always @(Ins or Nop or op or func or resetn)
    begin
        if(~resetn || Nop)
            begin
                IType = 0;
                NeedRS = 0;
                NeedRT = 0;
                RFDst = 2'b00;
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ExtOp = 2'b00;
                ALUOp = 4'b0001;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = 1'b0; 
                WBSel = 2'b00;
				NextIsDelaySlot = 1'b0;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end 
        else
        case (op)
            6'b00_0000://R
            case (func)
                6'b00_0000: //sll
                begin
                    IType = 1'b0;
                    NeedRS = 1;
                    NeedRT = 1;
                    RFDst = 2'b01;//RD
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ExtOp = 2'b00;
                    ALUOp = 4'b1000;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = 1'b1;
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
                6'b00_0010: //srl
                begin
                    IType = 1'b0;
                    NeedRS = 1;
                    NeedRT = 1;
                    RFDst = 2'b01;//RD
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ALUOp = 4'b1001;
                    ExtOp = 2'b00;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = 1;
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
                6'b00_0011: //sra
                begin
                    IType = 1'b0;
                    NeedRS = 1;
                    NeedRT = 1;
                    RFDst = 2'b01;//RD
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ExtOp = 2'b00;
                    ALUOp = 4'b1100;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = 1;
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
                6'b00_0100: //sllv
                begin
                    IType = 1'b0;
                    NeedRS = 1;
                    NeedRT = 1;
                    RFDst = 2'b01;//RD
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ExtOp = 2'b00;
                    ALUOp = 4'b1101;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = 1;
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
                6'b00_0110: //srlv
                begin
                    IType = 1'b0;
                    NeedRS = 1;
                    NeedRT = 1;
                    RFDst = 2'b01;//RD
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ExtOp = 2'b00;
                    ALUOp = 4'b1110;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = 1;
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
                6'b00_0111: //srav
                begin
                    IType = 1'b0;
                    NeedRS = 1;
                    NeedRT = 1;
                    RFDst = 2'b01;//RD
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ALUOp = 4'b1111;
                    ExtOp = 2'b00;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = 1;
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
                6'b00_1000,6'b00_1001: //jr jalr
                begin
                    IType = 1'b0;
                    NeedRS = 1;
                    NeedRT = 0;
                    RFDst = 2'b01;//RD
                    Jump = 1;
                    JR = 1;
                    BrOp = 3'b011;
                    ALUOp = 4'b0001;
                    ExtOp = 2'b00;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = func[0];
                    WBSel = 2'b10;
                    NextIsDelaySlot=1'b1;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
                6'b001100:  //scall
                begin
                    IType=1'b0;
                    NeedRS = 0;
                    NeedRT = 0;
                    RFDst = 2'b00;
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ALUOp = 4'b0001;
                    ExtOp = 2'b00;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = 0; 
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b1;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
                6'b00_1101: //break
                begin
                    IType = 0;
                    NeedRS = 0;
                    NeedRT = 0;
                    RFDst = 2'b00;
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ALUOp = 4'b0001;
                    ExtOp = 2'b00;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = 1'b0; 
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b1;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end 
                6'b01_1010,6'b01_1011,6'b01_1000,6'b01_1001: //div,divu,mult,multu
                begin
                    IType = 0;
                    NeedRS = 1;
                    NeedRT = 1;
                    RFDst = 2'b01;
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ALUOp = 4'b0001;
                    ExtOp = 2'b00;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 1;
                    MDU_en = 1;
                    MDUOp = func[1:0];
                    MUL = 0;
                    RFWr = 1'b0;
                         
                end
                6'b01_0010,6'b01_0011,6'b01_0000,6'b01_0001: //mflo,mtlo,mfhi,mthi
                begin
                    IType=1'b0;
                    NeedRS = func[0];
                    NeedRT = 0;
                    RFDst = 2'b01;
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ALUOp = 4'b0001;
                    ExtOp = 2'b00;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = ~func[0]; 
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = func[1:0];
                    MF = ~func[0];
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
                default: 
                begin
                    IType = 1'b0;
                    NeedRS = 1;
                    NeedRT = 1;
                    RFDst = 2'b01;//RD
                    Jump = 0;
                    JR = 0;
                    BrOp = 3'b011;
                    ALUOp = func[3:0];
                    ExtOp = 2'b00;
                    LenthStore = op[1:0];
                    LenthLoad = op[1:0];
                    SignLoad = ~op[2];
                    DMWr = 1'b0;
                    RFWr = 1;
                    WBSel = 2'b00;
                    NextIsDelaySlot=1'b0;
                    Undef_Instr=1'b0;
                    Scall=1'b0;
                    Break=1'b0;
                    dm_en=1'b0;
                    CP0_wr=1'b0;
                    Eret=1'b0;
                    MFT_Sel = 2'b00;
                    MF = 0;
                    MDU_en = 0;
                    MDUOp = 2'b00;
                    MUL = 0;
                end
            endcase
            6'b00_1000,6'b00_1001,6'b00_1100,6'b00_1101,6'b00_1110://addi,addiu,andi,ori,xori
            begin
                IType = 1'b1;
                NeedRS = 1;
                NeedRT = 0;
                RFDst = 2'b00;//RT
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ExtOp = {1'b0,~op[2]};
                ALUOp = {1'b0,op[2:0]};
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = 1;
                WBSel = 2'b00;
				NextIsDelaySlot=1'b0;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end 
            
            6'b011100:begin//MUL
                IType = 0;
                NeedRS = 1;
                NeedRT = 1;
                RFDst = 2'b01;
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ALUOp = 4'b0001;
                ExtOp = 2'b00;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                WBSel = 2'b00;
                NextIsDelaySlot=1'b0;
                Undef_Instr=1'b0;
                Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 1;
                if(func == 6'b000010)begin
                    MDU_en = 1;
                    MDUOp = 2'b00;
                    MUL = 1;
                    RFWr = 1'b1;
                end
                else begin
                    MDU_en = 1;
                    MDUOp = 2'b00;
                    MUL = 0;
                    RFWr = 1'b0;
                end 
            end

            6'b00_1111://LUI
            begin
                IType = 1;
                NeedRS = 0;
                NeedRT = 0;
                RFDst = 2'b00;//RT
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ExtOp = 2'b10;
                ALUOp = 4'b1111;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = 1;
                WBSel = 2'b00;
				NextIsDelaySlot=1'b0;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end 
            6'b00_1010,6'b00_1011://SLTI SLTIU
            begin
                IType = 1;
                NeedRS = 1;
                NeedRT = 0;
                RFDst = 2'b00;//RT
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ExtOp = {1'b0,~op[2]};
                ALUOp = {1'b1,op[2:0]};
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = 1;
                WBSel = 2'b00;
				NextIsDelaySlot=1'b0;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end 
            6'b010000:  //MFC0 MTC0 ERET
            begin
                IType = 0;
                NeedRS = 0;
                NeedRT = 1;
                RFDst = 2'b00;//RT
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ALUOp = 4'b0001;
                ExtOp = 2'b00;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                WBSel = 2'b11;
				NextIsDelaySlot=1'b0;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                if(Ins[25])
                begin
                    CP0_wr = 1'b0;
                    RFWr = 1'b0;
                    Eret = 1'b1;
                end
                else
                begin
                    CP0_wr = Ins[23];
                    RFWr = ~Ins[23];
                    Eret = 1'b0;
                end
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end

            6'b10_0000,6'b10_0100,6'b10_0001,6'b10_0101,6'b10_0011://lb lbu lh lhu lw
            begin
                IType = 1;
                NeedRS = 1;
                NeedRT = 0;
                RFDst = 2'b00;//RT
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ExtOp = 2'b01;
                ALUOp = 4'b0001;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = 1;
                WBSel = 2'b01;
				NextIsDelaySlot=1'b0;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b1;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end
            6'b10_1000,6'b10_1001,6'b10_1011://sb sh sw
            begin
                IType = 1;
                NeedRS = 1;
                NeedRT = 1;
                RFDst = 2'b00;
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ExtOp = 2'b01;
                ALUOp = 4'b0001;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b1;
                RFWr = 0;
                WBSel = 2'b00;
				NextIsDelaySlot=1'b0;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b1;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end 
            6'b00_0100,6'b00_0101,6'b00_0110,6'b00_0111://beq,bne,blez,bgtz
            begin
                IType = 0;
                NeedRS = 1;
                NeedRT = ~op[1];
                RFDst = 2'b00;
                Jump = 0;
                JR = 0;
                BrOp = op[2:0];
                ALUOp = 4'b0001;
                ExtOp = 2'b00;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = 1'b0;
                WBSel = 2'b00;
				NextIsDelaySlot=1'b1;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end 
            6'b00_0001://bltz,bgez,bgezal,bltzal
            begin
                IType = 0;
                NeedRS = 1;
                NeedRT = 0;
                RFDst = 2'b10;//31
                Jump = 0;
                JR = 0;
                BrOp = Ins[18:16];
                ALUOp = 4'b0001;
                ExtOp = 2'b00;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = Ins[20];
                WBSel = 2'b10;
				NextIsDelaySlot=1'b1;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end
            6'b00_0010,6'b00_0011://J JAL
            begin
                IType = 0;
                NeedRS = 0;
                NeedRT = 0;
                RFDst = 2'b10;//31
                Jump = 1;
                JR = 0;
                BrOp = 3'b011;
                ALUOp = 4'b0001;
                ExtOp = 2'b00;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = op[0];
                WBSel = 2'b10;
				NextIsDelaySlot=1'b1;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end 
            default: //undefine instruction 
            begin
                IType = 0;
                NeedRS = 0;
                NeedRT = 0;
                RFDst = 2'b00;
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ALUOp = 4'b0001;
                ExtOp = 2'b00;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = 0;
                WBSel = 2'b00; 
				NextIsDelaySlot=1'b0;
				Undef_Instr=resetn;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;
            end 
        endcase
    end

    

endmodule
/*
                IType = 0;
                NeedRS = 0;
                NeedRT = 0;
                RFDst = 2'b00;
                Jump = 0;
                JR = 0;
                BrOp = 3'b011;
                ALUOp = 4'b0001;
                ExtOp = 2'b00;
                LenthStore = op[1:0];
                LenthLoad = op[1:0];
                SignLoad = ~op[2];
                DMWr = 1'b0;
                RFWr = 1'b0; 
                WBSel = 2'b00;
				NextIsDelaySlot = 1'b0;
				Undef_Instr=1'b0;
				Scall=1'b0;
                Break=1'b0;
                dm_en=1'b0;
                CP0_wr=1'b0;
                Eret=1'b0;
                MFT_Sel = 2'b00;
                MF = 0;
                MDU_en = 0;
                MDUOp = 2'b00;
                MUL = 0;

*/