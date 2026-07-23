module rv64_ai_simd_engine (
  input  clk,
  input  rst_n,
  input  [127:0] vec_a,
  input  [127:0] vec_b,
  input  [3:0]   op,
  input  [1:0]   width,
  input  valid,
  output reg [127:0] vec_out,
  output reg         done
);

  wire [31:0] a0, a1, a2, a3;
  wire [31:0] b0, b1, b2, b3;
  wire [31:0] sum0, sum1, sum2, sum3;

  assign a0 = vec_a[31:0];
  assign a1 = vec_a[63:32];
  assign a2 = vec_a[95:64];
  assign a3 = vec_a[127:96];
  assign b0 = vec_b[31:0];
  assign b1 = vec_b[63:32];
  assign b2 = vec_b[95:64];
  assign b3 = vec_b[127:96];

  always @* begin
    vec_out = 128'b0;
    done = valid;
    case (op)
      4'd0: begin // add
        vec_out = vec_a + vec_b;
      end
      4'd1: begin // sub
        vec_out = vec_a - vec_b;
      end
      4'd2: begin // mul
        vec_out = vec_a * vec_b;
      end
      4'd3: begin // mac
        vec_out = vec_a + vec_b;
      end
      4'd4: begin // dot product
        vec_out = {sum0 + sum1 + sum2 + sum3, 96'b0};
      end
      4'd5: begin // min/max
        vec_out = vec_a;
      end
      4'd6: begin // clip
        vec_out = vec_a;
      end
      default: begin
        vec_out = vec_a;
      end
    endcase
  end
endmodule
