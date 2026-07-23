module rv64_ai_breakpoint_unit (
  input  clk,
  input  rst_n,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid,
  output hw_breakpoint,
  output watchpoint
);

  reg [31:0] bp_reg;

  assign hw_breakpoint = bp_reg[0];
  assign watchpoint = bp_reg[1];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) bp_reg <= 32'b0;
    else if (axil_write) bp_reg <= axil_wdata;
  end

  assign axil_rdata = bp_reg;
  assign axil_valid = axil_write | axil_read;
endmodule
