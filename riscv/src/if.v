`include "config.v"

module IF (
    input  wire clk,
    input  wire rst,
    input  wire rdy, 

    //pc_reg
    input  wire [`AddrBus] pc_i,
    input  wire jump_enable_i,
    output reg icache_hit,
    output wire pc_reg_inst_finished,

    //mem_ctrl
    input  wire mem_ctrl_finished,
    input  wire [`InstBus] inst_i,
    input  wire mem_ctrl_if_busy,
    input  wire mem_ctrl_mem_busy,
    output reg mem_ctrl_enable,
    output reg [`AddrBus] mem_ctrl_addr,

    //IF_ID
    output reg [`AddrBus] pc_o,
    output reg [`InstBus] inst_o,
    
    output reg if_stall
);

//Icache
reg [`InstBus] icache[`IcacheBus];
reg valid[`IcacheBus];
reg [`IcacheTagBus] tag[`IcacheBus];

assign pc_reg_inst_finished=mem_ctrl_finished;

integer i;
always @(posedge clk) begin
    if(rst==`Enable) begin
        for (i=0;i<`IcacheSize;i=i+1) begin
            valid[i]<=`Disable;
        end
        mem_ctrl_addr<=`ZeroWord;
    end else if(rdy==`Enable) begin
        if (mem_ctrl_finished==`Enable) begin
            icache[pc_i[`IcacheIndexBus]]<=inst_i;
            valid[pc_i[`IcacheIndexBus]]<=`Enable;
            tag[pc_i[`IcacheIndexBus]]<=pc_i[`IcacheTagBus];
            mem_ctrl_addr<=pc_i+4;
        end else begin
            mem_ctrl_addr<=pc_i;
        end
    end
end

always @(*) begin
    if(rst==`Enable) begin
        mem_ctrl_enable=`Disable;
        mem_ctrl_addr=`ZeroWord;
        pc_o=`ZeroWord;
        inst_o=`ZeroWord;
        if_stall=`Disable;
        icache_hit=`Disable;
    end else if(rdy==`Enable) begin
        if(jump_enable_i==`Enable) begin
            pc_o=`ZeroWord;
            inst_o=`ZeroWord;
            icache_hit=`Disable;
        end else if(mem_ctrl_finished==`Enable) begin
            pc_o=pc_i;
            inst_o=inst_i;
            icache_hit=`Disable;
            if_stall=`Disable;
            mem_ctrl_enable=`Disable;
        end else if (valid[pc_i[`IcacheIndexBus]]==`Enable&&tag[pc_i[`IcacheIndexBus]]==pc_i[`IcacheTagBus]) begin
            pc_o=pc_i;
            inst_o=icache[pc_i[`IcacheIndexBus]];
            icache_hit=`Enable;
            if_stall=`Disable;
            mem_ctrl_enable=`Disable;
        end else if(mem_ctrl_mem_busy==`Enable) begin
            pc_o=`ZeroWord;
            inst_o=`ZeroWord;
            if_stall=`Enable;
            mem_ctrl_enable=`Disable;
            icache_hit=`Disable;
        end else begin
            pc_o=`ZeroWord;
            inst_o=`ZeroWord;
            if_stall=`Enable;
            mem_ctrl_enable=`Enable;
            icache_hit=`Disable;
        end
    end else begin
        mem_ctrl_enable=`Disable;
        pc_o=`ZeroWord;
        inst_o=`ZeroWord;
        if_stall=`Disable;
        icache_hit=`Disable;
    end
end

endmodule //if