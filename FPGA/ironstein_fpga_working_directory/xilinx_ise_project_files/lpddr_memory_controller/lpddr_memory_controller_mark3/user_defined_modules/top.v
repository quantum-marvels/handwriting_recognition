`include "./reset_controller/reset_controller.v"
`include "./uart_core/uart_core.v"
`include "./integer_seven_segment_display_controller/integer_seven_segment_display_controller.v"
`include "./traffic_generator/traffic_generator_mark2.v"
`include "../coregen_project/lpddr_memory_controller/user_design/rtl/lpddr_memory_controller.v"

module top(
	// LPDDR connections
	inout  [15:0]					                     dram_dq,
   output [12:0]						                  dram_a,
   output [1:0]								            dram_ba,
   output                                          dram_cke,
   output                                          dram_ras_n,
   output                                          dram_cas_n,
   output                                          dram_we_n,
   output                                          dram_dm,
   inout                                           dram_udqs,
   inout                                           dram_rzq,
   output                                          dram_udm,
   inout                                           dram_dqs,
   output                                          dram_ck,
   output                                          dram_ck_n,
	// clock, reset and calibration signals
	input                                           sys_clk,				// clk
	input 														pll_reset_switch, // undebounced reest input for PLL
	input 														reset_switch, 		// reset switch input
   output                                          sys_rst_n,			// pll reset indicator output
	output wire 												rst0,
	output 														reset,				// reset indicator output
   output                                          calib_done,			// calibration done signal
	// uart signals
	input wire 													uart_rx,
	output wire 												uart_tx,
	// integer seven segment display controller signals
	output wire 												issd_led1_control_signal,
	output wire 												issd_led2_control_signal,
	output wire 												issd_led3_control_signal,
	output wire [7:0] 										issd_display_bits,
	output wire 												issd_led_change_tick,
	// debug 
	output wire 												wr_full
	);
	
	// mcb3 command path signals
	wire														cmd_clk;
	wire														cmd_en;
	wire [2:0]												cmd_instr;
	wire [5:0]												cmd_bl;
	wire [29:0]												cmd_byte_addr;
	wire														cmd_empty;
	wire														cmd_full;
	// mcb3 write path signals
	wire														wr_clk;
	wire														wr_en;
	wire [3:0]												wr_mask;
	wire [31:0]												wr_data;
//	wire														wr_full;
	wire														wr_empty;
	wire [6:0]												wr_count;
	wire														wr_underrun;
	wire														wr_error;
	// mcb3 read path signals
	wire														rd_clk;
	wire														rd_en;
	wire [31:0]												rd_data;
	wire														rd_full;
	wire														rd_empty;
	wire [6:0]												rd_count;
	wire														rd_overflow;
	wire														rd_error;
	
	assign sys_rst_n = ~ pll_reset_switch;
	
	// MODOLE INSTANTIAITONS
		// reset_controller instantiation
		reset_controller rest_controller_instance1(
			.clk(clk),
			.switch_input(reset_switch),
			.reset(reset)
		);
		
		// lpddr_memory_controller instantiaiton
		lpddr_memory_controller lpddr_memory_controller_instance1(
			// LPDDR CONNECTIONS
			.mcb3_dram_dq(dram_dq),
			.mcb3_dram_a(dram_a),
			.mcb3_dram_ba(dram_ba),
			.mcb3_dram_cke(dram_cke),
			.mcb3_dram_ras_n(dram_ras_n),
			.mcb3_dram_cas_n(dram_cas_n),
			.mcb3_dram_we_n(dram_we_n),
			.mcb3_dram_dm(dram_dm),
			.mcb3_dram_udqs(dram_udqs),
			.mcb3_rzq(dram_rzq),
			.mcb3_dram_udm(dram_udm),
			.mcb3_dram_dqs(dram_dqs),
			.mcb3_dram_ck(dram_ck),
			.mcb3_dram_ck_n(dram_ck_n),
			// SYSTEM CLOCK, RESET AND CALIBRATION SIGNALS
			.c3_sys_clk(sys_clk),
			.c3_sys_rst_n(sys_rst_n),
			.c3_calib_done(calib_done),
			.c3_clk0(clk),						// clock signal for the remainig system, output from pll
			.c3_rst0(rst0),
			// MCB3 COMMAND PATH SIGNALS
			.c3_p0_cmd_clk(cmd_clk),
			.c3_p0_cmd_en(cmd_en),
			.c3_p0_cmd_instr(cmd_instr),
			.c3_p0_cmd_bl(cmd_bl),
			.c3_p0_cmd_byte_addr(cmd_byte_addr),
			.c3_p0_cmd_empty(cmd_empty),
			.c3_p0_cmd_full(cmd_full),
			// MCB3 WRITE PATH SIGNALS
			.c3_p0_wr_clk(wr_clk),
			.c3_p0_wr_en(wr_en),
			.c3_p0_wr_mask(wr_mask),
			.c3_p0_wr_data(wr_data),
			.c3_p0_wr_full(wr_full),
			.c3_p0_wr_empty(wr_empty),
			.c3_p0_wr_count(wr_count),
			.c3_p0_wr_underrun(wr_underrun),
			.c3_p0_wr_error(wr_error),
			// MCB3 READ PATH SIGNALS
			.c3_p0_rd_clk(rd_clk),
			.c3_p0_rd_en(rd_en),
			.c3_p0_rd_data(rd_data),
			.c3_p0_rd_full(rd_full),
			.c3_p0_rd_empty(rd_empty),
			.c3_p0_rd_count(rd_count),
			.c3_p0_rd_overflow(rd_overflow),
			.c3_p0_rd_error(rd_error)
		);
		
		// uart_core instantiation
		wire uart_rx_done_tick;
		wire uart_tx_start_transmission;
		wire uart_tx_busy;
		wire [7:0] uart_rx_data_out;
		wire [7:0] uart_tx_data_in;
		
		uart_core #(.BAUDRATE(32'd9600),.FREQUENCY(32'd25000000))
			uart_core_instance1 (
				// control signals
				.clk(clk),
				.reset(reset),
				.rx_done_tick(uart_rx_done_tick),
				.tx_start_transmission(uart_tx_start_transmission),
				.tx_busy(uart_tx_busy),
				// data signals
				.rx(uart_rx),
				.rx_data_out(uart_rx_data_out),
				.tx(uart_tx),
				.tx_data_in(uart_tx_data_in)
			);
		
		// integer_seven_segment_display_controller instantiations
		wire [7:0] issd_integer_to_be_displayed;
		
		integer_seven_segment_display_controller integer_seven_segment_display_controller_instance1(
			.clk(clk),
			.reset(reset),
			.integer_to_be_displayed(issd_integer_to_be_displayed),
			.led1_control_signal(issd_led1_control_signal),
			.led2_control_signal(issd_led2_control_signal),
			.led3_control_signal(issd_led3_control_signal),
			.led_change_tick(issd_led_change_tick),
			.display_bits(issd_display_bits)
		);

		// traffic_generator
		wire [7:0] lpddr_fifo_count;
		
		traffic_generator traffic_generator_instance1(
			// control signals
			.clk(clk),
			.reset(reset),
			// uart signals
			.rx_data_out(uart_rx_data_out),
			.tx_data_in(uart_tx_data_in),
			.rx_done_tick(uart_rx_done_tick),
			.tx_start_transmission(uart_tx_start_transmission),
			// lpddr_memory_controller_signals
				// command path signals
				.cmd_clk(cmd_clk),
				.cmd_en(cmd_en),
				.cmd_instr(cmd_instr),
				.cmd_bl(cmd_bl),
				.cmd_byte_addr(cmd_byte_addr),
				.cmd_empty(cmd_empty),
				.cmd_full(cmd_full),
				// write datapath signals
				.wr_clk(wr_clk),
				.wr_en(wr_en),
				.wr_mask(wr_mask),
				.wr_data(wr_data),
				.wr_full(wr_full),
				.wr_empty(wr_empty),
				.wr_count(wr_count),
				.wr_underrun(wr_underrun),
				.wr_error(wr_error),
				// read_datapath_signals
				.rd_clk(rd_clk),
				.rd_en(rd_en),
				.rd_data(rd_data),
				.rd_full(rd_full),
				.rd_empty(rd_empty),
				.rd_count(rd_count),
				.rd_overflow(rd_overflow),
				.rd_error(rd_error),
				// test signals
				.fifo_count(lpddr_fifo_count)
		);
		
	// LOGIC
		
//		assign issd_integer_to_be_displayed = {1'b0,wr_count[6:0]};
		assign issd_integer_to_be_displayed = lpddr_fifo_count;

endmodule