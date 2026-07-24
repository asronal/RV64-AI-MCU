module rv64_ai_jtag_debug (
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
  output jtag_tms,
  output jtag_tdi,
  output jtag_tck,
  input  jtag_tdo
);

  reg [31:0] ctrl_reg;
  reg [31:0] jtag_reg;

  assign jtag_tms = ctrl_reg[0];
  assign jtag_tdi = ctrl_reg[1];
  assign jtag_tck = ctrl_reg[2];

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      ctrl_reg <= 32'b0;
      jtag_reg <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: ctrl_reg <= axil_wdata;
        8'h04: jtag_reg <= axil_wdata;
      endcase
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? ctrl_reg :
                      (axil_addr[7:0] == 8'h04) ? jtag_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
