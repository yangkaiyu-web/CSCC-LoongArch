module ALU(Operand_A,Operand_B,Shift,ALUOp,ALUOut,Overflow);

    input[31:0] Operand_A,Operand_B;
    input[3:0] ALUOp;
    input[4:0] Shift;
    output reg[31:0] ALUOut;
    output reg Overflow;

    reg Cout;

    always@(Operand_A,Operand_B,ALUOp,Shift)
    begin
        Overflow = 0;
        case(ALUOp)
            4'b0000://add
                begin
                    {Cout,ALUOut} = {Operand_A[31],Operand_A} + {Operand_B[31],Operand_B};
                    Overflow = Cout ^ ALUOut[31];
                end
            4'b0001: ALUOut = Operand_A + Operand_B;//addu
            4'b0010: //sub
                begin
                    {Cout,ALUOut} = {Operand_A[31],Operand_A} - {Operand_B[31],Operand_B};
                    Overflow = Cout ^ ALUOut[31];
                end
            4'b0011: ALUOut = Operand_A - Operand_B;//subu
            4'b0100: ALUOut = Operand_A & Operand_B;
            4'b0101: ALUOut = Operand_A | Operand_B;
            4'b0110: ALUOut = Operand_A ^ Operand_B;
            4'b0111: ALUOut = ~(Operand_A | Operand_B);

            4'b1010: 
                begin	//slt
                    if(Operand_A[31]~^Operand_B[31])
                        ALUOut=(Operand_A<Operand_B?32'b1:32'b0);
                    else if(Operand_A[31])
                        ALUOut=32'b1;
                    else
                        ALUOut=32'b0;
                end//slt
            4'b1011: ALUOut = ({{1'b0},Operand_A}<{{1'b0},Operand_B}?32'b1:32'b0); 	//sltu
            
            4'b1000: ALUOut = Operand_B<<Shift; //sll
            4'b1001: ALUOut = Operand_B>>Shift; //srl
            4'b1100: ALUOut = ($signed(Operand_B))>>>Shift; //sra
            4'b1101: ALUOut = Operand_B<<Operand_A[4:0];	//sllv
            4'b1110: ALUOut = Operand_B>>Operand_A[4:0];	//srlv
            4'b1111: ALUOut = ($signed(Operand_B))>>>Operand_A[4:0];	//srav
            default: ALUOut = Operand_B;
        endcase
    end
        


endmodule
