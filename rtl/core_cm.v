module rv64_ai_core (
  input  clk,
  input  rst_n,
  input  [63:0] imem_rdata,
  input  imem_valid,
  input  [63:0] dmem_rdata,
  input  dmem_valid,
  output reg [63:0] imem_addr,
  output reg [63:0] dmem_addr,
  output reg [63:0] dmem_wdata,
  output reg [7:0]  dmem_wstrb,
  output reg        dmem_read,
  output reg        dmem_write,
  output [63:0] perf_counter0,
  output [63:0] perf_counter1,
  output [63:0] perf_counter2,
  output [63:0] perf_counter3,
  output [63:0] perf_counter4,
  output [63:0] perf_counter5,
  output [63:0] perf_counter6,
  output [63:0] perf_counter7
);

  parameter GPR_DEPTH = 32;
  parameter BTB_DEPTH = 128;
  parameter RAS_DEPTH = 16;
  parameter PERF_CNTRS = 8;

  integer i;

  reg [63:0] pc_if, pc_id, pc_ex, pc_mem, pc_wb;
  reg [31:0] instr_if, instr_id, instr_ex, instr_mem, instr_wb;
  reg [63:0] gpr [0:GPR_DEPTH-1];
  reg [63:0] csr_mstatus, csr_mie, csr_mip, csr_mcause, csr_mepc, csr_mtvec;
  reg [63:0] pc_next_if;
  reg        stall_if, stall_id, stall_ex, stall_mem, stall_wb;
  reg        flush_id, flush_ex, flush_mem;
  reg        branch_taken, branch_predict_taken;
  reg [63:0] branch_target;
  reg [63:0] ras_stack [0:RAS_DEPTH-1];
  reg [4:0]  ras_ptr;
  reg [63:0] btb_target [0:BTB_DEPTH-1];
  reg [63:0] btb_tag [0:BTB_DEPTH-1];
  reg [1:0]  btb_state [0:BTB_DEPTH-1];
  reg [63:0] alu_result, alu_a, alu_b;
  reg [63:0] rs1_data, rs2_data;
  wire [63:0] imm_i, imm_s, imm_b, imm_u, imm_j;
  wire [4:0]  rs1_addr, rs2_addr, rd_addr;
  wire [31:0] ctrl_valid, ctrl_branch, ctrl_jump, ctrl_load, ctrl_store;
  wire [31:0] ctrl_reg_write, ctrl_mem_read, ctrl_mem_write, ctrl_mem_to_reg;
  wire [31:0] ctrl_unsigned_load, ctrl_csr_access, ctrl_is_mret, ctrl_use_imm, ctrl_use_pc;
  wire [1:0]  op_type;
  reg [63:0] perf_counter [0:PERF_CNTRS-1];

  initial begin
    if (PERF_CNTRS > 0) perf_counter[0] = 64'b0;
    if (PERF_CNTRS > 1) perf_counter[1] = 64'b0;
    if (PERF_CNTRS > 2) perf_counter[2] = 64'b0;
    if (PERF_CNTRS > 3) perf_counter[3] = 64'b0;
    if (PERF_CNTRS > 4) perf_counter[4] = 64'b0;
    if (PERF_CNTRS > 5) perf_counter[5] = 64'b0;
    if (PERF_CNTRS > 6) perf_counter[6] = 64'b0;
    if (PERF_CNTRS > 7) perf_counter[7] = 64'b0;
    pc_if = 64'h0;
    pc_id = 64'h0;
    pc_ex = 64'h0;
    pc_mem = 64'h0;
    pc_wb = 64'h0;
    ras_ptr = 5'b0;
  end

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

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc_if <= 64'h0;
      pc_id <= 64'h0;
      pc_ex <= 64'h0;
      pc_mem <= 64'h0;
      pc_wb <= 64'h0;
      instr_id <= 32'h0;
      instr_ex <= 32'h0;
      instr_mem <= 32'h0;
      instr_wb <= 32'h0;
    end else begin
      perf_counter[0] <= perf_counter[0] + 1;
      if (!stall_if) pc_if <= pc_next_if;
      if (!stall_id) begin
        pc_id <= pc_if;
        instr_id <= instr_if;
      end
      if (!stall_ex) begin
        pc_ex <= pc_id;
        instr_ex <= instr_id;
      end
      if (!stall_mem) begin
        pc_mem <= pc_ex;
        instr_mem <= instr_ex;
      end
      if (!stall_wb) begin
        pc_wb <= pc_mem;
        instr_wb <= instr_mem;
      end
    end
  end

  always @* begin
    pc_next_if = pc_if + 64'd4;
    imem_addr = pc_if;
    if (branch_taken) begin
      pc_next_if = branch_target;
    end
  end

  always @* begin
    rs1_data = gpr[rs1_addr];
    rs2_data = gpr[rs2_addr];
    if (ctrl_reg_write && (rd_addr == rs1_addr) && rs1_addr != 0) rs1_data = alu_result;
    if (ctrl_mem_to_reg && (rd_addr == rs2_addr) && rs2_addr != 0) rs2_data = alu_result;
  end

  always @* begin
    alu_a = rs1_data;
    alu_b = ctrl_use_imm ? imm_i : rs2_data;
    case (ctrl_valid)
      1'b0: alu_result = 64'b0;
      default: begin
        alu_result = alu_a + alu_b;
      end
    endcase
  end

  always @* begin
    branch_predict_taken = 1'b0;
    if (ctrl_branch) begin
      branch_predict_taken = 1'b1;
    end
  end

  always @* begin
    branch_taken = 1'b0;
    branch_target = 64'b0;
    if (ctrl_branch && (rs1_data == rs2_data)) begin
      branch_taken = 1'b1;
      branch_target = pc_ex + imm_b;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < GPR_DEPTH; i = i + 1) gpr[i] <= 64'b0;
      for (i = 0; i < BTB_DEPTH; i = i + 1) begin
        btb_target[i] <= 64'b0;
        btb_tag[i] <= 64'b0;
        btb_state[i] <= 2'b01;
      end
    end else begin
      if (ctrl_reg_write && rd_addr != 0) begin
        gpr[rd_addr] <= alu_result;
      end
      if (ctrl_branch && branch_taken) begin
        btb_state[pc_ex[8:1] % BTB_DEPTH] <= 2'b11;
        btb_target[pc_ex[8:1] % BTB_DEPTH] <= branch_target;
      end
    end
  end

  always @* begin
    dmem_addr = pc_ex + imm_s;
    dmem_wdata = rs2_data;
    dmem_read = ctrl_load;
    dmem_write = ctrl_store;
    dmem_wstrb = 8'hFF;
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
