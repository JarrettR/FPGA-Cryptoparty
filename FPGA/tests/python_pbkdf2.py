#!/usr/bin/python
# -*- coding: utf-8 -*-
################################################################################
#                            python_pbkdf2.py 
#    PBKDF2 mock object
#    Copyright (C) 2016  Jarrett Rainier
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

import hashlib #For testing mock objects
import random
from python_sha1 import Sha1Model
from python_hmac import HmacModel
'''
import cocotb
from cocotb.decorators import coroutine
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep, Event
from cocotb.drivers import BusDriver, ValidatedBusDriver
from cocotb.utils import hexdump
from cocotb.binary import BinaryValue
from cocotb.result import ReturnValue, TestError


class Pbkdf2Driver(BusDriver):
    """
    PBKDF2 Driver
    """
    _signals = ["dat_i", "load_i", "rst_i"]
    _optional_signals = []

    def __init__(self, entity, name, clock):
        BusDriver.__init__(self, entity, name, clock)
        
        word   = BinaryValue(bits=32)
        single = BinaryValue(bits=1)

        word.binstr   = ("x" * 32)
        single.binstr = ("x")

        self.bus.load_i <= single
        self.bus.rst_i <= single
        self.bus.dat_i <= word

'''
class Pbkdf2Model(object):
    
    def __init__(self):
        self.W = [0] * 80
        self.reset()
        
    def reset(self):
        self.message = [0] * 64
        self.messageLength = 0
        
    def run(self, objHmac, mk, ssid):
        test = objHmac.load(mk, ssid)
        
        x1 = objHmac.load(mk, ssid + '\0\0\0\1')
        x2 = objHmac.load(mk, ssid + '\0\0\0\2')
        #x1 = objHmac.load(mk, ssid + '\1')
        #x2 = objHmac.load(mk, ssid + '\2')
        
        for x in xrange(4096):
            x1 = objHmac.load(mk, self.toAscii(x1))
            x2 = objHmac.load(mk, self.toAscii(x2))
            #print '{} - {} - {}'.format(x1, (ord(c) for c in self.toAscii(x1)), x1)
            self.xorString(x1, x2)
        
        return x1 + ' ' + x2
        
    def addByte(self, input):
        self.shiftMessage()
        self.message[0] = input
        self.messageLength = self.messageLength + 1
        
    def xorString(self, in1, in2):
        i = 0
        out = ''
        x1 = self.toAscii(in1)
        x2 = self.toAscii(in2)
        for x in xrange(len(x1)):
            #print x1[x]
            what = chr(ord(x1[x]) ^ ord(x2[x]))
            out += what
            #print what
            
        return out
        
    def toAscii(self, input):
        str = ''
        while len(input) > 0:
            str = chr(int(input[-2:], 16)) + str
            input = input[0:-2]
        return str

    def formatW(self, start = 0, stop = 80):
        W = ''
        for x in range(start, stop):
            W = W + '{:08X} '.format(self.W[x])
        
        return W[:-1]

if __name__ == "__main__":
    objSha = Sha1Model()
    objHmac = HmacModel(objSha)
    objPbkdf2 = Pbkdf2Model()
    secret = 'Jefe'
    value = 'what do ya want for nothing?'
    secret = 'secret'
    value = 'value'
    
    # 64 hex digits / 32 bytes / 256 bits
    print objPbkdf2.run(objHmac, secret, value)
    