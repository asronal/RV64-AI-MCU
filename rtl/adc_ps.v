module rv64_ai_adc_usb_can (
  input  clk,
  input  rst_n,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid,
  input  [11:0] adc_in,
  output usb_tx,
  input  usb_rx,
  output can_tx,
  input  can_rx
);

  reg [31:0] adc_reg;
  reg [31:0] usb_reg;
  reg [31:0] can_reg;

  assign usb_tx = usb_reg[0];
  assign can_tx = can_reg[0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      adc_reg <= 32'b0;
      usb_reg <= 32'b0;
      can_reg <= 32'b0;
    end else begin
      adc_reg <= {20'b0, adc_in};
      if (axil_write) begin
        case (axil_addr[7:0])
          8'h08: usb_reg <= axil_wdata;
          8'h0C: can_reg <= axil_wdata;
        endcase
      end
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? adc_reg :
                      (axil_addr[7:0] == 8'h08) ? usb_reg :
                      (axil_addr[7:0] == 8'h0C) ? can_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
