module rv64_ai_xtensor_extension (
  input  clk,
  input  rst_n,
  input  [31:0] instr,
  input  [63:0] rs1,
  input  [63:0] rs2,
  output reg [63:0] rd,
  output reg valid
);

  wire [6:0] opcode;
  assign opcode = instr[6:0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd <= 64'b0;
      valid <= 1'b0;
    end else begin
      rd <= 64'b0;
      valid <= 1'b0;
      if (opcode == 7'b1011011) begin
        rd <= rs1 + rs2;
        valid <= 1'b1;
      end
    end
  end
endmodule
