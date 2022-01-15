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
    
    //EX_MEM
    output reg [`OptBus] inst_o,
    output reg [`RegAddrBus] rd_o, //also output to id
    output reg [`RegBus] vd, //also output to id
    output reg [`AddrBus] memctrl_addr,
    output reg w_enable_o,

    //ID
    output reg load_enable,
    output reg w_finished,

    //jump to pcreg & if_id
    output reg jump_enable,
    output reg [`AddrBus] jump_dist,

    //branch to pcreg
    output reg is_branch,
    output reg branch_taken_o,
    output reg [`AddrBus] branch_pc,
    output reg [`AddrBus] branch_dist,

    //IF_ID
    input  wire [`AddrBus] predicted_pc
);

always @(*) begin
    if(rst==`Enable||rdy==`Disable) begin
        inst_o=`ZeroOpt;
        rd_o=`ZeroRegAddr;
        vd=`ZeroWord;
        memctrl_addr=`ZeroWord;
        load_enable=`Disable;
        w_finished=`Disable;
        w_enable_o=`Disable;
        jump_enable=`Disable;
        jump_dist=`ZeroWord;
    end else begin
        inst_o=inst_i;
        rd_o=rd_i;
        vd=`ZeroWord;
        memctrl_addr=`ZeroWord;
        load_enable=`Disable;
        w_enable_o=w_enable_i;
        jump_enable=`Disable;
        jump_dist=`ZeroWord;
        is_branch=`Disable;
        branch_taken_o=`Disable;
        branch_pc=`ZeroWord;
        branch_dist=`ZeroWord;
        case (inst_i)
            `ZeroOpt:begin
                rd_o=`ZeroWord;
                w_finished=`Disable;
            end
            `LUI:begin
                vd=imm;
                w_finished=`Enable;
            end
            `AUIPC:begin
                vd=pc_i+imm;
                w_finished=`Enable;
            end
            `JAL:begin
                vd=pc_i+4;
                jump_enable=`Enable;
                jump_dist=pc_i+imm;
                w_finished=`Enable;
            end
            `JALR:begin
                vd=pc_i+4;
                jump_enable=`Enable;
                jump_dist=(vs1+imm)&32'hFFFFFFFE;
                w_finished=`Enable;
            end
            `BEQ:begin
                is_branch=`Enable;
                branch_pc=pc_i;
                branch_dist=pc_i+imm;
                if(vs1==vs2) begin
                    branch_taken_o=`Enable;
                    if(predicted_pc!=branch_dist) begin
                        jump_enable=`Enable;
                        jump_dist=pc_i+imm;
                    end
                end else begin
                    branch_taken_o=`Disable;
                    if(predicted_pc!=pc_i+4) begin
                        jump_enable=`Enable;    
                        jump_dist=pc_i+4; 
                    end  
                end
                w_finished=`Disable;
            end
            `BNE:begin
                is_branch=`Enable;
                branch_pc=pc_i;
                branch_dist=pc_i+imm;
                if(vs1!=vs2) begin
                    branch_taken_o=`Enable;
                    if(predicted_pc!=branch_dist) begin
                        jump_enable=`Enable;
                        jump_dist=pc_i+imm;
                    end
                end else begin
                    branch_taken_o=`Disable;
                    if(predicted_pc!=pc_i+4) begin
                        jump_enable=`Enable;    
                        jump_dist=pc_i+4; 
                    end  
                end
                w_finished=`Disable;
            end
            `BLT:begin
                is_branch=`Enable;
                branch_pc=pc_i;
                branch_dist=pc_i+imm;
                if($signed(vs1)<$signed(vs2)) begin
                    branch_taken_o=`Enable;
                    if(predicted_pc!=branch_dist) begin
                        jump_enable=`Enable;
                        jump_dist=pc_i+imm;
                    end
                end else begin
                    branch_taken_o=`Disable;
                    if(predicted_pc!=pc_i+4) begin
                        jump_enable=`Enable;    
                        jump_dist=pc_i+4; 
                    end  
                end
                w_finished=`Disable;
            end
            `BGE:begin
                is_branch=`Enable;
                branch_pc=pc_i;
                branch_dist=pc_i+imm;
                if($signed(vs1)>=$signed(vs2)) begin
                    branch_taken_o=`Enable;
                    if(predicted_pc!=branch_dist) begin
                        jump_enable=`Enable;
                        jump_dist=pc_i+imm;
                    end
                end else begin
                    branch_taken_o=`Disable;
                    if(predicted_pc!=pc_i+4) begin
                        jump_enable=`Enable;    
                        jump_dist=pc_i+4; 
                    end  
                end
                w_finished=`Disable;
            end
            `BLTU:begin
                is_branch=`Enable;
                branch_pc=pc_i;
                branch_dist=pc_i+imm;
                if(vs1<vs2) begin
                    branch_taken_o=`Enable;
                    if(predicted_pc!=branch_dist) begin
                        jump_enable=`Enable;
                        jump_dist=pc_i+imm;
                    end
                end else begin
                    branch_taken_o=`Disable;
                    if(predicted_pc!=pc_i+4) begin
                        jump_enable=`Enable;    
                        jump_dist=pc_i+4; 
                    end  
                end
                w_finished=`Disable;
            end
            `BGEU:begin
                is_branch=`Enable;
                branch_pc=pc_i;
                branch_dist=pc_i+imm;
                if(vs1>vs2) begin
                branch_taken_o=`Enable;
                    if(predicted_pc!=branch_dist) begin
                        jump_enable=`Enable;
                        jump_dist=pc_i+imm;
                    end
                end else begin
                    branch_taken_o=`Disable;
                    if(predicted_pc!=pc_i+4) begin
                        jump_enable=`Enable;    
                        jump_dist=pc_i+4; 
                    end  
                end
                w_finished=`Disable;
            end
            `LB,`LH,`LW,`LBU,`LHU:begin
                memctrl_addr=vs1+imm;
                load_enable=`Enable;
                w_finished=`Disable;
            end
            `SB,`SH,`SW:begin
                memctrl_addr=vs1+imm;
                vd=vs2;
                w_finished=`Disable;
            end
            `ADDI:begin
                vd=vs1+imm;
                w_finished=`Enable;
            end
            `SLTI:begin
                vd=$signed(vs1)<$signed(imm);
                w_finished=`Enable;
            end
            `SLTIU:begin
                vd=vs1<imm;
                w_finished=`Enable;
            end
            `XORI:begin
                vd=vs1^imm;
                w_finished=`Enable;
            end
            `ORI:begin
                vd=vs1|imm;
                w_finished=`Enable;
            end
            `ANDI:begin
                vd=vs1&imm;
                w_finished=`Enable;
            end
            `SLLI:begin
                vd=vs1<<imm[`ShamtBus];
                w_finished=`Enable;
            end
            `SRLI:begin
                vd=vs1>>imm[`ShamtBus];
                w_finished=`Enable;
            end
            `SRAI:begin
                vd=$signed(vs1)>>imm[`ShamtBus];
                w_finished=`Enable;
            end
            `ADD:begin
                vd=vs1+vs2;
                w_finished=`Enable;
            end
            `SUB:begin
                vd=vs1-vs2;
                w_finished=`Enable;
            end
            `SLL:begin
                vd=vs1<<vs2[`ShamtBus];
                w_finished=`Enable;
            end
            `SLT:begin
                vd=$signed(vs1)<$signed(vs2);
                w_finished=`Enable;
            end
            `SLTU:begin
                vd=vs1<vs2;
                w_finished=`Enable;
            end
            `XOR:begin
                vd=vs1^vs2;
                w_finished=`Enable;
            end
            `SRL:begin
                vd=vs1>>vs2[`ShamtBus];
                w_finished=`Enable;
            end
            `SRA:begin
                vd=$signed(vs1)>>vs2[`ShamtBus];
                w_finished=`Enable;
            end
            `OR:begin
                vd=vs1|vs2;
                w_finished=`Enable;
            end
            `AND:begin
                vd=vs1&vs2;
                w_finished=`Enable;
            end
        endcase
    end
end

endmodule //ex