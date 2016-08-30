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


module dram_fifo # (
      	parameter CLKOUT_DIVIDE = 2	// (2, 4, 8, 16, 32), see clkout
    ) (

	input fxclk_in,			// 48 MHz input clock pin
        input reset,
        output reset_out,		// reset output
      	output clkout,			// clock output 200MHz/CLKOUT_DIVIDE
	// ddr3 pins
	inout[15:0] ddr_dram_dq,
        inout ddr_rzq,
        inout ddr_zio,
        inout ddr_dram_udqs,
        inout ddr_dram_dqs,
	output[12:0] ddr_dram_a,
	output[1:0] ddr_dram_ba,
        output ddr_dram_cke,
        output ddr_dram_ras_n,
        output ddr_dram_cas_n,
        output ddr_dram_we_n,
        output ddr_dram_dm,
        output ddr_dram_udm,
        output ddr_dram_ck,
        output ddr_dram_ck_n,
        
	// FIFO protocol equal to FWFT FIFO in "7 Series Memory Resources" user guide (ug743)
	// input fifo interface
        input [31:0] DI,                // must be hold while FULL is asserted
        output FULL,                    // 1-bit output: Full flag
        output reg WRERR,               // 1-bit output: Write error
        input WRCLK,                    // 1-bit input: Rising edge write clock.
        input WREN,                     // 1-bit input: Write enable

	// output fifo interface
	output reg [31:0] DO,
	output reg EMPTY,               // 1-bit output: Empty flag, can be used as data valid indicator
        output reg RDERR,               // 1-bit output: Read error
        input RDCLK,                    // 1-bit input: Read clock
        input RDEN,                     // 1-bit input: Read enable
        
	// free memory
	output reg [APP_ADDR_WIDTH-1:0] mem_free_out,

	// for debugging
	output [9:0] status
    );

    localparam APP_ADDR_WIDTH = 18;	// 256 byte bursts
    
    wire fxclk, memclk, dcm0_locked, reset0, memclk_in;
    
    assign reset0 = reset || (!dcm0_locked);
    assign reset_out = reset0 || !c3_calib_done || c3_rst0;

    assign status[0] = reset;
    assign status[1] = dcm0_locked;
    assign status[2] = c3_calib_done;
    assign status[3] = c3_rst0;
    assign status[4] = WR_UNDERRUN[0] || WR_UNDERRUN[1] || WR_UNDERRUN[2];
    assign status[5] = WR_ERROR[0] || WR_ERROR[1] || WR_ERROR[2];
    assign status[6] = RD_OVERFLOW[0] || RD_OVERFLOW[1] || RD_OVERFLOW[2];
    assign status[7] = RD_ERROR[0] || RD_ERROR[1] || RD_ERROR[2];
    assign status[8] = FULL;
    assign status[9] = EMPTY; 

    // DRAM controller: status
    wire c3_calib_done, c3_rst0;
    
    // DRAM controller: writing
    reg reset_wr, WREN_BUF;
    reg [7:0] reset_wr_buf;
    reg [1:0] WR_PORT, WR_PORT2;
    reg [2:0] WR_CMD_EN, WR_EN;
    wire [2:0] WR_UNDERRUN, WR_ERROR, WR_EMPTY, WR_FULL;
    reg [APP_ADDR_WIDTH-1:0] WR_ADDR, WR_ADDR_FIRST, RD_ADDR_FIRST_WR1, RD_ADDR_FIRST_WR2;
    reg [31:0] WR_DATA;
    reg [6:0] WR_COUNT [0:2];

    // DRAM controller: reading
    reg reset_rd;
    reg [7:0] reset_rd_buf;
    reg [1:0] RD_PORT, RD_PORT2;
    reg [2:0] RD_CMD_EN, RD_EN;
    wire [2:0] RD_EMPTY, RD_OVERFLOW, RD_ERROR;
    wire [31:0] RD_DATA [0:2];
    reg [6:0] RD_COUNT [0:2];
    reg [APP_ADDR_WIDTH-1:0] RD_ADDR, RD_ADDR_NEXT, WR_ADDR_FIRST_RD1, WR_ADDR_FIRST_RD2, RD_ADDR_FIRST;

    
    DCM_CLKGEN #(
      .CLKFXDV_DIVIDE(CLKOUT_DIVIDE),       // CLKFXDV divide value (2, 4, 8, 16, 32)
      .CLKFX_DIVIDE(6),         // Divide value - D - (1-256)
      .CLKFX_MULTIPLY(25),      // Multiply value - M - (2-256)
      .CLKIN_PERIOD(20.833333),    // Input clock period specified in nS
      .SPREAD_SPECTRUM("NONE"), // Spread Spectrum mode "NONE", "CENTER_LOW_SPREAD", "CENTER_HIGH_SPREAD",
                                // "VIDEO_LINK_M0", "VIDEO_LINK_M1" or "VIDEO_LINK_M2" 
      .STARTUP_WAIT("FALSE")    // Delay config DONE until DCM_CLKGEN LOCKED (TRUE/FALSE)
    )
    dcm0 (
      .CLKIN(fxclk),         // 1-bit input: Input clock
      .CLKFX(memclk_in),
      .CLKFX180(),              // 1-bit output: Generated clock output 180 degree out of phase from CLKFX.
      .CLKFXDV(clkout),         // 1-bit output: Divided clock output
      .LOCKED(dcm0_locked),     // 1-bit output: Locked output
      .PROGDONE(),              // 1-bit output: Active high output to indicate the successful re-programming
      .STATUS(),                // 2-bit output: DCM_CLKGEN status
      .FREEZEDCM(1'b0),         // 1-bit input: Prevents frequency adjustments to input clock
      .PROGCLK(1'b0),           // 1-bit input: Clock input for M/D reconfiguration
      .PROGDATA(1'b0),          // 1-bit input: Serial data input for M/D reconfiguration
      .PROGEN(1'b0),            // 1-bit input: Active high program enable
      .RST(reset)               // 1-bit input: Reset input pin
    );
    
    BUFG memclk_buf (
	.I(memclk_in),
	.O(memclk) 
    );

    BUFG fxclk_buf (
	.I(fxclk_in),
	.O(fxclk) 
    );
    
    mem0 # (
	.C3_P0_MASK_SIZE(4),
	.C3_P0_DATA_PORT_SIZE(32),
	.C3_P1_MASK_SIZE(4),
    	.C3_P1_DATA_PORT_SIZE(32),
    	.DEBUG_EN(0),
    	.C3_MEMCLK_PERIOD(5000),
    	.C3_CALIB_SOFT_IP("TRUE"),
    	.C3_SIMULATION("FALSE"),
    	.C3_RST_ACT_LOW(0),
    	.C3_INPUT_CLK_TYPE("SINGLE_ENDED"),
    	.C3_MEM_ADDR_ORDER("ROW_BANK_COLUMN"),
    	.C3_NUM_DQ_PINS(16),
    	.C3_MEM_ADDR_WIDTH(13),
    	.C3_MEM_BANKADDR_WIDTH(2)
    )
    u_mem0 (
  	.mcb3_dram_dq           (ddr_dram_dq),  
  	.mcb3_dram_a            (ddr_dram_a),  
  	.mcb3_dram_ba           (ddr_dram_ba),
  	.mcb3_dram_ras_n        (ddr_dram_ras_n),                        
  	.mcb3_dram_cas_n        (ddr_dram_cas_n),                        
  	.mcb3_dram_we_n         (ddr_dram_we_n),                          
  	.mcb3_dram_cke          (ddr_dram_cke),                          
  	.mcb3_dram_ck           (ddr_dram_ck),                          
  	.mcb3_dram_ck_n         (ddr_dram_ck_n),       
  	.mcb3_dram_dqs          (ddr_dram_dqs),
  	.mcb3_dram_udqs         (ddr_dram_udqs),    // for X16 parts
  	.mcb3_dram_udm          (ddr_dram_udm),     // for X16 parts
  	.mcb3_dram_dm           (ddr_dram_dm),
      	.mcb3_rzq               (ddr_rzq),
	
  	.c3_clk0	        (),
  	.c3_calib_done  	(c3_calib_done),
  	.c3_rst0	        (c3_rst0),
    	.c3_sys_clk           	(memclk),
  	.c3_sys_rst_i           (reset0),                        
         
     	.c3_p0_cmd_clk          (WRCLK),
   	.c3_p0_cmd_en           (WR_CMD_EN[0]),
   	.c3_p0_cmd_instr        (3'b000),
   	.c3_p0_cmd_bl           (6'd63),
   	.c3_p0_cmd_byte_addr    ( {4'd0, WR_ADDR, 8'd0} ),
   	.c3_p0_cmd_empty        (),
   	.c3_p0_cmd_full         (),
   	.c3_p0_wr_clk           (WRCLK),
   	.c3_p0_wr_en            (WR_EN[0]),
   	.c3_p0_wr_mask          (4'd0),
   	.c3_p0_wr_data          (WR_DATA),
   	.c3_p0_wr_full          (WR_FULL[0]),
   	.c3_p0_wr_empty         (WR_EMPTY[0]),
   	.c3_p0_wr_count         (),
   	.c3_p0_wr_underrun      (WR_UNDERRUN[0]),
   	.c3_p0_wr_error         (WR_ERROR[0]),
   	.c3_p0_rd_clk           (WRCLK),
   	.c3_p0_rd_en            (1'b0),
   	.c3_p0_rd_data          (),
   	.c3_p0_rd_full          (),
   	.c3_p0_rd_empty         (),
   	.c3_p0_rd_count         (),
   	.c3_p0_rd_overflow      (),
   	.c3_p0_rd_error         (),

   	.c3_p1_cmd_clk          (RDCLK),
   	.c3_p1_cmd_en           (RD_CMD_EN[0]),
   	.c3_p1_cmd_instr        (3'b001),
   	.c3_p1_cmd_bl           (6'd63),
   	.c3_p1_cmd_byte_addr    ( {4'd0, RD_ADDR, 8'd0} ),
   	.c3_p1_cmd_empty        (),
   	.c3_p1_cmd_full         (),
   	.c3_p1_wr_clk           (RDCLK),
   	.c3_p1_wr_en            (1'b0),
   	.c3_p1_wr_mask          (4'd0),
   	.c3_p1_wr_data          (32'd0),
   	.c3_p1_wr_full          (),
   	.c3_p1_wr_empty         (),
   	.c3_p1_wr_count         (),
   	.c3_p1_wr_underrun      (),
   	.c3_p1_wr_error         (),
   	.c3_p1_rd_clk           (RDCLK),
   	.c3_p1_rd_en            (RD_EN[0]),
   	.c3_p1_rd_data          (RD_DATA[0]),
   	.c3_p1_rd_full          (),
   	.c3_p1_rd_empty         (RD_EMPTY[0]),
   	.c3_p1_rd_count         (),
   	.c3_p1_rd_overflow      (RD_OVERFLOW[0]),
   	.c3_p1_rd_error         (RD_ERROR[0]),

     	.c3_p2_cmd_clk          (WRCLK),
   	.c3_p2_cmd_en           (WR_CMD_EN[1]),
   	.c3_p2_cmd_instr        (3'b000),
   	.c3_p2_cmd_bl           (6'd63),
   	.c3_p2_cmd_byte_addr    ( {4'd0, WR_ADDR, 8'd0} ),
   	.c3_p2_cmd_empty        (),
   	.c3_p2_cmd_full         (),
   	.c3_p2_wr_clk           (WRCLK),
   	.c3_p2_wr_en            (WR_EN[1]),
   	.c3_p2_wr_mask          (4'd0),
   	.c3_p2_wr_data          (WR_DATA),
   	.c3_p2_wr_full          (WR_FULL[1]),
   	.c3_p2_wr_empty         (WR_EMPTY[1]),
   	.c3_p2_wr_count         (),
   	.c3_p2_wr_underrun      (WR_UNDERRUN[1]),
   	.c3_p2_wr_error         (WR_ERROR[1]),

   	.c3_p3_cmd_clk          (RDCLK),
   	.c3_p3_cmd_en           (RD_CMD_EN[1]),
   	.c3_p3_cmd_instr        (3'b001),
   	.c3_p3_cmd_bl           (6'd63),
   	.c3_p3_cmd_byte_addr    ( {4'd0, RD_ADDR, 8'd0} ),
   	.c3_p3_cmd_empty        (),
   	.c3_p3_cmd_full         (),
   	.c3_p3_rd_clk           (RDCLK),
   	.c3_p3_rd_en            (RD_EN[1]),
   	.c3_p3_rd_data          (RD_DATA[1]),
   	.c3_p3_rd_full          (),
   	.c3_p3_rd_empty         (RD_EMPTY[1]),
   	.c3_p3_rd_count         (),
   	.c3_p3_rd_overflow      (RD_OVERFLOW[1]),
   	.c3_p3_rd_error         (RD_ERROR[1]),

     	.c3_p4_cmd_clk          (WRCLK),
   	.c3_p4_cmd_en           (WR_CMD_EN[2]),
   	.c3_p4_cmd_instr        (3'b000),
   	.c3_p4_cmd_bl           (6'd63),
   	.c3_p4_cmd_byte_addr    ( {4'd0, WR_ADDR, 8'd0} ),
   	.c3_p4_cmd_empty        (),
   	.c3_p4_cmd_full         (),
   	.c3_p4_wr_clk           (WRCLK),
   	.c3_p4_wr_en            (WR_EN[2]),
   	.c3_p4_wr_mask          (4'd0),
   	.c3_p4_wr_data          (WR_DATA),
   	.c3_p4_wr_full          (WR_FULL[2]),
   	.c3_p4_wr_empty         (WR_EMPTY[2]),
   	.c3_p4_wr_count         (),
   	.c3_p4_wr_underrun      (WR_UNDERRUN[2]),
   	.c3_p4_wr_error         (WR_ERROR[2]),

   	.c3_p5_cmd_clk          (RDCLK),
   	.c3_p5_cmd_en           (RD_CMD_EN[2]),
   	.c3_p5_cmd_instr        (3'b001),
   	.c3_p5_cmd_bl           (6'd63),
   	.c3_p5_cmd_byte_addr    ( {4'd0, RD_ADDR, 8'd0} ),
   	.c3_p5_cmd_empty        (),
   	.c3_p5_cmd_full         (),
   	.c3_p5_rd_clk           (RDCLK),
   	.c3_p5_rd_en            (RD_EN[2]),
   	.c3_p5_rd_data          (RD_DATA[2]),
   	.c3_p5_rd_full          (),
   	.c3_p5_rd_empty         (RD_EMPTY[2]),
   	.c3_p5_rd_count         (),
   	.c3_p5_rd_overflow      (RD_OVERFLOW[2]),
   	.c3_p5_rd_error         (RD_ERROR[2])
    );

    assign FULL = WR_COUNT[WR_PORT][6] || reset_wr;
    
    always @ (posedge WRCLK)
    begin
	reset_wr_buf <= { reset_out, reset_wr_buf[7:1] };
	reset_wr <= reset_wr_buf != 8'd0;
	WR_CMD_EN <= 3'd0;
	WR_EN <= 3'd0;
	if ( reset_wr )
	begin
	    WR_ADDR <= { APP_ADDR_WIDTH{1'b1} }; 	// 1st address is WR_ADDR+1
	    WR_ADDR_FIRST <= { APP_ADDR_WIDTH{1'b0} }; 
	    WR_PORT <= 2'd0;
	    WR_PORT2 <= 2'd0;
	    WRERR <= 1'b0;
	    RD_ADDR_FIRST_WR1 <= { { (APP_ADDR_WIDTH-1){1'b1} }, 1'b0 };
	    RD_ADDR_FIRST_WR2 <= { { (APP_ADDR_WIDTH-1){1'b1} }, 1'b0 };
	    WR_COUNT[0] <= 7'd0;
	    WR_COUNT[1] <= 7'd0;
	    WR_COUNT[2] <= 7'd0;
    	    WREN_BUF <= 1'b0;
	end else
	begin
	    RD_ADDR_FIRST_WR1 <= RD_ADDR_FIRST;		
	    RD_ADDR_FIRST_WR2 <= RD_ADDR_FIRST_WR1;

	    if ( WREN || WREN_BUF ) 		// process data
	    begin
		WR_EN[WR_PORT] <= !WR_COUNT[WR_PORT][6];
		WR_DATA <= DI;
		WREN_BUF <= WR_COUNT[WR_PORT][6];
	    end
	    WRERR <= WREN && WREN_BUF;
	    
	    if ( WR_COUNT[WR_PORT] != 7'd65 ) // fifo stuff
	    begin
	        if ( WR_COUNT[WR_PORT][6] || ((WR_COUNT[WR_PORT]==7'd63) && WREN) )
	        begin
	    	    if ( RD_ADDR_FIRST_WR1==RD_ADDR_FIRST_WR2 && RD_ADDR_FIRST_WR1!=WR_ADDR )
		    begin
		        WR_CMD_EN[WR_PORT] <= 1'b1;
		        WR_PORT <= WR_PORT[1] ? 2'b00 : WR_PORT + 2'd1;
		        WR_ADDR <= WR_ADDR + 1;
		        WR_COUNT[WR_PORT] <= 7'd65;
		    end else
		    begin
		        WR_COUNT[WR_PORT] <= 7'd64;
		    end
		end else if ( WREN || WREN_BUF )
		begin
		    WR_COUNT[WR_PORT] <= WR_COUNT[WR_PORT] + 7'd1;
		end
	    end
    	    
    	    if ( WR_COUNT[WR_PORT2]==7'd65 && WR_EMPTY[WR_PORT2] && !WR_FULL[WR_PORT2])   // determines 1st (i.e. lowest) address in use
    	    begin
		WR_PORT2 <= WR_PORT2[1] ? 2'b00 : WR_PORT2 + 2'd1;
		WR_COUNT[WR_PORT2] <= 7'd0;
		WR_ADDR_FIRST <= WR_ADDR_FIRST + 1;
	    end
	end 
	mem_free_out <= RD_ADDR_FIRST_WR1 - WR_ADDR;
    end

    always @ (posedge RDCLK)
    begin
	reset_rd_buf <= { reset_out, reset_rd_buf[7:1] };
	reset_rd <= reset_rd_buf != 8'd0;
	RD_CMD_EN <= 3'd0;
	RD_EN <= 3'd0;
	RD_ADDR <= RD_ADDR_NEXT;
	if ( reset_rd )
	begin
	    RD_ADDR_NEXT <= { APP_ADDR_WIDTH{1'b0} };
	    RD_ADDR_FIRST <= { { (APP_ADDR_WIDTH-1){1'b1} }, 1'b0 };  // 1st addresse minus 1 that has to be read
	    RD_COUNT[0] <= 7'd0;
	    RD_COUNT[1] <= 7'd0;
	    RD_COUNT[2] <= 7'd0;
	    RD_PORT <= 2'd0;
	    RD_PORT2 <= 2'd0;
	    WR_ADDR_FIRST_RD1 <= { APP_ADDR_WIDTH{1'b0} };
	    WR_ADDR_FIRST_RD2 <= { APP_ADDR_WIDTH{1'b0} };
	    RDERR <= 1'b0;
	    EMPTY <= 1'b1;
	end else
	begin
	    RDERR <= RDEN && EMPTY;
	    
	    if ( RDEN || EMPTY )
	    begin
		if ( (RD_COUNT[RD_PORT]!=7'd0) && (!RD_EMPTY[RD_PORT]) ) 
		begin
		    EMPTY <= 1'b0;
		    DO <= RD_DATA[RD_PORT];
//		    DO <= { RD_DATA[RD_PORT][23:0], 1'd0, RD_COUNT[RD_PORT] };
		    RD_COUNT[RD_PORT] <= RD_COUNT[RD_PORT] - 7'd1;
	    	    RD_EN[RD_PORT] <= 1'b1;
		    if ( (RD_COUNT[RD_PORT]==7'd1) )
		    begin
		        RD_PORT <= RD_PORT[1] ? 2'b00 : RD_PORT + 2'd1;
	    	    	RD_ADDR_FIRST <= RD_ADDR_FIRST + 1;
		    end
		end else
		begin
		    EMPTY <= 1'b1;
		end
	    end

	    WR_ADDR_FIRST_RD1 <= WR_ADDR_FIRST;		// cmd generator
	    WR_ADDR_FIRST_RD2 <= WR_ADDR_FIRST_RD1;
	    if ( (RD_ADDR_NEXT != WR_ADDR_FIRST_RD1) && (WR_ADDR_FIRST_RD1 == WR_ADDR_FIRST_RD2) && (RD_COUNT[RD_PORT2]==7'd0) )
	    begin
		RD_COUNT[RD_PORT2] <= 7'd64;
		RD_CMD_EN[RD_PORT2] <= 1'b1;
		RD_PORT2 <= RD_PORT2[1] ? 2'b00 : RD_PORT2 + 2'd1;
		RD_ADDR_NEXT <= RD_ADDR_NEXT + 1;
	    end
	end
    end

endmodule
 