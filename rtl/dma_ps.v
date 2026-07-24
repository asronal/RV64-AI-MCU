module rv64_ai_dma_sg (
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
  output [7:0] dma_irq
);

  reg [31:0] ctrl_reg;
  reg [31:0] chan_reg [0:7];

  assign dma_irq = {chan_reg[7][0], chan_reg[6][0], chan_reg[5][0], chan_reg[4][0], chan_reg[3][0], chan_reg[2][0], chan_reg[1][0], chan_reg[0][0]};

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      ctrl_reg <= 32'b0;
      for (integer i = 0; i < 8; i = i + 1) chan_reg[i] <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: ctrl_reg <= axil_wdata;
        default: begin
          if (axil_addr[7:0] >= 8'h10 && axil_addr[7:0] < 8'h30) begin
            chan_reg[(axil_addr[7:0]-8'h10)>>2] <= axil_wdata;
          end
        end
      endcase
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? ctrl_reg :
                      (axil_addr[7:0] >= 8'h10 && axil_addr[7:0] < 8'h30) ? chan_reg[(axil_addr[7:0]-8'h10)>>2] : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
