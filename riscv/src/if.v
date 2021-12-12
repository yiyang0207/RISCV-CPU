`include "config.v"

module IF (
    input  wire clk,
    input  wire rst,
    input  wire rdy, 

    //pc_reg
    input  wire [`AddrBus] pc_i,

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

//direct mapped icache
reg [`InstBus] icache[`IcacheBus];
reg valid[`IcacheBus];
reg [`IcacheTagBus] tag[`IcacheBus];

integer i;
always @(posedge clk) begin
    if(rst==`Enable) begin
        for (i=0;i<`IcacheSize;i=i+1) begin
            valid[i]<=`Disable;
        end
        mem_ctrl_addr<=`ZeroWord;
    end else if (rdy==`Enable) begin
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
    end else if(rdy==`Enable) begin
        if(mem_ctrl_finished==`Enable) begin
            pc_o=pc_i;
            inst_o=inst_i;
            // $display("%h",inst_o);
            if_stall=`Disable;
            mem_ctrl_enable=`Disable;
            // mem_ctrl_addr=`ZeroWord;
        end else if (valid[pc_i[`IcacheIndexBus]]==`Enable&&tag[pc_i[`IcacheIndexBus]]==pc_i[`IcacheTagBus]) begin
            pc_o=pc_i;
            inst_o=icache[pc_i[`IcacheIndexBus]];
            // $display("%h",inst_o);
            if_stall=`Disable;
            mem_ctrl_enable=`Disable;
            // mem_ctrl_addr=`ZeroWord;
        end else if(mem_ctrl_mem_busy==`Enable) begin
            pc_o=`ZeroWord;
            inst_o=`ZeroWord;
            if_stall=`Enable;
            mem_ctrl_enable=`Disable;
        end else if(mem_ctrl_mem_busy==`Disable) begin
            pc_o=`ZeroWord;
            inst_o=`ZeroWord;
            if_stall=`Enable;
            mem_ctrl_enable=`Enable;
        end else begin
            pc_o=`ZeroWord;
            inst_o=`ZeroWord;
            if_stall=`Enable;
            mem_ctrl_enable=`Enable;
        end
    end else begin
        mem_ctrl_enable=`Disable;
        // mem_ctrl_addr=`ZeroWord;
        pc_o=`ZeroWord;
        inst_o=`ZeroWord;
        if_stall=`Disable;
    end
end

endmodule //if