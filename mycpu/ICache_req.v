module ICache_req(clk,rst,Flush,Stall,icache_valid_in,NPC,icache_index,icache_tag,icache_offset,icache_valid_out,ins_valid);
    input clk,rst,Stall,Flush;
    input [31:0] NPC;
    input icache_valid_in;
    output [6:0] icache_index;
    output [19:0] icache_tag;
    output [4:0] icache_offset;
    output reg icache_valid_out;
    output reg ins_valid;


    always @(posedge clk) begin
        if(rst)
            icache_valid_out <= 1'b0;
        else if(!Stall)
            icache_valid_out <= icache_valid_in;
    end

    always @(posedge clk) begin
        if(rst | (Stall & Flush))
            ins_valid <= 1'b0;
        else if(!Stall)
            ins_valid <= 1;
    end

//    assign NPC_real = (addr_ok | !icache_valid_in) ? NPC:NPC_last;
    assign {icache_tag,icache_index,icache_offset} = NPC;

endmodule