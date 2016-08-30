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
  * Thrown if a device is not supported, i.e. has the wrong USB ID's. */
public class DeviceNotSupportedException extends Exception {
/** 
 * Constructs an instance from the given device.
 * @param dev The device.
 */
    public DeviceNotSupportedException (Device dev) {
	super( ZtexDevice1.name(dev) + ": Device not supported" );
    }
}    
