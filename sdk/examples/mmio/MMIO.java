/*!
   mmio -- Memory mapped I/O example for ZTEX USB-FPGA Module 2.16
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
// ******* MMIO ****************************************************************
// *****************************************************************************
class MMIO extends Ztex1v1 {

// ******* MMIO ****************************************************************
// constructor
    public MMIO ( ZtexDevice1 pDev ) throws UsbException {
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
	    MMIO ztex = new MMIO ( bus.device(devNum) );
	    bus.unref();

	    if (ztex.config == null ) throw new Exception("Invalid configuration data");
	    byte majorVersion = ztex.config.getMajorVersion();
	    byte minorVersion = ztex.config.getMinorVersion();
	    String configFN = ztex.config.defaultBitstreamPath("mmio");
	    String fwFN = "mmio-" + majorVersion + "_" + (minorVersion / 10) + (minorVersion % 10)+".ihx";
	    String name="mmio example for ZTEX USB-FPGA Module "+majorVersion + "_" + (minorVersion / 10) + (minorVersion % 10);
	    System.out.println("Found " + ztex.config.getName()+",  using firmware image " + fwFN + ", using bitstream "+configFN);
	    
// upload the firmware if necessary
	    if ( ! new File(fwFN).exists() ) 
		throw new Exception("Firmware image `" + fwFN + "' does not exist. This FPGA board seems not to be supported by this example");

	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals(name)  ) {
	        System.out.println("Firmware upload time: " + ztex.uploadFirmware( fwFN, force ) + " ms");
	        force = true;
	    }
	    
// upload the bitstream
	    System.out.println("FPGA configuration time: " + ztex.configureFpga( configFN , true ) + " ms");

// claim interface 0
	    ztex.trySetConfiguration ( 1 );
	    ztex.claimInterface ( 0 );
	    
// read string from stdin and write it to USB device
	    String str = "";
	    BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );
	    while ( ! str.equals("quit") ) {
		System.out.print("Enter a string or `quit' to exit the program: ");
		str = reader.readLine();
		if ( ! str.equals("") )
		    ztex.echo(str);
	        System.out.println("");
	    }
	    
	    ztex.dispose();  // this also releases claimed interfaces
	    
	}
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 
   } 
   
}
