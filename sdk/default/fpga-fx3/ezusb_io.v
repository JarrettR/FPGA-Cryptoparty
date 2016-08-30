/*!
   Common communication interface of default firmwares
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
   Implements the bi-directional high speed interface of default 
   firmwares using the GPIF-II of FX3. It also includes an scheduler 
   (required if both directions are used at the same time) and short 
   packets (PKTEND).
   
   DMA0: FPGA --> FX3 transfers
   DMA1: FX3 --> FPGA transfers
*/  
module ezusb_io (
        output ifclk,
        input reset,                    // asynchronous reset input
        output reset_out,		// synchronous reset output
        // pins
        input ifclk_in,
        inout [15:0] fd,
	output reg SLWR, SLRD,	        // low active
	output reg SLOE, PKTEND,	// low active
	input EMPTY_FLAG, FULL_FLAG,	// almost full/empty due to flag latency of several clocks, low active
// signals for FPGA -> EZ-USB transfer
        input [15:0] DI,                // data written to EZ-USB
        input DI_valid,			// 1 indicates data valid; DI and DI_valid must be hold if DI_ready is 0
        output DI_ready, 		// 1 if new data are accepted
        input DI_enable,		// setting to 0 disables FPGA -> EZ-USB transfers
        input [15:0] pktend_timeout,	// timeout in multiples of 65536 clocks before a short packet committed
    					// setting to 0 disables this feature
	// signals for EZ-USB -> FPGA transfer
        output reg [15:0] DO,           // data read from EZ-USB
        output reg DO_valid,		// 1 indicated valid data
        input DO_ready,			// setting to 1 enables writing new data to DO in next clock; DO and DO_valid are hold if DO_ready is 0
    					// set to 0 to disable data reads 
        // debug output
        output [6:0] status
    );


    wire ifclk_inbuf, ifclk_fbin, ifclk_fbout, ifclk_out, locked;
    
    IBUFG ifclkin_buf (
	.I(ifclk_in),
	.O(ifclk_inbuf) 
    );

    BUFG ifclk_fb_buf (
        .I(ifclk_fbout),
        .O(ifclk_fbin)
     ); 

    BUFG ifclk_out_buf (
        .I(ifclk_out),
        .O(ifclk)
     ); 

    MMCME2_BASE #(
       .BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_MULT_F(10.0),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(0.0),
       .CLKOUT0_DIVIDE_F(10.0), 
       .CLKOUT1_DIVIDE(1),
       .CLKOUT2_DIVIDE(1),
       .CLKOUT3_DIVIDE(1),
       .CLKOUT4_DIVIDE(1),
       .CLKOUT5_DIVIDE(1),
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(0.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .CLKOUT4_CASCADE("FALSE"), 
       .DIVCLK_DIVIDE(1),
       .REF_JITTER1(0.0),
       .STARTUP_WAIT("FALSE")
    )  isclk_mmcm_inst (
       .CLKOUT0(ifclk_out),
       .CLKFBOUT(ifclk_fbout),
       .CLKIN1(ifclk_inbuf),
       .PWRDWN(1'b0),
       .RST(reset),
       .CLKFBIN(ifclk_fbin),
       .LOCKED(locked)
    );

    reg reset_ifclk = 1;
    reg if_out;
    reg [4:0] if_out_delay;
    reg [15:0] fd_buf;
    reg [15:0] resend_buf0, resend_buf1, resend_buf2, resend_buf3;
    reg [3:0] resend, resend_valid;

    reg SLRD_buf1, SLRD_buf2;
    reg pktend_en;
    reg [31:0] pktend_cnt;
    reg [15:0] DO_buf1, DO_buf2, DO_buf3;
    reg DO_buf1_valid, DO_buf2_valid, DO_buf3_valid;
    
    wire SLRD_next, SLWR_next;

    // FPGA <-> EZ-USB signals
    assign fd = if_out ? fd_buf : {16{1'bz}};

    assign status = { if_out, !SLRD, !SLWR, DI_valid, DO_ready, !EMPTY_FLAG, !FULL_FLAG };

    assign reset_out = reset || reset_ifclk;
    
    assign DI_ready = !reset_ifclk && FULL_FLAG && if_out && !resend[0];
    assign SLWR_next = reset_ifclk || !FULL_FLAG || !if_out || !(resend[0] || DI_valid);
    
    assign SLRD_next = reset_ifclk || !EMPTY_FLAG || if_out || !DO_ready || DO_buf1_valid;
    
    always @ (posedge ifclk)
    begin
	reset_ifclk <= reset || !locked;

	SLRD <= SLRD_next;
	SLRD_buf1 <= SLRD;
	SLRD_buf2 <= SLRD_buf1;
	
	SLWR <= SLWR_next;
	
	SLOE <= reset_ifclk || if_out;
	
	// FPGA --> EZ-USB
        if ( reset_ifclk )
        begin
	    resend <= 4'd0;
	    resend_valid <= 4'd0;
	end else if ( if_out )  
	begin
	    if ( FULL_FLAG ) 
	    begin
		fd_buf <= resend[0] ? resend_buf0 : DI;
		resend_buf0 <= resend_buf1;
		resend_buf1 <= resend_buf2;
		resend_buf2 <= resend_buf3;
		resend_buf3 <= DI;
		resend_valid <= { !resend[0] && DI_valid, resend_valid[3:1] };
		resend <= { 1'b0, resend[3:1] };
	    end else
	    begin
		resend <= resend_valid;  	// FLAGS are received three clocks after data.
	    end
	end
	    
	// EZ-USB -> FPGA
	// SLRD -> DATA,FLAG latency is two clocks
	// DATA - FLAG latency is 0
	// if DO_ready goes low two data word have to be buffered
        if ( reset_ifclk )
        begin
	    DO_buf1_valid = 1'b0;
	    DO_buf2_valid = 1'b0;
	    DO_buf3_valid = 1'b0;
	end else if ( EMPTY_FLAG && !SLRD_buf2 )	// EZ-USB -> FPGA: valid data
	begin
	    if ( DO_ready && !DO_buf1_valid )
	    begin
		DO <= fd;
	    end else
	    begin					// buffers data if DO_ready has been deasserted
		DO_buf1 <= fd;
		DO_buf2 <= DO_buf1;
		DO_buf3 <= DO_buf2;
		DO_buf1_valid <= 1'b1;
		DO_buf2_valid <= DO_buf1_valid;
		DO_buf3_valid <= DO_buf2_valid;
	    end
	    if ( DO_ready ) DO_valid = !DO_buf1_valid;
	end else if ( DO_ready ) 
	begin
	    if ( DO_buf3_valid )			// writes buffered data
	    begin
		DO <= DO_buf3;
		DO_buf3_valid <= 1'b0;
	    end else if ( DO_buf2_valid )		// writes buffered data
	    begin
		DO <= DO_buf2;
		DO_buf2_valid <= 1'b0;
	    end else if ( DO_buf1_valid )		// writes buffered data
	    begin
		DO <= DO_buf1;
		DO_buf1_valid <= 1'b0;
	    end 
	    DO_valid <= DO_buf1_valid;
	end 
	
	// select direction
	if ( reset_ifclk )
	begin
	    if_out_delay = 5'd0;
	    if_out <= DI_enable;  	// direction of EZ-USB interface: 1 means FPGA --> EZ_USB
	end else if ( SLWR && SLRD && SLWR_next && SLRD_next ) 
	begin
	    if_out_delay <= { 1'b1, if_out_delay[4:1] };
	    if ( if_out_delay[0] ) if_out <= DI_enable && (!DO_ready || !EMPTY_FLAG || DO_buf1_valid);
	end else
	begin
	    if_out_delay = 5'd0;
	end

	// PKTEND processing
        if ( reset_ifclk || !SLWR || !SLWR_next )
        begin
    	    pktend_en <= !reset_ifclk;
    	    pktend_cnt <= 32'd0;
    	    PKTEND <= 1'b1;
    	end else if ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) )
    	begin
    	    PKTEND <= 1'b1;
    	    pktend_en <= 1'b0;
    	end else 
    	begin
    	    PKTEND <= 1'b1;
	    pktend_en <= pktend_en && FULL_FLAG;   		// packet is sent if full flag is asserted
	    pktend_cnt <= pktend_cnt + 32'd1;
    	end
    end


endmodule

