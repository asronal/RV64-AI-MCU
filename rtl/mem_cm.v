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

  localparam BOOT_ROM_DEPTH = 8192;
  localparam INTERNAL_SRAM_DEPTH = 32768;
  localparam TENSOR_SRAM_DEPTH = 16384;
  localparam OTP_DEPTH = 512;
  localparam I_CACHE_DEPTH = 4096;
  localparam D_CACHE_DEPTH = 4096;

  reg [63:0] boot_rom_rdata, internal_sram_rdata, tensor_sram_rdata;
  reg [63:0] otp_rdata, icache_rdata, dcache_rdata;
  reg boot_rom_valid, internal_sram_valid, tensor_sram_valid;
  reg otp_valid, icache_valid, dcache_valid;
  reg [15:0] boot_rom_index;
  reg [15:0] internal_sram_index;
  reg [15:0] tensor_sram_index;
  reg [9:0] otp_index;
  reg [11:0] icache_index;
  reg [11:0] dcache_index;

  wire [63:0] boot_rom_wdata;
  wire [63:0] internal_sram_wdata;
  wire [63:0] tensor_sram_wdata;
  wire [63:0] otp_wdata;
  wire [63:0] icache_wdata;
  wire [63:0] dcache_wdata;

  wire boot_rom_read = read && (addr < 64'h0001_0000);
  wire internal_sram_read = read && (addr >= 64'h0001_0000) && (addr < 64'h0009_0000);
  wire tensor_sram_read = read && (addr >= 64'h0009_0000) && (addr < 64'h0011_0000);
  wire otp_read = read && (addr >= 64'h0011_0000) && (addr < 64'h0011_1000);
  wire icache_read = read && (addr >= 64'h0011_1000) && (addr < 64'h0012_0000);
  wire dcache_read = read && (addr >= 64'h0012_0000);

  wire boot_rom_write = write && (addr < 64'h0001_0000);
  wire internal_sram_write = write && (addr >= 64'h0001_0000) && (addr < 64'h0009_0000);
  wire tensor_sram_write = write && (addr >= 64'h0009_0000) && (addr < 64'h0011_0000);
  wire otp_write = write && (addr >= 64'h0011_0000) && (addr < 64'h0011_1000);
  wire icache_write = write && (addr >= 64'h0011_1000) && (addr < 64'h0012_0000);
  wire dcache_write = write && (addr >= 64'h0012_0000);

  assign boot_rom_index = addr[15:0] >> 3;
  assign internal_sram_index = addr[20:5];
  assign tensor_sram_index = addr[18:3];
  assign otp_index = addr[9:0] >> 3;
  assign icache_index = addr[15:0] >> 3;
  assign dcache_index = addr[15:0] >> 3;

  rv64_ai_mem_bank #(.DEPTH(BOOT_ROM_DEPTH), .INDEX_WIDTH(16)) u_boot_rom (
    .clk(clk), .rst_n(rst_n), .init(init),
    .index(boot_rom_index),
    .wdata(wdata), .wstrb(wstrb), .read(boot_rom_read), .write(boot_rom_write),
    .rdata(boot_rom_rdata), .valid(boot_rom_valid)
  );

  rv64_ai_mem_bank #(.DEPTH(INTERNAL_SRAM_DEPTH), .INDEX_WIDTH(16)) u_internal_sram (
    .clk(clk), .rst_n(rst_n), .init(init),
    .index(internal_sram_index),
    .wdata(wdata), .wstrb(wstrb), .read(internal_sram_read), .write(internal_sram_write),
    .rdata(internal_sram_rdata), .valid(internal_sram_valid)
  );

  rv64_ai_mem_bank #(.DEPTH(TENSOR_SRAM_DEPTH), .INDEX_WIDTH(16)) u_tensor_sram (
    .clk(clk), .rst_n(rst_n), .init(init),
    .index(tensor_sram_index),
    .wdata(wdata), .wstrb(wstrb), .read(tensor_sram_read), .write(tensor_sram_write),
    .rdata(tensor_sram_rdata), .valid(tensor_sram_valid)
  );

  rv64_ai_mem_bank #(.DEPTH(OTP_DEPTH), .INDEX_WIDTH(10)) u_otp (
    .clk(clk), .rst_n(rst_n), .init(init),
    .index(otp_index),
    .wdata(wdata), .wstrb(wstrb), .read(otp_read), .write(otp_write),
    .rdata(otp_rdata), .valid(otp_valid)
  );

  rv64_ai_mem_bank #(.DEPTH(I_CACHE_DEPTH), .INDEX_WIDTH(12)) u_icache (
    .clk(clk), .rst_n(rst_n), .init(init),
    .index(icache_index),
    .wdata(wdata), .wstrb(wstrb), .read(icache_read), .write(icache_write),
    .rdata(icache_rdata), .valid(icache_valid)
  );

  rv64_ai_mem_bank #(.DEPTH(D_CACHE_DEPTH), .INDEX_WIDTH(12)) u_dcache (
    .clk(clk), .rst_n(rst_n), .init(init),
    .index(dcache_index),
    .wdata(wdata), .wstrb(wstrb), .read(dcache_read), .write(dcache_write),
    .rdata(dcache_rdata), .valid(dcache_valid)
  );

  always @(*) begin
    if (boot_rom_read) begin
      rdata = boot_rom_rdata;
      valid = boot_rom_valid;
    end else if (internal_sram_read) begin
      rdata = internal_sram_rdata;
      valid = internal_sram_valid;
    end else if (tensor_sram_read) begin
      rdata = tensor_sram_rdata;
      valid = tensor_sram_valid;
    end else if (otp_read) begin
      rdata = otp_rdata;
      valid = otp_valid;
    end else if (icache_read) begin
      rdata = icache_rdata;
      valid = icache_valid;
    end else if (dcache_read) begin
      rdata = dcache_rdata;
      valid = dcache_valid;
    end else begin
      rdata = 64'b0;
      valid = 1'b0;
    end
  end
endmodule
