module Forward_for_ALU(
    RA_now,RB_now,
    RW_L1,WBSel_L1,RFWr_L1,
    RW_L2,WBSel_L2,RFWr_L2,
    RW_L3,WBSel_L3,RFWr_L3,
    RW_L4,RFWr_L4,
    ALUSelA,ALUSelB);
    input [4:0] RA_now,RB_now;
//    input IType;//whether ALU need RT. if IType, don't need

    input [4:0] RW_L1;//exe
    input [1:0] WBSel_L1;
    input RFWr_L1;

    input [4:0] RW_L2;//exp
    input [1:0] WBSel_L2;
    input RFWr_L2;

    input [4:0] RW_L3;//mem1
    input [1:0] WBSel_L3;
    input RFWr_L3;

    input [4:0] RW_L4;//mem2
    input RFWr_L4;

    
    output reg [2:0] ALUSelA,ALUSelB;
//A
    always @( RA_now
        or RW_L1 or WBSel_L1 or RFWr_L1 
        or RW_L2 or WBSel_L2 or RFWr_L2 
        or RW_L3 or WBSel_L3 or RFWr_L3 
        or RW_L4 or RFWr_L4 
    )
    begin
        if(RFWr_L1 && RW_L1==RA_now && WBSel_L1==2'b00)//last ins need ALUOut to write back
            ALUSelA = 3'b000;//ALUOut
        else if(RFWr_L2 && RW_L2==RA_now && WBSel_L2==2'b00)//last ins need ALUOut to write back
            ALUSelA = 3'b001;//ALUOut
        else if(RFWr_L3 && RW_L3==RA_now && WBSel_L3==2'b00)//last ins need ALUOut to write back
            ALUSelA = 3'b010;//ALUOut
        else if(RFWr_L4 && RW_L4==RA_now)
            ALUSelA = 3'b011;//WriteData_WB
        else
            ALUSelA = 3'b100;//from RF
    end
//B
    always @( RB_now
        or RW_L1 or WBSel_L1 or RFWr_L1 
        or RW_L2 or WBSel_L2 or RFWr_L2 
        or RW_L3 or WBSel_L3 or RFWr_L3 
        or RW_L4 or RFWr_L4 
    )
    begin
        if(RFWr_L1 && RW_L1==RB_now && WBSel_L1==2'b00)//last ins need ALUOut to write back
            ALUSelB = 3'b000;//ALUOut
        else if(RFWr_L2 && RW_L2==RB_now && WBSel_L2==2'b00)//last ins need ALUOut to write back
            ALUSelB = 3'b001;//ALUOut
        else if(RFWr_L3 && RW_L3==RB_now && WBSel_L3==2'b00)//last ins need ALUOut to write back
            ALUSelB = 3'b010;//ALUOut
        else if(RFWr_L4 && RW_L4==RB_now)
            ALUSelB = 3'b011;//WriteData_WB
        else
            ALUSelB = 3'b100;//from RF
    end

endmodule

module STALL(
    RA_now,RB_now,
    RW_L1,WBSel_L1,RFWr_L1,
    RW_L2,WBSel_L2,RFWr_L2,
    RW_L3,WBSel_L3,RFWr_L3,
    icache_valid,icache_valid_IF,icache_data_ok, //read_data
    dcache_valid,dcache_valid_MEM2,dcache_op_MEM2,dcache_addr_ok,dcache_data_ok, //read_data
    uncache_valid,uncache_valid_MEM1,uncache_op_MEM1,uncache_addr_ok,uncache_data_ok, //read_data
    MDU_busy,MFT,MUL,
    Stall_IF,Stall_ID,Stall_EXE,Stall_EXP,Stall_MEM1,Stall_MEM2
);
    input [4:0] RA_now,RB_now;

    input [4:0] RW_L1;
    input [1:0] WBSel_L1;
    input RFWr_L1;

    input [4:0] RW_L2;
    input [1:0] WBSel_L2;
    input RFWr_L2;

    input [4:0] RW_L3;
    input [1:0] WBSel_L3;
    input RFWr_L3;

    input MDU_busy;
    input MFT;
    input MUL;
    
    input icache_valid,icache_valid_IF,icache_data_ok;
    input dcache_valid,dcache_valid_MEM2,dcache_op_MEM2,dcache_addr_ok,dcache_data_ok;
    input uncache_valid,uncache_valid_MEM1,uncache_op_MEM1,uncache_addr_ok,uncache_data_ok;

    output Stall_IF,Stall_ID,Stall_EXE,Stall_EXP,Stall_MEM1,Stall_MEM2;

    reg Stall_Load_Use;
    reg Stall_MDU;
    reg Stall_MUL;
    
    wire Stall_Hazard;
    wire Stall_Daddr;
    wire Stall_Ddata;
    wire Stall_Udata;
    //output Stall_Hazard;
    //output Stall_Daddr;
    //output Stall_Ddata;
    //output Stall_Udata;
    //output Stall_Idata;
 
    assign Stall_Daddr = dcache_valid & !dcache_addr_ok;
    assign Stall_Ddata = dcache_valid_MEM2 & !dcache_op_MEM2 & !dcache_data_ok;
    assign Stall_Uaddr = uncache_valid & !uncache_addr_ok;
    assign Stall_Udata = uncache_valid_MEM1 & !uncache_op_MEM1 & !uncache_data_ok;
    assign Stall_Idata = icache_valid_IF & !icache_data_ok;
    assign Stall_Hazard = Stall_Load_Use | Stall_MDU;


    assign Stall_IF =   Stall_Hazard | Stall_Ddata | Stall_Daddr | Stall_Udata | Stall_Uaddr | Stall_Idata | Stall_MUL;
    assign Stall_ID =   Stall_Hazard | Stall_Ddata | Stall_Daddr | Stall_Udata | Stall_Uaddr | Stall_Idata | Stall_MUL;
    assign Stall_EXE =  Stall_Ddata | Stall_Daddr | Stall_Udata | Stall_Uaddr | Stall_MUL;
    assign Stall_EXP =  Stall_Ddata | Stall_Daddr | Stall_Udata | Stall_Uaddr ;
    assign Stall_MEM1 = Stall_Ddata | Stall_Daddr | Stall_Udata | Stall_Uaddr ;
    assign Stall_MEM2 = Stall_Ddata;

    always @(RFWr_L1 or RW_L1 or WBSel_L1 
        or RFWr_L2 or RW_L2 or WBSel_L2 
        or RFWr_L3 or RW_L3 or WBSel_L3 
        or RB_now or RA_now
    )
    begin
        if(RFWr_L1 && (RW_L1==RB_now || RW_L1==RA_now) && WBSel_L1 != 2'b00)
            Stall_Load_Use = 1;//last
        else  if(RFWr_L2 && (RW_L2==RB_now || RW_L2==RA_now) && WBSel_L2 != 2'b00)
            Stall_Load_Use = 1;//last but one
        else  if(RFWr_L3 && (RW_L3==RB_now || RW_L3==RA_now) && WBSel_L3 != 2'b00)
            Stall_Load_Use = 1;//last but 2
        else
            Stall_Load_Use = 0;
    end

    always @(MDU_busy or MFT)
    begin
        if(MFT & MDU_busy)
            Stall_MDU = 1;
        else
            Stall_MDU = 0;
    end

    always @(MDU_busy or MUL)
    begin
        if(MUL & MDU_busy)
            Stall_MUL = 1;
        else
            Stall_MUL = 0;
    end


endmodule
