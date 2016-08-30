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

package ztex;

import java.io.*;
import java.util.*;
import java.nio.*;

import org.usb4java.*;

/** 
  * Provides methods for uploading firmware to Cypress EZ-USB devices.
  */
public class EzUsb {
// ******* reset **************************************************************
/** 
  * Controls the reset state of a Cypress EZ-USB device.
  * @param handle The handle of the device.
  * @param r The reset state (true means reset).
  * @throws FirmwareUploadException if an error occurred while attempting to control the reset state.
  */
    public static void resetFx2 ( DeviceHandle handle, boolean r ) throws FirmwareUploadException {
	ByteBuffer buffer = BufferUtils.allocateByteBuffer(1);
	buffer.put(new byte[] { (byte) (r ? 1 : 0) });

	int k = LibUsb.controlTransfer(handle, (byte)0x40, (byte)(0xA0 & 255), (short)(0xE600 & 0xffff), (short)0, buffer, 1000);  
	if ( k<0 ) 
	    throw new FirmwareUploadException( LibUsb.strError(k) + ": unable to set reset="+r );
	else if ( k!=1 ) 
	    throw new FirmwareUploadException( "Unable to set reset="+r );
	try {
    	    Thread.sleep( r ? 50 : 400 );	// give the firmware some time for initialization
	}
	catch ( InterruptedException e ) {
	}
    }
     
// ******* uploadFirmware ******************************************************
/** 
  * Uploads the Firmware to a Cypress EZ-USB device.
  * @param handle The handle of the device.
  * @param imgFile The firmware image.
  * @return the upload time in ms.
  * @throws FirmwareUploadException if an error occurred while attempting to upload the firmware.
  */
    public static long uploadFirmware (DeviceHandle handle, ImgFile imgFile ) throws FirmwareUploadException {
	final int transactionBytes = 4096;
	
	ByteBuffer buffer = BufferUtils.allocateByteBuffer(transactionBytes).order(ByteOrder.LITTLE_ENDIAN);

	if ( !imgFile.isFx3 )
	    resetFx2( handle, true );  // FX2 assumed, reset = 1
	
	long t0 = new Date().getTime();
	int j = 0;
	for ( int i=0; i<=imgFile.data.length; i++ ) {
	    if ( i >= imgFile.data.length || imgFile.data[i] < 0 || j >=transactionBytes ) {
		if ( j > 0 ) {
		    long addr = ImgFile.uncompressAddr(i-j);
		    int k = LibUsb.controlTransfer(handle, (byte)0x40, (byte)(0xA0 & 255), (short)(addr & 0xffff), (short)(addr >> 16), BufferUtils.slice(buffer,0,j), 1000);   // upload j bytes
		    if ( k<0 ) 
			throw new FirmwareUploadException(LibUsb.strError(k));
		    else if ( k!=j ) 
			throw new FirmwareUploadException("sent "+k+" bytes, expected "+j);
		    try {
		        Thread.sleep( 1 );	// to avoid package loss
		    }
			catch ( InterruptedException e ) {
		    }
		    buffer.clear();
		}
		j = 0;
	    }

	    if ( i < imgFile.data.length && imgFile.data[i] >= 0 && imgFile.data[i] <= 255 ) {
		buffer.put( (byte) imgFile.data[i] );
		j+=1;
	    }
	}
	long t1 = new Date().getTime();
	
	if ( imgFile.startVector >=0 ) {
	    LibUsb.controlTransfer(handle, (byte)0x40, (byte)(0xA0 & 255), (short)(imgFile.startVector & 0xffff), (short)(imgFile.startVector >> 16), ByteBuffer.allocateDirect(0), 1000);   // upload start vector
	} 

	try {
	    if ( !imgFile.isFx3 ) {
		resetFx2( handle, false );  // FX2 assumed, reset = 0, errors (due to renumeration) can be ignored
	    }
	}
	catch ( FirmwareUploadException e ) {
	}
	return t1 - t0;
    }
}    

