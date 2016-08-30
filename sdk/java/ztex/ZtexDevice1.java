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
    USB device with ZTEX descriptor 1 and/or Cypress EZ-USB FX2/3 device
*/
package ztex;

import java.io.*;
import java.util.*;
import java.nio.*;

import org.usb4java.*;

/**
  * A class representing an EZ-USB device that supports the ZTEX descriptor 1 or an unconfigured EZ-USB device.<br>
  * Instances of this class are usually created by {@link ZtexScanBus1}.
  * The following table describes the ZTEX descriptor 1.
  * <a name="descriptor"></a>
  * <table bgcolor="#404040" cellspacing=1 cellpadding=4>
  *   <tr>
  *     <td bgcolor="#d0d0d0" valign="top"><b>Field name</b></td>
  *     <td bgcolor="#d0d0d0" valign="top"><b>Offset</b></td>
  *     <td bgcolor="#d0d0d0" valign="top"><b>Size</b></td>
  *     <td bgcolor="#d0d0d0" valign="top"><b>Description</b></td>
  *   </tr>
  *   <tr>
  *     <td bgcolor="#ffffff" valign="top">ZTEX_DESCRIPTOR_SIZE</td>
  *     <td bgcolor="#ffffff" valign="top">0</td>
  *     <td bgcolor="#ffffff" valign="top">1</td>
  *     <td bgcolor="#ffffff" valign="top">Size of the descriptor in bytes; must be 40 for descriptor version 1</td>
  *   </tr>
  *   <tr>
  *     <td bgcolor="#ffffff" valign="top">ZTEX_DESCRIPTOR_VERSION</td>
  *     <td bgcolor="#ffffff" valign="top">1</td>
  *     <td bgcolor="#ffffff" valign="top">1</td>
  *     <td bgcolor="#ffffff" valign="top">Descriptor version; 1 for version 1</td>
  *   </tr>
  *   <tr>
  *     <td bgcolor="#ffffff" valign="top">ZTEXID</td>
  *     <td bgcolor="#ffffff" valign="top">2</td>
  *     <td bgcolor="#ffffff" valign="top">4</td>
  *     <td bgcolor="#ffffff" valign="top">ID; must be "ZTEX"</td>
  *   </tr>
  *   <tr>
  *     <td bgcolor="#ffffff" valign="top">PRODUCT_ID</td>
  *     <td bgcolor="#ffffff" valign="top">6</td>
  *     <td bgcolor="#ffffff" valign="top">4</td>
  *     <td bgcolor="#ffffff" valign="top">Four numbers (0..255) representing the product ID and firmware compatibility information.<br>
  *         A firmware can overwrite an installed one<br>
  *	   <pre>if ( INSTALLED.PRODUCTID[0]==0 || PRODUCTID[0]==0 || INSTALLED.PRODUCTID[0]==PRODUCTID[0] ) && 
   ( INSTALLED.PRODUCTID[1]==0 || PRODUCTID[1]==0 || INSTALLED.PRODUCTID[1]==PRODUCTID[1] ) && 
   ( INSTALLED.PRODUCTID[2]==0 || PRODUCTID[2]==0 || INSTALLED.PRODUCTID[2]==PRODUCTID[2] ) && 
   ( INSTALLED.PRODUCTID[3]==0 || PRODUCTID[3]==0 || INSTALLED.PRODUCTID[3]==PRODUCTID[3] ) </pre>
  *       Here is a list of the preserved product ID's:
  *       <table><tr><td>&nbsp</td><td>
  *         <table>
  *          <tr><td>0.0.0.0</td> <td>default Product ID (no product specified)</td></tr>
  *           <tr><td>1.*.*.*</td> <td>may be used for experimental purposes</td></tr>
  *           <tr><td>10.*.*.*</td> <td>used for ZTEX products</td></tr>
  *           <tr><td>10.11.*.*</td> <td>ZTEX USB-FPGA-Module 1.2</td></tr>
  *           <tr><td>10.12.*.*</td> <td>ZTEX USB-FPGA-Module 1.11</td></tr>
  *	      <tr><td>10.12.2.1..4</td> <td>NIT (http://www.niteurope.com/)</td></tr>
  *           <tr><td>10.13.*.*</td> <td>ZTEX USB-FPGA-Module 1.15 (not 1.15y)</td></tr>
  *           <tr><td>10.14.*.*</td> <td>ZTEX USB-FPGA-Module 1.15x</td></tr>
  *           <tr><td>10.15.*.*</td> <td>ZTEX USB-FPGA-Module 1.15y</td></tr>
  *           <tr><td>10.16.*.*</td> <td> ZTEX USB-FPGA-Module 2.16</td></tr>
  *           <tr><td>10.17.*.*</td> <td>ZTEX USB-FPGA-Module 2.13</td></tr>
  *           <tr><td>10.18.*.*</td> <td>ZTEX USB-FPGA-Module 2.01</td></tr>
  *           <tr><td>10.19.*.*</td> <td>ZTEX USB-FPGA-Module 2.04</td></tr>
  *           <tr><td>10.20.*.*</td> <td>ZTEX USB-Module 1.0</td></tr>
  *           <tr><td>10.30.*.*</td> <td>ZTEX USB-XMEGA-Module 1.0</td></tr>
  *           <tr><td>10.40.*.*</td> <td>ZTEX USB-FPGA-Module 2.02</td></tr>
  *           <tr><td>10.41.*.*</td> <td>ZTEX USB-FPGA-Module 2.14</td></tr>
  *           <tr><td>10.0.1.1</td> <td>ZTEX BTCMiner firmware</td></tr>
  *         </table></td></tr></table>
  *         Please contact us (<a href="http://www.ztex.de/contact.e.html">http://www.ztex.de/contact.e.html</a>) if you want to register or reserve a Product ID (range).
  *       </td>
  *   </tr>
  *   <tr>
  *     <td bgcolor="#ffffff" valign="top">FW_VERSION</td>
  *     <td bgcolor="#ffffff" valign="top">10</td>
  *     <td bgcolor="#ffffff" valign="top">1</td>
  *     <td bgcolor="#ffffff" valign="top">May be used to specify the firmware version.</td>
  *   </tr>
  *   <tr>
  *     <td bgcolor="#ffffff" valign="top">INTERFACE_VERSION</td>
  *     <td bgcolor="#ffffff" valign="top">11</td>
  *     <td bgcolor="#ffffff" valign="top">1</td>
  *     <td bgcolor="#ffffff" valign="top">The interface version. This number specifies the protocol that is used for interfacing the host software. A description of interface version 1 can be found in {@link Ztex1v1} </td>
  *   </tr>
  *   <tr>
  *     <td bgcolor="#ffffff" valign="top">INTERFACE_CAPABILITIES</td>
  *     <td bgcolor="#ffffff" valign="top">12</td>
  *     <td bgcolor="#ffffff" valign="top">6</td>
  *     <td bgcolor="#ffffff" valign="top">6 bytes, each bit represents a capability. If set, the capability is supported. A description of the capabilities of interface version 1 can be found in {@link Ztex1v1} </td>
  *   </tr>
  *   <tr>
  *     <td bgcolor="#ffffff" valign="top">MODULE_RESERVED</td>
  *     <td bgcolor="#ffffff" valign="top">18</td>
  *     <td bgcolor="#ffffff" valign="top">12</td>
  *     <td bgcolor="#ffffff" valign="top">12 bytes for application specific use, i.e. they depend from the PRODUCT_ID </td>
  *   </tr>
  *   <tr>
  *     <td bgcolor="#ffffff" valign="top">SN_STRING</td>
  *     <td bgcolor="#ffffff" valign="top">30</td>
  *     <td bgcolor="#ffffff" valign="top">10</td>
  *     <td bgcolor="#ffffff" valign="top">A serial number string of 10 characters. The default SN is "0000000000"</td> </td>
  *   </tr>
  * </table>
  * @see Ztex1
  * @see Ztex1v1
  * @see ZtexScanBus1
*/

