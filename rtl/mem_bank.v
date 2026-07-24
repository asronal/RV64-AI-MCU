module rv64_ai_mem_bank #(
  parameter DEPTH = 1024,
  parameter INDEX_WIDTH = 16
)(
  input  wire clk,
  input  wire rst_n,
  input  wire init,
  input  wire [INDEX_WIDTH-1:0] index,
  input  wire [63:0] wdata,
  input  wire [7:0]  wstrb,
  input  wire read,
  input  wire write,
  output reg [63:0] rdata,
  output reg valid
);

  reg [63:0] mem [0:DEPTH-1];
  integer i;

  initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
      mem[i] = 64'b0;
    end
  end

  always @(posedge clk or posedge init or negedge rst_n) begin
    if (!rst_n || init) begin
      valid <= 1'b0;
      rdata <= 64'b0;
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] <= 64'b0;
      end
    end else begin
      valid <= read | write;
      if (read) begin
        rdata <= mem[index];
      end
      if (write) begin
        mem[index] <= wdata;
      end
    end
  end
endmodule
