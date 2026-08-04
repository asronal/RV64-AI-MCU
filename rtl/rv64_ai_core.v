`timescale 1ns/1ps

module rv64_ai_core (
  input  wire clk,
  input  wire rst_n,
  input  wire init,
  input  wire [63:0] imem_rdata,
  input  wire        imem_valid,
  input  wire [63:0] dmem_rdata,
  input  wire        dmem_valid,
  output reg  [63:0] imem_addr,
  output reg         imem_read,
  output reg  [63:0] dmem_addr,
  output reg  [63:0] dmem_wdata,
  output reg  [7:0]  dmem_wstrb,
  output reg         dmem_read,
  output reg         dmem_write,
  output wire [63:0] perf_counter0,
  output wire [63:0] perf_counter1,
  output wire [63:0] perf_counter2,
  output wire [63:0] perf_counter3,
  output wire [63:0] perf_counter4,
  output wire [63:0] perf_counter5,
  output wire [63:0] perf_counter6,
  output wire [63:0] perf_counter7
);

  parameter GPR_DEPTH = 32;
  parameter BTB_DEPTH = 128;
  // verilator lint_off UNUSEDPARAM
parameter RAS_DEPTH = 16;
// verilator lint_on UNUSEDPARAM
  parameter PERF_CNTRS = 8;

  integer i;

  reg [63:0] pc_if, pc_id, pc_ex, pc_mem, pc_wb;
  reg [31:0] instr_if, instr_id, instr_ex, instr_mem, instr_wb;
  reg [63:0] gpr [0:GPR_DEPTH-1];
  wire [63:0] pc_next_if;
  reg [63:0] branch_target;
  reg        branch_taken;
  wire        branch_predict_taken;
  reg [63:0] btb_target [0:BTB_DEPTH-1];
  reg [1:0]  btb_state  [0:BTB_DEPTH-1];
  reg [63:0] alu_result;
  reg [63:0] alu_a, alu_b;
  reg [63:0] rs1_data, rs2_data;
  reg [63:0] mem_data;
  reg [63:0] perf_counter [0:PERF_CNTRS-1];

  reg        ctrl_valid, ctrl_branch, ctrl_jump, ctrl_load, ctrl_store;
  reg        ctrl_reg_write, ctrl_mem_read, ctrl_mem_write, ctrl_mem_to_reg;
  reg        ctrl_unsigned_load, ctrl_csr_access, ctrl_is_mret, ctrl_use_imm, ctrl_use_pc;
  reg [4:0]  rs1_addr, rs2_addr, rd_addr;
  reg [63:0] imm_i, imm_s, imm_b, imm_u, imm_j;
  reg [1:0]  op_type;

  reg        ctrl_valid_id, ctrl_branch_id, ctrl_jump_id, ctrl_load_id, ctrl_store_id;
  reg        ctrl_reg_write_id, ctrl_mem_read_id, ctrl_mem_write_id, ctrl_mem_to_reg_id;
  reg        ctrl_unsigned_load_id, ctrl_csr_access_id, ctrl_is_mret_id, ctrl_use_imm_id, ctrl_use_pc_id;
  reg [4:0]  rs1_addr_id, rs2_addr_id, rd_addr_id;
  reg [63:0] imm_i_id, imm_s_id, imm_b_id, imm_u_id, imm_j_id;
  reg [1:0]  op_type_id;

  reg        ctrl_valid_ex, ctrl_branch_ex, ctrl_jump_ex, ctrl_load_ex, ctrl_store_ex;
  reg        ctrl_reg_write_ex, ctrl_mem_read_ex, ctrl_mem_write_ex, ctrl_mem_to_reg_ex;
  reg [4:0]  rs1_addr_ex, rs2_addr_ex, rd_addr_ex;
  reg [63:0] imm_i_ex, imm_s_ex, imm_b_ex, imm_u_ex, imm_j_ex;
  reg [1:0]  op_type_ex;
  reg [63:0] alu_a_ex, alu_b_ex;
  reg [63:0] rs1_data_ex, rs2_data_ex;

  reg        ctrl_reg_write_mem, ctrl_mem_to_reg_mem;
  reg [4:0]  rd_addr_mem;
  reg [63:0] alu_result_mem;
  reg [63:0] mem_data_mem;

  reg        ctrl_reg_write_wb, ctrl_mem_to_reg_wb;
  reg [4:0]  rd_addr_wb;
  reg [63:0] wb_data;

  wire [63:0] pc_plus4 = pc_if + 64'd4;
  wire [6:0]  btb_index = pc_if[8:2];

  rv64_ai_control_unit cu (
    .instr(instr_id),
    .ctrl_valid(ctrl_valid),
    .ctrl_branch(ctrl_branch),
    .ctrl_jump(ctrl_jump),
    .ctrl_load(ctrl_load),
    .ctrl_store(ctrl_store),
    .ctrl_reg_write(ctrl_reg_write),
    .ctrl_mem_read(ctrl_mem_read),
    .ctrl_mem_write(ctrl_mem_write),
    .ctrl_mem_to_reg(ctrl_mem_to_reg),
    .ctrl_unsigned_load(ctrl_unsigned_load),
    .ctrl_csr_access(ctrl_csr_access),
    .ctrl_is_mret(ctrl_is_mret),
    .ctrl_use_imm(ctrl_use_imm),
    .ctrl_use_pc(ctrl_use_pc),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_addr(rd_addr),
    .imm_i(imm_i),
    .imm_s(imm_s),
    .imm_b(imm_b),
    .imm_u(imm_u),
    .imm_j(imm_j),
    .op_type(op_type)
  );

  assign instr_if = ctrl_valid ? imem_rdata[31:0] : 32'h00000013;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n || init) begin
      pc_if <= 64'h0;
      pc_id <= 64'h0;
      pc_ex <= 64'h0;
      pc_mem <= 64'h0;
      pc_wb <= 64'h0;
      instr_id <= 32'h00000013;
      instr_ex <= 32'h00000013;
      instr_mem <= 32'h00000013;
      instr_wb <= 32'h00000013;
      for (i = 0; i < GPR_DEPTH; i = i + 1) gpr[i] <= 64'b0;
      for (i = 0; i < BTB_DEPTH; i = i + 1) begin
        btb_target[i] <= 64'b0;
        btb_state[i] <= 2'b01;
      end
      for (i = 0; i < PERF_CNTRS; i = i + 1) begin
        perf_counter[i] <= 64'b0;
      end
      dmem_addr <= 64'b0;
      dmem_wdata <= 64'b0;
      dmem_wstrb <= 8'h0;
      dmem_read <= 1'b0;
      dmem_write <= 1'b0;
      imem_addr <= 64'b0;
      imem_read <= 1'b0;
      branch_taken <= 1'b0;
      branch_target <= 64'b0;
      alu_result <= 64'b0;
      rs1_data <= 64'b0;
      rs2_data <= 64'b0;
      mem_data <= 64'b0;
      wb_data <= 64'b0;
    end else begin
      perf_counter[0] <= perf_counter[0] + 1;
      imem_addr <= pc_if;
      imem_read <= 1'b1;
      pc_if <= pc_next_if;

      pc_id <= pc_if;
      instr_id <= instr_if;

      pc_ex <= pc_id;
      instr_ex <= instr_id;

      pc_mem <= pc_ex;
      instr_mem <= instr_ex;

      pc_wb <= pc_mem;
      instr_wb <= instr_mem;

      ctrl_valid_id <= ctrl_valid;
      ctrl_branch_id <= ctrl_branch;
      ctrl_jump_id <= ctrl_jump;
      ctrl_load_id <= ctrl_load;
      ctrl_store_id <= ctrl_store;
      ctrl_reg_write_id <= ctrl_reg_write;
      ctrl_mem_read_id <= ctrl_mem_read;
      ctrl_mem_write_id <= ctrl_mem_write;
      ctrl_mem_to_reg_id <= ctrl_mem_to_reg;
      ctrl_unsigned_load_id <= ctrl_unsigned_load;
      ctrl_csr_access_id <= ctrl_csr_access;
      ctrl_is_mret_id <= ctrl_is_mret;
      ctrl_use_imm_id <= ctrl_use_imm;
      ctrl_use_pc_id <= ctrl_use_pc;
      rs1_addr_id <= rs1_addr;
      rs2_addr_id <= rs2_addr;
      rd_addr_id <= rd_addr;
      imm_i_id <= imm_i;
      imm_s_id <= imm_s;
      imm_b_id <= imm_b;
      imm_u_id <= imm_u;
      imm_j_id <= imm_j;
      op_type_id <= op_type;

      ctrl_valid_ex <= ctrl_valid_id;
      ctrl_branch_ex <= ctrl_branch_id;
      ctrl_jump_ex <= ctrl_jump_id;
      ctrl_load_ex <= ctrl_load_id;
      ctrl_store_ex <= ctrl_store_id;
      ctrl_reg_write_ex <= ctrl_reg_write_id;
      ctrl_mem_read_ex <= ctrl_mem_read_id;
      ctrl_mem_write_ex <= ctrl_mem_write_id;
      ctrl_mem_to_reg_ex <= ctrl_mem_to_reg_id;
      rs1_addr_ex <= rs1_addr_id;
      rs2_addr_ex <= rs2_addr_id;
      rd_addr_ex <= rd_addr_id;
      imm_i_ex <= imm_i_id;
      imm_s_ex <= imm_s_id;
      imm_b_ex <= imm_b_id;
      imm_u_ex <= imm_u_id;
      imm_j_ex <= imm_j_id;
      op_type_ex <= op_type_id;

      if (ctrl_reg_write_id && rd_addr_id != 5'd0) begin
        gpr[rd_addr_id] <= alu_result;
      end

      if (ctrl_branch_ex && (rs1_data_ex == rs2_data_ex)) begin
        branch_taken <= 1'b1;
        branch_target <= pc_ex + imm_b_ex;
        btb_target[pc_ex[8:2]] <= pc_ex + imm_b_ex;
        btb_state[pc_ex[8:2]] <= 2'b11;
      end else begin
        branch_taken <= 1'b0;
        branch_target <= pc_ex + 64'd4;
      end

      if (ctrl_mem_to_reg_mem) begin
        wb_data <= mem_data_mem;
      end else begin
        wb_data <= alu_result_mem;
      end
      ctrl_reg_write_mem <= ctrl_reg_write_ex;
      ctrl_mem_to_reg_mem <= ctrl_mem_to_reg_ex;
      rd_addr_mem <= rd_addr_ex;
      alu_result_mem <= alu_result;
      mem_data_mem <= dmem_rdata;
      ctrl_reg_write_wb <= ctrl_reg_write_mem;
      ctrl_mem_to_reg_wb <= ctrl_mem_to_reg_mem;
      rd_addr_wb <= rd_addr_mem;
    end
  end

  assign branch_predict_taken = (btb_state[btb_index] == 2'b11);
  assign pc_next_if = branch_taken ? branch_target :
                      (branch_predict_taken ? btb_target[btb_index] : pc_plus4);

  wire [63:0] rs1_data_gpr = (rs1_addr_id != 5'd0) ? gpr[rs1_addr_id] : 64'b0;
  wire [63:0] rs2_data_gpr = (rs2_addr_id != 5'd0) ? gpr[rs2_addr_id] : 64'b0;

  always @(*) begin
    rs1_data = rs1_data_gpr;
    rs2_data = rs2_data_gpr;
    if (ctrl_reg_write_ex && rd_addr_ex != 5'd0 && rd_addr_ex == rs1_addr_id) begin
      rs1_data = alu_result;
    end
    if (ctrl_reg_write_ex && rd_addr_ex != 5'd0 && rd_addr_ex == rs2_addr_id) begin
      rs2_data = alu_result;
    end
    if (ctrl_reg_write_mem && rd_addr_mem != 5'd0 && rd_addr_mem == rs1_addr_id) begin
      rs1_data = alu_result_mem;
    end
    if (ctrl_reg_write_mem && rd_addr_mem != 5'd0 && rd_addr_mem == rs2_addr_id) begin
      rs2_data = alu_result_mem;
    end
    if (ctrl_reg_write_wb && rd_addr_wb != 5'd0 && rd_addr_wb == rs1_addr_id) begin
      rs1_data = wb_data;
    end
    if (ctrl_reg_write_wb && rd_addr_wb != 5'd0 && rd_addr_wb == rs2_addr_id) begin
      rs2_data = wb_data;
    end
  end

  always @(*) begin
    alu_a = rs1_data;
    alu_b = ctrl_use_imm_id ? imm_i_id : rs2_data;
    alu_result = alu_a + alu_b;
  end

  always @(*) begin
    dmem_addr = 64'b0;
    dmem_wdata = 64'b0;
    dmem_wstrb = 8'h0;
    dmem_read = 1'b0;
    dmem_write = 1'b0;
    if (ctrl_load_ex) begin
      dmem_addr = alu_result;
      dmem_read = 1'b1;
      dmem_wstrb = 8'hFF;
    end else if (ctrl_store_ex) begin
      dmem_addr = alu_result;
      dmem_wdata = rs2_data_ex;
      dmem_write = 1'b1;
      dmem_wstrb = 8'hFF;
    end
  end

  always @(*) begin
    rs1_data_ex = rs1_data;
    rs2_data_ex = rs2_data;
    alu_a_ex = alu_a;
    alu_b_ex = alu_b;
  end

  generate
    if (PERF_CNTRS > 0) begin : gen_perf0
      assign perf_counter0 = perf_counter[0];
    end else begin : gen_perf0_zero
      assign perf_counter0 = 64'b0;
    end

    if (PERF_CNTRS > 1) begin : gen_perf1
      assign perf_counter1 = perf_counter[1];
    end else begin : gen_perf1_zero
      assign perf_counter1 = 64'b0;
    end

    if (PERF_CNTRS > 2) begin : gen_perf2
      assign perf_counter2 = perf_counter[2];
    end else begin : gen_perf2_zero
      assign perf_counter2 = 64'b0;
    end

    if (PERF_CNTRS > 3) begin : gen_perf3
      assign perf_counter3 = perf_counter[3];
    end else begin : gen_perf3_zero
      assign perf_counter3 = 64'b0;
    end

    if (PERF_CNTRS > 4) begin : gen_perf4
      assign perf_counter4 = perf_counter[4];
    end else begin : gen_perf4_zero
      assign perf_counter4 = 64'b0;
    end

    if (PERF_CNTRS > 5) begin : gen_perf5
      assign perf_counter5 = perf_counter[5];
    end else begin : gen_perf5_zero
      assign perf_counter5 = 64'b0;
    end

    if (PERF_CNTRS > 6) begin : gen_perf6
      assign perf_counter6 = perf_counter[6];
    end else begin : gen_perf6_zero
      assign perf_counter6 = 64'b0;
    end

    if (PERF_CNTRS > 7) begin : gen_perf7
      assign perf_counter7 = perf_counter[7];
    end else begin : gen_perf7_zero
      assign perf_counter7 = 64'b0;
    end
  endgenerate
endmodule
