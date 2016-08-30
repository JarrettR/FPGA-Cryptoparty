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

import org.usb4java.*;

/** * Signals an USB error. */
public class UsbException extends Exception {
/** 
 * Constructs an instance from the given error message.
 * @param msg The error message.
 */
   public UsbException(String msg) {
	super( msg );
    }

/** 
 * Constructs an instance from the given device and error message.
 * @param dev The device.
 * @param msg The error message.
 */
    public UsbException(Device dev,  String msg) {
	super( ZtexDevice1.name(dev) + ": " + msg );
    }

/** 
 * Constructs an instance from error message and error number.
 * @param msg The error message.
 * @param errNum The error number.
 */
    public UsbException(String msg, int errNum) {
	super( msg + ": " + LibUsb.strError(errNum) );
    }

/** 
 * Constructs an instance from the given device, error message and error number.
 * @param dev The device.
 * @param msg The error message.
 * @param errNum The error number.
 */
    public UsbException(Device dev,  String msg, int errNum) {
	super( ZtexDevice1.name(dev) + ": " + msg + ": " + LibUsb.strError(errNum) );
    }
}    
