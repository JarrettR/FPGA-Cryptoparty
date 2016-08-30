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

module memfifo (
	input fxclk_in,
	input ifclk_in,
	input reset,
	inout [3:0] gpio_n,
	// debug
	output led,
	output [9:0] led1,
	output [19:0] led2,
	input SW10,
	// ddr3 
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
	// ez-usb
        inout [15:0] fd,
	output SLWR, SLRD,
	output SLOE, PKTEND,
	input EMPTY_FLAG, FULL_FLAG
    );

    wire reset_mem, reset_usb;
    wire ifclk;
    reg reset_ifclk;
    wire [24:0] mem_free;
    wire [9:0] status;
    wire [6:0] if_status;
    wire [3:0] gpio_in;
    
    // input fifo
    reg [127:0] DI;
    wire FULL, WRERR, USB_DO_valid;
    reg WREN, wrerr_buf, USB_DO_ready, FULL_buf1, FULL_buf2;
    wire [15:0] USB_DO;
    reg [127:0] in_data;
    reg [2:0] wr_cnt;
    reg [6:0] test_cnt0, test_cnt1;
    reg [13:0] test_cs;
    wire [13:0] test_cs_w;
    reg in_valid;
    reg [3:0] clk_div;

    // output fifo
    wire [127:0] DO;
    wire EMPTY, RDERR, USB_DI_ready;
    reg RDEN, rderr_buf, USB_DI_valid;
    reg [127:0] rd_buf;
    reg [2:0] rd_cnt;

    dram_fifo #(
        .FIRST_WORD_FALL_THROUGH("TRUE"),  			// Sets the FIFO FWFT to FALSE, TRUE
	.ALMOST_EMPTY_OFFSET2(13'h0008)
    ) dram_fifo_inst (
	.fxclk_in(fxclk_in),					// 26 MHz input clock pin
        .reset(reset || reset_usb),
        .reset_out(reset_mem),					// reset output
      	.clkout2(),	 					// PLL clock outputs not used for memory interface
      	.clkout3(),	
      	.clkout4(),	
      	.clkout5(),	
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
        .ddr3_ck_p(ddr3_ck_p),
        .ddr3_ck_n(ddr3_ck_n),
        .ddr3_cke(ddr3_cke),
	.ddr3_dm(ddr3_dm),
        .ddr3_odt(ddr3_odt),
	// input fifo interface, see "7 Series Memory Resources" user guide (ug743)
	.DI(DI),
        .FULL(FULL),                    // 1-bit output: Full flag
        .ALMOSTFULL1(),  	     	// 1-bit output: Almost full flag
        .ALMOSTFULL2(),  	     	// 1-bit output: Almost full flag
        .WRERR(WRERR),                  // 1-bit output: Write error
        .WREN(WREN),                    // 1-bit input: Write enable
        .WRCLK(ifclk),                  // 1-bit input: Rising edge write clock.
	// output fifo interface, see "7 Series Memory Resources" user guide (ug743)
	.DO(DO),
	.EMPTY(EMPTY),                  // 1-bit output: Empty flag
        .ALMOSTEMPTY1(),                // 1-bit output: Almost empty flag
        .ALMOSTEMPTY2(),                // 1-bit output: Almost empty flag
        .RDERR(RDERR),                  // 1-bit output: Read error
        .RDCLK(ifclk),                  // 1-bit input: Read clock
        .RDEN(RDEN),                    // 1-bit input: Read enable
	// free memory
	.mem_free_out(mem_free),
	// for debugging
	.status(status)
    );

    ezusb_io ezusb_io_inst (
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
	.EMPTY_FLAG(EMPTY_FLAG),
	.FULL_FLAG(FULL_FLAG),
	// signals for FPGA -> EZ-USB transfer
	.DI(rd_buf[15:0]),		// data written to EZ-USB
	.DI_valid(USB_DI_valid),	// 1 indicates data valid; DI and DI_valid must be hold if DI_ready is 0
	.DI_ready(USB_DI_ready),	// 1 if new data are accepted
	.DI_enable(1'b1),		// setting to 0 disables FPGA -> EZ-USB transfers
        .pktend_timeout(16'd793),	// timeout in multiples of 65536 clocks (approx. 0.5s @ 104 MHz) before a short packet committed
//        .pktend_timeout(16'd0),		// timeout in multiples of 65536 clocks, 0 disables this feature
	// signals for EZ-USB -> FPGA transfer
	.DO(USB_DO),			// data read from EZ-USB
	.DO_valid(USB_DO_valid),	// 1 indicated valid data
	.DO_ready(USB_DO_ready),	// setting to 1 enables writing new data to DO in next clock; DO and DO_valid are hold if DO_ready is 0
        // debug output
	.status(if_status)	
    );

    ezusb_gpio ezusb_gpio_inst (
	.clk(ifclk),
	.gpio_n(gpio_n),
	.in(gpio_in),
	.out(4'd0)
    );

/*    BUFR ifclkin_buf (
	.I(ifclk_in),
	.O(ifclk) 
    ); */
//    assign ifclk = ifclk_in;

    // FPGA Board led
    assign led = !if_status[6]; // led is inverted

    // debug board LEDs    
    assign led1 = SW10 ? status : { EMPTY, FULL, wrerr_buf, rderr_buf, if_status[5:0] };
    
    assign led2[0] = mem_free != { 1'b1, 24'd0 };
    assign led2[1] = mem_free[23:19] < 5'd30;
    assign led2[2] = mem_free[23:19] < 5'd29;
    assign led2[3] = mem_free[23:19] < 5'd27;
    assign led2[4] = mem_free[23:19] < 5'd25;
    assign led2[5] = mem_free[23:19] < 5'd24;
    assign led2[6] = mem_free[23:19] < 5'd22;
    assign led2[7] = mem_free[23:19] < 5'd20;
    assign led2[8] = mem_free[23:19] < 5'd19;
    assign led2[9] = mem_free[23:19] < 5'd17;
    assign led2[10] = mem_free[23:19] < 5'd15;
    assign led2[11] = mem_free[23:19] < 5'd13;
    assign led2[12] = mem_free[23:19] < 5'd12;
    assign led2[13] = mem_free[23:19] < 5'd10;
    assign led2[14] = mem_free[23:19] < 5'd8;
    assign led2[15] = mem_free[23:19] < 5'd7;
    assign led2[16] = mem_free[23:19] < 5'd5;
    assign led2[17] = mem_free[23:19] < 5'd3;
    assign led2[18] = mem_free[23:19] < 5'd2;
    assign led2[19] = mem_free == 25'd0;

    assign test_cs_w = test_cs + {1'b1, test_cnt0};

    always @ (posedge ifclk)
    begin
	reset_ifclk <= reset || reset_usb || reset_mem;
	
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
	    rd_cnt <= 3'd0;
	    USB_DI_valid <= 1'd0;
	end else if ( USB_DI_ready )
	begin
	    USB_DI_valid <= !EMPTY;
	    if ( !EMPTY )
	    begin
	        if ( rd_cnt == 3'd0 )
	        begin
	    	    rd_buf <= DO;
		end else
	    	begin
	    	    rd_buf[111:0] <= rd_buf[127:16];
		end
		rd_cnt <= rd_cnt+1;
	    end
	end
	RDEN <= !reset_ifclk && USB_DI_ready && !EMPTY && (rd_cnt==3'd0);


	USB_DO_ready = !reset_ifclk && ((gpio_in[1:0]==2'd0 && !FULL) || (gpio_in[1:0]==2'd3));
	FULL_buf1 <= FULL;
	FULL_buf2 <= FULL_buf1;
		
	if ( reset_ifclk ) 
	begin
	    in_data <= 128'd0;
	    in_valid <= 1'b0;
	    wr_cnt <= 3'd0;
	    test_cnt0 <= 7'd0;
	    test_cnt1 <= 7'd111;
	    test_cs <= 12'd47;
	    WREN <= 1'b0;
	    clk_div <= 4'd15;
	end else if ( !FULL_buf2 )		// FULL can be processed delayed because data is buffered 
	begin
	    if ( in_valid ) DI <= in_data;

    	    if ( gpio_in[1:0] == 2'd0 )		// input from USB
    	    begin
    		if ( USB_DO_valid )
    		begin
		    in_data <= { USB_DO, in_data[127:16] };
		    in_valid <= wr_cnt == 3'd7;
	    	    wr_cnt <= wr_cnt + 1;
	    	end else
	    	begin
		    in_valid <= 1'b0;
		end
    	    end else if ( clk_div == 2'd0 )	// test data generator
	    begin
	        if ( wr_cnt == 3'd7 )
	        begin
		    in_data[127:112] <= { 1'b1, test_cs_w[6:0] ^ test_cs_w[13:7], 1'b1, test_cnt0 };
		    test_cnt0 <= test_cnt1;
		    test_cnt1 <= test_cnt1 + 7'd111;
	    	    test_cs <= 14'd47;
		    in_valid <= 1'b1;
		end else
		begin
		    test_cnt0 <= test_cnt0 + 7'd94;  // (111*2) & 127
		    test_cnt1 <= test_cnt1 + 7'd94;  // (111*2) & 127
		    test_cs <= test_cs + { 1'b1, test_cnt1 } + { 1'b0, test_cnt0 };
		    in_data[127:112] <= { 1'b1, test_cnt1, 1'b0, test_cnt0 };
		    in_valid <= 1'b0;
		end
		in_data[111:0] <= in_data[127:16];
	    	wr_cnt <= wr_cnt + 1;
	    end else 
	    begin
	        in_valid <= 1'b0;
	    end

	    // mode 3 is a debug mode: dummy read from USB, write test data
	    if ( gpio_in[0]==1'd1 ) 
//	    if ( gpio_in[1:0]==2'd1 ) 
	    begin
	        clk_div <= 4'd0;	// data rate: 208 MByte/s
	    end else 
	    begin
	        clk_div <= clk_div + 1;	// data rate: 13 MByte/s
	    end
	end
	WREN <= !reset_ifclk && in_valid && !FULL;
    end
	    
endmodule

