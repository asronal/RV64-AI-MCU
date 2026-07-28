module rv64_ai_mac_engine (
  input  clk,
  input  rst_n,
  input  [127:0] data_a,
  input  [127:0] data_b,
  input  [1:0]   mode,
  input  valid,
  output reg [255:0] acc_out,
  output reg         done
);

  always @* begin
    acc_out = 256'b0;
    done = valid;
    case (mode)
      2'd0: begin // int8 x4 MAC
        acc_out = {data_a[31:0] * data_b[31:0], data_a[63:32] * data_b[63:32], data_a[95:64] * data_b[95:64], data_a[127:96] * data_b[127:96]};
      end
      2'd1: begin // int16 x2 MAC
        acc_out = {data_a[63:0] * data_b[63:0], data_a[127:64] * data_b[127:64]};
      end
      2'd2: begin // int32 x1 MAC
        acc_out = data_a[63:0] * data_b[63:0];
      end
      2'd3: begin // int64 x1 MAC
        acc_out = data_a * data_b;
      end
    endcase
  end
endmodule
