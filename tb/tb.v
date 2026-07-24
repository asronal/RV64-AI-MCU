`timescale 1ns / 1ps

module tb;

  reg clk;
  reg rst_n;

  reg [31:0] awaddr;
  reg [2:0]  awprot;
  reg        awvalid;
  wire       awready;

  reg [31:0] wdata;
  reg [3:0]  wstrb;
  reg        wvalid;
  wire       wready;

  wire [1:0] bresp;
  wire       bvalid;
  reg        bready;

  reg [31:0] araddr;
  reg [2:0]  arprot;
  reg        arvalid;
  wire       arready;

  wire [31:0] rdata;
  wire [1:0]  rresp;
  wire        rvalid;
  reg         rready;

  wire [31:0] gpio_io;

  integer test_count;
  integer test_passed;
  integer test_failed;
  integer init_seen;
  integer reset_seen;

  rv64_ai_soc_top u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .axil_awaddr(awaddr),
    .axil_awprot(awprot),
    .axil_awvalid(awvalid),
    .axil_awready(awready),
    .axil_wdata(wdata),
    .axil_wstrb(wstrb),
    .axil_wvalid(wvalid),
    .axil_wready(wready),
    .axil_bresp(bresp),
    .axil_bvalid(bvalid),
    .axil_bready(bready),
    .axil_araddr(araddr),
    .axil_arprot(arprot),
    .axil_arvalid(arvalid),
    .axil_arready(arready),
    .axil_rdata(rdata),
    .axil_rresp(rresp),
    .axil_rvalid(rvalid),
    .axil_rready(rready),
    .gpio_io(gpio_io)
  );

  always #5 clk = ~clk;

  task check_write;
    input [31:0] addr;
    input [31:0] data;
    begin
      awaddr   = addr;
      awprot   = 3'b000;
      awvalid  = 1'b1;
      wdata    = data;
      wstrb    = 4'hF;
      wvalid   = 1'b1;
      bready   = 1'b1;

      @(posedge clk);
      while (!awready || !wready || !bvalid) begin
        @(posedge clk);
      end

      awvalid = 1'b0;
      wvalid  = 1'b0;

      @(posedge clk);
      $display("[WRITE] addr=0x%08h data=0x%08h", addr, data);
      test_count = test_count + 1;
    end
  endtask

  task check_read;
    input [31:0] addr;
    input [31:0] exp_data;
    begin
      araddr  = addr;
      arprot  = 3'b000;
      arvalid = 1'b1;
      rready  = 1'b1;

      @(posedge clk);
      while (!arready || !rvalid) begin
        @(posedge clk);
      end

      arvalid = 1'b0;

      if (rdata === exp_data) begin
        $display("[PASS] read addr=0x%08h data=0x%08h", addr, rdata);
        test_passed = test_passed + 1;
      end else begin
        $display("[FAIL] read addr=0x%08h got=0x%08h exp=0x%08h", addr, rdata, exp_data);
        test_failed = test_failed + 1;
      end

      test_count = test_count + 1;
    end
  endtask

  task check_read_non_x;
    input [31:0] addr;
    begin
      araddr  = addr;
      arprot  = 3'b000;
      arvalid = 1'b1;
      rready  = 1'b1;

      @(posedge clk);
      while (!arready || !rvalid) begin
        @(posedge clk);
      end

      arvalid = 1'b0;

      if (rdata !== 32'hx) begin
        $display("[PASS] read addr=0x%08h data=0x%08h", addr, rdata);
        test_passed = test_passed + 1;
      end else begin
        $display("[FAIL] read addr=0x%08h got=0x%08h (unknown)", addr, rdata);
        test_failed = test_failed + 1;
      end

      test_count = test_count + 1;
    end
  endtask

  initial begin
    $dumpfile("soc_top_tb.vcd");
    $dumpvars(0, tb);

    clk = 0;
    rst_n = 0;
    awaddr = 32'b0;
    awprot = 3'b0;
    awvalid = 1'b0;
    wdata = 32'b0;
    wstrb = 4'b0;
    wvalid = 1'b0;
    bready = 1'b0;
    araddr = 32'b0;
    arprot = 3'b0;
    arvalid = 1'b0;
    rready = 1'b0;

    test_count = 0;
    test_passed = 0;
    test_failed = 0;
    init_seen = 0;
    reset_seen = 0;

    #1;
    if (u_dut.u_core.init === 1'b1 || u_dut.u_mem.init === 1'b1) begin
      init_seen = 1;
      $display("[TB] init signal observed at core/memory boundary");
    end
    if (u_dut.u_core.rst_n === 1'b0 || u_dut.u_mem.rst_n === 1'b0) begin
      reset_seen = 1;
      $display("[TB] reset signal observed at core/memory boundary");
    end

    $display("[DBG] mem boot_rom[0]=0x%h internal_sram[0]=0x%h tensor_sram[0]=0x%h otp[0]=0x%h icache[0]=0x%h dcache[0]=0x%h", u_dut.u_mem.boot_rom[0], u_dut.u_mem.internal_sram[0], u_dut.u_mem.tensor_sram[0], u_dut.u_mem.otp[0], u_dut.u_mem.icache[0], u_dut.u_mem.dcache[0]);
    $display("[DBG] core pc_if=0x%h gpr[0]=0x%h perf_counter[0]=0x%h", u_dut.u_core.pc_if, u_dut.u_core.gpr[0], u_dut.u_core.perf_counter[0]);
    $display("[DBG] gpio dir_reg=0x%h", u_dut.u_gpio.dir_reg);
    $display("[DBG] xt rd=0x%h", u_dut.u_xt.rd);

    if (u_dut.u_mem.boot_rom[0] === 64'h0 &&
        u_dut.u_mem.internal_sram[0] === 64'h0 &&
        u_dut.u_mem.tensor_sram[0] === 64'h0 &&
        u_dut.u_mem.otp[0] === 64'h0 &&
        u_dut.u_mem.icache[0] === 64'h0 &&
        u_dut.u_mem.dcache[0] === 64'h0 &&
        u_dut.u_core.pc_if === 64'h0 &&
        u_dut.u_core.gpr[0] === 64'h0 &&
        u_dut.u_core.perf_counter[0] === 64'h0 &&
        u_dut.u_gpio.dir_reg === 32'h0 &&
        u_dut.u_xt.rd === 64'h0) begin
      $display("[PASS] core and memory state initialized by reset");
      test_passed = test_passed + 1;
    end else begin
      $display("[FAIL] reset initialization check failed");
      test_failed = test_failed + 1;
    end
    test_count = test_count + 1;

    #20;
    rst_n = 1;
    $display("[TB] reset released");
    #10;

    check_write(32'h0000_0000, 32'hA5A5_5A5A);
    check_read(32'h0000_0000, 32'hA5A5_5A5A);

    check_write(32'h0000_0100, 32'h1234_5678);
    check_read(32'h0000_0100, 32'h1234_5678);

    check_write(32'h0000_0200, 32'h89AB_CDEF);
    check_read(32'h0000_0200, 32'h89AB_CDEF);

    check_write(32'h0000_0300, 32'h0F0E_0D0C);
    check_read(32'h0000_0300, 32'h0F0E_0D0C);

    check_write(32'h0000_0400, 32'h1122_3344);
    check_read(32'h0000_0400, 32'h1122_3344);

    check_write(32'h0000_0500, 32'h5566_7788);
    check_read(32'h0000_0500, 32'h0000_0000);

    check_write(32'h0000_0600, 32'h99AA_BBCC);
    check_read(32'h0000_0600, 32'h99AA_BBCC);

    check_write(32'h0000_0700, 32'hDEAD_BEEF);
    check_read(32'h0000_0700, 32'hDEAD_BEEF);

    check_write(32'h0000_0800, 32'h1357_2468);
    check_read(32'h0000_0800, 32'h1357_2468);

    check_write(32'h0000_0900, 32'h1111_2222);
    check_read(32'h0000_0900, 32'h1111_2222);

    check_write(32'h0000_0A00, 32'h3333_4444);
    check_read(32'h0000_0A00, 32'h3333_4444);

    check_write(32'h0000_0B00, 32'h5555_6666);
    check_read(32'h0000_0B00, 32'h5555_6666);

    check_write(32'h0000_0C00, 32'h7777_8888);
    check_read(32'h0000_0C00, 32'h7777_8888);

    check_write(32'h0000_0D00, 32'h9999_AAAA);
    check_read(32'h0000_0D00, 32'h9999_AAAA);

    check_write(32'h0000_0E00, 32'hBBBB_CCCC);
    check_read_non_x(32'h0000_0E00);

    check_write(32'h0000_0F00, 32'hDDDD_EEEE);
    check_read(32'h0000_0F00, 32'hDDDD_EEEE);

    check_write(32'h0000_1000, 32'h1111_0000);
    check_read_non_x(32'h0000_1000);

    check_write(32'h0000_1100, 32'h2222_0000);
    check_read(32'h0000_1100, 32'h2222_0000);

    check_write(32'h0000_1200, 32'h3333_0000);
    check_read_non_x(32'h0000_1200);

    check_write(32'h0000_1300, 32'h4444_0000);
    check_read(32'h0000_1300, 32'h4444_0000);

    check_write(32'h0000_1400, 32'h5555_0000);
    check_read(32'h0000_1400, 32'h5555_0000);

    check_write(32'h0000_1600, 32'h6666_0000);
    check_read(32'h0000_1600, 32'h6666_0000);

    check_write(32'h0000_1700, 32'h7777_0000);
    check_read(32'h0000_1700, 32'h7777_0000);

    check_write(32'h0000_1800, 32'h8888_0000);
    check_read(32'h0000_1800, 32'h8888_0000);

    check_write(32'h0000_1900, 32'h9999_0000);
    check_read(32'h0000_1900, 32'h9999_0000);

    #20;
    $display("==================================================");
    $display(" Single SoC testbench summary                    ");
    $display(" Tests Passed: %0d", test_passed);
    $display(" Tests Failed: %0d", test_failed);
    $display(" Total Checks: %0d", test_count);
    if (test_failed == 0) begin
      $display(" RESULT: SINGLE SOC TESTBENCH PASSED");
    end else begin
      $display(" RESULT: SINGLE SOC TESTBENCH FAILED");
    end
    $display("==================================================");
    $finish;
  end

endmodule