public class ZtexDevice1 {
/** * Cypress vendor ID: 0x4b4 */
    public static final int cypressVendorId = 0x4b4;
/** * EZ-USB USB FX2 product ID: 0x8613 */
    public static final int cypressProductIdFx2 = 0x8613;
/** * EZ-USB USB FX3 product ID: 0x00f3 */
    public static final int cypressProductIdFx3 = 0x00f3;
//    public static final int cypressProductIdFx3 = 0x4720;

/** * Vendor ID of buggy FX3 devices (datecode 1149) */
    public static final int cypressVendorIdBuggy = 0x1480;
/** * Product ID of buggy FX3 devices (datecode 1149) */
    public static final int cypressProductIdBuggy = 0x0000;

/** * ZTEX vendor ID: 0x221a */
    public static final int ztexVendorId = 0x221A;
/** 
  * USB product ID for ZTEX devices that support ZTEX descriptor 1: 0x100.
  * This product ID is intended for general purpose use and can be shared by all devices that base on ZTEX modules.
  * Different products are identified by a second product ID, namely the PRODUCT_ID field of the <a href="#descriptor"> ZTEX descriptor 1</a>.
  * <p>
  * Please read the <a href="http://www.ztex.de/firmware-kit/usb_ids.e.html">informations about USB vendor and product ID's<a>.
  * @see #ztexProductIdMax
  */
    public static final int ztexProductId = 0x100;
/** 
  * Largest USB product ID for ZTEX devices that support ZTEX descriptor 1: 0x1ff.
  * USB product ID's from {@link #ztexProductId}+1 to ztexProductIdMax (0x101 to 0x1ff) are reserved for ZTEX devices and allow to identify products without reading the ZTEX descriptor.
  * <p>
  * Please read the <a href="http://www.ztex.de/firmware-kit/usb_ids.e.html">informations about USB vendor and product ID's<a>.
  * @see #ztexProductId
  */
    public static final int ztexProductIdMax = 0x1ff;

