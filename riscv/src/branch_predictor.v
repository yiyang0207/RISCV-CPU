`include "config.v"

module branch_predictor (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire [`AddrBus] if_pc,
    input  wire [`AddrBus] ex_pc,
    input  wire [`AddrBus] bp_dist_i,

    output reg bp_taken_o,
    output reg [`AddrBus] bp_dist_o
);

endmodule //branch_predictor