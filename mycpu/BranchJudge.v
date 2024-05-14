module BranchJudge(Operand_A,Operand_B,BrOp,branch);
	input[31:0] Operand_A;
	input[31:0] Operand_B;
    input [2:0] BrOp;//100:beq 101:bne 011:bgez 010:bltz 001:bgtz 000:blez 111:not branch
	output reg branch;
	
	wire eq,zero,gez;
	
	always @(BrOp or eq or zero or gez)
        case (BrOp)
            3'b000: branch = ~gez;//blt
            3'b001: branch = gez;//bge
            3'b100: branch = eq;//beq
            3'b101: branch = ~eq;//bne
            3'b110: branch = (~gez)|zero;//ble
            3'b111: branch = gez&(~zero);//bgt
            default: branch = 0;
        endcase

    assign eq = Operand_A == Operand_B;
    assign zero = ~(|Operand_A);
    assign gez = ~Operand_A[31];
	
endmodule