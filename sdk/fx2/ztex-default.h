/*!
   ZTEX Firmware Kit for EZ-USB FX2 Microcontrollers
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
   Template for default firmware
*/

// define capability 
#define[@CAPABILITY_LSI;]

// enable Flash support
ENABLE_FLASH;
//ENABLE_FLASH_BITSTREAM;

// configure endpoint 2, in, quad buffered, 512 bytes, interface 0
EP_CONFIG(2,0,BULK,IN,512,4);

// configure endpoint 6, out, double buffered, 512 bytes, interface 0
EP_CONFIG(6,0,BULK,OUT,512,4);
ENABLE_HS_FPGA_CONF(6);

void reset_gpif () {
    OEA = (OEA | OEA_MASK ) & ~OEA_UMASK;
    OEC = (OEC | OEC_MASK ) & ~OEC_UMASK;
    OEE = (OEE | OEE_MASK ) & ~OEE_UMASK;
    D_RESET = 1;
    GPIO_DIR = 0;			// disables FPGA driving GPIO_DAT
	
    EP2CS &= ~bmBIT0;			// clear stall bit
    EP6CS &= ~bmBIT0;			// clear stall bit

    IFCONFIG = bmBIT7 | bmBIT6 | bmBIT5 | 3;  // internal 48MHz clock, drive IFCLK output, slave FIFO interface
    SYNCDELAY; 
                     
    REVCTL = 0x1;
    SYNCDELAY; 

    FIFORESET = 0x80;			// reset FIFO ...
    SYNCDELAY;
    FIFORESET = 0x2;			// ... for EP 2
    SYNCDELAY;
    FIFORESET = 0x4;			// ... for EP 6
    SYNCDELAY;
    FIFORESET = 0x00;
    SYNCDELAY;

    EP2FIFOCFG = bmBIT0; 
    SYNCDELAY;
    EP2FIFOCFG = bmBIT3 | bmBIT0;      	// EP2: AUTOIN, WORDWIDE
    SYNCDELAY;
    EP2AUTOINLENH = 2;                 	// 512 bytes 
    SYNCDELAY;
    EP2AUTOINLENL = 0;
    SYNCDELAY;

    EP6FIFOCFG = bmBIT0;         		
    SYNCDELAY;
    EP6FIFOCFG = bmBIT4 | bmBIT0;       // EP6: 0 -> 1 transition of AUTOOUT bit arms the FIFO, WORDWIDE
    SYNCDELAY;

    FIFOPINPOLAR = 0;
    SYNCDELAY; 
    PINFLAGSAB = 0xca;			// FLAGA: EP6: EF; FLAGB: EP2 FF
    SYNCDELAY;

    wait(2);
    D_RESET = 0; 
}

/* *********************************************************************
   ***** EP0 vendor command 0x60 ***************************************
   ********************************************************************* */
// VC 0x60
// value != 0: reset signal is left active 
ADD_EP0_VENDOR_COMMAND((0x60,,
    D_RESET = 1;
    if ( SETUPDAT[2] == 0 ) {
	wait(2);
	D_RESET = 0;
    }
,,  
));;

/* *********************************************************************
   ***** EP0 vendor request 0x61 ***************************************
   ********************************************************************* */
// index: mask
// value: value
ADD_EP0_VENDOR_REQUEST((0x61,,		// GPIO CTL
    GPIO_CLK = 0;

    // writing
    GPIO_DIR = 0;	// MOSI
    GPIO_WE;
    __asm
        // min clk -> data hold: 8 clock cycles
	// load index
	mov	dptr, #_SETUPDAT+4
	movx	a,@dptr
	mov    r2, a
	// load value
	mov	dptr, #_SETUPDAT+2
	movx	a,@dptr
	anl	a, r2
  	// gpio[0]
  	rrc	a
  	mov 	_GPIO_DAT,c 
  	setb	_GPIO_CLK
  	// gpio[1]
  	nop
  	rrc	a
  	mov 	_GPIO_DAT,c 
  	clr	_GPIO_CLK
  	// gpio[2]
  	nop
  	rrc	a
  	mov 	_GPIO_DAT,c 
  	setb	_GPIO_CLK
  	// gpio[3]
  	nop
  	rrc	a
  	mov 	_GPIO_DAT,c 
  	clr	_GPIO_CLK
    __endasm;

    // reading
    GPIO_RE;
    GPIO_DIR = 1;	// 0->1 latches input and starts MISO
    __asm
	// give FPGA some time to generate output
  	nop	// some time
  	nop
  	nop
  	nop
  	nop
  	nop
  	nop
  	nop
        // max clk -> data delay: 8 cycles
	mov 	a, 0
	// gpio[3]
  	mov	c, _GPIO_DAT
  	setb	_GPIO_CLK
  	rlc	a
  	nop
	// gpio[2]
  	mov	c, _GPIO_DAT
  	clr	_GPIO_CLK
  	rlc	a
  	nop
	// gpio[1]
  	mov	c, _GPIO_DAT
  	setb	_GPIO_CLK
  	rlc	a
  	nop
	// gpio[0]
  	mov	c, _GPIO_DAT
  	rlc	a
  	// write to EP0BUF
	mov	dptr, #_EP0BUF
	movx	@dptr,a
    __endasm;
    GPIO_DIR = 0;	// MOSI
    EP0BCH = 0;
    EP0BCL = 1;
,,));;


/* *********************************************************************
   ***** EP0 vendor command 0x62 ***************************************
   ********************************************************************* */
