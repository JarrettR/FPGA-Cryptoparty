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

/** * Signals that a firmware image is corrupt. */ 
public class ImgFileDamagedException extends Exception {
/** 
  * Constructs an instance from a given file name, line number and error message.
  * @param filename The file name.
  * @param line The line number.
  * @param msg An error message.
  */
    public ImgFileDamagedException ( String filename, int line, String msg ) {
	super( "Firmware file " + filename + ( line>0 ? ( "(" + line + ")" ) : "" ) + " damaged: "+msg );
    }

    public ImgFileDamagedException ( String filename, String msg ) {
	super( "Firmware file " + filename + " damaged: "+msg );
    }
}    
