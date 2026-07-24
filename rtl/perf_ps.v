module rv64_ai_perf_counters (
  input  clk,
  input  rst_n,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid,
  output [31:0] perf0,
  output [31:0] perf1,
  output [31:0] perf2,
  output [31:0] perf3
);

  reg [31:0] perf0_reg, perf1_reg, perf2_reg, perf3_reg;

  assign perf0 = perf0_reg;
  assign perf1 = perf1_reg;
  assign perf2 = perf2_reg;
  assign perf3 = perf3_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      perf0_reg <= 32'b0;
      perf1_reg <= 32'b0;
      perf2_reg <= 32'b0;
      perf3_reg <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: perf0_reg <= axil_wdata;
        8'h04: perf1_reg <= axil_wdata;
        8'h08: perf2_reg <= axil_wdata;
        8'h0C: perf3_reg <= axil_wdata;
      endcase
    end else begin
      perf0_reg <= perf0_reg + 1;
      perf1_reg <= perf1_reg + 1;
      perf2_reg <= perf2_reg + 2;
      perf3_reg <= perf3_reg + 3;
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? perf0_reg :
                      (axil_addr[7:0] == 8'h04) ? perf1_reg :
                      (axil_addr[7:0] == 8'h08) ? perf2_reg :
                      (axil_addr[7:0] == 8'h0C) ? perf3_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
