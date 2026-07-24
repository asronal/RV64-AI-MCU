module rv64_ai_tpu_systolic_array (
  input  clk,
  input  rst_n,
  input  init,
  input  [255:0] wdata,
  input  [255:0] idata,
  input  valid,
  output [511:0] acc_out,
  output done
);

  reg [15:0] mac_acc [0:15][0:15];
  integer i, j;

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
          mac_acc[i][j] <= 16'b0;
        end
      end
    end else if (valid) begin
      for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
          mac_acc[i][j] <= mac_acc[i][j] + idata[(i*16)+:16] * wdata[(j*16)+:16];
        end
      end
    end
  end

  assign acc_out = {mac_acc[0][0], mac_acc[0][1], mac_acc[0][2], mac_acc[0][3],
                    mac_acc[0][4], mac_acc[0][5], mac_acc[0][6], mac_acc[0][7],
                    mac_acc[0][8], mac_acc[0][9], mac_acc[0][10], mac_acc[0][11],
                    mac_acc[0][12], mac_acc[0][13], mac_acc[0][14], mac_acc[0][15],
                    mac_acc[1][0], mac_acc[1][1], mac_acc[1][2], mac_acc[1][3],
                    mac_acc[1][4], mac_acc[1][5], mac_acc[1][6], mac_acc[1][7],
                    mac_acc[1][8], mac_acc[1][9], mac_acc[1][10], mac_acc[1][11],
                    mac_acc[1][12], mac_acc[1][13], mac_acc[1][14], mac_acc[1][15]};
  assign done = valid;
endmodule
