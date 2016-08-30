/*!
   fx3sdemo -- Demonstrates common features of the FX3S
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

import java.io.*;
import java.util.*;
import java.nio.*;

import org.usb4java.*;

import ztex.*;

// *****************************************************************************
// ******* ParameterException **************************************************
// *****************************************************************************
// Exception the prints a help message
class ParameterException extends Exception {
    public final static String helpMsg = new String (
		"Parameters:\n"+
		"    -d <number>       Device Number (default: 0)\n" +
		"    -f 	       Force uploads\n" +
		"    -p                Print bus info\n" +
		"    -h                This help" );
    
    public ParameterException (String msg) {
	super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* Fx3Demo *************************************************************
// *****************************************************************************
class Fx3Demo extends Ztex1v1 {

// ******* Debug ***************************************************************
// constructor
    public Fx3Demo ( ZtexDevice1 pDev ) throws UsbException {
	super ( pDev );
    }

// ******* echo ****************************************************************
// writes a string to Endpoint 4, reads it back from Endpoint 2 and writes the output to System.out
    public void echo ( String input ) throws UsbException {
	int i = bulkWrite(0x04, allocateByteBuffer(input.getBytes()) , 1000);
	if ( i<0 ) throw new UsbException("Error sending data: " + LibUsb.strError(i));
	System.out.println("Send "+i+" bytes: `"+input+"'" );

	try {
    	    Thread.sleep( 10 );
	}
	    catch ( InterruptedException e ) {
	}

	ByteBuffer buffer = BufferUtils.allocateByteBuffer(1024);
	i = bulkRead(0x82, buffer, 1000);
	if ( i<0 ) throw new UsbException("Error receiving data: " + LibUsb.strError(i));
	else if (i==0) System.out.println("Read "+0+" bytes" );  
	else {
	    byte[] buf = new byte[i];
	    buffer.get(buf);
	    System.out.println("Read "+i+" bytes: `"+new String(buf,0,i)+"'" );  
	} 
    }


// ******* main ****************************************************************
    public static void main (String args[]) {
    
	int devNum = 0;
	boolean force = false;
	
	try {

// Scan the USB. This also creates and initializes a new USB context.
	    ZtexScanBus1 bus = new ZtexScanBus1( ZtexDevice1.ztexVendorId, ZtexDevice1.ztexProductId, true, false, 1);
	    if ( bus.numberOfDevices() <= 0) {
		System.err.println("No devices found");
	        System.exit(0);
	    }
	    
// scan the command line arguments
    	    for (int i=0; i<args.length; i++ ) {
	        if ( args[i].equals("-d") ) {
	    	    i++;
		    try {
			if (i>=args.length) throw new Exception();
    			devNum = Integer.parseInt( args[i] );
		    } 
		    catch (Exception e) {
		        throw new ParameterException("Device number expected after -d");
		    }
		}
		else if ( args[i].equals("-f") ) {
		    force = true;
		}
		else if ( args[i].equals("-p") ) {
	    	    bus.printBus(System.out);
		    System.exit(0);
		}
		else if ( args[i].equals("-p") ) {
	    	    bus.printBus(System.out);
		    System.exit(0);
		}
		else if ( args[i].equals("-h") ) {
		        System.err.println(ParameterException.helpMsg);
	    	        System.exit(0);
		}
		else throw new ParameterException("Invalid Parameter: "+args[i]);
	    }
	    

// create the main class	    
	    Fx3Demo ztex = new Fx3Demo ( bus.device(devNum) );
	    bus.unref();
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("Demo for FX3 Boards")  ) {
		System.out.println("Trying to overwrite firmware in RAM. This only works if a board specific firmware with reset support is running.\n"+
		                   "If uploading firmware fails please restart board with disabled firmware" );
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "fx3demo.img", force ) + " ms");
	    }
	    
	    ztex.debug2PrintNextLogMessages(System.out); 

// claim interface 0
	    ztex.trySetConfiguration ( 1 );
	    ztex.claimInterface ( 0 );
	    
// print log
	    ztex.debug2PrintNextLogMessages(System.out);

// test flash
	    if ( ztex.flashEnabled() ) {
    		System.out.println("SPI Flash");
		System.out.println("Sector size: "+ztex.flashSectorSize());
		System.out.println("Sectors: "+ztex.flashSectors());
//	    	ztex.printSpiState();

	        byte[] buf0 = new byte[ztex.flashSectorSize()];
		byte[] buf1 = new byte[ztex.flashSectorSize()];
		byte[] buf2 = new byte[ztex.flashSectorSize()];
		for (int i=0; i<ztex.flashSectorSize(); i++ ) {
		    buf1[i] = (byte)((i % 251) & 255);
		    buf2[i] = (byte) 255;
		}
		try {
    		    System.out.println("Reading backup of sector 7");
		    ztex.flashReadSector(7, 1, buf0);
    		    System.out.println("Writing sector 7");
  		    ztex.flashWriteSector(7, 1, buf1);
    		    System.out.println("Reading sector 7");
		    ztex.flashReadSector(7, 1, buf2);
		    boolean errors = false;
		    for (int i=0; i<ztex.flashSectorSize(); i++ ) {
			if ( buf1[i] != buf2[i] ) {
			    errors = true;
			    System.out.println("Flash error at " + i + ":  " + (buf1[i] & 255) + " " + (buf2[i] & 255)+"        ");
			}
		    } 
		    if ( ! errors )  System.out.println("No Flash errors");
    		    System.out.println("Writing backup of sector 7");
  		    ztex.flashWriteSector(7, 1, buf0);
		}
		catch (Exception e) {
		    System.out.println("Flash test failed: " + e.getLocalizedMessage() );
	    	    ztex.printSpiState();
		} 
	    }
	    else {
    		System.out.println("No SPI Flash found or SPI Flash disabled due to reboot");
	    }

	    ztex.debug2PrintNextLogMessages(System.out); 

// speed test
	    try {
		ZtexEventHandler eventHandler = new ZtexEventHandler(ztex);
		eventHandler.start();
		ZtexUsbReader bulkReader = new ZtexUsbReader( ztex, 1, false, 16, 256*1024 );
		bulkReader.start(-1);
		long oldByteCount = 0;
		for ( int i=0; i<5; i++ ) {
	    	    System.out.print("1s speed test: ");
		    try { Thread.sleep(1000); } catch ( InterruptedException e) { } 
		    System.out.println(Math.round((bulkReader.byteCount()-oldByteCount)/1000000.0) + " MByte/s");
		    oldByteCount = bulkReader.byteCount();
		}
		if ( !bulkReader.cancelWait(10000) ) System.err.println("Unable to cancel reading");
	        if ( !eventHandler.terminate() ) System.err.println("Unable to terminate event handler");
	    }
	    catch ( Exception e ) {
		System.out.println("Speed test failed: " + e.getLocalizedMessage() );
	    }

	    ztex.debug2PrintNextLogMessages(System.out); 
	    
// read string from stdin and write it to USB device
	    try {
		String str = "";
		BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );
		while ( ! str.equals("quit") ) {
		    System.out.print("Enter a string or `quit' to exit the program: ");
		    str = reader.readLine();
		    if ( ! str.equals("") ) ztex.echo(str);
	    	    System.out.println("");
		    ztex.debug2PrintNextLogMessages(System.out);
		}
	    }
	    catch ( Exception e ) {
		System.out.println("ucecho test failed: " + e.getLocalizedMessage() );
	    }

	    ztex.debug2PrintNextLogMessages(System.out); 

	    ztex.dispose();  // this also releases claimed interfaces

	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
