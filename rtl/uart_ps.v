module rv64_ai_uart (
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
  output tx,
  input  rx
);

  reg [31:0] baud_reg;
  reg [31:0] tx_reg;
  reg [31:0] rx_reg;

  assign tx = tx_reg[0];

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      baud_reg <= 32'd115200;
      tx_reg   <= 32'b0;
      rx_reg   <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: baud_reg <= axil_wdata;
        8'h04: tx_reg   <= axil_wdata;
      endcase
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? baud_reg :
                      (axil_addr[7:0] == 8'h04) ? tx_reg :
                      (axil_addr[7:0] == 8'h08) ? rx_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
