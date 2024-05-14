module DCache(
clk, rst, cpu_valid, op, rd_req, rd_rdy, rd_addr, ret_data, ret_valid, ret_last, wr_rdy,
wr_req, wr_data, data_ok, index, tag, offset, cpu_wstrb,
from_cpu_wdata, rdata, addr_ok, wr_addr
);

input clk,rst;

//cpu->cache握手信号
input cpu_valid;
//

input op; //读还是写

//请求读axi时的握手信号
output rd_req;
input rd_rdy; //读请求能否被接收的握手信�??
//

output [31:0] rd_addr; //axi->cache读请求起始地�??
input [31:0] ret_data; //读返回数�??

//axi数据返回cache时的信号
input ret_valid; //返回数据有效
input ret_last;
//

//请求写axi时的握手信号
input wr_rdy; //此处要求wr_rdy要先于wr_req置起,wr_rdy应当�??16字节写缓存为空时置起
output wr_req;
//

output [31:0] wr_addr;

output [127:0] wr_data;

//cache->cpu握手信号
output data_ok;       //在读返回数据以及写完成时�??1

//读写地址
input [7:0] index;
input [16:0] tag;
input [1:0] offset;

input [3:0] cpu_wstrb;  //写字节使能信�??   
input [31:0] from_cpu_wdata; //写数�??

output [31:0] rdata;
output addr_ok;

wire op_1,op_2;
wire [7:0] index_1,index_2,wr_index;
wire [16:0] tag_1,tag_2;
wire [16:0] ram0_tag_1,ram1_tag_1,ram0_tag_2,ram1_tag_2,wr_tag;
wire [1:0] offset_1,offset_2;
wire [3:0] wstrb_1,wstrb_2;
wire [31:0] wdata_1,wdata_2;
wire [31:0] data_Bank0,data_Bank1,data_Bank2,data_Bank3;
wire ram_en,wr_en;
wire Write_en0_Bank,Write_en1_Bank,Write_en0_TagV,Write_en1_TagV;
wire ram0_v_1,ram1_v_1,ram0_v_2,ram1_v_2;
wire real_last;
wire replace_way;
wire cache_hit_1,cache_hit_2;
wire way0_hit_1,way1_hit_1,way0_hit_2,way1_hit_2;
wire [127:0] way0_data_1,way1_data_1,way0_data_2,way1_data_2;
wire [127:0] axi_return_data,Wr_final_data,input_Miss_data;
wire [127:0] Passway_data_1,Passway_data_2;
wire D0_value_1,D1_value_1,D0_value_2,D1_value_2;
wire Miss_Stall;
wire Stall,Stall_victim;
wire valid_1,valid_2;
wire Pass_data_ok_1,Pass_data_ok_2;
wire MissPass,MissPass_2;

assign addr_ok = ! ( Miss_Stall || ret_valid || Stall || Stall_victim );
assign rd_addr = {3'b0,tag_2,index_2,4'b0};

D_Pipeline_reg U_Pipeline_reg(
.clk(clk),.op(op),.index(index),.tag(tag),.offset(offset),.wstrb(cpu_wstrb),.wdata(from_cpu_wdata),.cpu_valid(cpu_valid),.Miss_Stall(Miss_Stall),
.ret_last(ret_last),.ret_valid(ret_valid),.Stall_victim(Stall_victim),
.op_1(op_1),.index_1(index_1),.tag_1(tag_1),.offset_1(offset_1),.wstrb_1(wstrb_1),.wdata_1(wdata_1),.valid_1(valid_1)
);

D_Signal_Select U_Signal_Select(
.way0_hit_2(way0_hit_2),.ram_en(ram_en),.wr_en(wr_en),.Wr_final_data(Wr_final_data),.ret_last(ret_last),.ret_valid(ret_valid),.replace_way(replace_way),.input_Miss_data(input_Miss_data),
.Write_en0_Bank(Write_en0_Bank),.Write_en1_Bank(Write_en1_Bank),.Write_en0_TagV(Write_en0_TagV),.Write_en1_TagV(Write_en1_TagV),
.data_Bank0(data_Bank0),.data_Bank1(data_Bank1),.data_Bank2(data_Bank2),.data_Bank3(data_Bank3)
);

D_Tag_Compare U_Tag_Compare(
.ram0_v_1(ram0_v_1),.ram1_v_1(ram1_v_1),.ram0_tag_1(ram0_tag_1),.ram1_tag_1(ram1_tag_1),.tag_1(tag_1),.valid_1(valid_1),.MissPass(MissPass),.replace_way(replace_way),
.cache_hit_1(cache_hit_1),.way0_hit_1(way0_hit_1),.way1_hit_1(way1_hit_1)
);

