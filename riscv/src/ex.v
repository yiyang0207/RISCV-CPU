`include "config.v"

module EX (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    input  wire [`AddrBus] pc_i,
    input  wire [`OptBus] inst_i,
    input  wire [`RegBus] vs1,
    input  wire [`RegBus] vs2,
    input  wire [`RegAddrBus] rd_i,
    input  wire [`RegBus] imm,
    input  wire jump_enable_i, //TODO delete?

    output reg [`AddrBus] pc_o,
    output reg [`OptBus] inst_o,
    output reg [`RegAddrBus] rd_o,
    output reg [`RegBus] vd,
    output reg w_enable,

    output reg jump_enable_o,
    output reg jump_dist
);

always @(*) begin
    if(rst==`Enable||rdy==`Disable) begin
        pc_o=`ZeroWord;
        inst_o=`NOP;
        rd_o=`ZeroRegAddr;
        vd=`ZeroWord;
        w_enable=`Disable;
        jump_enable_o=`Disable;
        jump_dist=`ZeroWord;
    end else begin
        pc_o=pc_i;
        inst_o=inst_i;
        rd_o=rd_i;
        vd=`ZeroWord;
        w_enable=`Disable;
        jump_enable_o=`Disable;

        case (inst_i)
            `NOP:begin
                rd_o=`ZeroWord;
            end
            `LUI:begin
                vd=imm;
            end
            `AUIPC:begin
                vd=pc_i+imm;
            end
            `JAL,`JALR:begin
                vd=pc_i+4;
            end
            `BEQ:begin
                jump_enable_o=`Enable;
                if(vs1==vs2) begin
                    jump_dist=pc_i+imm;
                end else begin
                    jump_dist=pc_i+4;
                end
            end
            `BNE:begin
                jump_enable_o=`Enable;
                if(vs1!=vs2) begin
                    jump_dist=pc_i+imm;
                end else begin
                    jump_dist=pc_i+4;
                end
            end
            `BLT:begin
                jump_enable_o=`Enable;
                if($signed(vs1)<$signed(vs2)) begin
                    jump_dist=pc_i+imm;
                end else begin
                    jump_dist=pc_i+4;
                end
            end
            `BGE:begin
                jump_enable_o=`Enable;
                if($signed(vs1)>=$signed(vs2)) begin
                    jump_dist=pc_i+imm;
                end else begin
                    jump_dist=pc_i+4;
                end
            end
            `BLTU:begin
                jump_enable_o=`Enable;
                if(vs1<vs2)  begin
                    jump_dist=pc_i+imm;
                end else begin
                    jump_dist=pc_i+4;
                end
            end
            `BGEU:begin
                jump_enable_o=`Enable;
                if(vs1>vs2) begin
                    jump_dist=pc_i+imm;
                end else begin
                    jump_dist=pc_i+4;
                end
            end
            `LB,`LH,`LW,`LBU,`LHU:begin
                vd=vs1+imm;
            end
            `SB,`SH,`SW:begin
                rd_o=vs1+imm;
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