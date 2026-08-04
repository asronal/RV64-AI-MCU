`timescale 1ns/1ps

module rv64_ai_control_unit (
  input  wire [31:0] instr,
  output reg         ctrl_valid,
  output reg         ctrl_branch,
  output reg         ctrl_jump,
  output reg         ctrl_load,
  output reg         ctrl_store,
  output reg         ctrl_reg_write,
  output reg         ctrl_mem_read,
  output reg         ctrl_mem_write,
  output reg         ctrl_mem_to_reg,
  output reg         ctrl_unsigned_load,
  output reg         ctrl_csr_access,
  output reg         ctrl_is_mret,
  output reg         ctrl_use_imm,
  output reg         ctrl_use_pc,
  output reg [4:0]   rs1_addr,
  output reg [4:0]   rs2_addr,
  output reg [4:0]   rd_addr,
  output reg [63:0]  imm_i,
  output reg [63:0]  imm_s,
  output reg [63:0]  imm_b,
  output reg [63:0]  imm_u,
  output reg [63:0]  imm_j,
  output reg [1:0]   op_type
);

  wire [6:0] opcode = instr[6:0];
  wire [2:0] funct3 = instr[14:12];

  always @(*) begin
    ctrl_valid         = 1'b0;
    ctrl_branch        = 1'b0;
    ctrl_jump          = 1'b0;
    ctrl_load          = 1'b0;
    ctrl_store         = 1'b0;
    ctrl_reg_write     = 1'b0;
    ctrl_mem_read      = 1'b0;
    ctrl_mem_write     = 1'b0;
    ctrl_mem_to_reg    = 1'b0;
    ctrl_unsigned_load = 1'b0;
    ctrl_csr_access    = 1'b0;
    ctrl_is_mret       = 1'b0;
    ctrl_use_imm       = 1'b0;
    ctrl_use_pc        = 1'b0;
    rs1_addr           = instr[19:15];
    rs2_addr           = instr[24:20];
    rd_addr            = instr[11:7];
    op_type            = 2'b00;
    imm_i              = 64'b0;
    imm_s              = 64'b0;
    imm_b              = 64'b0;
    imm_u              = 64'b0;
    imm_j              = 64'b0;

    case (opcode)
      7'b0110111: begin // LUI
        ctrl_valid     = 1'b1;
        ctrl_reg_write = 1'b1;
        ctrl_use_imm   = 1'b1;
        imm_u          = {32'b0, instr[31:12], 12'b0};
        op_type        = 2'b01;
      end
      7'b0010111: begin // AUIPC
        ctrl_valid     = 1'b1;
        ctrl_reg_write = 1'b1;
        ctrl_use_imm   = 1'b1;
        ctrl_use_pc    = 1'b1;
        imm_u          = {32'b0, instr[31:12], 12'b0};
        op_type        = 2'b01;
      end
      7'b1101111: begin // JAL
        ctrl_valid     = 1'b1;
        ctrl_reg_write = 1'b1;
        ctrl_jump      = 1'b1;
        ctrl_branch    = 1'b1;
        imm_j          = {{44{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        op_type        = 2'b10;
      end
      7'b1100111: begin // JALR
        ctrl_valid     = 1'b1;
        ctrl_reg_write = 1'b1;
        ctrl_jump      = 1'b1;
        imm_i          = {{52{instr[31]}}, instr[31:20]};
        op_type        = 2'b10;
      end
      7'b1100011: begin // BRANCH
        ctrl_valid     = 1'b1;
        ctrl_branch    = 1'b1;
        imm_b          = {{52{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        op_type        = 2'b11;
      end
      7'b0000011: begin // LOAD
        ctrl_valid         = 1'b1;
        ctrl_reg_write     = 1'b1;
        ctrl_load          = 1'b1;
        ctrl_mem_read      = 1'b1;
        ctrl_mem_to_reg    = 1'b1;
        ctrl_unsigned_load = (funct3 == 3'b100 || funct3 == 3'b101 || funct3 == 3'b110 || funct3 == 3'b111);
        imm_i              = {{52{instr[31]}}, instr[31:20]};
        op_type            = 2'b01;
      end
      7'b0100011: begin // STORE
        ctrl_valid     = 1'b1;
        ctrl_store     = 1'b1;
        ctrl_mem_write = 1'b1;
        imm_s          = {{52{instr[31]}}, instr[31:25], instr[11:7]};
        op_type        = 2'b01;
      end
      7'b0010011: begin // OP-IMM
        ctrl_valid     = 1'b1;
        ctrl_reg_write = 1'b1;
        ctrl_use_imm   = 1'b1;
        imm_i          = {{52{instr[31]}}, instr[31:20]};
        op_type        = 2'b01;
      end
      7'b0110011: begin // OP
        ctrl_valid     = 1'b1;
        ctrl_reg_write = 1'b1;
        op_type        = 2'b01;
      end
      7'b1110011: begin // SYSTEM/CSR
        ctrl_valid     = 1'b1;
        ctrl_csr_access = 1'b1;
        ctrl_is_mret   = (instr[31:20] == 12'h302);
        op_type        = 2'b01;
      end
      default: begin
        ctrl_valid = 1'b0;
      end
    endcase
  end
endmodule