Middle_Register U_Middle_Register(
.clk(clk),.Miss_Stall(Miss_Stall),.Stall_victim(Stall_victim),.ret_valid(ret_valid),.ret_last(ret_last),.MissPass(MissPass),.MissPass_2(MissPass_2),
.cache_hit_1(cache_hit_1),.way0_hit_1(way0_hit_1),.way1_hit_1(way1_hit_1),.op_1(op_1),.index_1(index_1),.offset_1(offset_1),.wstrb_1(wstrb_1),
.wdata_1(wdata_1),.valid_1(valid_1),.Passway_data_1(Passway_data_1),.way0_data_1(way0_data_1),.way1_data_1(way1_data_1),.Pass_data_ok_1(Pass_data_ok_1),
.ram0_tag_1(ram0_tag_1),.ram1_tag_1(ram1_tag_1),.ram0_v_1(ram0_v_1),.ram1_v_1(ram1_v_1),.D0_value_1(D0_value_1),.D1_value_1(D1_value_1),.tag_1(tag_1),
.cache_hit_2(cache_hit_2),.way0_hit_2(way0_hit_2),.way1_hit_2(way1_hit_2),.op_2(op_2),.index_2(index_2),.offset_2(offset_2),.wstrb_2(wstrb_2),
.wdata_2(wdata_2),.valid_2(valid_2),.Passway_data_2(Passway_data_2),.way0_data_2(way0_data_2),.way1_data_2(way1_data_2),.Pass_data_ok_2(Pass_data_ok_2),
.ram0_tag_2(ram0_tag_2),.ram1_tag_2(ram1_tag_2),.ram0_v_2(ram0_v_2),.ram1_v_2(ram1_v_2),.D0_value_2(D0_value_2),.D1_value_2(D1_value_2),.tag_2(tag_2)
);

D_Data_Select U_Data_Select(
.op_2(op_2),.offset_2(offset_2),.cache_hit_2(cache_hit_2),.axi_return_data(axi_return_data),.real_last(real_last),.Passway_data_2(Passway_data_2),.Pass_data_ok_2(Pass_data_ok_2),
.rdata(rdata),.data_ok(data_ok)
);

D_Write_Buffer U_Write_Buffer(
.offset_2(offset_2),.wstrb_2(wstrb_2),.wdata_2(wdata_2),.Passway_data_2(Passway_data_2),
.Wr_final_data(Wr_final_data)
);

D_Miss_Buffer U_Miss_Buffer(
.clk(clk),.rst(rst),.op_2(op_2),.wdata_2(wdata_2),.offset_2(offset_2),.wstrb_2(wstrb_2),.ret_data(ret_data),.ret_last(ret_last),.ret_valid(ret_valid),
.input_Miss_data(input_Miss_data),.real_last(real_last),.axi_return_data(axi_return_data)
);

D_LRU U_LRU(
.clk(clk),.rst(rst),.index_1(index_1),.index_2(index_2),.way0_hit_2(way0_hit_2),.way1_hit_2(way1_hit_2),.ret_valid(ret_valid),.ret_last(ret_last),.Miss_Stall(Miss_Stall),.Stall_victim(Stall_victim),
.replace_way(replace_way)
);

D_D_List U_D_List(
.clk(clk),.rst(rst),.index(index),.wr_en(wr_en),.ram_en(ram_en),.replace_way(replace_way),.ret_last(ret_last),.ret_valid(ret_valid),
.D0_value_1(D0_value_1),.D1_value_1(D1_value_1),.op_2(op_2),.index_2(index_2),.way0_hit_2(way0_hit_2),.way1_hit_2(way1_hit_2)
);
/*
D_ByPass U_D_ByPass(
.clk(clk),.index_1(index_1),.index_2(index_2),.op_1(op_1),.op_2(op_2),.cache_hit_1(cache_hit_1),.cache_hit_2(cache_hit_2),.way0_hit_1(way0_hit_1),.tag_1(tag_1),.tag_2(tag_2),
.Wr_final_data(Wr_final_data),.way0_data_1(way0_data_1),.way1_data_1(way1_data_1),.real_last(real_last),.input_Miss_data(input_Miss_data),
.Passway_data_1(Passway_data_1),.Pass_data_ok_1(Pass_data_ok_1),.MissPass(MissPass)
);*/

