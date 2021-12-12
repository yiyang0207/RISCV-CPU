`include "config.v"

module pc_reg (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire [`StallBus] stall, 

    //EX
    input  wire jump_enable,
    input  wire [`AddrBus] jump_dist,

    //branch
    // input  wire is_branch,
    // input  wire branch_taken_i,
    // input  wire [`AddrBus] branch_pc_i;
    // input  wire [`AddrBus] branch_dist,
    
    //IF
    output reg [`AddrBus] pc_o
);

// reg [`AddrBus] BTB[`PredBus];
// reg [`PredTagBus] tag[`PredBus];
// reg global_BHT;

always @(posedge clk) begin
    if(rst==`Enable) begin
        pc_o<=`ZeroWord;
    end else if(rdy==`Enable) begin
        if(jump_enable==`Enable) begin
            pc_o<=jump_dist;
        end else if(stall==`NoStall) begin
            pc_o<=pc_o+4;
        end
    end
end

endmodule //pc_reg