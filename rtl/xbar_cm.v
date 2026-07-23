module rv64_ai_axi4lite_crossbar (
  input  clk,
  input  rst_n,
  input  [31:0] cpu_awaddr,
  input  [2:0]  cpu_awprot,
  input  cpu_awvalid,
  output reg cpu_awready,
  input  [63:0] cpu_wdata,
  input  [7:0]  cpu_wstrb,
  input  cpu_wvalid,
  output reg cpu_wready,
  output reg [1:0] cpu_bresp,
  output reg cpu_bvalid,
  input  cpu_bready,
  input  [31:0] cpu_araddr,
  input  [2:0]  cpu_arprot,
  input  cpu_arvalid,
  output reg cpu_arready,
  output reg [63:0] cpu_rdata,
  output reg [1:0]  cpu_rresp,
  output reg cpu_rvalid,
  input  cpu_rready,
  output reg [63:0] rom_rdata,
  output reg [63:0] sram_rdata,
  output reg [63:0] tpu_rdata,
  output reg [63:0] dma_rdata
);

  wire [31:0] dec_awaddr;
  wire [31:0] dec_araddr;

  assign dec_awaddr = cpu_awaddr;
  assign dec_araddr = cpu_araddr;

  always @* begin
    cpu_awready = 1'b1;
    cpu_wready  = 1'b1;
    cpu_bresp   = 2'b00;
    cpu_bvalid  = cpu_awvalid && cpu_wvalid;
    cpu_arready = 1'b1;
    cpu_rresp   = 2'b00;
    cpu_rvalid  = cpu_arvalid;
    cpu_rdata   = 64'b0;
    rom_rdata   = 64'b0;
    sram_rdata  = 64'b0;
    tpu_rdata   = 64'b0;
    dma_rdata   = 64'b0;

    if (dec_araddr[31:16] == 16'h0000) begin
      cpu_rdata = rom_rdata;
    end else if (dec_araddr[31:20] == 12'h001) begin
      cpu_rdata = sram_rdata;
    end else if (dec_araddr[31:20] == 12'h002) begin
      cpu_rdata = tpu_rdata;
    end else if (dec_araddr[31:20] == 12'h003) begin
      cpu_rdata = dma_rdata;
    end
  end
endmodule
