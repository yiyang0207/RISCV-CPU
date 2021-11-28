// RISCV32I CPU top module
// port modification allowed for debugging purposes

`include "src/config.v"

module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
	input  wire                 rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]          dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

wire if_stall;
wire id_stall;
wire mem_stall;
wire [`StallBus] stall_ctrler;

stall_ctrl StallCtrl(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .if_stall(if_stall),
  .id_stall(id_stall),
  .mem_stall(mem_stall),
  .stall_ctrler(stall_ctrler)
);

wire regfile_r1_enable;
wire [`RegAddrBus] regfile_r1_addr;
wire [`RegBus] regfile_r1_data;
wire regfile_r2_enable; 
wire [`RegAddrBus] regfile_r2_addr;
wire [`RegBus] regfile_r2_data;
wire regfile_w_enable;
wire [`RegAddrBus] regfile_w_addr;
wire [`RegBus] regfile_w_data;

regfile RegFile(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .r1_enable(regfile_r1_enable),
  .r1_addr(regfile_r1_addr),
  .r1_data(regfile_r1_data),
  .r2_enable(regfile_r2_enable),
  .r2_addr(regfile_r2_addr),
  .r2_data(regfile_r2_data),
  .w_enable(regfile_w_enable),
  .w_addr(regfile_w_addr),
  .w_data(regfile_w_data)
);

wire pcreg_jump_enable;
wire [`AddrBus] pcreg_jump_dist;
wire [`AddrBus] pcreg_pc;

pc_reg PcReg(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .stall(stall_ctrler),
  .jump_enable_i(pcreg_jump_enable),
  .jump_dist(pcreg_jump_dist),
  .pc(pcreg_pc),
  .jump_enable_o()
);

wire memctrl_if_enable;
wire [`AddrBus] memctrl_if_addr;
wire [`InstBus] memctrl_if_inst;
wire memctrl_if_busy;
wire memctrl_if_finished;
wire memctrl_mem_enable;
wire [`AddrBus] memctrl_mem_addr;
wire [2:0] memctrl_mem_data_len;
wire [`RegBus] memctrl_data_from_mem;
wire memctrl_mem_rw_sel;
wire [`RegBus] memctrl_data_to_mem;
wire memctrl_mem_busy;
wire memctrl_mem_finished;

mem_ctrl MemCtrl(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .ram_data_i(mem_din),
  .ram_data_o(mem_dout),
  .ram_addr(mem_a),
  .ram_rw_sel(mem_wr),
  .if_enable(memctrl_if_enable),
  .if_addr(memctrl_if_addr),
  .if_inst(memctrl_if_inst),
  .if_busy(memctrl_if_busy),
  .if_finished(memctrl_if_finished),
  .mem_enable(memctrl_mem_enable),
  .mem_addr(memctrl_mem_addr),
  .mem_data_len(memctrl_mem_data_len),
  .mem_data_i(memctrl_data_from_mem),
  .mem_rw_sel(memctrl_mem_rw_sel),
  .mem_data_o(memctrl_data_to_mem),
  .mem_busy(memctrl_mem_busy),
  .mem_finished(memctrl_mem_finished)
);

wire [`AddrBus] if_ifid_pc;
wire [`InstBus] if_ifid_inst;

IF If(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .pc_i(pcreg_pc),
  .mem_ctrl_finished(memctrl_if_finished),
  .inst_i(memctrl_if_inst),
  .mem_ctrl_if_busy(memctrl_if_busy),
  .mem_ctrl_mem_busy(memctrl_mem_busy),
  .mem_ctrl_enable(memctrl_if_enable),
  .mem_ctrl_addr(memctrl_if_addr),
  .pc_o(if_ifid_pc),
  .inst_o(if_ifid_inst),
  .if_stall(if_stall)
);

wire ifid_jump_enable;
wire [`AddrBus] ifid_id_pc;
wire [`InstBus] ifid_id_inst;

IF_ID IfId(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .if_pc(if_ifid_pc),
  .if_inst(if_ifid_inst),
  .jump_enable(ifid_jump_enable),
  .stall_ctrler(stall_ctrler),
  .id_pc(ifid_id_pc),
  .id_inst(ifid_id_inst)
);

wire [`AddrBus] id_idex_pc;
wire [`OptBus] id_idex_inst;
wire [`RegBus] id_idex_vs1;
wire [`RegBus] id_idex_vs2;
wire [`RegAddrBus] id_idex_rd;
wire [`RegBus] id_idex_imm;
wire id_idex_w_enable;
wire ex_id_load_enable;
wire [`RegAddrBus] ex_exmem_rd;
wire [`RegBus] ex_exmem_vd;
wire ex_exmem_w_enable;
wire mem_id_w_enable;
wire [`RegAddrBus] mem_id_rd;
wire [`RegBus] mem_id_vd;

ID Id(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .pc_i(ifid_id_pc),
  .inst_i(ifid_id_inst),
  .pc_o(id_idex_pc),
  .inst_o(id_idex_inst),
  .vs1(id_idex_vs1),
  .vs2(id_idex_vs2),
  .rd(id_idex_rd),
  .imm(id_idex_imm),
  .w_enable_o(id_idex_w_enable),
  .ex_load_enable(ex_id_load_enable),
  .ex_w_enable(ex_exmem_w_enable),
  .ex_rd(ex_exmem_rd),
  .ex_vd(ex_exmem_vd),
  .mem_w_enable(mem_id_w_enable),
  .mem_rd(mem_id_rd),
  .mem_vd(mem_id_vd),
  .r1_data(regfile_r1_data),
  .r2_data(regfile_r2_data),
  .rs1(regfile_r1_addr),
  .rs2(regfile_r2_addr),
  .r1_enable(regfile_r1_enable),
  .r2_enable(regfile_r2_enable),
  .id_stall(id_stall)
);

wire idex_jump_enable;
wire [`AddrBus] idex_ex_pc;
wire [`OptBus] idex_ex_inst;
wire [`RegBus] idex_ex_vs1;
wire [`RegBus] idex_ex_vs2;
wire [`RegAddrBus] idex_ex_rd;
wire [`RegBus] idex_ex_imm;
wire idex_ex_w_enable;

ID_EX IdEx(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .id_pc(id_idex_pc),
  .id_inst(id_idex_inst),
  .id_vs1(id_idex_vs1),
  .id_vs2(id_idex_vs2),
  .id_rd(id_idex_rd),
  .id_imm(id_idex_imm),
  .id_w_enable(id_idex_w_enable),
  .jump_enable(idex_jump_enable),
  .stall_ctrler(stall_ctrler),
  .ex_pc(idex_ex_pc),
  .ex_inst(idex_ex_inst),
  .ex_vs1(idex_ex_vs1),
  .ex_vs2(idex_ex_vs2),
  .ex_rd(idex_ex_rd),
  .ex_imm(idex_ex_imm),
  .ex_w_enable(idex_ex_w_enable)
);

wire [`OptBus] ex_exmem_inst;
wire [`AddrBus] ex_exmem_memctrl_addr;
wire ex_jump_enable;
wire [`AddrBus] ex_jump_dist;

