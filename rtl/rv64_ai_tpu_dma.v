`timescale 1ns/1ps

module rv64_ai_tpu_dma (
  input  clk,
  input  rst_n,
  input  init,
  input  [31:0] src_addr,
  input  [31:0] dst_addr,
  input  [15:0] length,
  input  start,
  output reg done,
  output reg [31:0] src_ptr,
  output reg [31:0] dst_ptr
);

  reg [15:0] xfer_len;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      done    <= 1'b0;
      src_ptr <= 32'b0;
      dst_ptr <= 32'b0;
      xfer_len <= 16'b0;
    end else if (init) begin
      done    <= 1'b0;
      src_ptr <= 32'b0;
      dst_ptr <= 32'b0;
      xfer_len <= 16'b0;
    end else if (start) begin
      xfer_len <= length;
      src_ptr <= src_addr;
      dst_ptr <= dst_addr;
      done    <= (length != 16'b0);
    end else begin
      done <= 1'b0;
    end
  end
endmodule
