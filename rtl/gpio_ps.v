module rv64_ai_gpio (
  input  clk,
  input  rst_n,
  input  [31:0] axil_addr,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_write,
  input  axil_read,
  output [31:0] axil_rdata,
  output axil_valid,
  inout  [31:0] gpio_io
);

  reg [31:0] dir_reg;
  reg [31:0] out_reg;
  wire [31:0] in_reg;

  assign gpio_io = dir_reg ? out_reg : 32'bz;
  assign in_reg = gpio_io;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dir_reg <= 32'b0;
      out_reg <= 32'b0;
    end else if (axil_write && axil_addr[7:0] == 8'h00) begin
      dir_reg <= axil_wdata;
    end else if (axil_write && axil_addr[7:0] == 8'h04) begin
      out_reg <= axil_wdata;
    end
  end

  assign axil_rdata = (axil_addr[7:0] == 8'h00) ? dir_reg :
                      (axil_addr[7:0] == 8'h04) ? out_reg :
                      (axil_addr[7:0] == 8'h08) ? in_reg : 32'b0;
  assign axil_valid = axil_write | axil_read;
endmodule
