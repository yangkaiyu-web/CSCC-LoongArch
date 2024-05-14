module EXCEPTION(clk,Status_EXL_in,Overflow,SAddressError,LAddressError,InDelaySlot,PCAddressError,PCofThisInstr,PCofPreInstr,BadVAddr,Scall,Undef_Instr,Break,Soft_Break,Hard_Break,Eret,
	Exc,FlushExc,BadVAddr_Wr,BadVAddr_out,Status_EXL_out,Cause_BD_Wr,Cause_BD_out,Cause_ExcCode_Wr,
	Cause_ExcCode_out,EPC_Wr,EPC_out);
input clk;
input Overflow;
input InDelaySlot;
input PCAddressError;
input Scall;
input Break;
input Undef_Instr;
input LAddressError,SAddressError;
input Status_EXL_in;
input[31:0] BadVAddr;
input[31:0] PCofThisInstr,PCofPreInstr;
input Soft_Break,Hard_Break;
input Eret;

output [1:0] Exc;
output FlushExc;
output EPC_Wr,Cause_BD_Wr,BadVAddr_Wr,Cause_ExcCode_Wr;
output Status_EXL_out,Cause_BD_out;
output reg[4:0] Cause_ExcCode_out;
output[31:0] BadVAddr_out,EPC_out;

assign FlushExc = |Exc;
assign Exc = ({2{Overflow|LAddressError|SAddressError|PCAddressError|Scall|Undef_Instr|Break|Soft_Break|Hard_Break}}&2'b01)
			|({2{Eret}}&2'b10);
//01 :380  10:epc
assign EPC_Wr=(Exc[0])&(~Status_EXL_in);
assign Cause_BD_Wr=Exc&&(~Status_EXL_in);//且不处于中断状态
assign Cause_ExcCode_Wr=Exc;
assign Status_EXL_out=Exc[0]&&(~Status_EXL_in);
assign BadVAddr_Wr=LAddressError|SAddressError|PCAddressError;
assign Cause_BD_out=InDelaySlot;
assign EPC_out=Soft_Break ? PCofPreInstr + 4 : (InDelaySlot ? PCofThisInstr-4 : PCofThisInstr);
assign BadVAddr_out=(PCAddressError ? PCofThisInstr : BadVAddr);

/*	
always @(int or PCAddressError or Undef_Instr or Overflow or Scall or Break or SAddressError or LAddressError)
begin
	if(|int)
		Cause_ExcCode_out=5'b0;
	else if(PCAddressError)
		Cause_ExcCode_out=5'b00100;
	else if(Undef_Instr)
		Cause_ExcCode_out=5'b01010;
	else if(Overflow|Scall|Break)
		case({Overflow,Scall,Break})
			3'b100:
				Cause_ExcCode_out=5'b01100;
			3'b010:
				Cause_ExcCode_out=5'b01000;
			3'b001:
				Cause_ExcCode_out=5'b01001;
			default:
				Cause_ExcCode_out=5'b00000;
		endcase
	else if(SAddressError|LAddressError)
		case({SAddressError,LAddressError})
			2'b10:
				Cause_ExcCode_out=5'b00101;
			2'b01:
				Cause_ExcCode_out=5'b00100;
			default:
				Cause_ExcCode_out=5'b00000;
		endcase
	else
		Cause_ExcCode_out=5'b00000;
end

endmodule
*/
always @(PCAddressError or Undef_Instr or Overflow or Scall or Break or SAddressError or LAddressError or Soft_Break or Hard_Break)
begin
	if(Soft_Break | Hard_Break)
		Cause_ExcCode_out=5'b0;
	else if(PCAddressError)
		Cause_ExcCode_out=5'b00100;
	else if(Undef_Instr)
		Cause_ExcCode_out=5'b01010;
	else if(Overflow|Scall|Break)
		case({Overflow,Scall,Break})
			3'b100:
				Cause_ExcCode_out=5'b01100;
			3'b010:
				Cause_ExcCode_out=5'b01000;
			3'b001:
				Cause_ExcCode_out=5'b01001;
			default:
				Cause_ExcCode_out=5'b00000;
		endcase
	else if(SAddressError|LAddressError)
		case({SAddressError,LAddressError})
			2'b10:
				Cause_ExcCode_out=5'b00101;
			2'b01:
				Cause_ExcCode_out=5'b00100;
			default:
				Cause_ExcCode_out=5'b00000;
		endcase
	else
		Cause_ExcCode_out=5'b00000;
end

endmodule