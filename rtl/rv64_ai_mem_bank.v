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

  integer i;
  (* ram_style = "block" *) (* keep = "true" *) reg [63:0] mem [0:DEPTH-1];

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end else begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] = 64'b0;
      end
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      valid <= 1'b0;
      rdata <= 64'b0;
    end else if (init) begin
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
      if (write && |wstrb) begin
        mem[index] <= wdata;
      end
    end
  end
endmodule