void lsi_write_byte (BYTE b) {	// b is in dpl
    b;				// makes the compiler happy
    __asm
        // min clk -> data hold: 8 clock cycles
        // LSI_CLK must be 0
	mov 	a,dpl
	// 0
	rrc	a	
	mov	_LSI_MOSI,c
        setb	_LSI_CLK
        nop
	// 1
	rrc	a
	mov	_LSI_MOSI,c
        clr	_LSI_CLK
        nop
	// 2
	rrc	a
	mov	_LSI_MOSI,c
        setb	_LSI_CLK
        nop
	// 3
	rrc	a
	mov	_LSI_MOSI,c
        clr	_LSI_CLK
        nop
        // 4
	rrc	a
	mov	_LSI_MOSI,c
        setb	_LSI_CLK
        nop
        // 5
	rrc	a
	mov	_LSI_MOSI,c
        clr	_LSI_CLK
        nop
        // 6
	rrc	a
	mov	_LSI_MOSI,c
        setb	_LSI_CLK
        nop
        // 7
	rrc	a
	mov	_LSI_MOSI,c
        clr	_LSI_CLK
    __endasm;
    
}  

__xdata BYTE lsi_write_cnt; 	// modulo 5 byte count

void ep0_lsi_write() {
    BYTE b;
    for (b=0; b<EP0BCL; b++) {
	lsi_write_byte(EP0BUF[b]);
	if ( lsi_write_cnt == 4 ) {
	    LSI_MOSI = 0;
	    LSI_STOP = 1;
	    LSI_CLK = 1;
	    lsi_write_cnt=0;
	    LSI_STOP = 0;
	    LSI_CLK = 0;
	}
	else {
	    lsi_write_cnt++;
	}
    }
}

ADD_EP0_VENDOR_COMMAND((0x62,,		// send FPGA configuration data
    lsi_write_cnt = 0;
    LSI_STOP = 0;
    LSI_CLK = 0;
,,
    ep0_lsi_write();
));;


/* *********************************************************************
   ***** EP0 vendor request 0x63 ***************************************
   ********************************************************************* */
BYTE lsi_read_byte () {	
    __asm
        // max clk -> data delay: 8 cycles
        // LSI_CLK must be 0
	// 0
  	mov	c, _LSI_MISO
  	clr	_LSI_CLK
  	nop
  	rrc	a
	// 1
  	mov	c, _LSI_MISO
  	setb	_LSI_CLK
  	nop
  	rrc	a
	// 2
  	mov	c, _LSI_MISO
  	clr	_LSI_CLK
  	nop
  	rrc	a
	// 3
  	mov	c, _LSI_MISO
  	setb	_LSI_CLK
  	nop
  	rrc	a
	// 4
  	mov	c, _LSI_MISO
  	clr	_LSI_CLK
  	nop
  	rrc	a
	// 5
  	mov	c, _LSI_MISO
  	setb	_LSI_CLK
  	nop
  	rrc	a
	// 6
  	mov	c, _LSI_MISO
  	clr	_LSI_CLK
  	nop
  	rrc	a
	// 7
  	mov	c, _LSI_MISO
  	setb	_LSI_CLK
  	nop
  	rrc	a
        mov	dpl,a		// result stored in dpl
        ret
__endasm;
	return 0;		// never called, makes the compiler happy
}  

__xdata BYTE lsi_read_adr; 	// 
__xdata BYTE lsi_read_cnt; 	// modulo 4 byte count

void ep0_lsi_read() {
    BYTE b, c;
    c=ep0_payload_transfer;
    for (b=0; b<c; b++) {
	if ( lsi_read_cnt == 0 ) {
	    LSI_STOP = 0;
	    LSI_CLK = 0;
	    lsi_write_byte(lsi_read_adr);
	    LSI_MOSI = 1;
	    LSI_STOP = 1;
	    LSI_CLK = 1;
	    lsi_read_adr++;
	}
	lsi_read_cnt = (lsi_read_cnt+1) & 3;
	EP0BUF[b]=lsi_read_byte();
    }
    EP0BCH = 0;
    EP0BCL = c;
}

ADD_EP0_VENDOR_REQUEST((0x63,,		// get info about default firmware
    lsi_read_cnt = 0;
    lsi_read_adr = SETUPDAT[4];
    LSI_CLK = 0;
    ep0_lsi_read();
,,
    ep0_lsi_read();
));;


/* *********************************************************************
   ***** EP0 vendor request 0x64 ***************************************
   ********************************************************************* */
ADD_EP0_VENDOR_REQUEST((0x64,,		// get info about default firmware
    EP0BUF[0] = 1;	 		// version
    EP0BUF[1] = 6;  			// output endpoint
    EP0BUF[2] = 2;  			// input endpoint
    EP0BUF[3] = 1;  			// sub version
    EP0BUF[4] = 0;  			// reserved for future use
    EP0BUF[5] = 0;  			// reserved for future use
    EP0BUF[6] = 0;  			// reserved for future use
    EP0BUF[7] = 0;  			// reserved for future use
    EP0BCH = 0;
    if ( ep0_payload_transfer > 8 ) {
	EP0BCL = 8; 
    }
    else {
	EP0BCL = ep0_payload_transfer; 
    }
,,));;

// this is called automatically after FPGA configuration
#define[POST_FPGA_CONFIG][POST_FPGA_CONFIG
    reset_gpif ();
]

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    init_USB();
    
    while (1) {	}					//  twiddle thumbs
}
