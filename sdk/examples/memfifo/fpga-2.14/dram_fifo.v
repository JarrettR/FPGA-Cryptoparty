/*!
   memfifo -- Connects the bi-directional high speed interface of default firmware to a FIFO built of on-board SDRAM or on-chip BRAM
   Copyright (C) 2009-2016 ZTEX GmbH.
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/
/* 
   Implements a huge FIFO  from all SDRAM.
*/  

module fifo_512x128 #(
	parameter ALMOST_EMPTY_OFFSET1 = 13'h0020,    // Sets the almost empty threshold
	parameter ALMOST_EMPTY_OFFSET2 = 13'h0006,    // Sets the almost empty threshold
        parameter ALMOST_FULL_OFFSET1 = 13'h0020,     // Sets almost full threshold
        parameter ALMOST_FULL_OFFSET2 = 13'h0006,     // Sets almost full threshold
        parameter FIRST_WORD_FALL_THROUGH = "TRUE"   // Sets the FIFO FWFT to FALSE, TRUE
    ) (
        input RST,                     // 1-bit input: Reset
	// input signals
        input [127:0] DI,               // 64-bit input: Data input
        output FULL,                    // 1-bit output: Full flag
        output ALMOSTFULL1,       	// 1-bit output: Almost full flag
        output ALMOSTFULL2,       	// 1-bit output: Almost full flag
        output WRERR,                   // 1-bit output: Write error
        input WRCLK,                    // 1-bit input: Rising edge write clock.
        input WREN,                     // 1-bit input: Write enable
	// output signals
	output [127:0] DO,
	output EMPTY,                   // 1-bit output: Empty flag
        output ALMOSTEMPTY1,            // 1-bit output: Almost empty flag
        output ALMOSTEMPTY2,            // 1-bit output: Almost empty flag
        output RDERR,                   // 1-bit output: Read error
        input RDCLK,                    // 1-bit input: Read clock
        input RDEN                      // 1-bit input: Read enable
    );

    FIFO36E1 #(
	.ALMOST_EMPTY_OFFSET(ALMOST_EMPTY_OFFSET1),
        .ALMOST_FULL_OFFSET(ALMOST_FULL_OFFSET1),
        .DATA_WIDTH(72),
        .DO_REG(1),
        .EN_ECC_READ("TRUE"),
        .EN_ECC_WRITE("TRUE"),
        .EN_SYN("FALSE"),
        .FIFO_MODE("FIFO36_72"), 
        .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH),
        .INIT(72'h000000000000000000),
        .SIM_DEVICE("7SERIES"), 
        .SRVAL(72'h000000000000000000)
    )
    U (
      .DBITERR(),
      .ECCPARITY(),
      .SBITERR(),
      .DO(DO[127:64]),
      .DOP(),
      .ALMOSTEMPTY(ALMOSTEMPTY1),
      .ALMOSTFULL(ALMOSTFULL1),
      .EMPTY(EMPTY_U),
      .FULL(FULL_U),
      .RDCOUNT(),
      .RDERR(RDERR_U),
      .WRCOUNT(),
      .WRERR(WRERR_U),
      .INJECTDBITERR(1'b0),
      .INJECTSBITERR(1'b0),
      .RDCLK(RDCLK),
      .RDEN(RDEN),
      .REGCE(1'b0),
      .RST(RST),
      .RSTREG(1'b0),
      .WRCLK(WRCLK),
      .WREN(WREN),
      .DI(DI[127:64]),
      .DIP(4'd0)
   );

    FIFO36E1 #(
	.ALMOST_EMPTY_OFFSET(ALMOST_EMPTY_OFFSET2),
        .ALMOST_FULL_OFFSET(ALMOST_FULL_OFFSET2),
        .DATA_WIDTH(72),
        .DO_REG(1),
        .EN_ECC_READ("TRUE"),
        .EN_ECC_WRITE("TRUE"),
        .EN_SYN("FALSE"),
        .FIFO_MODE("FIFO36_72"), 
        .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH),
        .INIT(72'h000000000000000000),
        .SIM_DEVICE("7SERIES"), 
        .SRVAL(72'h000000000000000000)
    )
    L (
      .DBITERR(),
      .ECCPARITY(),
      .SBITERR(),
      .DO(DO[63:0]),
      .DOP(),
      .ALMOSTEMPTY(ALMOSTEMPTY2),
      .ALMOSTFULL(ALMOSTFULL2),
      .EMPTY(EMPTY_L),
      .FULL(FULL_L),
      .RDCOUNT(),
      .RDERR(RDERR_L),
      .WRCOUNT(),
      .WRERR(WRERR_L),
      .INJECTDBITERR(1'b0),
      .INJECTSBITERR(1'b0),
      .RDCLK(RDCLK),
      .RDEN(RDEN),
      .REGCE(1'b0),
      .RST(RST),
      .RSTREG(1'b0),
      .WRCLK(WRCLK),
      .WREN(WREN),
      .DI(DI[63:0]),
      .DIP(4'd0)
   );
   
   assign EMPTY = EMPTY_U || EMPTY_L;
   assign FULL = FULL_U || FULL_L;
   assign RDERR = RDERR_U || RDERR_L;
   assign WRERR = WRERR_U || WRERR_L;
   
endmodule


module dram_fifo # (
	// fifo parameters, see "7 Series Memory Resources" user guide (ug743)
	parameter ALMOST_EMPTY_OFFSET1 = 13'h0010,      // Sets the almost empty threshold
	parameter ALMOST_EMPTY_OFFSET2 = 13'h0010,      // Sets the almost empty threshold
        parameter ALMOST_FULL_OFFSET1 = 13'h0010,       // Sets almost full threshold
        parameter ALMOST_FULL_OFFSET2 = 13'h0010,       // Sets almost full threshold
        parameter FIRST_WORD_FALL_THROUGH = "TRUE",  	// Sets the FIFO FWFT to FALSE, TRUE
        // clock dividers for PLL outputs not used for memory interface, VCO frequency is 806 MHz
      	parameter CLKOUT2_DIVIDE = 1,
      	parameter CLKOUT3_DIVIDE = 1,
      	parameter CLKOUT4_DIVIDE = 1,
      	parameter CLKOUT5_DIVIDE = 1,
      	parameter CLKOUT2_PHASE = 0.0,
      	parameter CLKOUT3_PHASE = 0.0,
      	parameter CLKOUT4_PHASE = 0.0,
      	parameter CLKOUT5_PHASE = 0.0
    ) (
	input fxclk_in,					// 26 MHz input clock pin
        input reset,
        output reset_out,				// reset output
      	output clkout2, clkout3, clkout4, clkout5,	// PLL clock outputs not used for memory interface
        
	// ddr3 pins
	inout [15:0] ddr3_dq,
	inout [1:0] ddr3_dqs_n,
	inout [1:0] ddr3_dqs_p,
	output [13:0] ddr3_addr,
	output [2:0] ddr3_ba,
	output ddr3_ras_n,
	output ddr3_cas_n,
	output ddr3_we_n,
        output ddr3_reset_n,
	output [0:0] ddr3_ck_p,
        output [0:0] ddr3_ck_n,
	output [0:0] ddr3_cke,
        output [1:0] ddr3_dm,
	output [0:0] ddr3_odt,
        
	// input fifo interface, see "7 Series Memory Resources" user guide (ug743)
        input [127:0] DI,               // 64-bit input: Data input
        output FULL,                    // 1-bit output: Full flag
        output ALMOSTFULL1,       	// 1-bit output: Almost full flag
        output ALMOSTFULL2,       	// 1-bit output: Almost full flag
        output WRERR,                   // 1-bit output: Write error
        input WRCLK,                    // 1-bit input: Rising edge write clock.
        input WREN,                     // 1-bit input: Write enable

	// output fifo interface, see "7 Series Memory Resources" user guide (ug743)
	output [127:0] DO,
	output EMPTY,                   // 1-bit output: Empty flag
        output ALMOSTEMPTY1,            // 1-bit output: Almost empty flag
        output ALMOSTEMPTY2,            // 1-bit output: Almost empty flag
        output RDERR,                   // 1-bit output: Read error
        input RDCLK,                    // 1-bit input: Read clock
        input RDEN,                     // 1-bit input: Read enable
        
	// free memory
	output [APP_ADDR_WIDTH:0] mem_free_out,

	// for debugging
	output [9:0] status
    );

    localparam APP_DATA_WIDTH = 128;	
    localparam APP_MASK_WIDTH = 16;
    localparam APP_ADDR_WIDTH = 24;

    wire pll_fb, clk200_in, clk400_in, clk200, clk400, uiclk, fxclk;
    
    wire mem_reset, ui_clk_sync_rst, init_calib_complete;
    reg reset_buf;

// memory control
    reg [7:0] wr_cnt, rd_cnt;
    reg [APP_ADDR_WIDTH-1:0] mem_wr_addr, mem_rd_addr;
    reg [APP_ADDR_WIDTH:0] mem_free;
    reg rd_mode, wr_mode_buf;
    wire wr_mode;

// fifo control
    wire infifo_empty, infifo_almost_empty, outfifo_almost_full, infifo_rden;
    wire [APP_DATA_WIDTH-1:0] infifo_do;
    reg [6:0] outfifo_pending;
    reg [9:0] rd_cnt_dbg;

// debug
    wire infifo_err_w, outfifo_err_w;
    reg infifo_err, outfifo_err, outfifo_err_uf;

// memory interface    
    reg [APP_ADDR_WIDTH-1:0] app_addr;
    reg [2:0] app_cmd;
    reg app_en, app_wdf_wren;
    wire app_rdy, app_wdf_rdy, app_rd_data_valid;
    reg [APP_DATA_WIDTH-1:0] app_wdf_data;
    wire [APP_DATA_WIDTH-1:0] app_rd_data;

    BUFG fxclk_buf (
	.I(fxclk_in),
	.O(fxclk) 
    );

    BUFG clk200_buf (  		// sometimes it is generated automatically, sometimes not ...
	.I(clk200_in),
	.O(clk200) 
    );

    BUFG clk400_buf (
	.I(clk400_in),
	.O(clk400) 
    );

    PLLE2_BASE #(
    	.BANDWIDTH("LOW"),
      	.CLKFBOUT_MULT(31),     // f_VCO = 806 MHz (valid: 800 .. 1600 MHz)
      	.CLKFBOUT_PHASE(0.0),
      	.CLKIN1_PERIOD(0.0),
      	.CLKOUT0_DIVIDE(2),	// 403 Mz
      	.CLKOUT1_DIVIDE(4),	// 201.5 MHz
      	.CLKOUT2_DIVIDE(CLKOUT2_DIVIDE),
      	.CLKOUT3_DIVIDE(CLKOUT3_DIVIDE),
      	.CLKOUT4_DIVIDE(CLKOUT4_DIVIDE),
      	.CLKOUT5_DIVIDE(CLKOUT5_DIVIDE),
      	.CLKOUT0_DUTY_CYCLE(0.5),
      	.CLKOUT1_DUTY_CYCLE(0.5),
      	.CLKOUT2_DUTY_CYCLE(0.5),
      	.CLKOUT3_DUTY_CYCLE(0.5),
      	.CLKOUT4_DUTY_CYCLE(0.5),
      	.CLKOUT5_DUTY_CYCLE(0.5),
      	.CLKOUT0_PHASE(0.0),
      	.CLKOUT1_PHASE(0.0),
      	.CLKOUT2_PHASE(CLKOUT2_PHASE),
      	.CLKOUT3_PHASE(CLKOUT3_PHASE),
      	.CLKOUT4_PHASE(CLKOUT4_PHASE),
      	.CLKOUT5_PHASE(CLKOUT5_PHASE),
      	.DIVCLK_DIVIDE(1),
      	.REF_JITTER1(0.0),
      	.STARTUP_WAIT("FALSE")
    )
    dram_fifo_pll_inst (
      	.CLKIN1(fxclk),
      	.CLKOUT0(clk400_in),
      	.CLKOUT1(clk200_in),   
      	.CLKOUT2(clkout2),   
      	.CLKOUT3(clkout3),   
      	.CLKOUT4(clkout4),   
      	.CLKOUT5(clkout5),   
      	.CLKFBOUT(pll_fb),
      	.CLKFBIN(pll_fb),
      	.PWRDWN(1'b0),
      	.RST(1'b0)
    );
    
    fifo_512x128 #(
	.ALMOST_EMPTY_OFFSET1(13'h0026),
	.ALMOST_EMPTY_OFFSET2(13'h0006),
	.ALMOST_FULL_OFFSET1(ALMOST_FULL_OFFSET1),
	.ALMOST_FULL_OFFSET2(ALMOST_FULL_OFFSET2),
        .FIRST_WORD_FALL_THROUGH("TRUE")
    ) infifo (
	.RST(reset_buf),
	// output
	.DO(infifo_do),
	.EMPTY(infifo_empty),
	.ALMOSTEMPTY1(infifo_almost_empty),
	.ALMOSTEMPTY2(),
	.RDERR(infifo_err_w),
	.RDCLK(uiclk),
	.RDEN(infifo_rden),
	// input
        .DI(DI),
	.FULL(FULL),
        .ALMOSTFULL1(ALMOSTFULL1),
        .ALMOSTFULL2(ALMOSTFULL2),
        .WRERR(WRERR),
        .WRCLK(WRCLK),
        .WREN(WREN)
    );

    fifo_512x128 #(
	.ALMOST_FULL_OFFSET1(13'h0044),
	.ALMOST_FULL_OFFSET2(13'h0004),
	.ALMOST_EMPTY_OFFSET1(ALMOST_EMPTY_OFFSET1),
	.ALMOST_EMPTY_OFFSET2(ALMOST_EMPTY_OFFSET2),
        .FIRST_WORD_FALL_THROUGH(FIRST_WORD_FALL_THROUGH)
    ) outfifo (
	.RST(reset_buf),
	// output
	.DO(DO),
	.EMPTY(EMPTY),
	.ALMOSTEMPTY1(ALMOSTEMPTY1),
	.ALMOSTEMPTY2(ALMOSTEMPTY2),
	.RDERR(RDERR),
	.RDCLK(RDCLK),
	.RDEN(RDEN),
	// input
        .DI(app_rd_data),
	.FULL(),
        .ALMOSTFULL1(outfifo_almost_full),
        .ALMOSTFULL2(),
        .WRERR(outfifo_err_w),
        .WRCLK(uiclk),
        .WREN(app_rd_data_valid)
    );

    mig_7series_0   mem0 (
// Memory interface ports
	.ddr3_dq(ddr3_dq),
        .ddr3_dqs_n(ddr3_dqs_n),
        .ddr3_dqs_p(ddr3_dqs_p),
        .ddr3_addr(ddr3_addr),
        .ddr3_ba(ddr3_ba),
        .ddr3_ras_n(ddr3_ras_n),
        .ddr3_cas_n(ddr3_cas_n),
        .ddr3_we_n(ddr3_we_n),
        .ddr3_reset_n(ddr3_reset_n),
        .ddr3_ck_p(ddr3_ck_p[0]),
        .ddr3_ck_n(ddr3_ck_n[0]),
        .ddr3_cke(ddr3_cke[0]),
	.ddr3_dm(ddr3_dm),
        .ddr3_odt(ddr3_odt[0]),
// Application interface ports
        .app_addr( {1'b0, app_addr, 3'b000} ),	
        .app_cmd(app_cmd),
        .app_en(app_en),
        .app_rdy(app_rdy),
        .app_wdf_rdy(app_wdf_rdy), 
        .app_wdf_data(app_wdf_data),
        .app_wdf_mask({ APP_MASK_WIDTH {1'b0} }),
        .app_wdf_end(app_wdf_wren), // always the last word in 4:1 mode 
        .app_wdf_wren(app_wdf_wren),
        .app_rd_data(app_rd_data),
        .app_rd_data_end(app_rd_data_end),
        .app_rd_data_valid(app_rd_data_valid),
        .app_sr_req(1'b0), 
        .app_sr_active(),
        .app_ref_req(1'b0),
        .app_ref_ack(),
        .app_zq_req(1'b0),
        .app_zq_ack(),
        .ui_clk(uiclk),
        .ui_clk_sync_rst(ui_clk_sync_rst),
        .init_calib_complete(init_calib_complete),
        .sys_rst(!reset),
// clocks inputs
        .sys_clk_i(clk400),
        .clk_ref_i(clk200)
    );

    assign mem_reset = reset || ui_clk_sync_rst || !init_calib_complete;
    assign reset_out = reset_buf;
    assign wr_mode = wr_mode_buf && app_wdf_rdy && !infifo_empty;
    assign infifo_rden = app_rdy && wr_mode && !rd_mode;
    
    assign status[0] = init_calib_complete;
    assign status[1] = app_rdy;
    assign status[2] = app_wdf_rdy;
    assign status[3] = app_rd_data_valid;
    assign status[4] = infifo_err;
    assign status[5] = outfifo_err;
    assign status[6] = outfifo_err_uf;
    assign status[7] = wr_mode;
    assign status[8] = rd_mode;
    assign status[9] = !reset;
    
    assign mem_free_out = mem_free;

    always @ (posedge uiclk)
    begin
// reset
	reset_buf <= mem_reset;

	// used for debugging only
	if ( reset_buf ) outfifo_err <= 1'b0;
	else if ( outfifo_err_w ) outfifo_err <= 1'b1;
	if ( reset_buf ) infifo_err <= 1'b0;
	else if ( infifo_err_w ) infifo_err <= 1'b1;

	// memory interface --> outfifo
	if ( reset_buf )
	begin
	    outfifo_err_uf <= 1'b0;
	    outfifo_pending <= 7'd0;
	end else if ( app_rd_data_valid && !(rd_mode && app_rdy) ) 
	begin
	    if ( outfifo_pending != 7'd0 ) 
	    begin
		outfifo_pending = outfifo_pending - 7'd1;
	    end else 
	    begin
	        outfifo_err_uf <= 1'b1;
	    end
	end else if ( (!app_rd_data_valid) && rd_mode && app_rdy ) 
	begin
	    outfifo_pending = outfifo_pending + 7'd1;
	end
	
	// wr_mode
	if ( reset_buf )
	begin
	    wr_mode_buf <= 1'b0;
	end else if ( infifo_empty || (!app_wdf_rdy) || wr_cnt[7] || ( mem_free[APP_ADDR_WIDTH:1] == {APP_ADDR_WIDTH{1'b0}} ) )     //  at maximum 128 words
	begin
	    wr_mode_buf <= 1'b0;
	end else if ( (!rd_mode) && !infifo_almost_empty && (mem_free[APP_ADDR_WIDTH:5] != {(APP_ADDR_WIDTH-4){1'b0}}) )  // at least 32 words
	begin
	    wr_mode_buf <= 1'b1;
	end

	// rd_mode
	if ( reset_buf )
	begin
	    rd_mode <= 1'b0;
	end else if ( rd_mode || outfifo_almost_full || outfifo_pending[6] || rd_cnt[7] || ( mem_free[APP_ADDR_WIDTH-1:0] == {(APP_ADDR_WIDTH){1'b1}}) || mem_free[APP_ADDR_WIDTH] )	 //  at maximum 128 words )
	begin
	    rd_mode <= 1'b0;
	end else if ( (!wr_mode_buf) && (outfifo_pending[6:5] == 2'd0) && (mem_free[APP_ADDR_WIDTH-1:5] != {(APP_ADDR_WIDTH-5){1'b1}}) )  // at least 32 words
	begin
	    rd_mode <= 1'b1;
	end

	if ( reset_buf )
	begin
    	    rd_cnt_dbg <= 10'd0;
    	end else if ( app_rd_data_valid )
	begin
    	    rd_cnt_dbg <= rd_cnt_dbg + 1;
    	end;
	
// command generator
	if ( reset_buf )
	begin
	    app_en <= 1'b0;
	    mem_wr_addr <= {APP_ADDR_WIDTH{1'b0}};
	    mem_rd_addr <= {APP_ADDR_WIDTH{1'b0}};
  	    mem_free <= {1'b1, {APP_ADDR_WIDTH{1'b0}}};
	    wr_cnt <= 8'd0;
	    rd_cnt <= 8'd0;
	end else if ( app_rdy )
	begin
	    if ( rd_mode )
	    begin
		app_cmd <= 3'b001;
		app_en <= 1'b1;
		app_addr <= mem_rd_addr;
		mem_rd_addr <= mem_rd_addr + 1;
	        rd_cnt <= rd_cnt + 1;
		wr_cnt <= 8'd0;
	        mem_free <= mem_free + 1;
	    end else if ( wr_mode )
	    begin
		app_cmd <= 3'b000;
		app_en <= 1'b1;
		app_addr <= mem_wr_addr;
		app_wdf_data <= infifo_do;
//		app_wdf_data <= { 8{mem_wr_addr[15:0]} };
//		app_wdf_data <= { {7{mem_wr_addr[15:0]}},  infifo_do[71:64], infifo_do[7:0] };
		mem_wr_addr <= mem_wr_addr + 1;
		mem_free <= mem_free - 1;
		wr_cnt <= wr_cnt + 1;
		rd_cnt <= 8'd0;
	    end else
	    begin
		app_en <= 1'b0;
		wr_cnt <= 8'd0;
		rd_cnt <= 8'd0;
	    end
	end

	if ( reset_buf )
	begin
	    app_wdf_wren <= 1'b0;
//   infifo_rden <= 1'b0;
	end else if ( app_rdy && (!rd_mode) && wr_mode )
	begin
	    app_wdf_wren <= 1'b1;
//   infifo_rden <= 1'b1;
	end else 
	begin
	    if ( app_wdf_rdy ) app_wdf_wren <= 1'b0;
//   infifo_rden <= 1'b0;
	end
	

    end

endmodule
