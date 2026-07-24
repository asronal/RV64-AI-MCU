module rv64_ai_pmp (
  input  clk,
  input  rst_n,
  input  init,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid,
  output [31:0] pmp_cfg
);

  reg [31:0] pmp_cfg_reg;

  assign pmp_cfg = pmp_cfg_reg;

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n) pmp_cfg_reg <= 32'b0;
    else if (axil_write) pmp_cfg_reg <= axil_wdata;
  end

  assign axil_rdata = pmp_cfg_reg;
  assign axil_valid = axil_write | axil_read;
endmodule
