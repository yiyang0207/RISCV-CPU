`include "config.v"

module EX (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //ID_EX
    input  wire [`AddrBus] pc_i,
    input  wire [`OptBus] inst_i,
    input  wire [`RegBus] vs1,
    input  wire [`RegBus] vs2,
    input  wire [`RegAddrBus] rd_i,
    input  wire [`RegBus] imm,
    input  wire w_enable_i,
    // input  wire branch_i, //TODO delete?
    
    //EX_MEM
    output reg [`OptBus] inst_o,
    output reg [`RegAddrBus] rd_o, //also output to id
    output reg [`RegBus] vd, //also output to id
    output reg [`AddrBus] memctrl_addr,
    output reg w_enable_o, //also output to id

    //ID
    output reg load_enable,

    //jump
    output reg jump_enable,
    output reg [`AddrBus] jump_dist

    //branch_predictor
    // output reg bp_enable,
    // output reg [`AddrBus] bp_dist,
    // output reg [`AddrBus] bp_pc,
    // output reg bp_taken,

    // output reg ex_stall
);

always @(*) begin
    if(rst==`Enable||rdy==`Disable) begin
        // pc_o=`ZeroWord;
        inst_o=`ZeroOpt;
        rd_o=`ZeroRegAddr;
        vd=`ZeroWord;
        memctrl_addr=`ZeroWord;
        load_enable=`Disable;
        w_enable_o=`Disable;
        jump_enable=`Disable;
        jump_dist=`ZeroWord;
        //TODO
        // ex_stall=`Disable;
    end else begin
        // pc_o=pc_i;
        inst_o=inst_i;
        rd_o=rd_i;
        vd=`ZeroWord;
        memctrl_addr=`ZeroWord;
        load_enable=`Disable;
        w_enable_o=w_enable_i;
        jump_enable=`Disable;
        jump_dist=`ZeroWord;
        //TODO
        // ex_stall=`Disable;
        case (inst_i)
            `ZeroOpt:begin
                rd_o=`ZeroWord;
            end
            `LUI:begin
                vd=imm;
            end
            `AUIPC:begin
                vd=pc_i+imm;
            end
            `JAL:begin
                vd=pc_i+4;
                jump_enable=`Enable;
                jump_dist=pc_i+imm;
            end
            `JALR:begin
                vd=pc_i+4;
                jump_enable=`Enable;
                jump_dist=(vs1+imm)&32'hFFFFFFFE;
            end
            `BEQ:begin
                if(vs1==vs2) begin
                    jump_enable=`Enable;
                    jump_dist=pc_i+imm;
                end else begin
                    jump_enable=`Disable;
                end
            end
            `BNE:begin
                if(vs1!=vs2) begin
                    jump_enable=`Enable;
                    jump_dist=pc_i+imm;
                end else begin
                    jump_enable=`Disable;
                end
            end
            `BLT:begin
                if($signed(vs1)<$signed(vs2)) begin
                    jump_enable=`Enable;
                    jump_dist=pc_i+imm;
                end else begin
                    jump_enable=`Disable;
                end
            end
            `BGE:begin
                if($signed(vs1)>=$signed(vs2)) begin
                    jump_enable=`Enable;
                    jump_dist=pc_i+imm;
                end else begin
                    jump_enable=`Disable;
                end
            end
            `BLTU:begin
                if(vs1<vs2)  begin
                jump_enable=`Enable;
                    jump_dist=pc_i+imm;
                end else begin
                    jump_enable=`Disable;
                end
            end
            `BGEU:begin
                if(vs1>vs2) begin
                jump_enable=`Enable;
                    jump_dist=pc_i+imm;
                end else begin
                    jump_enable=`Disable;
                end
            end
            `LB,`LH,`LW,`LBU,`LHU:begin
                memctrl_addr=vs1+imm;
                load_enable=`Enable;
            end
            `SB,`SH,`SW:begin
                memctrl_addr=vs1+imm;
                vd=vs2;
            end
            `ADDI:begin
                vd=vs1+imm;
            end
            `SLTI:begin
                vd=$signed(vs1)<$signed(imm);
            end
            `SLTIU:begin
                vd=vs1<imm;
            end
            `XORI:begin
                vd=vs1^imm;
            end
            `ORI:begin
                vd=vs1|imm;
            end
            `ANDI:begin
                vd=vs1&imm;
            end
            `SLLI:begin
                vd=vs1<<imm[`ShamtBus];
            end
            `SRLI:begin
                vd=vs1>>imm[`ShamtBus];
            end
            `SRAI:begin
                vd=$signed(vs1)>>imm[`ShamtBus];
            end
            `ADD:begin
                vd=vs1+vs2;
            end
            `SUB:begin
                vd=vs1-vs2;
            end
            `SLL:begin
                vd=vs1<<vs2[`ShamtBus];
            end
            `SLT:begin
                vd=$signed(vs1)<$signed(vs2);
            end
            `SLTU:begin
                vd=vs1<vs2;
            end
            `XOR:begin
                vd=vs1^vs2;
            end
            `SRL:begin
                vd=vs1>>vs2[`ShamtBus];
            end
            `SRA:begin
                vd=$signed(vs1)>>vs2[`ShamtBus];
            end
            `OR:begin
                vd=vs1|vs2;
            end
            `AND:begin
                vd=vs1&vs2;
            end
        endcase
    end
end

endmodule //ex