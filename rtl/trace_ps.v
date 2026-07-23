module rv64_ai_trace_buffer (
  input  clk,
  input  rst_n,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid,
  output [31:0] trace_word
);

  reg [31:0] trace_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) trace_reg <= 32'b0;
    else if (axil_write) trace_reg <= axil_wdata;
  end

  assign trace_word = trace_reg;
  assign axil_rdata = trace_reg;
  assign axil_valid = axil_write | axil_read;
endmodule
