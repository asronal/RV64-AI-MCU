module rv64_ai_control_unit (
  input  [31:0] instr,
  output reg [31:0] ctrl_valid,
  output reg [31:0] ctrl_branch,
  output reg [31:0] ctrl_jump,
  output reg [31:0] ctrl_load,
  output reg [31:0] ctrl_store,
  output reg [31:0] ctrl_reg_write,
  output reg [31:0] ctrl_mem_read,
  output reg [31:0] ctrl_mem_write,
  output reg [31:0] ctrl_mem_to_reg,
  output reg [31:0] ctrl_unsigned_load,
  output reg [31:0] ctrl_csr_access,
  output reg [31:0] ctrl_is_mret,
  output reg [31:0] ctrl_use_imm,
  output reg [31:0] ctrl_use_pc,
  output [4:0]  rs1_addr,
  output [4:0]  rs2_addr,
  output [4:0]  rd_addr,
  output reg [63:0] imm_i,
  output reg [63:0] imm_s,
  output reg [63:0] imm_b,
  output reg [63:0] imm_u,
  output reg [63:0] imm_j,
  output reg [1:0]  op_type
);

  wire [6:0] opcode;
  wire [2:0] funct3;
  wire [6:0] funct7;

  assign opcode = instr[6:0];
  assign funct3 = instr[14:12];
  assign funct7 = instr[31:25];
  assign rs1_addr = instr[19:15];
  assign rs2_addr = instr[24:20];
  assign rd_addr  = instr[11:7];

  always @* begin
    ctrl_valid         = 32'b0;
    ctrl_branch        = 32'b0;
    ctrl_jump          = 32'b0;
    ctrl_load          = 32'b0;
    ctrl_store         = 32'b0;
    ctrl_reg_write     = 32'b0;
    ctrl_mem_read      = 32'b0;
    ctrl_mem_write     = 32'b0;
    ctrl_mem_to_reg    = 32'b0;
    ctrl_unsigned_load = 32'b0;
    ctrl_csr_access    = 32'b0;
    ctrl_is_mret       = 32'b0;
    ctrl_use_imm       = 32'b0;
    ctrl_use_pc        = 32'b0;
    op_type            = 2'b00;
    imm_i              = 64'b0;
    imm_s              = 64'b0;
    imm_b              = 64'b0;
    imm_u              = 64'b0;
    imm_j              = 64'b0;

    case (opcode)
      7'b0110111: begin // LUI
        ctrl_valid = 32'b1;
        ctrl_reg_write = 32'b1;
        ctrl_use_imm = 32'b1;
        imm_u = {instr[31:12], 12'b0};
        op_type = 2'b01;
      end
      7'b0010111: begin // AUIPC
        ctrl_valid = 32'b1;
        ctrl_reg_write = 32'b1;
        ctrl_use_imm = 32'b1;
        ctrl_use_pc = 32'b1;
        imm_u = {instr[31:12], 12'b0};
        op_type = 2'b01;
      end
      7'b1101111: begin // JAL
        ctrl_valid = 32'b1;
        ctrl_reg_write = 32'b1;
        ctrl_jump = 32'b1;
        ctrl_branch = 32'b1;
        imm_j = {{43{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        op_type = 2'b10;
      end
      7'b1100111: begin // JALR
        ctrl_valid = 32'b1;
        ctrl_reg_write = 32'b1;
        ctrl_jump = 32'b1;
        imm_i = {{56{instr[31]}}, instr[31:20]};
        op_type = 2'b10;
      end
      7'b1100011: begin // BRANCH
        ctrl_valid = 32'b1;
        ctrl_branch = 32'b1;
        imm_b = {{51{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        op_type = 2'b11;
      end
      7'b0000011: begin // LOAD
        ctrl_valid = 32'b1;
        ctrl_reg_write = 32'b1;
        ctrl_load = 32'b1;
        ctrl_mem_read = 32'b1;
        ctrl_mem_to_reg = 32'b1;
        ctrl_unsigned_load = (funct3 == 3'b100 || funct3 == 3'b101 || funct3 == 3'b110 || funct3 == 3'b111) ? 32'b1 : 32'b0;
        imm_i = {{56{instr[31]}}, instr[31:20]};
        op_type = 2'b01;
      end
      7'b0100011: begin // STORE
        ctrl_valid = 32'b1;
        ctrl_store = 32'b1;
        ctrl_mem_write = 32'b1;
        imm_s = {{56{instr[31]}}, instr[31:25], instr[11:7]};
        op_type = 2'b01;
      end
      7'b0010011: begin // OP-IMM
        ctrl_valid = 32'b1;
        ctrl_reg_write = 32'b1;
        ctrl_use_imm = 32'b1;
        imm_i = {{56{instr[31]}}, instr[31:20]};
        op_type = 2'b01;
      end
      7'b0110011: begin // OP
        ctrl_valid = 32'b1;
        ctrl_reg_write = 32'b1;
        op_type = 2'b01;
      end
      7'b0001111: begin // FENCE
        ctrl_valid = 32'b1;
      end
      7'b1110011: begin // SYSTEM/CSR
        ctrl_valid = 32'b1;
        ctrl_csr_access = 32'b1;
        ctrl_is_mret = (instr[31:20] == 12'h302) ? 32'b1 : 32'b0;
        op_type = 2'b01;
      end
      default: begin
        ctrl_valid = 32'b0;
      end
    endcase
  end
endmodule
