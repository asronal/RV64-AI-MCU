module rv64_ai_tpu_top (
  input  clk,
  input  rst_n,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid
);

  wire [255:0] wdata;
  wire [255:0] idata;
  wire [511:0] acc_out;
  wire sys_done;

  rv64_ai_tpu_systolic_array u_systolic (
    .clk(clk),
    .rst_n(rst_n),
    .wdata(wdata),
    .idata(idata),
    .valid(1'b1),
    .acc_out(acc_out),
    .done(sys_done)
  );

  rv64_ai_tpu_dma u_dma (
    .clk(clk),
    .rst_n(rst_n),
    .src_addr(axil_addr),
    .dst_addr(axil_addr + 32'd4),
    .length(16'd16),
    .start(axil_write),
    .done(sys_done),
    .src_ptr(),
    .dst_ptr()
  );

  assign axil_rdata = {sys_done, acc_out[31:0]};
  assign axil_valid = axil_write | axil_read;
endmodule
