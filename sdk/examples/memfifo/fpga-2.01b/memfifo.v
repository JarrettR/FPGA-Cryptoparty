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
   Top level module: glues everything together.    
*/  

`define IDX(x) (((x)+1)*(8)-1):((x)*(8))

module memfifo (
	input ifclk_in,
	input reset,
	// debug
	output [9:0] led1,
	input SW8,
	// ez-usb
        inout [15:0] fd,
	output SLWR, SLRD,
	output SLOE, FIFOADDR0, FIFOADDR1, PKTEND,
	input FLAGA, FLAGB,
	// GPIO
	input gpio_clk, gpio_dir,
	inout gpio_dat
    );

    wire reset_usb;
    wire ifclk;
    reg reset_ifclk;
    wire [9:0] status;
    wire [3:0] if_status;
    wire [3:0] mode;
    
    // input fifo
    reg [31:0] DI;
    wire FULL, WRERR, USB_DO_valid;
    reg WREN, wrerr_buf;
    wire [15:0] USB_DO;
    reg [31:0] in_data;
    reg [3:0] wr_cnt;
    reg [6:0] test_cnt;
    reg [13:0] test_cs;
    reg in_valid;
    wire test_sync;
    reg [1:0] clk_div;

    // output fifo
    wire [31:0] DO;
    wire EMPTY, RDERR, USB_DI_ready;
    reg RDEN, rderr_buf, USB_DI_valid;
    reg [31:0] rd_buf;
    reg rd_cnt;
    

    bram_fifo bram_fifo_inst (
        .reset(reset || reset_usb),
	// input fifo interface
	.DI(DI),			// must be hold while FULL is asserted
        .FULL(FULL),                    // 1-bit output: Full flag
        .WRERR(WRERR),                  // 1-bit output: Write error
        .WREN(WREN),                    // 1-bit input: Write enable
        .WRCLK(ifclk),                  // 1-bit input: Rising edge write clock.
	// output fifo interface
	.DO(DO),
	.EMPTY(EMPTY),                  // 1-bit output: Empty flag
        .RDERR(RDERR),                  // 1-bit output: Read error
        .RDCLK(ifclk),                  // 1-bit input: Read clock
        .RDEN(RDEN)                     // 1-bit input: Read enable
	// for debugging
    );

    ezusb_gpio gpio_inst (
	.clk(ifclk),			// system clock, minimum frequency is 24 MHz
	// hardware pins
	.gpio_clk(gpio_clk),		// data clock; data sent on both edges
	.gpio_dir(gpio_dir),		// 1: output, 0->1 transition latches input data and starts writing
	.gpio_dat(gpio_dat),
	// interface
	.in(mode),
	.out(4'd0)			// wired or: GPIO's not used for output should be 0
    );

    ezusb_io #(
	.OUTEP(2),		        // EP for FPGA -> EZ-USB transfers
	.INEP(6) 		        // EP for EZ-USB -> FPGA transfers 
    ) ezusb_io_inst (
        .ifclk(ifclk),
        .reset(reset),   		// asynchronous reset input
        .reset_out(reset_usb),		// synchronous reset output
        // pins
        .ifclk_in(ifclk_in),
        .fd(fd),
	.SLWR(SLWR),
	.SLRD(SLRD),
	.SLOE(SLOE), 
	.PKTEND(PKTEND),
	.FIFOADDR({FIFOADDR1, FIFOADDR0}), 
	.EMPTY_FLAG(FLAGA),
	.FULL_FLAG(FLAGB),
	// signals for FPGA -> EZ-USB transfer
	.DI(rd_buf[15:0]),		// data written to EZ-USB
	.DI_valid(USB_DI_valid),	// 1 indicates data valid; DI and DI_valid must be hold if DI_ready is 0
	.DI_ready(USB_DI_ready),	// 1 if new data are accepted
	.DI_enable(1'b1),		// setting to 0 disables FPGA -> EZ-USB transfers
        .pktend_timeout(16'd73),	// timeout in multiples of 65536 clocks (approx. 0.1s @ 48 MHz) before a short packet committed
    					// setting to 0 disables this feature
	// signals for EZ-USB -> FPGA transfer
	.DO(USB_DO),			// data read from EZ-USB
	.DO_valid(USB_DO_valid),	// 1 indicated valid data
	.DO_ready((mode[1:0]==2'd0) && !reset_ifclk && !FULL),	// setting to 1 enables writing new data to DO in next clock; DO and DO_valid are hold if DO_ready is 0
        // debug output
	.status(if_status)	
    );

    // debug board LEDs    
    assign led1 =  { EMPTY, FULL, wrerr_buf, rderr_buf, if_status, FLAGB, FLAGA };
    
    assign test_sync = wr_cnt[0] || (wr_cnt == 4'd14);

    always @ (posedge ifclk)
    begin
	reset_ifclk <= reset || reset_usb;
	
	if ( reset_ifclk ) 
	begin
	    rderr_buf <= 1'b0;
	    wrerr_buf <= 1'b0;
	end else
	begin
	    rderr_buf <= rderr_buf || RDERR;
	    wrerr_buf <= wrerr_buf || WRERR;
	end

	// FPGA -> EZ-USB FIFO
        if ( reset_ifclk )
        begin
	    rd_cnt <= 1'd0;
	    USB_DI_valid <= 1'd0;
	end else if ( USB_DI_ready )
	begin
	    USB_DI_valid <= !EMPTY;
	    if ( !EMPTY )
	    begin
	        if ( rd_cnt == 1'd0 )
	        begin
	    	    rd_buf <= DO;
		end else
	    	begin
	    	    rd_buf[15:0] <= rd_buf[31:16];
		end
		rd_cnt <= rd_cnt + 1'd1;
	    end
	end

	RDEN <= !reset_ifclk && USB_DI_ready && !EMPTY && (rd_cnt==1'd0);
	
	if ( reset_ifclk ) 
	begin
	    in_data <= 31'd0;
	    in_valid <= 1'b0;
	    wr_cnt <= 4'd0;
	    test_cnt <= 7'd0;
	    test_cs <= 12'd47;
	    WREN <= 1'b0;
	    clk_div <= 2'd3;
	    DI <= 32'h05040302;
	end else if ( !FULL )
	begin
	    if ( in_valid ) DI <= in_data;
//	    DI <= DI + 32'h03030303;

    	    if ( mode[1:0] == 2'd0 )		// input from USB
    	    begin
    		if ( USB_DO_valid )
    		begin
		    in_data <= { USB_DO, in_data[31:16] };
		    in_valid <= wr_cnt[0];
	    	    wr_cnt <= wr_cnt + 4'd1;
	    	end else
	    	begin
		    in_valid <= 1'b0;
		end
    	    end else if ( clk_div == 2'd0 )	// test data generator 
	    begin
	        if ( wr_cnt == 4'd15 )
	        begin
	    	    test_cs <= 12'd47;
		    in_data[30:24] <= test_cs[6:0] ^ test_cs[13:7];
		end else
		begin
		    test_cnt <= test_cnt + 7'd111;
		    test_cs <= test_cs + { test_sync, test_cnt };
		    in_data[30:24] <= test_cnt;
		end
		in_data[31] <= test_sync;
		in_data[23:0] <= in_data[31:8];
		in_valid <= wr_cnt[1:0] == 2'd3;
	    	wr_cnt <= wr_cnt + 4'd1;
	    end else 
	    begin
	        in_valid <= 1'b0;
	    end

	    if ( (mode[1:0]==2'd1) || ((mode[1:0]==2'd3) && SW8 ) ) 
	    begin
	        clk_div <= 2'd0;	// data rate: 48 MByte/s
	    end else 
	    begin
	        clk_div <= clk_div + 2'd1;	// data rate: 12 MByte/s
	    end
	end
	WREN <= !reset_ifclk && in_valid && !FULL;
//	WREN <= !reset_ifclk && !FULL;
    end
	    
endmodule

