module DM_decoder(DM_en,ALUOut,Din,LenthLoad,LenthStore,DMWr,Flush,
SAddressError,LAddressError,
Dout,dcache_valid,dcache_index,dcache_offset,dcache_tag,dcache_wstrb,dcache_op,
uncache_valid,uncache_index,uncache_offset,uncache_tag,uncache_wstrb,uncache_op,
awsize,arsize
);
    input DM_en;
    input [31:0] ALUOut;
    input [31:0] Din;
    input [1:0] LenthLoad,LenthStore;
    input DMWr;
    input Flush;

    output reg SAddressError,LAddressError;
    output reg [31:0] Dout;
    output dcache_valid,uncache_valid;
    output [7:0] dcache_index,uncache_index;
    output [3:0] dcache_offset,uncache_offset;
    output [19:0] uncache_tag;
    output reg [19:0] dcache_tag;
    output [3:0] dcache_wstrb,uncache_wstrb;
    output dcache_op,uncache_op;
    output reg [2:0] awsize,arsize;

    reg [3:0] DM_Wen;
    reg [3:0] temp;
    wire Error;
    wire [3:0] DMWr4;
    wire [1:0] Addr_Last;

    assign Addr_Last = ALUOut[1:0];

    assign Error = LAddressError|SAddressError;
    assign DMWr4 = {4{DMWr&(~Error)}};

//error
    always @(DMWr or DM_en or LenthLoad or Addr_Last)      
    begin
        if(!DMWr&&DM_en&&((LenthLoad==2'b11&&(|Addr_Last))||(LenthLoad==2'b01&&Addr_Last[0])))
            LAddressError=1'b1;
        else
            LAddressError=1'b0;
    end

    always @(DMWr or DM_en or LenthStore or Addr_Last)
    begin
        if(DMWr&&DM_en&&((LenthStore==2'b11&&(|Addr_Last))||(LenthStore==2'b01&&Addr_Last[0])))
            SAddressError=1'b1;
        else   
            SAddressError=1'b0;
    end
//wstrb
    always @(LenthStore or DMWr4)
    case (LenthStore)
        2'b11: temp = 4'b1111 & DMWr4;
        2'b01: temp = 4'b0011 & DMWr4;
        2'b00: temp = 4'b0001 & DMWr4;
        default: temp = 0;
    endcase

    always @(Addr_Last or temp or Flush)
    if(Flush)
        DM_Wen = 4'b0;
    else
        case (Addr_Last)
            2'b00: DM_Wen = temp;
            2'b01: DM_Wen = {temp[2:0],1'b0};
            2'b10: DM_Wen = {temp[1:0],2'b00};
            2'b11: DM_Wen = {temp[0],3'b000};
            default: DM_Wen = 0;
        endcase

    assign dcache_wstrb = DM_Wen;
    assign uncache_wstrb = DM_Wen;
//wdata
    always @(Addr_Last or Din)
    case (Addr_Last)
        2'b00: Dout = Din;
        2'b01: Dout = {Din[23:0],8'b0};
        2'b10: Dout = {Din[15:0],16'b0};
        2'b11: Dout = {Din[7:0],24'b0};
        default: Dout = 0;
    endcase
//awsize
    always @(LenthStore)
    case (LenthStore)
        2'b11: awsize = 3'b010;
        2'b01: awsize = 3'b001;
        default: awsize = 3'b000;
    endcase
//arsize
    always @(LenthLoad)
    case (LenthLoad)
        2'b11: arsize = 3'b010;
        2'b01: arsize = 3'b001;
        default: arsize = 3'b000;
    endcase

//DCache or UnCache
    assign dcache_valid = ~(ALUOut[31] & ALUOut[29]) & DM_en & !Flush;
    assign uncache_valid = ALUOut[31] & ALUOut[29] & DM_en & !Flush;
    
    assign dcache_index = ALUOut[11:4];
    assign dcache_offset = ALUOut[3:0];

    always @(ALUOut)
    begin
        case(ALUOut[31:28])
        4'b1000,4'b1001:dcache_tag = {1'b0,ALUOut[30:12]};
        4'b1100,4'b1101,4'b1110,4'b1111:dcache_tag = ALUOut[31:12];
        default:dcache_tag = ALUOut[31:12];
        endcase
    end
    
    //assign dcache_tag = {3'b0,ALUOut[28:12]};

    assign uncache_index = ALUOut[11:4];
    assign uncache_tag = {3'b0,ALUOut[28:12]};
    assign uncache_offset = ALUOut[3:0];

    assign dcache_op = DMWr;
    assign uncache_op = DMWr;


endmodule