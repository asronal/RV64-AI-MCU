module rv64_ai_clock_sleep_wakeup (
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
  output sleep_mode,
  output deep_sleep,
  output wake_irq
);

  reg [31:0] ctrl_reg;

  assign sleep_mode = ctrl_reg[0];
  assign deep_sleep = ctrl_reg[1];
  assign wake_irq = ctrl_reg[2];

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n) ctrl_reg <= 32'b0;
    else if (axil_write) ctrl_reg <= axil_wdata;
  end

  assign axil_rdata = ctrl_reg;
  assign axil_valid = axil_write | axil_read;
endmodule
