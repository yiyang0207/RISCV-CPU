`include "config.v"

module mem_ctrl(
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //ram
    input  wire [`RamDataBus] ram_data_i,
    output wire [`RamDataBus] ram_data_o,
    output wire [`AddrBus] ram_addr,
    output wire ram_rw_sel,
    
    //IF
    input  wire if_enable,
    input  wire [`AddrBus] if_addr,
    output reg [`InstBus] if_inst,
    output reg if_busy, 
    output reg  if_finished,

    //MEM
    input  wire mem_enable,
    input  wire [`AddrBus] mem_addr,
    input  wire [2:0] mem_data_len,
    input  wire [`RegBus] mem_data_i,
    input  wire mem_rw_sel,
    output reg [`RegBus] mem_data_o,
    output reg mem_busy,
    output reg mem_finished
);

reg[2:0] cnt;

wire [7:0] tmp_data[0:3];
assign tmp_data[0]=mem_data_i[7:0];
assign tmp_data[1]=mem_data_i[15:8];
assign tmp_data[2]=mem_data_i[23:16];
assign tmp_data[3]=mem_data_i[31:24];

wire [`AddrBus] addr=(mem_enable==`Enable)?mem_addr:if_addr;
assign ram_addr=addr+cnt;
assign ram_data_o=tmp_data[cnt];
assign ram_rw_sel=(mem_enable==`Enable)?mem_rw_sel:1'b0;

reg[`RegBus] data_o;
reg[`AddrBus] cur_addr;

always @(posedge clk) begin
    if (rst==`Enable) begin
        if_inst<=`ZeroWord;
        if_busy<=`Disable;
        if_finished<=`Disable;
        mem_data_o<=`ZeroWord;
        mem_busy <=`Disable;
        mem_finished<=`Disable;
        cnt<=3'b000;
        data_o<=`ZeroWord;
    end else if (rdy==`Enable) begin
        if (mem_enable==`Enable&&mem_rw_sel==1'b0) begin //read
            if_inst<=`ZeroWord;
            if_busy<=`Disable;
            mem_busy<=`Enable;
            if_finished<=`Disable;
            mem_finished<=`Disable;
            case (cnt)
                3'b001: data_o[7:0]=ram_data_i;
                3'b010: data_o[15:8]=ram_data_i;
                3'b011: data_o[23:16]=ram_data_i;
                3'b100: data_o[31:24]=ram_data_i;
            endcase
            if (cnt<mem_data_len) begin
                cnt<=cnt+3'b001;
            end else begin
                mem_data_o<=data_o;
                cnt<=3'b000;
                if_busy<=`Disable;
                mem_busy<=`Disable;
                mem_finished<=`Enable;
            end
        end else if (mem_enable==`Enable&&mem_rw_sel==1'b1) begin //write
            if_inst<=`ZeroWord;
            mem_data_o<=`ZeroWord;
            if_busy<=`Disable;
            mem_busy<=`Enable;
            if_finished<=`Disable;
            mem_finished<=`Disable;
            if (cnt==mem_data_len) begin
                cnt<=3'b000;
                if_busy<=`Disable;
                mem_busy<=`Disable;
                mem_finished<=`Enable;
            end else begin
                cnt<=cnt+3'b001;
            end
        end else if (if_enable==`Enable) begin //if
            if (if_addr!=cur_addr) begin
                cnt<=3'b000;
            end
            mem_data_o<=`ZeroWord;
            if_busy<=`Enable;
            mem_busy<=`Disable;
            if_finished<=`Disable;
            mem_finished<=`Disable;
            case (cnt)
                3'b001: data_o[7:0]<=ram_data_i;
                3'b010: data_o[15:8]<=ram_data_i;
                3'b011: data_o[23:16]<=ram_data_i;
                3'b100: data_o[31:24]=ram_data_i;
            endcase
            if (cnt==3'b100) begin
                if_inst<=data_o;
                cnt<=3'b000;
                if_busy<=`Disable;
                mem_busy<=`Disable;
                if_finished<=`Enable;
            end else if (if_addr==cur_addr)begin
                cnt<=cnt+3'b001;
            end
            cur_addr<=if_addr;
        end else begin
            cnt<=3'b000;
            if_busy<=`Disable;
            mem_busy<=`Disable;
            if_finished<=`Disable;
            mem_finished<=`Disable;
            if_inst<=`ZeroWord;
            mem_data_o<=`ZeroWord;
            data_o<=`ZeroWord;
        end
    end
end


endmodule //mem_ctrl