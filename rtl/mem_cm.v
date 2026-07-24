module rv64_ai_memory_subsystem (
  input  clk,
  input  rst_n,
  input  init,
  input  [63:0] addr,
  input  [63:0] wdata,
  input  [7:0]  wstrb,
  input  read,
  input  write,
  output reg [63:0] rdata,
  output reg valid
);

  localparam BOOT_ROM_SIZE = 64*1024;
  localparam INTERNAL_SRAM_SIZE = 512*1024;
  localparam TENSOR_SRAM_SIZE = 256*1024;
  localparam OTP_SIZE = 4*1024;
  localparam I_CACHE_SIZE = 32*1024;
  localparam D_CACHE_SIZE = 32*1024;

  reg [63:0] boot_rom [0:BOOT_ROM_SIZE/8-1];
  reg [63:0] internal_sram [0:INTERNAL_SRAM_SIZE/8-1];
  reg [63:0] tensor_sram [0:TENSOR_SRAM_SIZE/8-1];
  reg [63:0] otp [0:OTP_SIZE/8-1];
  reg [63:0] icache [0:I_CACHE_SIZE/8-1];
  reg [63:0] dcache [0:D_CACHE_SIZE/8-1];
  integer i;

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      valid <= 1'b0;
      rdata <= 64'b0;
      for (i = 0; i < BOOT_ROM_SIZE/8; i = i + 1) boot_rom[i] <= 64'b0;
      for (i = 0; i < INTERNAL_SRAM_SIZE/8; i = i + 1) internal_sram[i] <= 64'b0;
      for (i = 0; i < TENSOR_SRAM_SIZE/8; i = i + 1) tensor_sram[i] <= 64'b0;
      for (i = 0; i < OTP_SIZE/8; i = i + 1) otp[i] <= 64'b0;
      for (i = 0; i < I_CACHE_SIZE/8; i = i + 1) icache[i] <= 64'b0;
      for (i = 0; i < D_CACHE_SIZE/8; i = i + 1) dcache[i] <= 64'b0;
    end else begin
      valid <= read | write;
      if (read) begin
        if (addr < 64'h0001_0000) begin
          rdata <= boot_rom[addr[15:3]];
        end else if (addr < 64'h0009_0000) begin
          rdata <= internal_sram[addr[20:3]];
        end else if (addr < 64'h0011_0000) begin
          rdata <= tensor_sram[addr[18:3]];
        end else if (addr < 64'h0011_1000) begin
          rdata <= otp[addr[9:3]];
        end else if (addr < 64'h0012_0000) begin
          rdata <= icache[addr[15:3]];
        end else begin
          rdata <= dcache[addr[15:3]];
        end
      end
      if (write) begin
        if (addr < 64'h0009_0000) internal_sram[addr[20:3]] <= wdata;
        else if (addr < 64'h0011_0000) tensor_sram[addr[18:3]] <= wdata;
        else if (addr < 64'h0012_0000) icache[addr[15:3]] <= wdata;
        else dcache[addr[15:3]] <= wdata;
      end
    end
  end
endmodule
