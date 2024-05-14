module MDU (clk,rst,Flush,MDU_en,MUL,operand_x,operand_y,MDUOp,MFT_Sel,MDUOut,busy);
    input clk,Flush,rst;
    input MDU_en;
    input MUL;
    input [31:0] operand_x,operand_y;
    input [1:0] MDUOp;//00:mult 01:multu 10:div 11:divu
    input [1:0] MFT_Sel;//00:MFHI 10:MFLO 01:MTHI 11:MTLO
    
    output [31:0] MDUOut;
    output busy;

    reg [31:0] A,B;
    reg [1:0] opcode;
    reg [31:0] HI,LO;
    reg MUL_1;

    reg doing;

    assign busy = (MDU_en & ~Flush) | doing;

    wire [63:0] MultOut,DivOut_S,DivOut_U;
    wire finish_S,finish_U,finish_M;
    reg Div_en,Divu_en,Mult_en;

    assign MDUOut = MUL?MultOut[31:0] : (MFT_Sel[1]?LO:HI);

    always @(posedge clk)
        if (MDU_en & ~Flush)
            doing <= 1;
        else if(doing)
            case (opcode)
                2'b10: doing <= ~finish_S;//div 
                2'b11: doing <= ~finish_U;//divu
                default: doing <= ~finish_M;//
            endcase
    
    always @(posedge clk)
        if(MDU_en & ~Flush)
            A <= operand_x;
    
    always @(posedge clk)
        if(MDU_en & ~Flush)
            B <= operand_y;

    always @(posedge clk)
        if(MDU_en & ~Flush)
            opcode <= MDUOp;

    always @(posedge clk)
        if(MDU_en & ~Flush)
            MUL_1 <= MUL;

    always @(posedge clk)
        if(MDU_en & ~Flush)
            case (MDUOp)
                2'b11:begin
                    Divu_en <= 1;
                    Div_en <= 0;
                    Mult_en <= 0;
                    end
                2'b10:begin
                    Divu_en <= 0;
                    Div_en <= 1;
                    Mult_en <= 0;
                    end    
                default: begin
                    Divu_en <= 0;
                    Div_en <= 0;
                    Mult_en <= 1;
                    end    
            endcase
        else
            begin
                Divu_en <= 0;
                Div_en <= 0;
                Mult_en <= 0;
            end    

    always @(posedge clk)
        if(&MFT_Sel)//11:MTLO
            LO <= operand_x;
        else if(MFT_Sel[0])//01:MTHI
            HI <= operand_x;
        else if(finish_M && ~opcode[1])
            {HI,LO} <= MultOut;//mult(u)
        else if(finish_S && opcode == 2'b10)
            {LO,HI} <= DivOut_S;//div
        else if(finish_U && opcode == 2'b11)
            {LO,HI} <= DivOut_U;//divu
            
    Mult U_Mult( .Mult_en(Mult_en), .clk(clk), .rst(rst),
        .MultA(A), .MultB(B), .MDUOp(opcode), 
        .MultOut(MultOut), .finish(finish_M));

    Div_U U_Div_U(.clk(clk),
    .DivA(A), .DivB(B), .Divu_en(Divu_en), 
    .DivOut_U(DivOut_U), .finish(finish_U));// unsigned A/B

    Div_S U_Div_S(.clk(clk),
    .DivA(A), .DivB(B), .Div_en(Div_en), 
    .DivOut_S(DivOut_S), .finish(finish_S));// unsigned A/B

endmodule




module Mult(clk,rst,Mult_en,MultA,MultB,MDUOp,MultOut,finish);
    input clk,rst;
    input Mult_en;
    input [31:0] MultA,MultB;
    input [1:0] MDUOp;
    output [63:0] MultOut;
    output finish;

    wire [63:0] result_U,result_S;


    mult_S U_multS (
        .CLK(clk), 
        .A(MultA),  // input wire [31 : 0] A
        .B(MultB),  // input wire [31 : 0] B
        .P(result_S)  // output wire [63 : 0] P
    );

    mult_U U_multU (
        .CLK(clk),
        .A(MultA),  // input wire [31 : 0] A
        .B(MultB),  // input wire [31 : 0] B
        .P(result_U)  // output wire [63 : 0] P
    );
/*
        reg cnt;
        always @(posedge clk) begin
        if(Mult_en)
            cnt = 1;
        else
            cnt = 0; 
    end

    assign finish = cnt;//1
*/
    
    reg [1:0]cnt;
    always @(posedge clk or posedge rst) begin
        if(rst)
            cnt <= 0;
        else if(Mult_en)
            cnt <= 1;
        else if(cnt == 2'b10)
            cnt <= 0; 
        else if(cnt != 0)
            cnt <= cnt+1;
    end

    assign finish = cnt[1];//2


//这里替换IP核
    assign MultOut = MDUOp[0]?result_U:result_S;

endmodule

module Div_U(clk,DivA,DivB,Divu_en,DivOut_U,finish);// unsigned A/B
    input [31:0] DivA,DivB;
    //input [1:0] MDUOp;
    input Divu_en;
    input clk;
    output [63:0] DivOut_U;
    output finish;

    wire s_axis_dividend_tready,s_axis_divisor_tready;
    wire m_axis_dout_tvalid;
    reg s_axis_divisor_tvalid,s_axis_dividend_tvalid;
    wire [63:0] DivOut;

    assign finish = m_axis_dout_tvalid;


    always @(posedge clk)
        if(Divu_en)
            s_axis_dividend_tvalid <= 1;
        else if(s_axis_divisor_tready==1 && s_axis_divisor_tvalid==1 && s_axis_dividend_tvalid==1 && s_axis_dividend_tready==1)
            s_axis_dividend_tvalid <= 0;

    always @(posedge clk)
        if(Divu_en)
            s_axis_divisor_tvalid <= 1;
        else if(s_axis_divisor_tready==1 && s_axis_divisor_tvalid==1 && s_axis_dividend_tvalid==1 && s_axis_dividend_tready==1)
            s_axis_divisor_tvalid <= 0;

    div_gen_0 math_divu (             //无符号除法
    .aclk                    (clk),
    .s_axis_divisor_tvalid   (s_axis_divisor_tvalid),   //除数
    .s_axis_divisor_tdata    (DivB),
    .s_axis_divisor_tready   (s_axis_divisor_tready),
    .s_axis_dividend_tvalid  (s_axis_dividend_tvalid),   //被除数
    .s_axis_dividend_tdata   (DivA),
    .s_axis_dividend_tready  (s_axis_dividend_tready),
    .m_axis_dout_tvalid      (m_axis_dout_tvalid),      //busy信号可由此生成
    .m_axis_dout_tdata       (DivOut)//商和余数,商在[63：32]位
    );

    assign DivOut_U = DivOut;

endmodule


module Div_S(clk,DivA,DivB,Div_en,DivOut_S,finish);// signed A/B
    input [31:0] DivA,DivB;
    //input [1:0] MDUOp;
    input Div_en;
    input clk;
    output [63:0] DivOut_S;
    output finish;

    wire s_axis_dividend_tready,s_axis_divisor_tready;
    wire m_axis_dout_tvalid;
    reg s_axis_divisor_tvalid,s_axis_dividend_tvalid;
    wire [63:0] DivOut;

    assign finish = m_axis_dout_tvalid;

    always @(posedge clk)
        if(Div_en)
            s_axis_dividend_tvalid <= 1;
        else if(s_axis_divisor_tready==1 && s_axis_divisor_tvalid==1 && s_axis_dividend_tvalid==1 && s_axis_dividend_tready==1)
            s_axis_dividend_tvalid <= 0;

    always @(posedge clk)
        if(Div_en)
            s_axis_divisor_tvalid <= 1;
        else if(s_axis_divisor_tready==1 && s_axis_divisor_tvalid==1 && s_axis_dividend_tvalid==1 && s_axis_dividend_tready==1)
            s_axis_divisor_tvalid <= 0;

    div_gen_1 math_divs(             //带符号除法
    .aclk                    (clk),
    .s_axis_divisor_tvalid   (s_axis_divisor_tvalid),   //除数
    .s_axis_divisor_tdata    (DivB),
    .s_axis_divisor_tready   (s_axis_divisor_tready),
    .s_axis_dividend_tvalid  (s_axis_dividend_tvalid),   //被除数
    .s_axis_dividend_tdata   (DivA),
    .s_axis_dividend_tready  (s_axis_dividend_tready),
    .m_axis_dout_tvalid      (m_axis_dout_tvalid),      //商和余数,商在[63：32]位
    .m_axis_dout_tdata       (DivOut)
    );

    assign DivOut_S = DivOut;

endmodule