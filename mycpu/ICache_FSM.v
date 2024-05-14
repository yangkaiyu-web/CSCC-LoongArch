module Cache_FSM_Master(//主状态机
clk,rst,cpu_valid,cache_hit,rd_rdy,ret_last,ret_valid,
ram_en,Miss_Stall,rd_req
);
input clk;
input rst;
input cpu_valid;
input cache_hit;
input rd_rdy;
input ret_last,ret_valid;
output reg rd_req;
output reg ram_en;
output reg Miss_Stall;

reg [1:0] state,next_state;

parameter [1:0] IDLE = 2'b00;
parameter [1:0] LOOKUP = 2'b01;
parameter [1:0] REPLACE = 2'b10;
parameter [1:0] REFILL = 2'b11;

/*
reg [31:0] count_all;
reg [31:0] count_miss;

always@(posedge rst or posedge clk)
begin
    if(rst)
        count_miss <= 0; 
    else if(ret_valid && ret_last)
        count_miss <= count_miss + 1;
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        count_all <= 0;
    else if(state == LOOKUP)
        count_all <= count_all + 1;
end
*/

always@(posedge clk,posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        state <= next_state;
end

always@(rst,state,cache_hit,cpu_valid,rd_rdy,ret_last,ret_valid)
begin
    if(rst)begin
        ram_en = 0;
        rd_req = 0;
        Miss_Stall = 0;
        next_state = IDLE;
    end

    else begin
        case(state)
        IDLE:begin       
            if(cpu_valid)begin
                ram_en = 1;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = LOOKUP;
            end

            else begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = IDLE;
            end
        end 

        LOOKUP:begin
            if(!cache_hit)begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 1;
                next_state = REPLACE;
            end
            
            else if(cpu_valid)begin
                ram_en = 1;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = LOOKUP;
            end

            else begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = IDLE; 
            end
        end

        REPLACE:begin
            if(!rd_rdy)begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 1;
                next_state = REPLACE;
            end
            
            else begin
                ram_en = 0;
                rd_req = 1;
                Miss_Stall = 1;
                next_state = REFILL;
            end
        end

        REFILL:begin
            if( ret_last & ret_valid )begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = IDLE;
            end

            else begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 1;
                next_state = REFILL;
            end
        end

        default:begin
            ram_en = 0;
            rd_req = 0;
            Miss_Stall = 0;
            next_state = IDLE;
        end

        endcase
    end
end

endmodule