D_ByPass U_D_ByPass(
.clk(clk),.index_1(index_1),.index_2(index_2),.op_1(op_1),.wr_en(wr_en),.cache_hit_1(cache_hit_1),.way0_hit_1(way0_hit_1),.tag_1(tag_1),.tag_2(tag_2),
.Wr_final_data(Wr_final_data),.way0_data_1(way0_data_1),.way1_data_1(way1_data_1),.real_last(real_last),.input_Miss_data(input_Miss_data),
.Passway_data_1(Passway_data_1),.Pass_data_ok_1(Pass_data_ok_1),.MissPass(MissPass)
);

D_Conflict_Block U_Conflict_Block(
.index(index),.index_2(index_2),.wr_index(wr_index),.op_2(op_2),.cpu_valid(cpu_valid),.valid_2(valid_2),.D0_value_2(D0_value_2),.D1_value_2(D1_value_2),.MissPass_2(MissPass_2),
.ram0_v_2(ram0_v_2),.ram1_v_2(ram1_v_2),.replace_way(replace_way),.wr_rdy(wr_rdy),.cache_hit_2(cache_hit_2),.tag_2(tag_2),.wr_tag(wr_tag),
.Stall_victim(Stall_victim),.Stall(Stall)
);

Victim_Buffer U_Victim_Buffer(
.clk(clk),.replace_way(replace_way),.D0_value_2(D0_value_2),.D1_value_2(D1_value_2),.ram0_v_2(ram0_v_2),.ram1_v_2(ram1_v_2),.way0_data_2(way0_data_2),.way1_data_2(way1_data_2),
.ram0_tag_2(ram0_tag_2),.ram1_tag_2(ram1_tag_2),.index_2(index_2),.wr_rdy(wr_rdy),.valid_2(valid_2),.cache_hit_2(cache_hit_2),
.wr_data(wr_data),.wr_req(wr_req),.wr_tag(wr_tag),.wr_index(wr_index),.wr_addr(wr_addr)
);

DCache_FSM_Master U_Dcache_FSM_Master(
.clk(clk),.rst(rst),.cpu_valid(cpu_valid),.cache_hit_2(cache_hit_2),.rd_rdy(rd_rdy),.ret_last(ret_last),.ret_valid(ret_valid),.Stall(Stall),.Stall_victim(Stall_victim),
.ram_en(ram_en),.Miss_Stall(Miss_Stall),.rd_req(rd_req),.valid_1(valid_1),.MissPass_2(MissPass_2)
);

Dcache_FSM_Slave U_Dcache_FSM_Slave(
.clk(clk),.rst(rst),.cache_hit_2(cache_hit_2),.op_2(op_2),.wr_en(wr_en),.valid_2(valid_2)
);

//两路页表
D_Way_TagV U_D_Way0TagV(
.clka(clk),.addra(index_2),.dina({tag_2,1'b1}),.ena(Write_en0_TagV),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb({ram0_tag_1,ram0_v_1}),.enb(ram_en)
);

D_Way_Bank U_D_Way0Bank0(
.clka(clk),.addra(index_2),.dina(data_Bank0),.ena(Write_en0_Bank),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data_1[31:0]),.enb(ram_en)
);

D_Way_Bank U_D_Way0Bank1(
.clka(clk),.addra(index_2),.dina(data_Bank1),.ena(Write_en0_Bank),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data_1[63:32]),.enb(ram_en)
);

D_Way_Bank U_D_Way0Bank2(
.clka(clk),.addra(index_2),.dina(data_Bank2),.ena(Write_en0_Bank),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data_1[95:64]),.enb(ram_en) 
);

D_Way_Bank U_D_Way0Bank3(
.clka(clk),.addra(index_2),.dina(data_Bank3),.ena(Write_en0_Bank),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way0_data_1[127:96]),.enb(ram_en)
);

D_Way_TagV U_D_Way1TagV(
.clka(clk),.addra(index_2),.dina({tag_2,1'b1}),.ena(Write_en1_TagV),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb({ram1_tag_1,ram1_v_1}),.enb(ram_en)
);

D_Way_Bank U_D_Way1Bank0(
.clka(clk),.addra(index_2),.dina(data_Bank0),.ena(Write_en1_Bank),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data_1[31:0]),.enb(ram_en) 
);

D_Way_Bank U_D_Way1Bank1(
.clka(clk),.addra(index_2),.dina(data_Bank1),.ena(Write_en1_Bank),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data_1[63:32]),.enb(ram_en) 
);