EX Ex(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .pc_i(idex_ex_pc),
  .inst_i(idex_ex_inst),
  .vs1(idex_ex_vs1),
  .vs2(idex_ex_vs2),
  .rd_i(idex_ex_rd),
  .imm(idex_ex_imm),
  .w_enable_i(idex_ex_w_enable),
  .inst_o(ex_exmem_inst),
  .rd_o(ex_exmem_rd),
  .vd(ex_exmem_vd),
  .memctrl_addr(ex_exmem_memctrl_addr),
  .load_enable(ex_id_load_enable),
  .w_enable_o(ex_exmem_w_enable),
  .jump_enable(ex_jump_enable),
  .jump_dist(ex_jump_dist)
);

wire [`OptBus] exmem_mem_inst;
wire [`RegAddrBus] exmem_mem_rd;
wire [`RegBus] exmem_mem_vd;
wire exmem_mem_w_enable;
wire [`AddrBus] exmem_mem_memctrl_addr;

EX_MEM ExMem(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .ex_inst(ex_exmem_inst),
  .ex_rd(ex_exmem_rd),
  .ex_vd(ex_exmem_vd),
  .ex_w_enable(ex_exmem_w_enable),
  .stall_ctrler(stall_ctrler),
  .mem_inst(exmem_mem_inst),
  .mem_rd(exmem_mem_rd),
  .mem_vd(exmem_mem_vd),
  .mem_w_enable(exmem_mem_w_enable),
  .mem_memctrl_addr(exmem_mem_memctrl_addr)
);

wire [`RegAddrBus] mem_memwb_rd;
wire [`RegBus] mem_memwb_vd;
wire mem_memwb_w_enable;

MEM Mem(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .inst_i(exmem_mem_inst),
  .rd_i(exmem_mem_rd),
  .vd_i(exmem_mem_vd),
  .w_enable_i(exmem_mem_w_enable),
  .memctrl_addr_i(exmem_mem_memctrl_addr),
  .rd_o(mem_memwb_rd),
  .vd_o(mem_memwb_vd),
  .w_enable_o(mem_memwb_w_enable),
  .mem_ctrl_finished(memctrl_mem_finished),
  .mem_ctrl_data_i(memctrl_data_to_mem),
  .mem_ctrl_if_busy(memctrl_if_busy),
  .mem_ctrl_mem_busy(memctrl_mem_busy),
  .mem_ctrl_enable(memctrl_mem_enable),
  .mem_ctrl_addr_o(memctrl_mem_addr),
  .mem_ctrl_data_len(memctrl_mem_data_len),
  .mem_ctrl_data_o(memctrl_data_from_mem),
  .mem_ctrl_rw_sel(memctrl_mem_rw_sel),
  .mem_stall(mem_stall)
);

MEM_WB MemWb(
  .clk(clk_in),
  .rst(rst_in),
  .rdy(rdy_in),
  .mem_rd(mem_memwb_rd),
  .mem_vd(mem_memwb_vd),
  .mem_w_enable(mem_memwb_w_enable),
  .wb_rd(regfile_w_addr),
  .wb_vd(regfile_w_data),
  .wb_w_enable(regfile_w_enable)
);

endmodule