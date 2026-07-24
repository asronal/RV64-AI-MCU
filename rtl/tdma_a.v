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

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      done <= 1'b0;
      src_ptr <= 32'b0;
      dst_ptr <= 32'b0;
    end else if (start) begin
      src_ptr <= src_addr;
      dst_ptr <= dst_addr;
      done <= 1'b1;
    end else begin
      done <= 1'b0;
    end
  end
endmodule
