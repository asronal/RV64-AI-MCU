module rv64_ai_dsp_coprocessor (
  input  clk,
  input  rst_n,
  input  [31:0] axil_awaddr,
  input  [2:0]  axil_awprot,
  input  axil_awvalid,
  output axil_awready,
  input  [31:0] axil_wdata,
  input  [3:0]  axil_wstrb,
  input  axil_wvalid,
  output axil_wready,
  output [1:0] axil_bresp,
  output axil_bvalid,
  input  axil_bready,
  input  [31:0] axil_araddr,
  input  [2:0]  axil_arprot,
  input  axil_arvalid,
  output axil_arready,
  output [31:0] axil_rdata,
  output [1:0] axil_rresp,
  output axil_rvalid,
  input  axil_rready
);

  localparam CTRL_REG = 32'h0000;
  localparam STATUS_REG = 32'h0004;
  localparam CMD_REG = 32'h0008;
  localparam SIMD_REG = 32'h0010;

  reg [31:0] ctrl_reg;
  reg [31:0] status_reg;
  reg [31:0] cmd_reg;
  reg [31:0] simd_reg;
  reg [31:0] rdata_reg;

  wire [127:0] simd_vec_a;
  wire [127:0] simd_vec_b;
  wire [127:0] simd_vec_out;
  wire [255:0] mac_acc_out;
  wire simd_done, mac_done;

  assign axil_awready = 1'b1;
  assign axil_wready  = 1'b1;
  assign axil_bresp   = 2'b00;
  assign axil_bvalid  = axil_awvalid && axil_wvalid;
  assign axil_arready = 1'b1;
  assign axil_rresp   = 2'b00;
  assign axil_rvalid  = axil_arvalid;

  rv64_ai_simd_engine u_simd (
    .clk(clk),
    .rst_n(rst_n),
    .vec_a(simd_vec_a),
    .vec_b(simd_vec_b),
    .op(ctrl_reg[3:0]),
    .width(ctrl_reg[5:4]),
    .valid(ctrl_reg[0]),
    .vec_out(simd_vec_out),
    .done(simd_done)
  );

  rv64_ai_mac_engine u_mac (
    .clk(clk),
    .rst_n(rst_n),
    .data_a(simd_vec_a),
    .data_b(simd_vec_b),
    .mode(ctrl_reg[7:6]),
    .valid(ctrl_reg[1]),
    .acc_out(mac_acc_out),
    .done(mac_done)
  );

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ctrl_reg <= 32'b0;
      cmd_reg  <= 32'b0;
      simd_reg <= 32'b0;
      status_reg <= 32'b0;
    end else begin
      if (axil_awvalid && axil_wvalid) begin
        case (axil_awaddr[7:0])
          CTRL_REG: ctrl_reg <= axil_wdata;
          CMD_REG:  cmd_reg  <= axil_wdata;
          SIMD_REG: simd_reg <= axil_wdata;
          default: ;
        endcase
      end
      if (simd_done || mac_done) begin
        status_reg[0] <= simd_done;
        status_reg[1] <= mac_done;
      end
    end
  end

  always @* begin
    rdata_reg = 32'b0;
    if (axil_arvalid) begin
      case (axil_araddr[7:0])
        CTRL_REG:   rdata_reg = ctrl_reg;
        STATUS_REG: rdata_reg = status_reg;
        CMD_REG:    rdata_reg = cmd_reg;
        SIMD_REG:   rdata_reg = simd_reg;
        default:    rdata_reg = 32'b0;
      endcase
    end
  end

  assign axil_rdata = rdata_reg;

  assign simd_vec_a = {simd_reg, simd_reg};
  assign simd_vec_b = {cmd_reg, cmd_reg};
endmodule