D_Way_Bank U_D_Way1Bank2(
.clka(clk),.addra(index_2),.dina(data_Bank2),.ena(Write_en1_Bank),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data_1[95:64]),.enb(ram_en)  
);

D_Way_Bank U_D_Way1Bank3(
.clka(clk),.addra(index_2),.dina(data_Bank3),.ena(Write_en1_Bank),.wea(1'b1),
.clkb(clk),.addrb(index),.doutb(way1_data_1[127:96]),.enb(ram_en) 
);

endmodule


module D_Pipeline_reg(
clk,op,index,tag,offset,wstrb,wdata,cpu_valid,Miss_Stall,ret_last,ret_valid,Stall_victim,
op_1,index_1,tag_1,offset_1,wstrb_1,wdata_1,valid_1
);
input clk;
input op;
input [7:0] index;
input [16:0] tag;
input [1:0] offset;
input [3:0] wstrb;
input [31:0] wdata;
input cpu_valid;
input Miss_Stall;
input ret_last,ret_valid;
input Stall_victim;
output reg op_1;
output reg [7:0] index_1;
output reg [16:0] tag_1;
output reg [1:0] offset_1;
output reg [3:0] wstrb_1;
output reg [31:0] wdata_1;
output reg valid_1;

always@(posedge clk)
begin
    if(!Stall_victim && !Miss_Stall && !(ret_last&ret_valid))begin
        op_1 <= op;
        index_1 <= index;
        tag_1 <= tag;
        offset_1 <= offset;
        wstrb_1 <= wstrb;
        wdata_1 <= wdata;
        valid_1 <= cpu_valid;
    end
end

endmodule


module D_Signal_Select(
way0_hit_2,ram_en,wr_en,Wr_final_data,replace_way,input_Miss_data,ret_last,ret_valid,
Write_en0_Bank,Write_en1_Bank,Write_en0_TagV,Write_en1_TagV,
data_Bank0,data_Bank1,data_Bank2,data_Bank3
);
input way0_hit_2;
input ram_en,wr_en;
input ret_last,ret_valid;
input replace_way;
input [127:0] input_Miss_data,Wr_final_data;
output Write_en0_Bank,Write_en1_Bank,Write_en0_TagV,Write_en1_TagV;
output [31:0] data_Bank0,data_Bank1,data_Bank2,data_Bank3;

assign data_Bank0 = wr_en ? Wr_final_data[ 31: 0] : input_Miss_data[ 31: 0] ;
assign data_Bank1 = wr_en ? Wr_final_data[ 63:32] : input_Miss_data[ 63:32] ;
assign data_Bank2 = wr_en ? Wr_final_data[ 95:64] : input_Miss_data[ 95:64] ;
assign data_Bank3 = wr_en ? Wr_final_data[127:96] : input_Miss_data[127:96] ;
assign Write_en0_Bank = (ret_valid && ret_last && !replace_way) || (wr_en &&  way0_hit_2) ;
assign Write_en1_Bank = (ret_valid && ret_last &&  replace_way) || (wr_en && !way0_hit_2) ;
assign Write_en0_TagV = ret_valid && ret_last && !replace_way ;
assign Write_en1_TagV = ret_valid && ret_last &&  replace_way ;

endmodule


module D_Tag_Compare(
ram0_v_1,ram1_v_1,ram0_tag_1,ram1_tag_1,tag_1,valid_1,MissPass,replace_way,
cache_hit_1,way0_hit_1,way1_hit_1
);
input ram0_v_1,ram1_v_1;
input valid_1;
input [16:0] ram0_tag_1,ram1_tag_1,tag_1;
input MissPass;
input replace_way;
output cache_hit_1;
output way0_hit_1,way1_hit_1;

assign way0_hit_1 = ((ram0_v_1 && (ram0_tag_1 == tag_1) && valid_1 && !MissPass) || (MissPass && !replace_way)) ;
assign way1_hit_1 = ((ram1_v_1 && (ram1_tag_1 == tag_1) && valid_1 && !MissPass) || (MissPass &&  replace_way)) ;
assign cache_hit_1 = way0_hit_1 || way1_hit_1;

endmodule


module Middle_Register(
clk,Miss_Stall,Stall_victim,ret_last,ret_valid,MissPass,MissPass_2,
cache_hit_1,way0_hit_1,way1_hit_1,op_1,index_1,offset_1,wstrb_1,wdata_1,valid_1,Passway_data_1,tag_1,
ram0_tag_1,ram1_tag_1,ram0_v_1,ram1_v_1,D0_value_1,D1_value_1,way0_data_1,way1_data_1,Pass_data_ok_1,
cache_hit_2,way0_hit_2,way1_hit_2,op_2,index_2,offset_2,wstrb_2,wdata_2,valid_2,Passway_data_2,tag_2,
ram0_tag_2,ram1_tag_2,ram0_v_2,ram1_v_2,D0_value_2,D1_value_2,way0_data_2,way1_data_2,Pass_data_ok_2
);
input clk;
input Miss_Stall,Stall_victim;
input MissPass;
input cache_hit_1;
input way0_hit_1,way1_hit_1;
input [127:0] Passway_data_1;
input [127:0] way0_data_1,way1_data_1;
input op_1;
input [7:0] index_1;
input [1:0] offset_1;
input [3:0] wstrb_1;
input [31:0] wdata_1;
input [16:0] tag_1;
input valid_1;
input [16:0] ram0_tag_1,ram1_tag_1;
input ram0_v_1,ram1_v_1;
input D0_value_1,D1_value_1;
input Pass_data_ok_1;
input ret_valid,ret_last;
output reg cache_hit_2;
output reg way0_hit_2,way1_hit_2;
output reg [127:0] Passway_data_2;
output reg [127:0] way0_data_2,way1_data_2;
output reg op_2;
output reg [7:0] index_2;
output reg [1:0] offset_2;
output reg [3:0] wstrb_2;
output reg [31:0] wdata_2;
output reg valid_2;
output reg [16:0] ram0_tag_2,ram1_tag_2;
output reg ram0_v_2,ram1_v_2;
output reg D0_value_2,D1_value_2;
output reg Pass_data_ok_2;
output reg [16:0] tag_2;
output reg MissPass_2;

always@(posedge clk)
begin
    if(!Stall_victim && valid_1 && !Miss_Stall && !(ret_last&ret_valid))begin
        cache_hit_2 <= cache_hit_1;
        way0_hit_2 <= way0_hit_1;
        way1_hit_2 <= way1_hit_1;
        op_2 <= op_1;
        index_2 <= index_1;
        offset_2 <= offset_1;
        wstrb_2 <= wstrb_1;
        wdata_2 <= wdata_1;
        Passway_data_2 <= Passway_data_1;
        way0_data_2 <= way0_data_1;
        way1_data_2 <= way1_data_1;
        ram0_tag_2 <= ram0_tag_1;
        ram1_tag_2 <= ram1_tag_1;
        ram0_v_2 <= ram0_v_1;
        ram1_v_2 <= ram1_v_1;
        D0_value_2 <= D0_value_1;
        D1_value_2 <= D1_value_1;
        Pass_data_ok_2 <= Pass_data_ok_1;
        tag_2 <= tag_1;
        MissPass_2 <= MissPass;
    end
end

always@(posedge clk)
begin
    if(Miss_Stall || (ret_last&ret_valid))
        valid_2 <= 0;
    else
        valid_2 <= valid_1;
end

endmodule


module D_Data_Select(
op_2,offset_2,cache_hit_2,axi_return_data,real_last,Passway_data_2,Pass_data_ok_2,
rdata,data_ok
);
input op_2;
input [1:0] offset_2;
input [127:0] Passway_data_2;
input [127:0] axi_return_data;
input real_last;
input cache_hit_2;
input Pass_data_ok_2;
output [31:0] rdata;
output data_ok;

wire [31:0] way_load_word;

assign way_load_word = Passway_data_2[ (offset_2*32+31) -: 32];
assign rdata = real_last ? axi_return_data[(offset_2*32+31) -: 32] : way_load_word;
assign data_ok = !op_2 && (Pass_data_ok_2 || real_last);

endmodule


module D_Write_Buffer(
offset_2,wstrb_2,wdata_2,Passway_data_2,
Wr_final_data
);
input [1:0] offset_2;
input [3:0] wstrb_2;
input [31:0] wdata_2;
input [127:0] Passway_data_2;
output reg [127:0] Wr_final_data;

reg [31:0] Wr_wdata;
reg [31:0] ram_replace_data;

//寻找�??要写入的那一路的bank
always@(offset_2,Passway_data_2)
begin
    case(offset_2)
        2'b00: ram_replace_data = Passway_data_2[31:0];
        2'b01: ram_replace_data = Passway_data_2[63:32];
        2'b10: ram_replace_data = Passway_data_2[95:64];
        default: ram_replace_data = Passway_data_2[127:96];
    endcase
end

always@(wstrb_2,ram_replace_data,wdata_2)
begin
    case(wstrb_2)
        4'b1111: Wr_wdata = wdata_2;
        4'b0001: Wr_wdata = {ram_replace_data[31:8],wdata_2[7:0]};
        4'b0010: Wr_wdata = {ram_replace_data[31:16],wdata_2[15:8],ram_replace_data[7:0]};
        4'b0100: Wr_wdata = {ram_replace_data[31:24],wdata_2[23:16],ram_replace_data[15:0]};
        4'b1000: Wr_wdata = {wdata_2[31:24],ram_replace_data[23:0]};
        4'b0011: Wr_wdata = {ram_replace_data[31:16],wdata_2[15:0]};
        4'b1100: Wr_wdata = {wdata_2[31:16],ram_replace_data[15:0]};
        default: Wr_wdata = 32'b0;
    endcase
end

always@(offset_2,Wr_wdata,Passway_data_2)
begin
    case(offset_2)
        2'b00: Wr_final_data = {Passway_data_2[127:32],Wr_wdata};
        2'b01: Wr_final_data = {Passway_data_2[127:64],Wr_wdata,Passway_data_2[31:0]};
        2'b10: Wr_final_data = {Passway_data_2[127:96],Wr_wdata,Passway_data_2[63:0]};
        default: Wr_final_data = {Wr_wdata,Passway_data_2[95:0]};
    endcase
end

endmodule


module D_Miss_Buffer(
clk,rst,op_2,wdata_2,offset_2,wstrb_2,ret_data,ret_last,ret_valid,
input_Miss_data,real_last,axi_return_data
);
input clk,rst;
input op_2;
input ret_last;
input ret_valid;
input [31:0] wdata_2;
input [31:0] ret_data;
input [1:0] offset_2;
input [3:0] wstrb_2;
output reg real_last;
output reg [127:0] input_Miss_data;
output reg [127:0] axi_return_data;

reg [31:0] Miss_replace_data;
reg [31:0] Miss_wdata;
reg [1:0] num;

always@(posedge clk)
begin
    if(ret_valid & ret_last)
        real_last <= 1;

    else
        real_last <= 0;
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        num <= 0;

    else if(ret_valid & ret_last)
        num <= 0;

    else if(ret_valid)
        num <= num + 1;
end

always@(posedge clk or posedge rst)
begin
    if(rst)
        axi_return_data <= 0;

    else if(ret_valid)    //传�?�完三个数据
        axi_return_data[(num*32+31) -: 32] <= ret_data;
end

always@(ret_last,ret_valid,offset_2,op_2,axi_return_data,ret_data)
begin
    if(ret_valid & ret_last & op_2)begin
        case(offset_2)
            2'b00: Miss_replace_data = axi_return_data[31:0];
            2'b01: Miss_replace_data = axi_return_data[63:32];
            2'b10: Miss_replace_data = axi_return_data[95:64];
            default: Miss_replace_data = ret_data;
        endcase
    end

    else
        Miss_replace_data = 32'b0;
end

always@(ret_last,ret_valid,wstrb_2,Miss_replace_data,op_2,wdata_2)
begin
    if(ret_valid & ret_last & op_2)begin
        case(wstrb_2)
            4'b1111: Miss_wdata = wdata_2;
            4'b0001: Miss_wdata = {Miss_replace_data[31:8],wdata_2[7:0]};
            4'b0010: Miss_wdata = {Miss_replace_data[31:16],wdata_2[15:8],Miss_replace_data[7:0]};
            4'b0100: Miss_wdata = {Miss_replace_data[31:24],wdata_2[23:16],Miss_replace_data[15:0]};
            4'b1000: Miss_wdata = {wdata_2[31:24],Miss_replace_data[23:0]};
            4'b0011: Miss_wdata = {Miss_replace_data[31:16],wdata_2[15:0]};
            4'b1100: Miss_wdata = {wdata_2[31:16],Miss_replace_data[15:0]};
            default: Miss_wdata = 32'b0;
        endcase
    end

    else
        Miss_wdata = 32'b0;
end

always@(Miss_wdata,op_2,axi_return_data,offset_2,ret_data)
begin
    if(op_2)
        case(offset_2)
            2'b00: input_Miss_data = {ret_data,axi_return_data[95:32],Miss_wdata};
            2'b01: input_Miss_data = {ret_data,axi_return_data[95:64],Miss_wdata,axi_return_data[31:0]};
            2'b10: input_Miss_data = {ret_data,Miss_wdata,axi_return_data[63:0]};
            default: input_Miss_data = {Miss_wdata,axi_return_data[95:0]};
        endcase

    else
        input_Miss_data = {ret_data,axi_return_data[95:0]};
end

endmodule


module D_LRU(
clk,rst,index_1,index_2,way0_hit_2,way1_hit_2,ret_last,ret_valid,Stall_victim,Miss_Stall,
replace_way
);
input clk,rst;
input ret_valid,ret_last;
input Stall_victim,Miss_Stall;
input way0_hit_2,way1_hit_2;
input [7:0] index_1,index_2;
output reg replace_way;

reg [255:0] flag0;   //记录�??近使用过的一�??

always@(posedge clk or posedge rst)
begin
    if(rst)
        flag0[255:0] <= {256{1'b1}};

    else if(ret_last & ret_valid)
        flag0[index_2] <= ~flag0[index_2];

    else if(way0_hit_2)
        flag0[index_2] <= 1;

    else if(way1_hit_2)
        flag0[index_2] <= 0;
end

always @(posedge clk)
begin
    if(!Stall_victim && !Miss_Stall && !(ret_last&ret_valid))
        replace_way <= flag0[index_1];
end

endmodule


module D_D_List(
clk,rst,
index_2,index,way0_hit_2,way1_hit_2,wr_en,ram_en,D0_value_1,D1_value_1,replace_way,ret_last,ret_valid,op_2
);
input clk,rst;
input [7:0] index_2,index;
input way0_hit_2,way1_hit_2;
input wr_en,ram_en;
input replace_way;
input ret_last,ret_valid;
input op_2;
output reg D0_value_1,D1_value_1;

reg [255:0] D0;
reg [255:0] D1;

always@(posedge clk or posedge rst)
begin
    if(rst) begin
        D0 <= 256'b0;
        D1 <= 256'b0;
    end

    else if(wr_en & way0_hit_2)
        D0[index_2] <= 1;

    else if(wr_en & way1_hit_2)
        D1[index_2] <= 1;

    else if(ret_valid & ret_last)begin
        case({replace_way,op_2})
            2'b00: D0[index_2] <= 0;
            2'b01: D0[index_2] <= 1;
            2'b10: D1[index_2] <= 0;
            default: D1[index_2] <= 1;
        endcase
    end
end

always@(posedge clk)
begin
    if(ram_en)
        D0_value_1 <= D0[index];
end

always@(posedge clk)
begin
    if(ram_en)
        D1_value_1 <= D1[index];
end

endmodule

module D_ByPass(
clk,index_1,index_2,wr_en,
cache_hit_1,way0_hit_1,op_1,Wr_final_data,way0_data_1,way1_data_1,real_last,input_Miss_data,tag_1,tag_2,
Passway_data_1,Pass_data_ok_1,MissPass
);
input clk;
input [7:0] index_1,index_2;
input wr_en;
input op_1;
input real_last;
input cache_hit_1;
input way0_hit_1;
input [16:0] tag_1,tag_2;
input [127:0] Wr_final_data;
input [127:0] input_Miss_data;
input [127:0] way0_data_1,way1_data_1;
output reg [127:0] Passway_data_1;
output Pass_data_ok_1;
output reg MissPass;

reg [127:0] input_Miss_data_1;
reg ByPass;

always@(posedge clk)
    input_Miss_data_1 <= input_Miss_data;

always@(index_1,index_2,wr_en,cache_hit_1,tag_1,tag_2)
begin
    if(index_1 == index_2 && wr_en && cache_hit_1 && tag_1 == tag_2)
        ByPass = 1;
    else
        ByPass = 0;
end

always@(index_1,index_2,real_last,tag_1,tag_2)
begin
    if(index_1 == index_2 && real_last && tag_1 == tag_2)
        MissPass = 1;
    else
        MissPass = 0;
end

always@(ByPass,MissPass,way0_hit_1,input_Miss_data_1,Wr_final_data,way0_data_1,way1_data_1)
begin
    if(ByPass)
        Passway_data_1 = Wr_final_data;

    else if(MissPass)
        Passway_data_1 = input_Miss_data_1;

    else if(way0_hit_1)
        Passway_data_1 = way0_data_1;

    else
        Passway_data_1 = way1_data_1;
end

assign Pass_data_ok_1 = cache_hit_1 || MissPass;

endmodule


module D_Conflict_Block(
index,index_2,wr_index,op_2,cpu_valid,valid_2,D0_value_2,D1_value_2,ram0_v_2,ram1_v_2,replace_way,wr_rdy,cache_hit_2,tag_2,wr_tag,MissPass_2,
Stall_victim,Stall
);
input cpu_valid;
input valid_2;
input op_2;
input [7:0] index,index_2,wr_index;
input D0_value_2,D1_value_2;
input ram0_v_2,ram1_v_2;
input replace_way;
input wr_rdy;
input cache_hit_2;
input [16:0] tag_2,wr_tag;
input MissPass_2;
output reg Stall;
output Stall_victim;

reg Stall_rd,Stall_wr;

//当第二拍需要写（sw）的块与cpu要访问的块冲突时有效
always@(index,index_2,op_2,valid_2,cache_hit_2)
begin
    if(index == index_2 & op_2 & valid_2 & cache_hit_2)
        Stall = 1;
    else
        Stall = 0;
end

//在当前指令写回内存未结束且下一条指令MISS后也需要写回时有效
always@(D0_value_2,D1_value_2,ram0_v_2,ram1_v_2,replace_way,wr_rdy,valid_2,cache_hit_2,MissPass_2)
begin
    if((!wr_rdy) && valid_2 && !cache_hit_2 && !MissPass_2)begin
        if( !replace_way & D0_value_2 & ram0_v_2 )
            Stall_wr = 1;

        else if( replace_way & D1_value_2 & ram1_v_2 )
            Stall_wr = 1;

        else
            Stall_wr = 0;
    end

    else
        Stall_wr = 0;
end

//在当前指令写回内存未结束且下一条指令MISS后需要访问内存中同样地址时有效
always@(cache_hit_2,tag_2,wr_tag,index_2,wr_index,wr_rdy,valid_2,MissPass_2)
begin
    if((!wr_rdy) && valid_2 && !cache_hit_2 && (tag_2 == wr_tag) && (index_2 == wr_index) && !MissPass_2)
        Stall_rd = 1;      

    else
        Stall_rd = 0;
end

assign Stall_victim = Stall_rd | Stall_wr;

endmodule


module Victim_Buffer(
clk,replace_way,wr_rdy,
D0_value_2,D1_value_2,ram0_v_2,ram1_v_2,way0_data_2,way1_data_2,ram0_tag_2,ram1_tag_2,index_2,valid_2,cache_hit_2,
wr_data,wr_req,wr_tag,wr_index,wr_addr
);
input clk;
input D0_value_2,D1_value_2;
input ram0_v_2,ram1_v_2;
input [127:0] way0_data_2,way1_data_2;
input [16:0] ram0_tag_2,ram1_tag_2;
input replace_way;
input [7:0] index_2;
input wr_rdy;
input valid_2;
input cache_hit_2;
output reg [127:0] wr_data;
output reg wr_req;
output reg [16:0] wr_tag;
output reg [7:0] wr_index;
output [31:0] wr_addr;

always@(posedge clk)
begin
    if(wr_rdy & valid_2 & !cache_hit_2)begin
        if( !replace_way & D0_value_2 & ram0_v_2 )
            wr_data <= way0_data_2;

        else if( replace_way & D1_value_2 & ram1_v_2 )
            wr_data <= way1_data_2;
    end
end

always@(posedge clk)
begin
    if(wr_rdy & valid_2 & !cache_hit_2)begin
        if( !replace_way & D0_value_2 & ram0_v_2 )
            wr_req <= 1;

        else if( replace_way & D1_value_2 & ram1_v_2 )
            wr_req <= 1;

        else
            wr_req <= 0;
    end

    else
        wr_req <= 0;
end

always@(posedge clk)
begin
    if(wr_rdy & valid_2 & !cache_hit_2)begin
        if( !replace_way & D0_value_2 & ram0_v_2 )
            wr_tag <= ram0_tag_2;
        
        else if( replace_way & D1_value_2 & ram1_v_2 )
            wr_tag <= ram1_tag_2;
    end
end

always@(posedge clk)
begin
    if(wr_rdy & valid_2 & !cache_hit_2)begin
        if( !replace_way & D0_value_2 & ram0_v_2 )
            wr_index <= index_2;
        
        else if( replace_way & D1_value_2 & ram1_v_2 )
            wr_index <= index_2;
    end
end

assign wr_addr = {3'b0,wr_tag,wr_index,4'b0};

endmodule
