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

/** 
  * Thrown if a device runs with no or the wrong firmware, i.e. if the ZTEX descriptor is not found or damaged. */
public class InvalidFirmwareException extends Exception {
/** 
 * Constructs an instance from the error message.
 * @param msg The error message.
 */
    public InvalidFirmwareException ( String msg) {
	super( msg );
    }

/** 
 * Constructs an instance from the given device and error message.
 * @param ztex The device.
 * @param msg The error message.
 */
    public InvalidFirmwareException ( Ztex1 ztex, String msg) {
	this( ztex.dev().dev(), msg );
    } 

/** 
 * Constructs an instance from the given device and error message.
 * @param dev The device.
 * @param msg The error message.
 */
    public InvalidFirmwareException ( ZtexDevice1 dev, String msg) {
	this( dev.name() + ": " + msg );
    }

/** 
 * Constructs an instance from the given device and error message.
 * @param dev The device.
 * @param msg The error message.
 */
    public InvalidFirmwareException (Device dev, String msg) {
	super( ZtexDevice1.name(dev) + ": Invalid Firmware: "+ msg );
    }

/** 
 * Constructs an instance from the given device and error message.
 * @param ztex The device.
 */
    public InvalidFirmwareException ( Ztex1 ztex ) {
	this( ztex.dev().name() + ": Invalif Firmware" );
    } 

/** 
 * Constructs an instance from the given device and error message.
 * @param dev The device.
 */
    public InvalidFirmwareException ( ZtexDevice1 dev ) {
	this( dev.dev() );
    }

/** 
 * Constructs an instance from the given device and error message.
 * @param dev The device.
 */
    public InvalidFirmwareException (Device dev ) {
	super( ZtexDevice1.name(dev) + ": Invalid Firmware" );
    }
    
    
}    
