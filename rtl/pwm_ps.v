module rv64_ai_pwm_timer_wdt_rtc (
  input  clk,
  input  rst_n,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid,
  output pwm_out,
  output irq
);

  reg [31:0] pwm_reg;
  reg [31:0] timer_reg;
  reg [31:0] wdt_reg;
  reg [31:0] rtc_reg;

  assign pwm_out = pwm_reg[0];
  assign irq = timer_reg[0] | wdt_reg[0] | rtc_reg[0];

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pwm_reg <= 32'b0;
      timer_reg <= 32'b0;
      wdt_reg <= 32'b0;
      rtc_reg <= 32'b0;
    end else if (axil_write) begin
      case (axil_addr[7:0])
        8'h00: pwm_reg  <= axil_wdata;
        8'h04: timer_reg <= axil_wdata;
        8'h08: wdt_reg   <= axil_wdata;
        8'h0C: rtc_reg   <= axil_wdata;
      endcase
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? pwm_reg :
                      (axil_addr[7:0] == 8'h04) ? timer_reg :
                      (axil_addr[7:0] == 8'h08) ? wdt_reg :
                      (axil_addr[7:0] == 8'h0C) ? rtc_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
