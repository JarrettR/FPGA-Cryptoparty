/*!
   Java host software API of ZTEX SDK
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
    Reads a firmware image. .ihx and .img format is supported supported
*/
package ztex;

import java.io.*;
import java.util.*;
import java.net.*;
/**
  * A class representing a firmware image.
  */
public class ImgFile {

/**
  * This array stores the firmware image.
  * Values &lt;0 and &gt;255 mean that the data is undefined.
  */
    public short data[] = null;
    
/**
  * Start vector. 
  * Values &lt;0 mean that no start vector is defined.
  */    
    public long startVector = -1;
    
/**
  * Assumed to be an FX3 firmware.
  * This value is also set by {@link ZtexImgFile1}.
  */    
    public boolean isFx3 = false;


// ******* compressAddr ********************************************************
/**
  * Compresses the FX3 address space.
  * @param addr Uncompressed address
  * @param len Length of the data packet (used for address validity check).
  * @return Compressed address.
  * @throws ImgParseException If an invalid address occurs.
  */
    private static final int compressAddr( long addr, int len ) throws ImgParseException {
	int sector = (int) (addr >> 28);
	addr = addr & 0xfffffff;
	int addr_max = 64*1024;
	int addr_offs = 0;
	if ( sector >= 1 ) { addr_offs+=addr_max+1; addr_max=8*1024; }      // 64*1024+1
	if ( sector >= 4 ) { addr_offs+=addr_max+1; addr_max=512*1024; }    // 72*1024+2
	if ( sector >= 0xe ) { addr_offs+=addr_max+1; addr_max=256*1024; }  // 584*1024+3
	if ( sector >= 0xf ) { addr_offs+=addr_max+1; addr_max=32*1024; }   // 840*1024+4 .. 872*1024+3
	if ( addr<0 || addr+len>addr_max ) throw new ImgParseException( "Address out of range: " + Integer.toHexString((int)addr) );
	return (int)addr + addr_offs;
    }

// ******* uncompressAddr ******************************************************
/**
  * Uncompresses the FX3 address space.
  * @param addr Compressed address
  * @return Uncompressed address.
  */
    public static final long uncompressAddr( int addr ) {
	if ( addr >= 840*1024+4 ) return addr - (840*1024+4) + 0xf0000000;
	if ( addr >= 584*1024+3 ) return addr - (584*1024+3) + 0xe0000000;
	if ( addr >=  72*1024+2 ) return addr - ( 72*1024+2) + 0x40000000;
	if ( addr >=  64*1024+1 ) return addr - ( 64*1024+1) + 0x10000000;
	return addr;
    }
    
// ******* read ****************************************************************
    private static final int read( InputStream in ) throws IOException, ImgParseException {
	int b = in.read();
	if ( b<0 ) throw new ImgParseException( "Unexpected end of file" );
	return b;
    }
    
// ******* readHexDigit ********************************************************
    private static final int readHexDigit( InputStream in ) throws IOException, ImgParseException {
        int b = in.read();
	if ( b>=(byte) '0' && b<=(byte) '9' )
	    return b-(byte) '0';
	if ( b>=(byte) 'a' && b<=(byte) 'f' )
	    return 10+b-(byte) 'a';
	if ( b>=(byte) 'A' && b<=(byte) 'F' )
	    return 10+b-(byte) 'A';
	if ( b == -1 )
	    throw new ImgParseException( "Unexpected end of file" );
	throw new ImgParseException( "Hex digit expected: " + (char) b );
    }

// ******* readHexByte *********************************************************
    private static final int readHexByte(InputStream in) throws IOException, ImgParseException {
	return (readHexDigit(in) << 4) | readHexDigit(in);
    }
    
// ******* ImgFile *************************************************************
/**
  * Constructs an instance from a given file name.
  * This method can also read system resources, e.g. files from the current jar archive.
  * @param in Input stream from which the firmware file is read.
  * @param name Name of the input.
  * @throws IOException If an read error occurred.
  * @throws ImgFileDamagedException If the firmware file is damaged.
  */
    public ImgFile ( InputStream in, String name ) throws IOException, ImgFileDamagedException {
	int b, len, cs, addr;
	byte buf[] = new byte[256];
	boolean eof = false;
	int line = 0;
	
	boolean isImg = false;
	
	cs = 0;
	try {
	    b = read(in);
	    if ( b == (byte) 'C' ) {
		b = read(in);
		isFx3 = isImg = b == (byte) 'Y';
	    }

	    data = isImg ? new short[873*1024] : new short[64*1024];
	    
	    for ( int i=0; i<data.length; i++ )
		data[i] = -1;
	    	
	    if ( isImg ) {			// img file
		startVector = ( (read(in) & 1)==0 ) ? 0 : -1;
		if ( (b=read(in)) != 0xb0 ) throw new ImgParseException( "Invalid image type: " + Integer.toHexString(b) );
		while ( true ) {
		    len = read(in) | (read(in) << 8) | (read(in) << 16) | (read(in) << 24);
		    if ( len==0 ) break;
		    addr = compressAddr(read(in) | (read(in) << 8) | (read(in) << 16) | (read(in) << 24), len*4);
//		    System.out.println("ImgFile: " + len*4 + " bytes at 0x" + Integer.toHexString(addr));
		    for ( int i=0; i<len; i++ ) {
			data[addr+i*4] = (short) read(in);
			data[addr+i*4+1] = (short) read(in);
			data[addr+i*4+2] = (short) read(in);
			data[addr+i*4+3] = (short) read(in);
			cs += data[addr+i*4] | (data[addr+i*4+1]<<8) | (data[addr+i*4+2]<<16) | (data[addr+i*4+3] << 24);
		    }
		}
		if ( startVector==0 ) {
		    startVector=read(in) | (read(in) << 8) | (read(in) << 16) | (read(in) << 24);
		}
		else {
		    System.err.println("Warning: No program entry defined");
		}
		b = read(in) | (read(in) << 8) | (read(in) << 16) | (read(in) << 24);
		if ( b != cs )
		    throw new ImgParseException( "Checksum error" );
	    }
	    else {				// ihx file
		while ( ! eof ) {
		    while ( b != (byte) ':' ) {
			b = read(in);
		    }
		
		    line ++;

		    len = readHexByte(in);		// length field 
		    cs = len;
	    
		    b = readHexByte(in);		// address field 
		    cs += b;
		    addr = b << 8;
		    b = readHexByte(in);
		    cs += b;
		    addr |= b;
	    
		    b = readHexByte(in);		// record type field
		    cs += b;
	    
		    for ( int i=0; i<len; i++ ) {	// data
			buf[i] = (byte) readHexByte(in);
			cs+=buf[i];
		    }
	    
		    cs += readHexByte(in);		// checksum
		    if ( (cs & 0xff) != 0 ) {
			throw new ImgParseException( "Checksum error" );
		    }
	    
		    if ( b == 0 ) {			// data record
			for (int i=0; i<len; i++ ) {
			    if ( data[addr+i]>=0 ) System.err.println ( "Warning: Memory at position " + Integer.toHexString(i) + " overwritten" );
			    data[addr+i] = (short) (buf[i] & 255);
			}
		    }
		    else if (b == 1 ) {		// eof record
			eof = true;
		    }
		    else {
			throw new ImgParseException( "Invalid record type: " + b );
		    }
		}	    
	    }
	}
	catch ( ImgParseException e ) {
	    throw new ImgFileDamagedException ( name, line, e.getLocalizedMessage() );
	}

	try {
	    in.close();
	}
	catch ( Exception e ) {
	    System.err.println( "Warning: Error closing file " + name + ": " + e.getLocalizedMessage() );
	}
    }

/**
  * Constructs an instance from a given file name.
  * This method can also read system resources, e.g. files from the current jar archive.
  * @param fileName The file name.
  * @throws IOException If an read error occurred.
  * @throws ImgFileDamagedException If the firmware image file is damaged.
  */
    public ImgFile ( String fileName ) throws IOException, ImgFileDamagedException {
	this( JInputStream.getInputStream( fileName ), fileName );
    }

// ******* dataInfo ************************************************************
 /**
  * Print out some information about the memory usage.
  * @param out Where the data is printed out.
  */
   public void dataInfo( PrintStream out ) {
	int addr=-1;
	for ( int i=0; i<=data.length; i++ ) {	// data
	    if ( (i==data.length || data[i]<0) && addr>=0 ) {
		System.out.println( i-addr + " Bytes from " + Integer.toHexString(addr) + " to " + Integer.toHexString(i-1) );
		addr = -1;
	    }
	    if ( i<data.length && data[i]>=0 && addr<0 ) 
		addr = i;
	}
    }

}    

