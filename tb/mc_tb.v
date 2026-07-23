`timescale 1ns / 1ps

module mc_tb;

  // Clock & Reset
  reg clk;
  reg rst_n;

  // Memory Controller Interface Signals
  reg  [63:0] mem_addr;
  reg  [63:0] mem_wdata;
  reg  [7:0]  mem_wstrb;
  reg         mem_read;
  reg         mem_write;
  wire [63:0] mem_rdata;
  wire        mem_valid;

  // Track pass/fail test status
  integer tests_passed;
  integer tests_failed;

  // Instantiate Memory Subsystem (Memory Controller)
  rv64_ai_memory_subsystem u_mem_subsystem (
    .clk(clk),
    .rst_n(rst_n),
    .addr(mem_addr),
    .wdata(mem_wdata),
    .wstrb(mem_wstrb),
    .read(mem_read),
    .write(mem_write),
    .rdata(mem_rdata),
    .valid(mem_valid)
  );

  // Clock Generator (100 MHz => 10ns period)
  always #5 clk = ~clk;

  // Memory Read Task
  task do_mem_read(
    input [63:0] addr,
    input [63:0] expected_data,
    input integer check_expected
  );
    begin
      @(posedge clk);
      mem_addr  <= addr;
      mem_read  <= 1'b1;
      mem_write <= 1'b0;
      
      @(posedge clk);
      mem_read  <= 1'b0;
      
      wait (mem_valid);
      $display("[MC_TB READ ] Addr: 0x%16h -> RData: 0x%16h (Valid: %b)", addr, mem_rdata, mem_valid);
      
      if (check_expected) begin
        if (mem_rdata === expected_data) begin
          $display("[PASS] Read data matched expected 0x%16h", expected_data);
          tests_passed = tests_passed + 1;
        end else begin
          $display("[FAIL] Read data 0x%16h != expected 0x%16h", mem_rdata, expected_data);
          tests_failed = tests_failed + 1;
        end
      end
    end
  endtask

  // Memory Write Task
  task do_mem_write(
    input [63:0] addr,
    input [63:0] wdata,
    input [7:0]  wstrb
  );
    begin
      @(posedge clk);
      mem_addr  <= addr;
      mem_wdata <= wdata;
      mem_wstrb <= wstrb;
      mem_write <= 1'b1;
      mem_read  <= 1'b0;
      
      @(posedge clk);
      mem_write <= 1'b0;
      
      wait (mem_valid);
      $display("[MC_TB WRITE] Addr: 0x%16h <- WData: 0x%16h (WStrb: 0x%2h)", addr, wdata, wstrb);
    end
  endtask

  // Main Test Procedure
  initial begin
    $dumpfile("sim_mc_tb.vcd");
    $dumpvars(0, mc_tb);

    clk          = 0;
    rst_n        = 0;
    mem_addr     = 64'h0;
    mem_wdata    = 64'h0;
    mem_wstrb    = 8'h0;
    mem_read     = 1'b0;
    mem_write    = 1'b0;
    tests_passed = 0;
    tests_failed = 0;

    $display("==================================================");
    $display("   Starting Memory Controller Testbench (mc_tb)   ");
    $display("==================================================");

    // Apply Reset
    #20;
    rst_n = 1;
    $display("[MC_TB] Reset released.");
    #20;

    // Test 1: Write and Read Internal SRAM (Addr: 0x0001_0000)
    $display("\n--- Test 1: Internal SRAM Access ---");
    do_mem_write(64'h0001_0000, 64'hCAFE_BABE_DEAD_BEEF, 8'hFF);
    do_mem_read(64'h0001_0000, 64'hCAFE_BABE_DEAD_BEEF, 1);

    // Test 2: Write and Read Tensor SRAM (Addr: 0x0009_0000)
    $display("\n--- Test 2: Tensor SRAM Access ---");
    do_mem_write(64'h0009_0000, 64'h0123_4567_89AB_CDEF, 8'hFF);
    do_mem_read(64'h0009_0000, 64'h0123_4567_89AB_CDEF, 1);

    // Test 3: Write and Read D-Cache (Addr: 0x0012_0000)
    $display("\n--- Test 3: Data Cache Access ---");
    do_mem_write(64'h0012_0000, 64'hA5A5_5A5A_1234_5678, 8'hFF);
    do_mem_read(64'h0012_0000, 64'hA5A5_5A5A_1234_5678, 1);

    // Summary
    #50;
    $display("==================================================");
    $display("           Memory Controller Test Summary         ");
    $display(" Tests Passed: %0d", tests_passed);
    $display(" Tests Failed: %0d", tests_failed);
    if (tests_failed == 0) begin
      $display(" RESULT: ALL TESTS PASSED!");
    end else begin
      $display(" RESULT: TEST SUITE FAILED!");
    end
    $display("==================================================");
    $finish;
  end

endmodule
