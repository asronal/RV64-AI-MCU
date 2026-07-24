module rv64_ai_crypto_engine (
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
  output [31:0] crypto_status
);

  reg [31:0] aes128_reg;
  reg [31:0] aes256_reg;
  reg [31:0] sha256_reg;
  reg [31:0] sha512_reg;
  reg [31:0] crc32_reg;

  assign crypto_status = {aes128_reg[0], aes256_reg[0], sha256_reg[0], sha512_reg[0], crc32_reg[0], 27'b0};

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      aes128_reg <= 32'b0;
      aes256_reg <= 32'b0;
      sha256_reg <= 32'b0;
      sha512_reg <= 32'b0;
      crc32_reg  <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: aes128_reg <= axil_wdata;
        8'h04: aes256_reg <= axil_wdata;
        8'h08: sha256_reg <= axil_wdata;
        8'h0C: sha512_reg <= axil_wdata;
        8'h10: crc32_reg  <= axil_wdata;
      endcase
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? aes128_reg :
                      (axil_addr[7:0] == 8'h04) ? aes256_reg :
                      (axil_addr[7:0] == 8'h08) ? sha256_reg :
                      (axil_addr[7:0] == 8'h0C) ? sha512_reg :
                      (axil_addr[7:0] == 8'h10) ? crc32_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
