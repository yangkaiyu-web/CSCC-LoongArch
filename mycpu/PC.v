module PC(rst,clk, NPC, PC, PCAddressError, put_req);
    
    input [31:0] NPC;
    input clk,rst;
    output reg [31:0] PC;
    output PCAddressError;
    output put_req;

    assign PCAddressError = (PC[0]|PC[1]);

    always @(posedge clk or posedge rst)
        if(rst)
            PC <= 32'hbfc0_0000-32'h4;
        else
            PC <= NPC;
    /*
    always @(posedge clk) begin
        put_req <= !addr_ok ? put_req:
                    (PC == NPC) ? 1'b0: 1'b1;
    end
    */
    assign put_req = 1;
endmodule
