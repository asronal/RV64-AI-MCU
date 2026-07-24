module rv64_ai_security_block (
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
  output secure_boot_ok,
  output otp_ready,
  output trng_ready
);

  reg [31:0] sec_reg;
  reg [31:0] otp_reg;
  reg [31:0] trng_reg;

  assign secure_boot_ok = sec_reg[0];
  assign otp_ready = otp_reg[0];
  assign trng_ready = trng_reg[0];

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      sec_reg <= 32'b0;
      otp_reg <= 32'b0;
      trng_reg <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: sec_reg <= axil_wdata;
        8'h04: otp_reg <= axil_wdata;
        8'h08: trng_reg <= axil_wdata;
      endcase
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? sec_reg :
                      (axil_addr[7:0] == 8'h04) ? otp_reg :
                      (axil_addr[7:0] == 8'h08) ? trng_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
