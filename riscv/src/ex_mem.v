`include "config.v"

module EX_MEM (
    input  wire clk,
    input  wire rst,
    input  wire rdy,
    input  wire [`AddrBus] ex_pc,
    input  wire [`RegBus] ex_vd,
    input  wire [`RegAddrBus] ex_rd,
    input  wire ex_rd_enable,

    output reg [`AddrBus] mem_pc,
    output reg [`RegBus] mem_vd,
    output reg [`RegAddrBus] mem_rd,
    output reg mem_rd_enable
);

endmodule //ex_mem