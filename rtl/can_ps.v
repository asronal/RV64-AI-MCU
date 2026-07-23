module rv64_ai_can_fd (
  input  clk,
  input  rst_n,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid,
  output can_tx,
  input  can_rx
);

  reg [31:0] ctrl_reg;
  reg [31:0] data_reg;

  assign can_tx = ctrl_reg[0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ctrl_reg <= 32'b0;
      data_reg <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: ctrl_reg <= axil_wdata;
        8'h04: data_reg <= axil_wdata;
      endcase
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? ctrl_reg :
                      (axil_addr[7:0] == 8'h04) ? data_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
