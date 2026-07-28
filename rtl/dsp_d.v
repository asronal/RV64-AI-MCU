module rv64_ai_dsp_top (
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

  wire [127:0] simd_vec_a, simd_vec_b, simd_vec_out;
  wire [255:0] mac_acc_out;
  wire simd_done, mac_done;
  wire [31:0] mac_acc_lo;
  wire simd_done_valid;
  wire mac_done_valid;

  rv64_ai_simd_engine u_simd (
    .clk(clk),
    .rst_n(rst_n),
    .vec_a(simd_vec_a),
    .vec_b(simd_vec_b),
    .op(4'd0),
    .width(2'd0),
    .valid(1'b1),
    .vec_out(simd_vec_out),
    .done(simd_done)
  );

  rv64_ai_mac_engine u_mac (
    .clk(clk),
    .rst_n(rst_n),
    .data_a(simd_vec_a),
    .data_b(simd_vec_b),
    .mode(2'd0),
    .valid(1'b1),
    .acc_out(mac_acc_out),
    .done(mac_done)
  );

  assign simd_done_valid = 1'b0;
  assign mac_done_valid  = 1'b0;
  assign mac_acc_lo      = 32'b0;

  assign axil_rdata = {simd_done_valid, mac_done_valid, mac_acc_lo};
  assign axil_valid = axil_read | axil_write;
endmodule
