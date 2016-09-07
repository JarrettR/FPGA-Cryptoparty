#!/usr/bin/python
# -*- coding: utf-8 -*-
################################################################################
#                              python_ztex.py 
#    Top-level simulation of complete ZTEX 1.15y board
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

from python_sha1 import Sha1Model
from python_hmac import HmacModelModel
import cocotb
from cocotb.decorators import coroutine
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep, Event
from cocotb.drivers import BusDriver, ValidatedBusDriver
from cocotb.utils import hexdump
from cocotb.binary import BinaryValue
from cocotb.result import ReturnValue, TestError

class ZtexDriver(BusDriver):
    """
    ZTEX Driver
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
        
        
class ZtexModel(object):
    
    def __init__(self, HmacObj, Sha1Obj):
        self.Hmac = HmacObj
        self.Sha1 = Sha1Obj
        self.reset()
        
        
    def reset(self):
        self.message = [0] * 64
        self,messageLength = 0
    
    
    def run(self):
        secret = 'Jefe'
        value = 'what do ya want for nothing?'
        print "Goal: "
        print hmac.new(secret, value, hashlib.sha1).hexdigest()
        return self.load(secret, value)
        
    def addByte(self, input):
        self.shiftMessage()
        self.message[0] = input
        self.messageLength = self.messageLength + 1
        
    def shiftMessage(self):
        for x in range(63, 1, -1):
            self.message[x] = self.message[x - 1]

    def load(self, secret, value):
        self.addSecret(secret)
        
        shaBi = self.Sha1.hashString(self.generateString(self.Bi) + value)
        shaBiDec = shaBi.decode("hex")
        
        Bo = self.generateString(self.Bo) + shaBiDec
        self.shaBo = self.Sha1.hashString(Bo)
        
        return self.shaBo


if __name__ == "__main__":
    objSha = Sha1Model()
    objHmac = HmacModel(objSha)
    secret = 'Jefe'
    value = 'what do ya want for nothing?'
    secret = 'secret'
    value = 'value'
    
    print "Goal:   " + hmac.new(secret, value, hashlib.sha1).hexdigest()
    print "Result: " + objHmac.load(secret, value)
    