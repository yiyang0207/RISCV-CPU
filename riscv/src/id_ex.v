`include "config.v"

module ID_EX (
    input  wire clk,
    input  wire rst,
    input  wire rdy,
    input  wire [`AddrBus] id_pc,
    input  wire [`RegBus] id_rs1,
    input  wire [`RegBus] id_rs2,
    input  wire [`RegBus] id_imm,
    input  wire [`RegAddrBus] id_rd,
    input  wire id_rd_enable,

    output reg [`AddrBus] ex_pc,
    output reg [`RegBus] ex_rs1,
    output reg [`RegBus] ex_rs2,
    output reg [`RegBus] ex_imm,
    output reg [`RegBus] ex_rd,
    output reg ex_rd_enable
);

endmodule //id_ex