/*!
   fx2demo -- uppercase conversion example for all EZ-USB devices
   Copyright (C) 2009-2014 ZTEX GmbH.
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
		"    -d <number>  Device Number (default: 0)\n" +
		"    -f           Force uploads\n" +
		"    -p           Print bus info\n" +
		"    -h           This help" );
    
    public ParameterException (String msg) {
	super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* Fx2Demo *************************************************************
// *****************************************************************************
//class Fx2Demo extends Ztex1v1 {
class Fx2Demo extends Ztex1v1 {

// ******* Fx2Demo *************************************************************
// constructor
    public Fx2Demo ( ZtexDevice1 pDev ) throws UsbException {
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
	    ZtexScanBus1 bus = new ZtexScanBus1(ZtexDevice1.ztexVendorId, ZtexDevice1.ztexProductId, true, false, 1);
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
		else if ( args[i].equals("-h") ) {
		        System.err.println(ParameterException.helpMsg);
	    	        System.exit(0);
		}
		else throw new ParameterException("Invalid Parameter: "+args[i]);
	    }
	    

// create the main class	    
	    Fx2Demo ztex = new Fx2Demo ( bus.device(devNum) );
	    bus.unref();
	    
// upload the firmware if necessary
	    if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("fx2demo for EZ-USB devices")  ) {
		System.out.println("Firmware upload time: " + ztex.uploadFirmware( "fx2demo.ihx", force ) + " ms");
	    }
	    
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

// print staistics stored in debug stack
	    byte[] buf = new byte[400];
    	    int j = ztex.debugReadMessages(true,buf);
	    System.out.println(ztex.debugLastMsg() + " transactions: ");
    	    for (int i=0; i<j; i++ ) 
    		System.out.println( "    " + (i+1) + ": converted " + ((buf[i*4+2] & 255) | ((buf[i*4+3] & 255)<<8)) + " / " + ((buf[i*4] & 255) | ((buf[i*4+1] & 255)<<8)) + " characters");
	    
// release interface 0
	    ztex.releaseInterface(0);	
	    ztex.dispose();
	    
	} 
	catch (Exception e) {
	    System.out.println("Error: "+e.getLocalizedMessage() );
	} 

   } 
   
}
