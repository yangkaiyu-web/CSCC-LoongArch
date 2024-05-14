module DCache_FSM_Master(//主状态机
clk,rst,cpu_valid,cache_hit_2,rd_rdy,ret_last,ret_valid,Stall,Stall_victim,MissPass_2,valid_1,
ram_en,Miss_Stall,rd_req
);
input clk;
input rst;
input cpu_valid,valid_1;
input cache_hit_2;
input rd_rdy;
input ret_last,ret_valid;
input Stall,Stall_victim;
input MissPass_2;
output reg rd_req;
output reg ram_en;
output reg Miss_Stall;

reg [2:0] state,next_state;

parameter [2:0] IDLE = 3'b000;
parameter [2:0] LOOKUP = 3'b001;
parameter [2:0] YVALID = 3'b010;
parameter [2:0] NVALID = 3'b011;
parameter [2:0] REPLACE = 3'b100;
parameter [2:0] REFILL = 3'b101;

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
    else if(state == LOOKUP && !Stall_victim)
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

always@(rst,state,cache_hit_2,cpu_valid,rd_rdy,ret_last,ret_valid,Stall,Stall_victim,MissPass_2,valid_1)
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
            if(cpu_valid)begin
                ram_en = 1;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = YVALID;
            end

            else begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = NVALID; 
            end
        end

        YVALID:begin
            if(MissPass_2)begin
                rd_req = 0;
                Miss_Stall = 0;

                if(cpu_valid)begin
                    ram_en = 1;
                    next_state = YVALID;
                end

                else begin
                    ram_en = 0;
                    next_state = NVALID;    
                end          
            end

            else if(Stall)begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = NVALID;
            end

            else if(Stall_victim)begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = YVALID;
            end

            else if(!cache_hit_2)begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 1;
                next_state = REPLACE;
            end

            else if(cpu_valid)begin
                ram_en = 1;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = YVALID;                
            end

            else begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = NVALID;                
            end
        end

        NVALID:begin
            if(MissPass_2)begin
                rd_req = 0;
                Miss_Stall = 0;

                if(cpu_valid)begin
                    ram_en = 1;
                    next_state = LOOKUP;
                end

                else begin
                    ram_en = 0;
                    next_state = IDLE;
                end          
            end

            else if(Stall)begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = IDLE;
            end

            else if(Stall_victim)begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;
                next_state = NVALID;
            end

            else if(!cache_hit_2)begin
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
            if( ret_last & ret_valid)begin
                ram_en = 0;
                rd_req = 0;
                Miss_Stall = 0;

                if(valid_1)
                    next_state = LOOKUP;

                else
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


module Dcache_FSM_Slave(//从状态机
clk,rst,cache_hit_2,op_2,wr_en,valid_2
);
input clk;
input rst;
input cache_hit_2;
input valid_2;
input op_2;
output reg wr_en;

parameter IDLE = 1'b0;
parameter WRITE = 1'b1;

reg state,next_state;

always@(posedge clk or posedge rst)
begin
    if(rst)
        state <= IDLE;
    else
        state <= next_state;
end

always@(state,cache_hit_2,op_2,valid_2)
begin
    case(state)
    IDLE:begin
        if(cache_hit_2 && op_2 && valid_2 )begin
            wr_en = 1;
            next_state = WRITE;
        end

        else begin
            wr_en = 0;
            next_state = IDLE;
        end
    end

    WRITE:begin
        if( cache_hit_2 && op_2 && valid_2 )begin
            wr_en = 1;
            next_state = WRITE;
        end

        else begin
            wr_en = 0;
            next_state = IDLE;
        end
    end

    endcase
end

endmodule