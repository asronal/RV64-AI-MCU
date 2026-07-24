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
  localparam [31:0] BRK_BASE  = 32'h0000_0900;
  localparam [31:0] CAN_BASE  = 32'h0000_0A00;
  localparam [31:0] CLK_BASE  = 32'h0000_0B00;
  localparam [31:0] CRYPTO_BASE = 32'h0000_0C00;
  localparam [31:0] DMA_BASE  = 32'h0000_0D00;
  localparam [31:0] DSP_BASE  = 32'h0000_0E00;
  localparam [31:0] JTAG_BASE = 32'h0000_0F00;
  localparam [31:0] PERF_BASE = 32'h0000_1000;
  localparam [31:0] PMP_BASE  = 32'h0000_1100;
  localparam [31:0] TPU_BASE  = 32'h0000_1200;
  localparam [31:0] TRACE_BASE = 32'h0000_1300;
  localparam [31:0] USB_BASE  = 32'h0000_1400;
  localparam [31:0] XT_BASE   = 32'h0000_1500;
  localparam [31:0] DBG_BASE  = 32'h0000_1600;
  localparam [31:0] I2C2_BASE = 32'h0000_1700;
  localparam [31:0] SPI2_BASE = 32'h0000_1800;
  localparam [31:0] UART2_BASE = 32'h0000_1900;

  wire [31:0] gpio_rdata, uart_rdata, spi_rdata, i2c_rdata, pwm_rdata;
  wire [31:0] adc_rdata, plic_rdata, qspi_rdata, sec_rdata;
  wire [31:0] brk_rdata, can_rdata, clk_rdata, crypto_rdata, dma_rdata;
  wire [31:0] dsp_rdata, jtag_rdata, perf_rdata, pmp_rdata, tpu_rdata;
  wire [31:0] trace_rdata, usb_rdata, dbg_rdata, i2c2_rdata, spi2_rdata, uart2_rdata;
  wire gpio_valid, uart_valid, spi_valid, i2c_valid, pwm_valid;
  wire adc_valid, plic_valid, qspi_valid, sec_valid;
  wire brk_valid, can_valid, clk_valid, crypto_valid, dma_valid;
  wire dsp_valid, jtag_valid, perf_valid, pmp_valid, tpu_valid;
  wire trace_valid, usb_valid, dbg_valid, i2c2_valid, spi2_valid, uart2_valid;
  wire [31:0] axil_addr;

  wire gpio_wsel, uart_wsel, spi_wsel, i2c_wsel, pwm_wsel;
  wire adc_wsel, plic_wsel, qspi_wsel, sec_wsel;
  wire brk_wsel, can_wsel, clk_wsel, crypto_wsel, dma_wsel;
  wire dsp_wsel, jtag_wsel, perf_wsel, pmp_wsel, tpu_wsel;
  wire trace_wsel, usb_wsel, dbg_wsel, i2c2_wsel, spi2_wsel, uart2_wsel;
  wire gpio_rsel, uart_rsel, spi_rsel, i2c_rsel, pwm_rsel;
  wire adc_rsel, plic_rsel, qspi_rsel, sec_rsel;
  wire brk_rsel, can_rsel, clk_rsel, crypto_rsel, dma_rsel;
  wire dsp_rsel, jtag_rsel, perf_rsel, pmp_rsel, tpu_rsel;
  wire trace_rsel, usb_rsel, dbg_rsel, i2c2_rsel, spi2_rsel, uart2_rsel;
  wire any_write_sel, any_read_sel;

  wire [63:0] xt_rd;
  wire xt_valid;

  wire [63:0] core_imem_addr;
  wire [63:0] core_dmem_addr;
  wire [63:0] core_dmem_wdata;
  wire [7:0]  core_dmem_wstrb;
  wire        core_dmem_read;
  wire        core_dmem_write;
  wire [63:0] mem_rdata;
  wire        mem_valid;
  wire [63:0] perf_counter0;
  wire [63:0] perf_counter1;
  wire [63:0] perf_counter2;
  wire [63:0] perf_counter3;
  wire [63:0] perf_counter4;
  wire [63:0] perf_counter5;
  wire [63:0] perf_counter6;
  wire [63:0] perf_counter7;
  wire sys_init;

  wire [63:0] mem_addr = (core_dmem_read || core_dmem_write) ? core_dmem_addr : core_imem_addr;
  wire [63:0] mem_wdata = core_dmem_wdata;
  assign sys_init = ~rst_n;
  wire [7:0]  mem_wstrb = core_dmem_wstrb;
  wire        mem_read  = core_dmem_read;
  wire        mem_write = core_dmem_write;

  assign gpio_wsel = (axil_awaddr[31:8] == GPIO_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign uart_wsel = (axil_awaddr[31:8] == UART_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign spi_wsel  = (axil_awaddr[31:8] == SPI_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign i2c_wsel  = (axil_awaddr[31:8] == I2C_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign pwm_wsel  = (axil_awaddr[31:8] == PWM_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign adc_wsel  = (axil_awaddr[31:8] == ADC_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign plic_wsel = (axil_awaddr[31:8] == PLIC_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign qspi_wsel = (axil_awaddr[31:8] == QSPI_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign sec_wsel  = (axil_awaddr[31:8] == SEC_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign brk_wsel  = (axil_awaddr[31:8] == BRK_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign can_wsel  = (axil_awaddr[31:8] == CAN_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign clk_wsel  = (axil_awaddr[31:8] == CLK_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign crypto_wsel = (axil_awaddr[31:8] == CRYPTO_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign dma_wsel  = (axil_awaddr[31:8] == DMA_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign dsp_wsel  = (axil_awaddr[31:8] == DSP_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign jtag_wsel = (axil_awaddr[31:8] == JTAG_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign perf_wsel = (axil_awaddr[31:8] == PERF_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign pmp_wsel  = (axil_awaddr[31:8] == PMP_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign tpu_wsel  = (axil_awaddr[31:8] == TPU_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign trace_wsel = (axil_awaddr[31:8] == TRACE_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign usb_wsel  = (axil_awaddr[31:8] == USB_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign dbg_wsel  = (axil_awaddr[31:8] == DBG_BASE[31:8])  && axil_awvalid && axil_wvalid;
  assign i2c2_wsel = (axil_awaddr[31:8] == I2C2_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign spi2_wsel = (axil_awaddr[31:8] == SPI2_BASE[31:8]) && axil_awvalid && axil_wvalid;
  assign uart2_wsel = (axil_awaddr[31:8] == UART2_BASE[31:8]) && axil_awvalid && axil_wvalid;

  assign gpio_rsel = (axil_araddr[31:8] == GPIO_BASE[31:8]) && axil_arvalid;
  assign uart_rsel = (axil_araddr[31:8] == UART_BASE[31:8]) && axil_arvalid;
  assign spi_rsel  = (axil_araddr[31:8] == SPI_BASE[31:8])  && axil_arvalid;
  assign i2c_rsel  = (axil_araddr[31:8] == I2C_BASE[31:8])  && axil_arvalid;
  assign pwm_rsel  = (axil_araddr[31:8] == PWM_BASE[31:8])  && axil_arvalid;
  assign adc_rsel  = (axil_araddr[31:8] == ADC_BASE[31:8])  && axil_arvalid;
  assign plic_rsel = (axil_araddr[31:8] == PLIC_BASE[31:8]) && axil_arvalid;
  assign qspi_rsel = (axil_araddr[31:8] == QSPI_BASE[31:8]) && axil_arvalid;
  assign sec_rsel  = (axil_araddr[31:8] == SEC_BASE[31:8])  && axil_arvalid;
  assign brk_rsel  = (axil_araddr[31:8] == BRK_BASE[31:8])  && axil_arvalid;
  assign can_rsel  = (axil_araddr[31:8] == CAN_BASE[31:8])  && axil_arvalid;
  assign clk_rsel  = (axil_araddr[31:8] == CLK_BASE[31:8])  && axil_arvalid;
  assign crypto_rsel = (axil_araddr[31:8] == CRYPTO_BASE[31:8]) && axil_arvalid;
  assign dma_rsel  = (axil_araddr[31:8] == DMA_BASE[31:8])  && axil_arvalid;
  assign dsp_rsel  = (axil_araddr[31:8] == DSP_BASE[31:8])  && axil_arvalid;
  assign jtag_rsel = (axil_araddr[31:8] == JTAG_BASE[31:8]) && axil_arvalid;
  assign perf_rsel = (axil_araddr[31:8] == PERF_BASE[31:8]) && axil_arvalid;
  assign pmp_rsel  = (axil_araddr[31:8] == PMP_BASE[31:8])  && axil_arvalid;
  assign tpu_rsel  = (axil_araddr[31:8] == TPU_BASE[31:8])  && axil_arvalid;
  assign trace_rsel = (axil_araddr[31:8] == TRACE_BASE[31:8]) && axil_arvalid;
  assign usb_rsel  = (axil_araddr[31:8] == USB_BASE[31:8])  && axil_arvalid;
  assign dbg_rsel  = (axil_araddr[31:8] == DBG_BASE[31:8])  && axil_arvalid;
  assign i2c2_rsel = (axil_araddr[31:8] == I2C2_BASE[31:8]) && axil_arvalid;
  assign spi2_rsel = (axil_araddr[31:8] == SPI2_BASE[31:8]) && axil_arvalid;
  assign uart2_rsel = (axil_araddr[31:8] == UART2_BASE[31:8]) && axil_arvalid;

  assign any_write_sel = gpio_wsel | uart_wsel | spi_wsel | i2c_wsel | pwm_wsel |
                         adc_wsel | plic_wsel | qspi_wsel | sec_wsel | brk_wsel |
                         can_wsel | clk_wsel | crypto_wsel | dma_wsel | dsp_wsel |
                         jtag_wsel | perf_wsel | pmp_wsel | tpu_wsel | trace_wsel |
                         usb_wsel | dbg_wsel | i2c2_wsel | spi2_wsel | uart2_wsel;
  assign any_read_sel  = gpio_rsel | uart_rsel | spi_rsel | i2c_rsel | pwm_rsel |
                         adc_rsel | plic_rsel | qspi_rsel | sec_rsel | brk_rsel |
                         can_rsel | clk_rsel | crypto_rsel | dma_rsel | dsp_rsel |
                         jtag_rsel | perf_rsel | pmp_rsel | tpu_rsel | trace_rsel |
                         usb_rsel | dbg_rsel | i2c2_rsel | spi2_rsel | uart2_rsel;
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

  rv64_ai_breakpoint_unit u_brk (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(brk_wsel),
    .axil_read(brk_rsel),
    .axil_rdata(brk_rdata),
    .axil_valid(brk_valid),
    .hw_breakpoint(),
    .watchpoint()
  );

  rv64_ai_can_fd u_can (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(can_wsel),
    .axil_read(can_rsel),
    .axil_rdata(can_rdata),
    .axil_valid(can_valid),
    .can_tx(),
    .can_rx(1'b0)
  );

  rv64_ai_clock_sleep_wakeup u_clk (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(clk_wsel),
    .axil_read(clk_rsel),
    .axil_rdata(clk_rdata),
    .axil_valid(clk_valid),
    .sleep_mode(),
    .deep_sleep(),
    .wake_irq()
  );

  rv64_ai_crypto_engine u_crypto (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(crypto_wsel),
    .axil_read(crypto_rsel),
    .axil_rdata(crypto_rdata),
    .axil_valid(crypto_valid),
    .crypto_status()
  );

  rv64_ai_dma_sg u_dma (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(dma_wsel),
    .axil_read(dma_rsel),
    .axil_rdata(dma_rdata),
    .axil_valid(dma_valid),
    .dma_irq()
  );

  rv64_ai_dsp_top u_dsp (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(dsp_wsel),
    .axil_read(dsp_rsel),
    .axil_rdata(dsp_rdata),
    .axil_valid(dsp_valid)
  );

  rv64_ai_jtag_debug u_jtag (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(jtag_wsel),
    .axil_read(jtag_rsel),
    .axil_rdata(jtag_rdata),
    .axil_valid(jtag_valid),
    .jtag_tms(),
    .jtag_tdi(),
    .jtag_tck(),
    .jtag_tdo(1'b0)
  );

  rv64_ai_perf_counters u_perf (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(perf_wsel),
    .axil_read(perf_rsel),
    .axil_rdata(perf_rdata),
    .axil_valid(perf_valid),
    .perf0(),
    .perf1(),
    .perf2(),
    .perf3()
  );

  rv64_ai_pmp u_pmp (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(pmp_wsel),
    .axil_read(pmp_rsel),
    .axil_rdata(pmp_rdata),
    .axil_valid(pmp_valid),
    .pmp_cfg()
  );

  rv64_ai_tpu_top u_tpu (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(tpu_wsel),
    .axil_read(tpu_rsel),
    .axil_rdata(tpu_rdata),
    .axil_valid(tpu_valid)
  );

  rv64_ai_trace_buffer u_trace (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(trace_wsel),
    .axil_read(trace_rsel),
    .axil_rdata(trace_rdata),
    .axil_valid(trace_valid),
    .trace_word()
  );

  rv64_ai_usb_fs u_usb (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(usb_wsel),
    .axil_read(usb_rsel),
    .axil_rdata(usb_rdata),
    .axil_valid(usb_valid),
    .usb_tx(),
    .usb_rx(1'b0)
  );

  rv64_ai_xtensor_extension u_xt (
    .clk(clk),
    .rst_n(rst_n),
    .init(sys_init),
    .instr(32'b0),
    .rs1(64'b0),
    .rs2(64'b0),
    .rd(xt_rd),
    .valid(xt_valid)
  );

  rv64_ai_debug_module u_dbg (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(dbg_wsel),
    .axil_read(dbg_rsel),
    .axil_rdata(dbg_rdata),
    .axil_valid(dbg_valid),
    .debug_halt(),
    .trace_buf()
  );

  rv64_ai_i2c2 u_i2c2 (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(i2c2_wsel),
    .axil_read(i2c2_rsel),
    .axil_rdata(i2c2_rdata),
    .axil_valid(i2c2_valid),
    .scl(),
    .sda()
  );

  rv64_ai_spi2 u_spi2 (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(spi2_wsel),
    .axil_read(spi2_rsel),
    .axil_rdata(spi2_rdata),
    .axil_valid(spi2_valid),
    .sclk(),
    .mosi(),
    .miso(1'b0)
  );

  rv64_ai_uart2 u_uart2 (
    .clk(clk), .rst_n(rst_n),
    .axil_addr(axil_addr),
    .axil_wdata(axil_wdata),
    .axil_wstrb(axil_wstrb),
    .axil_write(uart2_wsel),
    .axil_read(uart2_rsel),
    .axil_rdata(uart2_rdata),
    .axil_valid(uart2_valid),
    .tx(),
    .rx(1'b0)
  );

  rv64_ai_core u_core (
    .clk(clk),
    .rst_n(rst_n),
    .init(sys_init),
    .imem_rdata(mem_rdata),
    .imem_valid(mem_valid),
    .dmem_rdata(mem_rdata),
    .dmem_valid(mem_valid),
    .imem_addr(core_imem_addr),
    .dmem_addr(core_dmem_addr),
    .dmem_wdata(core_dmem_wdata),
    .dmem_wstrb(core_dmem_wstrb),
    .dmem_read(core_dmem_read),
    .dmem_write(core_dmem_write),
    .perf_counter0(perf_counter0),
    .perf_counter1(perf_counter1),
    .perf_counter2(perf_counter2),
    .perf_counter3(perf_counter3),
    .perf_counter4(perf_counter4),
    .perf_counter5(perf_counter5),
    .perf_counter6(perf_counter6),
    .perf_counter7(perf_counter7)
  );

  rv64_ai_memory_subsystem u_mem (
    .clk(clk),
    .rst_n(rst_n),
    .init(sys_init),
    .addr(mem_addr),
    .wdata(mem_wdata),
    .wstrb(mem_wstrb),
    .read(mem_read),
    .write(mem_write),
    .rdata(mem_rdata),
    .valid(mem_valid)
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
                        sec_rsel  ? sec_rdata  :
                        brk_rsel  ? brk_rdata  :
                        can_rsel  ? can_rdata  :
                        clk_rsel  ? clk_rdata  :
                        crypto_rsel ? crypto_rdata :
                        dma_rsel  ? dma_rdata  :
                        dsp_rsel  ? dsp_rdata  :
                        jtag_rsel ? jtag_rdata :
                        perf_rsel ? perf_rdata :
                        pmp_rsel  ? pmp_rdata  :
                        tpu_rsel  ? tpu_rdata  :
                        trace_rsel ? trace_rdata :
                        usb_rsel  ? usb_rdata  :
                        dbg_rsel  ? dbg_rdata  :
                        i2c2_rsel ? i2c2_rdata :
                        spi2_rsel ? spi2_rdata :
                        uart2_rsel ? uart2_rdata : 32'b0;
endmodule
