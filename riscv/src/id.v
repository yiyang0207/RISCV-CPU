`include "config.v"

module ID (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //IF_ID
    input  wire [`AddrBus] pc_i,
    input  wire [`InstBus] inst_i,
    // input  wire branch_i,

    //ID_EX
    output reg [`AddrBus] pc_o,
    output reg [`OptBus] inst_o,
    output reg [`RegBus] vs1,
    output reg [`RegBus] vs2,
    output reg [`RegAddrBus] rd,
    output reg [`RegBus] imm,
    output reg w_enable_o,
    // output reg branch_o,

    //EX
    input  wire ex_load_enable,
    input  wire ex_w_enable,
    input  wire [`RegAddrBus] ex_rd,
    input  wire [`RegBus] ex_vd,

    //MEM
    input  wire mem_w_enable,
    input  wire [`RegAddrBus] mem_rd,
    input  wire [`RegBus] mem_vd,

    //regfile
    input  wire [`RegBus] r1_data,
    input  wire [`RegBus] r2_data,
    output reg [`RegAddrBus] rs1,
    output reg [`RegAddrBus] rs2,
    output reg r1_enable,
    output reg r2_enable,

    output wire id_stall
);

wire [`OpcodeBus] opcode=inst_i[`OpcodeBus];
wire [2:0] func3=inst_i[14:12];
wire [6:0] func7=inst_i[31:25];

always @(*) begin
    if(rst==`Enable||rdy==`Disable)begin
        rs1=`ZeroWord;
        rs2=`ZeroWord;
        r1_enable=`Disable;
        r2_enable=`Disable;
        pc_o=`ZeroWord;
        vs1=`ZeroWord;
        vs2=`ZeroWord;
        rd=`ZeroRegAddr;
        imm=`ZeroWord;
        w_enable_o=`Disable;
        // branch_o=`Disable;
    end else begin
        pc_o=pc_i;
        rd=`ZeroRegAddr;
        imm=`ZeroWord;
        // branch_o=branch_i;
        rs1=inst_i[19:15];
        rs2=inst_i[24:20];
        case (opcode)
            7'b0110111:begin
                inst_o=`LUI;
                rd=inst_i[11:7];
                imm={inst_i[31:12],12'b0};
                w_enable_o=`Enable;
                r1_enable=`Disable;
                r2_enable=`Disable;
            end
            7'b0010111:begin
                inst_o=`AUIPC;
                rd=inst_i[11:7];
                imm={inst_i[31:12],12'b0};
                w_enable_o=`Enable;
                r1_enable=`Disable;
                r2_enable=`Disable;
            end
            7'b1101111:begin
                inst_o=`JAL;
                rd=inst_i[11:7];
                imm={{12{inst_i[31]}},inst_i[19:12],inst_i[20],inst_i[30:21],1'b0};
                w_enable_o=`Enable;
                r1_enable=`Disable;
                r2_enable=`Disable;
            end
            7'b1100111:begin
                inst_o=`JALR;
                rd=inst_i[11:7];
                imm={{21{inst_i[31]}},inst_i[30:20]};
                // $display("%d",imm);
                w_enable_o=`Enable;
                r1_enable=`Enable;
                r2_enable=`Disable;
            end
            7'b1100011:begin //branch
                imm={{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};
                w_enable_o=`Disable;
                r1_enable=`Enable;
                r2_enable=`Enable;
                case (func3)
                    3'b000:inst_o=`BEQ;
                    3'b001:inst_o=`BNE;
                    3'b100:inst_o=`BLT;
                    3'b101:inst_o=`BGE;
                    3'b110:inst_o=`BLTU;
                    3'b111:inst_o=`BGEU;
                endcase
            end
            7'b0000011:begin //load
                rd=inst_i[11:7];
                imm={{21{inst_i[31]}},inst_i[30:20]};
                w_enable_o=`Enable;
                r1_enable=`Enable;
                r2_enable=`Disable;
                case (func3)
                    3'b000:inst_o=`LB;
                    3'b001:inst_o=`LH;
                    3'b010:inst_o=`LW;
                    3'b100:inst_o=`LBU;
                    3'b101:inst_o=`LHU;
                endcase
            end
            7'b0100011:begin //store
                imm={{21{inst_i[31]}},inst_i[30:25],inst_i[11:7]};
                w_enable_o=`Disable;
                r1_enable=`Enable;
                r2_enable=`Enable;
                case (func3)
                    3'b000:inst_o=`SB;
                    3'b001:inst_o=`SH;
                    3'b010:inst_o=`SW;
                endcase
            end
            7'b0010011:begin //operation with imm
                rd=inst_i[11:7];
                imm={{21{inst_i[31]}},inst_i[30:20]};
                //shamt=imm[4:0], `ShamtBus=4:0
                w_enable_o=`Enable;
                r1_enable=`Enable;
                r2_enable=`Disable;
                case (func3)
                    3'b000:inst_o=`ADDI;
                    3'b010:inst_o=`SLTI;
                    3'b011:inst_o=`SLTIU;
                    3'b100:inst_o=`XORI;
                    3'b110:inst_o=`ORI;
                    3'b111:inst_o=`ANDI;
                    3'b001:inst_o=`SLLI;
                    3'b101:begin
                        case (func7)
                            7'b0000000:inst_o=`SRLI;
                            7'b0100000:inst_o=`SRAI;
                        endcase
                    end
                endcase
            end
            7'b0110011:begin //operation with reg
                rd=inst_i[11:7];
                w_enable_o=`Enable;
                r1_enable=`Enable;
                r2_enable=`Enable;
                case (func3)
                    3'b000:begin
                        case (func7)
                            7'b0000000:inst_o=`ADD;
                            7'b0100000:inst_o=`SUB;
                        endcase
                    end
                    3'b001:inst_o=`SLL;
                    3'b010:inst_o=`SLT;
                    3'b011:inst_o=`SLTU;
                    3'b100:inst_o=`XOR;
                    3'b101:begin
                        case (func7)
                            7'b0000000:inst_o=`SRL;
                            7'b0100000:inst_o=`SRA;
                        endcase
                    end
                    3'b110:inst_o=`OR;
                    3'b111:inst_o=`AND;
                endcase
            end
            default:begin
                inst_o=`ZeroOpt;
                r1_enable=`Disable;
                r2_enable=`Disable;
                vs1=`ZeroWord;
                vs2=`ZeroWord;
                rd=`ZeroRegAddr;
                imm=`ZeroWord;
            end
        endcase
    end
end

reg r1_stall;
reg r2_stall;
assign id_stall=r1_stall|r2_stall;

//forwarding
always @(*) begin //read1
    r1_stall=`Disable;
    if(rst==`Enable||rdy==`Disable) begin
        vs1=`ZeroWord;
    end else begin
        if(r1_enable==`Enable) begin
            if(ex_load_enable==`Enable&&rs1==ex_rd) begin
                vs1=`ZeroWord;
                r1_stall=`Enable;
            end else if(ex_w_enable==`Enable&&rs1==ex_rd) begin
                vs1=ex_vd;
            end else if(mem_w_enable==`Enable&&rs1==mem_rd) begin
                vs1=mem_vd;
            end else begin
                vs1=r1_data;
            end
        end else begin
            vs1=`ZeroWord;
        end
    end
end
always @(*) begin //read2
    r2_stall=`Disable;
    if(rst==`Enable||rdy==`Disable) begin
        vs2=`ZeroWord;
    end else begin
        if(r2_enable==`Enable) begin
            if(ex_load_enable==`Enable&&rs2==ex_rd) begin
                vs2=`ZeroWord;
                r2_stall=`Enable;
            end else if(ex_w_enable==`Enable&&rs2==ex_rd) begin
                vs2=ex_vd;
            end else if(mem_w_enable==`Enable&&rs2==mem_rd) begin
                vs2=mem_vd;
            end else begin
                vs2=r2_data;
            end
        end else begin
            vs2=`ZeroWord;
        end
    end
end

endmodule //id