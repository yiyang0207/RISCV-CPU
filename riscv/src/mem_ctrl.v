`include "src/config.v"

module mem_ctrl (
    input  wire clk,
    input  wire rst,
    input  wire rdy,

    //ram
    input  wire [`RamDataBus] ram_data_i,
    output reg [`RamDataBus] ram_data_o,
    output wire [`AddrBus] ram_addr,
    output reg ram_rw_sel, //selector: read 0/write 1

    //if
    input  wire if_enable,
    input  wire [`AddrBus] if_addr,
    output reg [`InstBus] if_inst,
    output reg if_busy,
    output reg if_finished,

    //mem
    input  wire mem_enable,
    input  wire [`AddrBus] mem_addr,
    input  wire [2:0] mem_data_len,
    input  wire [`RegBus] mem_data_i,
    input  wire mem_rw_sel, //read 0/write 1
    output reg [`RegBus] mem_data_o,
    output reg mem_busy,
    output reg mem_finished
);

reg [2:0] cnt;
reg [`RamDataBus] tmp_load_data[0:3];

wire [`RamDataBus] tmp_store_data[0:3];
assign tmp_store_data[0]=mem_data_i[7:0];
assign tmp_store_data[1]=mem_data_i[15:8];
assign tmp_store_data[2]=mem_data_i[23:16];
assign tmp_store_data[3]=mem_data_i[31:24];

assign ram_addr=(if_enable==`Enable)?if_addr+cnt:mem_addr+cnt;

always @(posedge clk) begin
    if(rst==`Enable) begin
        ram_data_o<=`ZeroByte;
        // ram_addr<=`ZeroWord;
        ram_rw_sel<=`ZeroBit;
        if_inst<=`ZeroWord;
        if_busy<=`Disable;
        if_finished<=`Disable;
        mem_data_o<=`ZeroWord;
        mem_busy<=`Disable;
        mem_finished<=`Disable;
    end else if(rdy==`Enable) begin
        if(mem_enable==`Enable) begin
            ram_data_o<=`ZeroByte;
            ram_rw_sel<=mem_rw_sel;
            mem_data_o<=`ZeroWord;
            mem_busy<=`Enable;
            mem_finished<=`Disable;
            if_busy<=`Disable;
            if(mem_rw_sel==1'b0) begin //read
                if(cnt<3'b100) begin
                    tmp_load_data[cnt]<=ram_data_i;
                    cnt<=cnt+3'b001;
                end else if(cnt==3'b100) begin
                    cnt<=3'b000;
                    mem_data_o<={tmp_load_data[3],tmp_load_data[2],tmp_load_data[1],tmp_load_data[0]};
                    mem_busy<=`Disable;
                    mem_finished<=`Enable;
                end
            end else begin //write
                if(cnt<mem_data_len) begin
                    ram_data_o<=tmp_store_data[cnt];
                    cnt<=cnt+3'b001;
                end else if(cnt==mem_data_len) begin
                    cnt<=3'b000;
                    mem_busy=`Disable;
                    mem_finished<=`Enable;
                end
            end
        end else if(if_enable==`Enable)  begin
            ram_data_o<=`ZeroByte;
            ram_rw_sel<=1'b0;
            if_inst<=`ZeroWord;
            if_busy<=`Enable;
            if_finished<=`Disable;
            mem_busy<=`Disable;
            if(cnt<3'b100) begin
                tmp_load_data[cnt]<=ram_data_i;
                cnt<=cnt+3'b001;
            end else if(cnt==3'b100) begin
                cnt<=3'b000;
                if_inst<={tmp_load_data[3],tmp_load_data[2],tmp_load_data[1],tmp_load_data[0]};
                if_busy<=`Disable;
                if_finished<=`Enable;
            end
        end begin
            cnt<=3'b000;
            if_finished<=`Disable;
            mem_finished<=`Disable;
        end
    end 
end

endmodule //mem_ctrl