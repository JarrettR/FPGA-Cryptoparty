/*!
   ucecho -- uppercase conversion example for ZTEX USB-FPGA Module 1.15b and 1.15y2
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

import ch.ntb.usb.*;

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
		"    -w                Enable certain workarounds\n"+
		"    -h                This help" );
    
    public ParameterException (String msg) {
	super( msg + "\n" + helpMsg );
    }
}

// *****************************************************************************
// ******* Test0 ***************************************************************
// *****************************************************************************
class WPA2 extends Ztex1v1 {

// ******* WPA2 **************************************************************
// constructor
    public WPA2 ( ZtexDevice1 pDev ) throws UsbException {
        super ( pDev );
    }

// ******* load ****************************************************************
// writes a file to Endpoint 4, reads it back from Endpoint 2 and writes the output to System.out
    public void load ( int fpga, String filename ) throws UsbException, InvalidFirmwareException, IndexOutOfBoundsException {
        byte[] buf;
        RandomAccessFile f;
        
        try {
            f = new RandomAccessFile(filename, "r");
            try {
                buf = new byte[(int)f.length()];
                f.readFully(buf);
                
                selectFpga(fpga);
                
                int i = LibusbJava.usb_bulk_write(handle(), 0x04, buf, buf.length, 1000);
                if ( i<0 )
                    throw new UsbException("Error sending data: " + LibusbJava.usb_strerror());
                System.out.println("FPGA " + fpga + ": Send file: `" + filename + "' (" + i + " bytes)" );

                try {
                        Thread.sleep( 10 );
                }  catch ( InterruptedException e ) { }

                buf = new byte[1024];
                i = LibusbJava.usb_bulk_read(handle(), 0x82, buf, 1024, 1000);
                if ( i < 0 )
                    throw new UsbException("Error receiving data: " + LibusbJava.usb_strerror());
                System.out.println("FPGA " + fpga + ": Read "+i+" bytes: `"+new String(buf,0,i)+"'" );  
            } catch ( IOException e ) {
                System.out.println("Could not read file!");
            }
        } catch ( FileNotFoundException e ) {
            System.out.println("File not found!");
        }
    }

// ******* echo ****************************************************************
// writes a string to Endpoint 4, reads it back from Endpoint 2 and writes the output to System.out
    public void echo ( int fpga, String input ) throws UsbException, InvalidFirmwareException, IndexOutOfBoundsException {
        byte buf[] = input.getBytes(); 
        
        selectFpga(fpga);
        
        int i = LibusbJava.usb_bulk_write(handle(), 0x04, buf, buf.length, 1000);
        if ( i<0 )
            throw new UsbException("Error sending data: " + LibusbJava.usb_strerror());
        System.out.println("FPGA " + fpga + ": Send " + i + " bytes: `" + input + "'" );

        try {
                Thread.sleep( 10 );
        }
            catch ( InterruptedException e ) {
        }

        buf = new byte[1024];
        i = LibusbJava.usb_bulk_read(handle(), 0x82, buf, 1024, 1000);
        if ( i < 0 )
            throw new UsbException("Error receiving data: " + LibusbJava.usb_strerror());
        System.out.println("FPGA " + fpga + ": Read "+i+" bytes: `"+new String(buf,0,i)+"'" );  
    }

// ******* read_in ****************************************************************
// writes the 'read input' command to Endpoint 4, reads the input data from Endpoint 2 and writes it to System.out
    public void read_in ( int fpga ) throws UsbException, InvalidFirmwareException, IndexOutOfBoundsException {
        byte sendBuf[] = "r".getBytes();
        //sendBuf[0] = "r".getBytes; 
        
        selectFpga(fpga);
        
        int i = LibusbJava.usb_bulk_write(handle(), 0x04, sendBuf, sendBuf.length, 1000);
        if ( i<0 )
            throw new UsbException("Error sending data: " + LibusbJava.usb_strerror());
        System.out.println("FPGA " + fpga + ": Send " + i + " bytes: `" + sendBuf + "'" );
        sendBuf = "s".getBytes();
        
        try {
                Thread.sleep( 30 );
        }
            catch ( InterruptedException e ) {
        }

        byte buf[] = new byte[1024];
        String outbuf = "";
        do {
            i = LibusbJava.usb_bulk_read(handle(), 0x82, buf, 1024, 1000);
            System.out.println("Sup");
            if ( i < 0 )
                throw new UsbException("Error receiving data: " + LibusbJava.usb_strerror());
            System.out.println("FPGA " + fpga + ": Read "+i+" bytes: `"+new String(buf,0,i)+"'" );
            //i = LibusbJava.usb_bulk_write(handle(), 0x04, sendBuf, sendBuf.length, 1000);
            //if ( i<0 )
            //    throw new UsbException("Error sending data: " + LibusbJava.usb_strerror());
            //outbuf += new String(buf,0,i);
        } while (sendBuf[sendBuf.length] != 0x00);
        System.out.println("FPGA " + fpga + ": Read "+i+" bytes: `"+outbuf+"'" );  
    }
    
// ******* main ****************************************************************
        public static void main (String args[]) {
        
        int devNum = 0;
        boolean force = false;
        boolean workarounds = false;
        
        try {
    // init USB stuff
            LibusbJava.usb_init();

    // scan the USB bus
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
                else if ( args[i].equals("-w") ) {
                    workarounds = true;
                }
                else if ( args[i].equals("-h") ) {
                    System.err.println(ParameterException.helpMsg);
                        System.exit(0);
                }
                else throw new ParameterException("Invalid Parameter: "+args[i]);
            }
            

            // create the main class	    
            WPA2 ztex = new WPA2 ( bus.device(devNum) );
            ztex.certainWorkarounds = workarounds;
            
            // upload the firmware if necessary
            if ( force || ! ztex.valid() || ! ztex.dev().productString().equals("WPA2 for UFM 1.15y")  ) {
                System.out.println("Firmware upload time: " + ztex.uploadFirmware( "wpa2.ihx", force ) + " ms");
                force=true;
            }

            System.out.println("" + ztex.numberOfFpgas() + " FPGA's found");

            // upload the bitstream if necessary
            for (int i=0; i<ztex.numberOfFpgas(); i++ ) {
                ztex.selectFpga(i);
                if ( force || ! ztex.getFpgaConfiguration() ) {
                    System.out.print("FPGA "+i+": ");
                    System.out.println("FPGA configuration time: " + ztex.configureFpga( "../hdl/ztex_wrapper.bit" , force ) + " ms");
                    //ztex.vendorCommand (0x60, "Set test mode", 0, 0);
                    //reader.reset();
                }
            } 

            // claim interface 0
            ztex.trySetConfiguration ( 1 );
            ztex.claimInterface ( 0 );
            
            // read string from stdin and write it to USB device
            String str = "";
            BufferedReader reader = new BufferedReader( new InputStreamReader( System.in ) );
            while ( ! str.equals("quit") ) {
                System.out.print("Enter a command string or `quit' to exit the program: ");
                str = reader.readLine();
                if ( str.equals("?") ) {
                    System.out.print("    l:       load file\n");
                    System.out.print("    i<5>:    send input command, followed by 5 byte input\n");
                    System.out.print("    s:       request status\n");
                    System.out.print("    r:       read target input\n");
                    System.out.print("    o:       read target output\n");
                    System.out.print("    b:       begin calculations\n");
                    System.out.print("    a:       abort\n");
                } else if ( str.equals("l") ) {
                    for ( int i=0; i<ztex.numberOfFpgas(); i++ ) 
                        ztex.load(i, "test.hccap");
                } else if ( str.equals("r") ) {
                    for ( int i=0; i<ztex.numberOfFpgas(); i++ ) 
                        ztex.read_in(i);
                /*} else if ( str.equals("s") ) {
                    for ( int i=0; i<ztex.numberOfFpgas(); i++ ) 
                        ztex.load(i, "test.hccap");
                } else if ( str.equals("i") ) {
                    for ( int i=0; i<ztex.numberOfFpgas(); i++ ) 
                        ztex.load(i, "test.hccap");
                } else if ( str.equals("b") ) {
                    for ( int i=0; i<ztex.numberOfFpgas(); i++ ) 
                        ztex.load(i, "test.hccap");
                } else if ( str.equals("a") ) {
                    for ( int i=0; i<ztex.numberOfFpgas(); i++ ) 
                        ztex.load(i, "test.hccap");*/
                } else if ( ! str.equals("") ) {
                    for ( int i=0; i<ztex.numberOfFpgas(); i++ ) 
                        ztex.echo(i, str);
                }
                System.out.println("");
            }
            
            // release interface 0
            ztex.releaseInterface( 0 );	
            
        }
        catch (Exception e) {
            System.out.println("Error: "+e.getLocalizedMessage() );
        } 
   } 
   
}
