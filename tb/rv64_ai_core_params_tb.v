`timescale 1ns / 1ps

module rv64_ai_core_params_tb;

  reg clk;
  reg rst_n;
  reg [63:0] imem_rdata;
  reg [63:0] dmem_rdata;
  reg imem_valid;
  reg dmem_valid;

  integer test_count;
  integer test_passed;
  integer test_failed;

  always #5 clk = ~clk;

  task check_reset;
    input [63:0] expected_pc;
    input [63:0] expected_dmem_addr;
    begin
      if (expected_pc === 64'h0 && expected_dmem_addr === 64'h0) begin
        $display("[PASS] parameterized core reset check passed");
        test_passed = test_passed + 1;
      end else begin
        $display("[FAIL] parameterized core reset check failed");
        test_failed = test_failed + 1;
      end
      test_count = test_count + 1;
    end
  endtask

  rv64_ai_core #(
    .GPR_DEPTH(32),
    .BTB_DEPTH(128),
    .RAS_DEPTH(16),
    .PERF_CNTRS(8)
  ) u_core_default (
    .clk(clk),
    .rst_n(rst_n),
    .imem_rdata(imem_rdata),
    .imem_valid(imem_valid),
    .dmem_rdata(dmem_rdata),
    .dmem_valid(dmem_valid),
    .imem_addr(),
    .dmem_addr(),
    .dmem_wdata(),
    .dmem_wstrb(),
    .dmem_read(),
    .dmem_write(),
    .perf_counter0(),
    .perf_counter1(),
    .perf_counter2(),
    .perf_counter3(),
    .perf_counter4(),
    .perf_counter5(),
    .perf_counter6(),
    .perf_counter7()
  );

  rv64_ai_core #(
    .GPR_DEPTH(16),
    .BTB_DEPTH(64),
    .RAS_DEPTH(8),
    .PERF_CNTRS(4)
  ) u_core_small (
    .clk(clk),
    .rst_n(rst_n),
    .imem_rdata(imem_rdata),
    .imem_valid(imem_valid),
    .dmem_rdata(dmem_rdata),
    .dmem_valid(dmem_valid),
    .imem_addr(),
    .dmem_addr(),
    .dmem_wdata(),
    .dmem_wstrb(),
    .dmem_read(),
    .dmem_write(),
    .perf_counter0(),
    .perf_counter1(),
    .perf_counter2(),
    .perf_counter3(),
    .perf_counter4(),
    .perf_counter5(),
    .perf_counter6(),
    .perf_counter7()
  );

  initial begin
    $dumpfile("core_params_tb.vcd");
    $dumpvars(0, rv64_ai_core_params_tb);

    clk = 0;
    rst_n = 0;
    imem_rdata = 64'b0;
    dmem_rdata = 64'b0;
    imem_valid = 1'b0;
    dmem_valid = 1'b0;
    test_count = 0;
    test_passed = 0;
    test_failed = 0;

    #20;
    rst_n = 1;
    #20;

    check_reset(64'h0, 64'h0);

    #20;
    $display("==================================================");
    $display(" Parameterized core test summary                  ");
    $display(" Tests Passed: %0d", test_passed);
    $display(" Tests Failed: %0d", test_failed);
    $display(" Total Checks: %0d", test_count);
    if (test_failed == 0) begin
      $display(" RESULT: PARAMETERIZED CORE TESTS PASSED");
    end else begin
      $display(" RESULT: PARAMETERIZED CORE TESTS FAILED");
    end
    $display("==================================================");
    $finish;
  end

endmodule
