module rv64_ai_qspi_psram_dma (
  input  clk,
  input  rst_n,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid,
  output qspi_cs,
  output psram_cs,
  output dma_irq
);

  reg [31:0] qspi_reg;
  reg [31:0] psram_reg;
  reg [31:0] dma_reg;

  assign qspi_cs = qspi_reg[0];
  assign psram_cs = psram_reg[0];
  assign dma_irq = dma_reg[0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      qspi_reg <= 32'b0;
      psram_reg <= 32'b0;
      dma_reg <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: qspi_reg <= axil_wdata;
        8'h04: psram_reg <= axil_wdata;
        8'h08: dma_reg <= axil_wdata;
      endcase
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? qspi_reg :
                      (axil_addr[7:0] == 8'h04) ? psram_reg :
                      (axil_addr[7:0] == 8'h08) ? dma_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
