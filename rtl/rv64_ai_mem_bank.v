`timescale 1ns/1ps

(* keep_hierarchy = "yes" *) module rv64_ai_mem_bank #(
  parameter DEPTH = 1024,
  parameter INDEX_WIDTH = 16,
  parameter INIT_FILE = ""
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

  localparam [INDEX_WIDTH-1:0] MAX_INIT_ADDR = DEPTH - 1;
  integer i;
  reg [INDEX_WIDTH-1:0] init_addr;
  reg init_busy;
  (* ram_style = "block" *) (* ramstyle = "block" *) (* keep = "true" *) reg [63:0] mem [0:DEPTH-1];

`ifndef SYNTHESIS
  // Simulation-only initialization path. The synthesis build defines
  // SYNTHESIS so this block is not elaborated, avoiding heavy init-file
  // and full-array initialization work during mapping.
  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 64'b0;
      end
    end
  end
`endif

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid <= 1'b0;
      rdata <= 64'b0;
      init_busy <= 1'b0;
      init_addr <= {INDEX_WIDTH{1'b0}};
    end else if (init) begin
      valid <= 1'b0;
      rdata <= 64'b0;
      init_busy <= 1'b1;
      init_addr <= {INDEX_WIDTH{1'b0}};
    end else if (init_busy) begin
        valid <= 1'b0;
      rdata <= 64'b0;
      mem[init_addr] <= 64'b0;
      if (init_addr == MAX_INIT_ADDR) begin
        init_busy <= 1'b0;
      end
      init_addr <= init_addr + 1;
    end else begin
      valid <= read | write;
      if (read) begin
        rdata <= mem[index];
      end
      if (write && |wstrb) begin
        mem[index] <= wdata;
      end
    end
  end
endmodule