    private Device dev = null;
    private boolean valid = false;		// true if descriptor 1 is available
    private int usbVendorId = -1;
    private int usbProductId = -1;
    private String manufacturerString = null;
    private String productString = null;
    private String snString = null;
    private byte productId[] = { 0,0,0,0 };	// product ID from the ZTEX descriptor, not the USB product ID
    private byte fwVersion = 0;
    private byte interfaceVersion = 0;
    private byte interfaceCapabilities[] = { 0,0,0,0, 0,0 };
    private byte moduleReserved[] = { 0,0,0,0, 0,0,0,0, 0,0,0,0 };
    private boolean fx3 = false;
    private ZtexContext context = null;
    private int refCount = 0;

// ******* byteArrayString *****************************************************
/**
  * Produces a nice string representation of an array of bytes.
  * @param buf A byte array.
  * @return a nice string
  */ 
    public static String byteArrayString ( byte buf[] ) {
	String s = new String( "" );
	for ( int i = 0; i<buf.length; i++ ) {
	    if ( i != 0 ) 
		s+=".";
	    s+=buf[i] & 255;
	}
	return s;
    }
    
// ******* ZtexDevice1 *********************************************************
/**
  * Constructs an instance from a given USB device.<br>
  * If the given vendor and product id's match to the vendor and product id's of the given USB device,
  * the ZTEX descriptor 1 is attempted to read. If this fails, an {@link InvalidFirmwareException} is thrown.
  * To suppress this behavior (e.g. if the EZ-USB device is known to be unconfigured) the vendor and product id's 
  * can be set to -1.
  * @param p_context The USB context.
  * @param p_dev The USB device.
  * @param pUsbVendorId The given vendor ID.
  * @param pUsbProductId The given product ID.
  * @param allowUnconfigured If true, unconfigured devices are allowed.
  * @throws UsbException if an USB communication error occurs.
  * @throws InvalidFirmwareException if no valid ZTEX descriptor 1 is found.
  * @throws DeviceNotSupported if the device has the wrong USB ID's.
  */
    public ZtexDevice1 (ZtexContext p_context, Device p_dev, int pUsbVendorId, int pUsbProductId, boolean allowUnconfigured) throws UsbException, InvalidFirmwareException, DeviceNotSupportedException  {
	context = p_context;
	dev = p_dev;
	refCount = 0;

        DeviceDescriptor dd = new DeviceDescriptor();
        int result = LibUsb.getDeviceDescriptor(dev, dd);
        if (result != LibUsb.SUCCESS) throw new UsbException(dev, "Unable to read device descriptor", result);
	usbVendorId = dd.idVendor() & 65535;
	usbProductId = dd.idProduct() & 65535;
        
	fx3 = (usbVendorId == cypressVendorId) && (usbProductId == cypressProductIdFx3) || (usbVendorId == cypressVendorIdBuggy) && (usbProductId == cypressProductIdBuggy);
	if ( ! ( ( 
	           (usbVendorId == pUsbVendorId) && 
	           (usbProductId == pUsbProductId || ( usbVendorId == ztexVendorId && pUsbProductId<0 && usbProductId>=ztexProductId && usbProductId<ztexProductIdMax ) )
	         ) ||
	         ( 
	           allowUnconfigured && 
	            ( (usbVendorId == cypressVendorId) && (usbProductId == cypressProductIdFx2) || fx3 )
	         ) )  )
	    throw new DeviceNotSupportedException(p_dev);
	
	DeviceHandle handle = new DeviceHandle();
	result = LibUsb.open(dev, handle);
	if (result != LibUsb.SUCCESS) throw new UsbException(dev, "Unable to open USB device", result);

	if ( dd.iManufacturer() > 0 ) 
	    manufacturerString = LibUsb.getStringDescriptor( handle, dd.iManufacturer() );
	if ( dd.iProduct() > 0 ) 
	    productString = LibUsb.getStringDescriptor( handle, dd.iProduct() );
	if ( dd.iSerialNumber() > 0 )  
	    snString = LibUsb.getStringDescriptor( handle, dd.iSerialNumber() );
		
//	    System.out.println("snString="+snString);
	if ( snString == null ) {
	    LibUsb.close(handle);
	    if ( allowUnconfigured ) {
		ref();
	        return;
	    }
	    else {
	        throw new InvalidFirmwareException( dev, "Not a ZTEX device" );  // ZTEX devices always have a SN. See also the next comment a few lines below
	    }
	} 
	
	ByteBuffer buf = BufferUtils.allocateByteBuffer(42);
	int i = LibUsb.controlTransfer(handle, (byte) (0xc0 & 255), (byte)0x22, (short)0,(short)0, buf, 500);	// Failing of this may cause problems under windows. Therefore we check for the SN above.
	if ( i < 0 ) {
	    LibUsb.close(handle);
	    if ( allowUnconfigured ) {
		ref();
	        return;
	    }    
	    else {
	        throw new InvalidFirmwareException( dev, "Error reading ZTEX descriptor: " + LibUsb.strError(i) );
	    }
	}
	else if ( i != 40 ) {
	    LibUsb.close(handle);
	    if ( allowUnconfigured ) {
		ref();
	        return;
	    }
	    else {
	        throw new InvalidFirmwareException( dev, "Error reading ZTEX descriptor: Invalid size: " + i );
	    }
	}

	if ( buf.get()!=40 || buf.get()!=1 || buf.get()!='Z' || buf.get()!='T' || buf.get()!='E' || buf.get()!='X' ) {
	    LibUsb.close(handle);
	    if ( allowUnconfigured ) {
		ref();
	        return;
	    }
	    else  {
	        throw new InvalidFirmwareException( dev, "Invalid ZTEX descriptor" );
	    }
	}
	buf.get(productId, 0, 4);              // 6
	fwVersion = buf.get();                 // 10
	interfaceVersion = buf.get();          // 11
	buf.get(interfaceCapabilities, 0, 6);  // 12
	buf.get(moduleReserved, 0, 12);	       // 18
	    
	fx3 = (interfaceCapabilities[1] & 4) != 0;
	
	valid = true;
	ref();
        LibUsb.close(handle);
    }

// ******* toString ************************************************************
/** 
  * Returns a string representation if the device with a lot of useful information.
  * @return a string representation if the device with a lot of useful information.
  */
    public String toString () {
	return name() + "  ID=" + Integer.toHexString(usbVendorId) + ":" + Integer.toHexString(usbProductId) +"\n"  +
	      ( manufacturerString == null ? "" : ("   Manufacturer=\""  + manufacturerString + "\"") ) +
	      ( productString == null ? "" : ("  Product=\""  + productString + "\"") ) +
	      ( snString == null ? "" : ("    SerialNumber=\""  + snString + "\"") ) +
	      ( valid ? "\n   productID=" + byteArrayString(productId) + "  fwVer="+(fwVersion & 255) + "  ifVer="+(interfaceVersion & 255)  : "" );
    }

// ******* name ****************************************************************
/** 
  * Returns a name that identifies a device.
  * @param p_dev the device.
  * @return a name that identifies a device.
  */
    public static String name ( Device p_dev ) {
	return "bus=" + LibUsb.getBusNumber(p_dev) + " device=" + LibUsb.getDeviceAddress(p_dev) + " port=" + LibUsb.getPortNumber(p_dev);
    }

// ******* name ****************************************************************
/** 
  * Returns a name that identifies the device.
  * @return a name that identifies the device.
  */
    public String name () {
	return name(dev);
    }

// ******* compatible **********************************************************
/** 
  * Checks whether the given product ID is compatible to the device.<br>
  * The given product ID is compatible
  * <pre>if ( this.productId(0)==0 || productId0<=0 || this.productId(0)==productId0 ) && 
   ( this.productId(0)==0 || productId1<=0 || this.productId(1)==productId1 ) && 
   ( this.productId(2)==0 || productId2<=0 || this.productId(2)==productId2 ) && 
   ( this.productId(3)==0 || productId3<=0 || this.productId(3)==productId3 ) </pre>
  * @param productId0 Byte 0 of the given product ID
  * @param productId1 Byte 1 of the given product ID
  * @param productId2 Byte 2 of the given product ID
  * @param productId3 Byte 3 of the given product ID
  * @return true if the given product ID is compatible
  */
    public final boolean compatible( int productId0, int productId1, int productId2, int productId3 ) {
	return ( productId[0]==0 || productId0<=0 || (productId[0] & 255) == productId0 ) &&
	       ( productId[1]==0 || productId1<=0 || (productId[1] & 255) == productId1 ) &&
	       ( productId[2]==0 || productId2<=0 || (productId[2] & 255) == productId2 ) &&
	       ( productId[3]==0 || productId3<=0 || (productId[3] & 255) == productId3 );
    }
    
// ******* dev *****************************************************************
/** 
  * Returns the USB device.
  * @return the USB device.
  */
    public final Device dev() {
	return dev;
    }

// ******* context *************************************************************
/** 
  * Returns the USB context of the device.
  * @return the USB context of the device.
  */
    public final ZtexContext context() {
	return context;
    }

// ******* valid ***************************************************************
/** 
  * Returns true if ZTEX descriptor 1 is available.
  * @return true if ZTEX descriptor 1 is available.
  */
    public final boolean valid() {
	return valid;
    }

// ******* usbVendorId *********************************************************
/** 
  * Returns the USB vendor ID of the device.
  * @return the USB vendor ID of the device.
  */
    public final int usbVendorId() {
	return usbVendorId;
    }

// ******* usbProductId *********************************************************
/** 
  * Returns the USB product ID of the device.
  * @return the USB product ID of the device.
  */
    public final int usbProductId() {
	return usbProductId;
    }

// ******* manufacturerString **************************************************
/** 
  * Returns the manufacturer string of the device.
  * @return the manufacturer string of the device.
  */
    public final String manufacturerString() {
	return manufacturerString;
    }

// ******* productString *******************************************************
/** 
  * Returns the product string of the device.
  * @return the product string of the device.
  */
    public final String productString() {
	return productString;
    }

// ******* snString ************************************************************
/** 
  * Returns the serial number string of the device.
  * @return the serial number string of the device.
  */
    public final String snString() {
	return snString;
    }

// ******* productId ***********************************************************
/** 
  * Returns the product ID (all 4 bytes).
  * @return PRODUCT_ID, see above.
  */
    public final byte[] productId() {
	return productId;
    }

/** 
  * Returns byte i of the product ID.
  * @return PRODUCT_ID[i], see above.
  * @param i index 
  */
    public int productId( int i ) {
	return productId[i] & 255;
    }

// ******* fwVersion ***********************************************************
/** 
  * Returns the firmware version.
  * @return FW_VERSION, see above.
  */
    public final int fwVersion() {
	return fwVersion & 255;
    }

// ******* interfaceVersion *****************************************************
/** 
  * Returns the interface version.
  * @return INTERFACE_VERSION, see above.
  */
    public final int interfaceVersion() {
	return interfaceVersion & 255;
    }

// ******* interfaceCapabilities ************************************************
/** 
  * Returns the interface capabilities (all 6 bytes).
  * @return INTERFACE_CAPABILITIES, see above.
  */
    public final byte[] interfaceCapabilities() {
	return interfaceCapabilities;
    }

/** 
  * Returns byte i of the interface capabilities.
  * @return INTERFACE_CAPABILITIES[i], see above.
  * @param i index 
  */
    public final int interfaceCapabilities( int i ) {
	return interfaceCapabilities[i] & 255;
    }

/** 
  * Returns byte i, bit j  of the interface capabilities.
  * @return INTERFACE_CAPABILITIES[i].j, see above.
  * @param i byte index 
  * @param j bit index 
  */
    public final boolean interfaceCapabilities( int i, int j ) {
	return 	(i>=0) && (i<=5) && (j>=0) && (j<8) &&
		(((interfaceCapabilities[i] & 255) & (1 << j)) != 0);
    }

// ******* moduleReserved ******************************************************
/** 
  * Returns the application specific information (all 12 bytes).
  * @return MODULE_RESERVED, see above.
  */
    public final byte[] moduleReserved() {
	return moduleReserved;
    }

/** 
  * Returns byte i of the application specific information.
  * @return MODULE_RESERVED[i], see above.
  * @param i index 
  */
    public final int moduleReserved( int i ) {
	return moduleReserved[i] & 255;
    }

// ******* fx3 *****************************************************************
/** 
  * Returns true if device is an FX3
  * @return true if device is an FX3
  */
    public final boolean fx3 () {
	return fx3;
    }

// ******* ref *****************************************************************
/** 
  * Increases reference counter.
  */
    public synchronized void ref() throws UsbException {
	refCount ++;
	if ( refCount == 1 ) {
	    LibUsb.refDevice(dev);
	    context.ref();
//	    System.out.println("created ZtexDevice1: "+name());
	}
    }

// ******* unref ***************************************************************
/** 
  * Decreases reference counter and rleases resources if 0 is reached.
  */
    public synchronized void unref() {
	refCount --;
	if ( refCount == 0 ) {
//	    System.out.println("disposing ZtexDevice1: "+name());
	    LibUsb.unrefDevice(dev);
	    context.unref();
	}
    }

// ******* finalize ************************************************************
    protected void finalize() throws Throwable {
	if (refCount > 0) refCount=1;
	unref();
        super.finalize();
    }

}
