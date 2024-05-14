module Uncache(
clk,rst,
cpu_valid,op,addr,cpu_wstrb,wdata,addr_ok,data_ok,rdata,arsize,awsize,
rd_rdy,ret_valid,ret_data,rd_req,rd_addr,wr_req,wr_addr,axi_wstrb,wr_data,wr_rdy,axi_arsize,axi_awsize
);

input rst;
input clk;
input cpu_valid;
input [31:0] addr;
input op;               //1:write 0:read
input [3:0] cpu_wstrb;  //写字节使能信号
input [31:0] wdata; //写数据
input [2:0] arsize;
input [2:0] awsize;
output addr_ok;
output data_ok;
output reg[31:0] rdata;
//AXI总线
input rd_rdy;
input wr_rdy;
input ret_valid;
input [31:0] ret_data;
output rd_req;
output [31:0] rd_addr;//读请求起始地址
output wr_req;
output [31:0] wr_addr;
output [3:0] axi_wstrb;
output [31:0] wr_data;
output [2:0] axi_arsize,axi_awsize;

wire Stall;
wire [3:0] wstrb_1;
wire [31:0] wdata_1;
wire [31:0] addr_1;
wire [2:0] awsize_1,arsize_1;

always @(posedge clk) 
begin
    if(ret_valid)
        rdata <= ret_data;
end

assign wr_data = Stall ? wdata_1 : wdata;
assign axi_wstrb = Stall ? wstrb_1 : cpu_wstrb;

assign wr_addr = Stall ? addr_1 : addr;
assign rd_addr = Stall? addr_1 : addr;

assign axi_arsize = Stall ? arsize_1 : arsize;
assign axi_awsize = Stall ? awsize_1 : awsize;

Uncache_FSM U_Uncache_FSM(
.clk(clk), .rst(rst), .cpu_valid(cpu_valid), .op(op), .rd_rdy(rd_rdy), .wr_rdy(wr_rdy), 
.addr_ok(addr_ok), .rd_req(rd_req), 
.wr_req(wr_req), .data_ok(data_ok), .Stall(Stall)
);

Req_Buffer U_Req_Buffer(
.clk(clk), .wdata(wdata), .cpu_wstrb(cpu_wstrb), .addr(addr), .arsize(arsize), .awsize(awsize), .Stall(Stall),
.wdata_1(wdata_1), .wstrb_1(wstrb_1), .addr_1(addr_1), .arsize_1(arsize_1), .awsize_1(awsize_1)
);
endmodule


module Uncache_FSM(
    clk, rst, cpu_valid, op, rd_rdy, wr_rdy,
    addr_ok, rd_req, wr_req, data_ok, Stall
);

input clk,rst;
input cpu_valid;
input op;
input rd_rdy,wr_rdy;

output reg addr_ok; //现在正在cpu中发起的请求对应的地址等数据在下一周期可以进入req_buffer里保存起来时置1
output reg data_ok; //data_ok:data已经被写入axi（data被写入axi的下一个周期置1）
output reg rd_req,wr_req;
output reg Stall; //用于保留req_buffer中正在请求的地址等数据

parameter [1:0] IDLE = 2'b00;
parameter [1:0] READ = 2'b01;
parameter [1:0] WRITE = 2'b10;

reg [1:0] state,next_state;

always@(posedge clk)
begin
    if(rst)
        state <= IDLE;
    else
        state <= next_state;
end

always @(state or cpu_valid or op or rd_rdy or wr_rdy or rst) 
begin
    if(rst)
    begin
        data_ok = 1;
        rd_req = 0;
        wr_req = 0;                    
        addr_ok = 0;
        Stall = 0;
        next_state = IDLE;
    end

    case (state)
        IDLE: 
        begin
            if(cpu_valid && ~op)
            begin
                if(rd_rdy)
                begin
                    data_ok = 1;
                    rd_req = 1;
                    wr_req = 0;                    
                    addr_ok = 1;
                    Stall = 0;
                    next_state = READ;
                end
                else
                begin
                    data_ok = 1;
                    rd_req = 0;
                    wr_req = 0;                    
                    addr_ok = 0;
                    Stall = 0;
                    next_state = IDLE;
                end
            end

            else if(cpu_valid && op)
            begin
                if(wr_rdy)
                begin
                    data_ok = 1;
                    rd_req = 0;
                    wr_req = 1;                    
                    addr_ok = 1;
                    Stall = 0;
                    next_state = WRITE;
                end
                else
                begin
                    data_ok = 1;
                    rd_req = 0;
                    wr_req = 0;                    
                    addr_ok = 0;
                    Stall = 0;
                    next_state = IDLE;
                end
            end

            else
            begin
                data_ok = 1;
                rd_req = 0;
                wr_req = 0;                    
                addr_ok = 1;
                Stall = 1;
                next_state = IDLE;                
            end
        end 

        READ:
        begin
            if(!rd_rdy)
            begin
                data_ok = 0;
                addr_ok = 0;
                wr_req = 0;
                rd_req = 1;
                Stall = 1;
                next_state = READ;
            end

            else
            begin
                data_ok = 1;
                if(cpu_valid && ~op)
                begin
                    addr_ok = 1;
                    rd_req = 1;
                    wr_req = 0;    
                    Stall = 0;                
                    next_state = READ;              
                end

                else if(cpu_valid && op)
                begin
                    addr_ok = 1;
                    rd_req = 0;
                    wr_req = 1;
                    Stall = 0;
                    next_state = WRITE;
                end

                else
                begin
                    addr_ok = 1;
                    rd_req = 0;
                    wr_req = 0;
                    Stall = 0;
                    next_state = IDLE;
                end
            end
        end

        WRITE:
        begin
            if(!wr_rdy)
            begin
                data_ok = 0;
                addr_ok = 0;
                wr_req = 1;
                rd_req = 0;
                Stall = 1;
                next_state = WRITE;
            end

            else
            begin
                data_ok = 1;
                if(cpu_valid && ~op)
                begin
                    addr_ok = 1;
                    rd_req = 1;
                    wr_req = 0;    
                    Stall = 0;                
                    next_state = READ;              
                end

                else if(cpu_valid && op)
                begin
                    addr_ok = 1;
                    rd_req = 0;
                    wr_req = 1;
                    Stall = 0;
                    next_state = WRITE;
                end

                else
                begin
                    addr_ok = 1;
                    rd_req = 0;
                    wr_req = 0;
                    Stall = 0;
                    next_state = IDLE;
                end
            end
        end

        default:
        begin
            data_ok = 0;
            rd_req = 0;
            wr_req = 0;                    
            addr_ok = 0;
            Stall = 0;
            next_state = IDLE;
        end

    endcase    
end

endmodule

module Req_Buffer (
clk, wdata, addr, cpu_wstrb, arsize, awsize, Stall,
wdata_1, addr_1, wstrb_1, arsize_1, awsize_1
);

input clk;
input [31:0] wdata;
input [31:0] addr;
input [3:0] cpu_wstrb;
input [2:0] arsize,awsize;
input Stall;
output reg [31:0] wdata_1;
output reg [3:0] wstrb_1;
output reg [31:0] addr_1;
output reg [2:0] arsize_1,awsize_1;

always@(posedge clk)
begin
    if(!Stall)
    begin
        wdata_1 <= wdata;
        addr_1 <= addr;
        wstrb_1 <= cpu_wstrb;
        arsize_1 <= arsize;
        awsize_1 <= awsize;
    end
end

endmodule

