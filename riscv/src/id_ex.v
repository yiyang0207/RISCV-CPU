`include "src/config.v"

module ID_EX (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //ID
    input  wire [`AddrBus] id_pc,
    input  wire [`OptBus] id_inst,
    input  wire [`RegBus] id_vs1,
    input  wire [`RegBus] id_vs2,
    input  wire [`RegAddrBus] id_rd,
    input  wire [`RegBus] id_imm,
    input  wire id_w_enable,
    // input  wire id_branch,

    input  wire jump_enable,
    input  wire [`StallBus] stall_ctrler,

    //EX
    output reg [`AddrBus] ex_pc,
    output reg [`OptBus] ex_inst,
    output reg [`RegBus] ex_vs1,
    output reg [`RegBus] ex_vs2,
    output reg [`RegAddrBus] ex_rd,
    output reg [`RegBus] ex_imm,
    output reg ex_w_enable
    // output reg ex_branch
);

always @(posedge clk) begin
    if(rst==`Enable) begin
        ex_pc<=`ZeroWord;
        ex_inst<=`ZeroOpt;
        ex_vs1<=`ZeroWord;
        ex_vs2<=`ZeroWord;
        ex_rd<=`ZeroRegAddr;
        ex_imm<=`ZeroWord;
        ex_w_enable<=`Disable;
        // ex_branch<=`Disable;
    end else if(rdy==`Enable) begin
        if(stall_ctrler[1]==`Disable&&jump_enable==`Disable) begin
            ex_pc<=id_pc;
            ex_inst<=id_inst;
            ex_vs1<=id_vs1;
            ex_vs2<=id_vs2;
            ex_rd<=id_rd;
            ex_imm<=id_imm;
            ex_w_enable<=id_w_enable;
            // ex_branch<=id_branch;
        end else if(jump_enable==`Enable||stall_ctrler[2]==`Disable) begin
            ex_pc<=`ZeroWord;
            ex_inst<=`ZeroOpt;
            ex_vs1<=`ZeroWord;
            ex_vs2<=`ZeroWord;
            ex_rd<=`ZeroRegAddr;
            ex_imm<=`ZeroWord;
            ex_w_enable<=`Disable;
            // ex_branch<=`Disable;
        end
    end
end

endmodule //id_ex