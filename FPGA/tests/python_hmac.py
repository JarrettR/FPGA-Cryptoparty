#!/usr/bin/python
# -*- coding: utf-8 -*-
################################################################################
#  Home-rolled HMAC algorithm allows better debugging of intermediate steps 
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
import hashlib
import hmac
'''
import cocotb
from cocotb.decorators import coroutine
from cocotb.triggers import RisingEdge, ReadOnly, NextTimeStep, Event
from cocotb.drivers import BusDriver, ValidatedBusDriver
from cocotb.utils import hexdump
from cocotb.binary import BinaryValue
from cocotb.result import ReturnValue, TestError

class HmacDriver(BusDriver):
    """
    HMAC Driver
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
class HmacModel(object):
    
    def __init__(self, Sha1Obj):
        self.Sha1 = Sha1Obj
        self.shaBo = ''
        self.reset()
        
        
    def reset(self):
        self.Bi = [0x36] * 64
        self.Bo = [0x5c] * 64
    
    
    def run(self):
        secret = 'Jefe'
        value = 'what do ya want for nothing?'
        print "Goal: "
        print hmac.new(secret, value, hashlib.sha1).hexdigest()
        return self.load(secret, value)
        
    def addSecret(self, secret):
        for x in range(0, len(secret)):
            self.Bi[x] = self.Bi[x] ^ ord(secret[x])
            self.Bo[x] = self.Bo[x] ^ ord(secret[x])

    def load(self, secret, value):
        self.reset()
        self.addSecret(secret)
        
        shaBi = self.Sha1.hashString(self.generateString(self.Bi) + value)
        shaBiDec = shaBi.decode("hex")
        
        Bo = self.generateString(self.Bo) + shaBiDec
        self.shaBo = self.Sha1.hashString(Bo)
        
        return self.shaBo
        
    def generateString(self, intList):
        out = ''
        for x in range(0, len(intList)):
            #print intList[x]
            out = out + chr(intList[x])
        
        return out

if __name__ == "__main__":
    objSha = Sha1Model()
    objHmac = HmacModel(objSha)
    secret = 'Jefe'
    value = 'what do ya want for nothing?'
    secret = 'secret'
    value = 'value'
    
    print "Goal:   " + hmac.new(secret, value, hashlib.sha1).hexdigest()
    print "Result: " + objHmac.load(secret, value)
    