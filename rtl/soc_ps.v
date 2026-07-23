module rv64_ai_soc_top (
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
  input  axil_rready,
  inout  [31:0] gpio_io
);

  localparam [31:0] GPIO_BASE = 32'h0000_0000;
  localparam [31:0] UART_BASE = 32'h0000_0100;
  localparam [31:0] SPI_BASE  = 32'h0000_0200;
  localparam [31:0] I2C_BASE  = 32'h0000_0300;
  localparam [31:0] PWM_BASE  = 32'h0000_0400;
  localparam [31:0] ADC_BASE  = 32'h0000_0500;
  localparam [31:0] PLIC_BASE = 32'h0000_0600;
  localparam [31:0] QSPI_BASE = 32'h0000_0700;
  localparam [31:0] SEC_BASE  = 32'h0000_0800;

  wire [31:0] gpio_rdata, uart_rdata, spi_rdata, i2c_rdata, pwm_rdata;
  wire [31:0] adc_rdata, plic_rdata, qspi_rdata, sec_rdata;
  wire gpio_valid, uart_valid, spi_valid, i2c_valid, pwm_valid;
  wire adc_valid, plic_valid, qspi_valid, sec_valid;
  wire [31:0] axil_addr;

  wire gpio_wsel, uart_wsel, spi_wsel, i2c_wsel, pwm_wsel;
  wire adc_wsel, plic_wsel, qspi_wsel, sec_wsel;
  wire gpio_rsel, uart_rsel, spi_rsel, i2c_rsel, pwm_rsel;
  wire adc_rsel, plic_rsel, qspi_rsel, sec_rsel;
  wire any_write_sel, any_read_sel;

  assign gpio_wsel = (axil_awaddr[31:8] == GPIO_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign uart_wsel = (axil_awaddr[31:8] == UART_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign spi_wsel  = (axil_awaddr[31:8] == SPI_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign i2c_wsel  = (axil_awaddr[31:8] == I2C_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign pwm_wsel  = (axil_awaddr[31:8] == PWM_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign adc_wsel  = (axil_awaddr[31:8] == ADC_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign plic_wsel = (axil_awaddr[31:8] == PLIC_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign qspi_wsel = (axil_awaddr[31:8] == QSPI_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign sec_wsel  = (axil_awaddr[31:8] == SEC_BASE[31:8])  && axil_awvalid && axil_wvalid;

  assign gpio_rsel = (axil_araddr[31:8] == GPIO_BASE[31:8]) && axil_arvalid;
  assign uart_rsel = (axil_araddr[31:8] == UART_BASE[31:8]) && axil_arvalid;
  assign spi_rsel  = (axil_araddr[31:8] == SPI_BASE[31:8])  && axil_arvalid;
  assign i2c_rsel  = (axil_araddr[31:8] == I2C_BASE[31:8])  && axil_arvalid;
  assign pwm_rsel  = (axil_araddr[31:8] == PWM_BASE[31:8])  && axil_arvalid;
  assign adc_rsel  = (axil_araddr[31:8] == ADC_BASE[31:8])  && axil_arvalid;
  assign plic_rsel = (axil_araddr[31:8] == PLIC_BASE[31:8]) && axil_arvalid;
  assign qspi_rsel = (axil_araddr[31:8] == QSPI_BASE[31:8]) && axil_arvalid;
  assign sec_rsel  = (axil_araddr[31:8] == SEC_BASE[31:8])  && axil_arvalid;

  assign any_write_sel = gpio_wsel | uart_wsel | spi_wsel | i2c_wsel | pwm_wsel |
                         adc_wsel | plic_wsel | qspi_wsel | sec_wsel;
  assign any_read_sel  = gpio_rsel | uart_rsel | spi_rsel | i2c_rsel | pwm_rsel |
                         adc_rsel | plic_rsel | qspi_rsel | sec_rsel;
  assign axil_addr     = (axil_awvalid && axil_wvalid) ? axil_awaddr : axil_araddr;

  rv64_ai_gpio u_gpio (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(gpio_wsel),
    .axil_read(gpio_rsel),
    .axil_rdata(gpio_rdata),
    .axil_valid(gpio_valid),
    .gpio_io(gpio_io)
  );

  rv64_ai_uart u_uart0 (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(uart_wsel),
    .axil_read(uart_rsel),
    .axil_rdata(uart_rdata),
    .axil_valid(uart_valid),
    .tx(),
    .rx(1'b0)
  );

  rv64_ai_spi u_spi0 (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(spi_wsel),
    .axil_read(spi_rsel),
    .axil_rdata(spi_rdata),
    .axil_valid(spi_valid),
    .sclk(),
    .mosi(),
    .miso(1'b0)
  );

  rv64_ai_i2c u_i2c0 (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(i2c_wsel),
    .axil_read(i2c_rsel),
    .axil_rdata(i2c_rdata),
    .axil_valid(i2c_valid),
    .scl(),
    .sda()
  );

  rv64_ai_pwm_timer_wdt_rtc u_pwmt (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(pwm_wsel),
    .axil_read(pwm_rsel),
    .axil_rdata(pwm_rdata),
    .axil_valid(pwm_valid),
    .pwm_out(),
    .irq()
  );

  rv64_ai_adc_usb_can u_adc (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(adc_wsel),
    .axil_read(adc_rsel),
    .axil_rdata(adc_rdata),
    .axil_valid(adc_valid),
    .adc_in(12'b0),
    .usb_tx(),
    .usb_rx(1'b0),
    .can_tx(),
    .can_rx(1'b0)
  );

  rv64_ai_plic_clint_debug u_plic (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(plic_wsel),
    .axil_read(plic_rsel),
    .axil_rdata(plic_rdata),
    .axil_valid(plic_valid),
    .irq(),
    .debug_halt()
  );

  rv64_ai_qspi_psram_dma u_qspi (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(qspi_wsel),
    .axil_read(qspi_rsel),
    .axil_rdata(qspi_rdata),
    .axil_valid(qspi_valid),
    .qspi_cs(),
    .psram_cs(),
    .dma_irq()
  );

  rv64_ai_security_block u_sec (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(sec_wsel),
    .axil_read(sec_rsel),
    .axil_rdata(sec_rdata),
    .axil_valid(sec_valid),
    .secure_boot_ok(),
    .otp_ready(),
    .trng_ready()
  );

  assign axil_awready = 1'b1;
  assign axil_wready  = 1'b1;
  assign axil_bresp   = 2'b00;
  assign axil_bvalid  = any_write_sel;
  assign axil_arready = 1'b1;
  assign axil_rresp   = 2'b00;
  assign axil_rvalid  = any_read_sel;
  assign axil_rdata   = gpio_rsel ? gpio_rdata :
                        uart_rsel ? uart_rdata :
                        spi_rsel  ? spi_rdata  :
                        i2c_rsel  ? i2c_rdata  :
                        pwm_rsel  ? pwm_rdata  :
                        adc_rsel  ? adc_rdata  :
                        plic_rsel ? plic_rdata :
                        qspi_rsel ? qspi_rdata :
                        sec_rsel  ? sec_rdata  : 32'b0;
endmodule
