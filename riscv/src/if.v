`include "src/config.v"

module IF (
    input  wire clk,
    input  wire rst,
    input  wire rdy, 

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

always @(*) begin
    if(rst==`Enable) begin
        mem_ctrl_enable=`ZeroBit;
        mem_ctrl_addr=`ZeroWord;
        pc_o=`ZeroWord;
        inst_o=`ZeroWord;
        if_stall=`Disable;
    end else if(rdy==`Enable) begin
        if(mem_ctrl_finished==`Enable) begin
            pc_o=pc_i;
            inst_o=inst_i;
            if_stall=`Disable;
            mem_ctrl_enable=`Disable;
            mem_ctrl_addr=`ZeroWord;
        end else if(mem_ctrl_mem_busy==`Enable) begin
            pc_o=`ZeroWord;
            inst_o=`ZeroWord;
            if_stall=`Disable;
            mem_ctrl_enable=`Disable;
            mem_ctrl_addr=`ZeroWord;
        end else begin
            pc_o=pc_i;
            inst_o=`ZeroWord;
            if_stall=`Enable;
            mem_ctrl_enable=`Enable;
            mem_ctrl_addr=`ZeroWord;
        end
    end 
end

endmodule //if