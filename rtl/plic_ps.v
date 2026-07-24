module rv64_ai_plic_clint_debug (
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
  output irq,
  output debug_halt
);

  reg [31:0] plic_reg;
  reg [31:0] clint_reg;
  reg [31:0] dbg_reg;

  assign irq = plic_reg[0] | clint_reg[0];
  assign debug_halt = dbg_reg[0];

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      plic_reg <= 32'b0;
      clint_reg <= 32'b0;
      dbg_reg <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: plic_reg <= axil_wdata;
        8'h04: clint_reg <= axil_wdata;
        8'h08: dbg_reg <= axil_wdata;
      endcase
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? plic_reg :
                      (axil_addr[7:0] == 8'h04) ? clint_reg :
                      (axil_addr[7:0] == 8'h08) ? dbg_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
