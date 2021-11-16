`include "config.v"

module MEM_WB (
    input  wire clk,
    input  wire rst,
    input  wire rdy,
    input  wire [`AddrBus] mem_pc,
    input  wire [`RegBus] mem_vd,
    input  wire [`RegAddrBus] mem_rd,
    input  wire mem_rd_enable,
    
    output reg [`AddrBus] wb_pc,
    output reg [`RegBus] wb_vd,
    output reg [`RegAddrBus] wb_rd,
    output reg wb_rd_enable
);
always @(posedge clk) begin
    if(rst==`Enable)begin
        wb_vd<=`ZeroWord;
        wb_rd<=`ZeroWord;
        wb_rd_enable<=`Disable;
    end else if(rdy==`Enable)begin
        //TODO
    end
end
endmodule //mem_wb