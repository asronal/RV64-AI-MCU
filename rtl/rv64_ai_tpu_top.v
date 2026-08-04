`timescale 1ns/1ps

module rv64_ai_tpu_top (
  input  clk,
  input  rst_n,
  input  init,
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
  wire systolic_done;
  wire dma_done;
  wire [31:0] src_ptr;
  wire [31:0] dst_ptr;
  wire [31:0] acc_lo;
  wire sys_done_valid;

  rv64_ai_tpu_systolic_array u_systolic (
    .clk(clk),
    .rst_n(rst_n),
    .init(init),
    .wdata(wdata),
    .idata(idata),
    .valid(1'b1),
    .acc_out(acc_out),
    .done(systolic_done)
  );

  rv64_ai_tpu_dma u_dma (
    .clk(clk),
    .rst_n(rst_n),
    .init(init),
    .src_addr(axil_addr),
    .dst_addr(axil_addr + 32'd4),
    .length(16'd16),
    .start(axil_write),
    .done(dma_done),
    .src_ptr(src_ptr),
    .dst_ptr(dst_ptr)
  );

  assign sys_done_valid = systolic_done | dma_done;
  assign acc_lo         = 32'b0;

  assign axil_rdata = {acc_lo[31:1], sys_done_valid};
  assign axil_valid = axil_write | axil_read;
endmodule
