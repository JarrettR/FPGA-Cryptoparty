#!/usr/bin/python
# -*- coding: utf-8 -*-
################################################################################
#                                test_wpa2.py 
#    Top level regresssion tests for WPA2/PBKDF2 - Modify Makefile to run 
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

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.result import TestFailure
from cocotb.log import SimLog
from cocotb.wavedrom import Wavedrom
import random
from shutil import copyfile
from python_sha1 import Sha1Model, Sha1Driver
from python_hmac import HmacModel, HmacDriver
from python_pbkdf2 import Pbkdf2Model, Pbkdf2Driver

_debug = False

@cocotb.coroutine
def load_random_data(dut, log, mockObject, bytes):
    secret = ''
    value = ''
    if dut != None:
        dut.load_secret_i <= 1
    
    for i in range(bytes):
        inputSecret = random.randint(ord('A'), ord('z'))
        inputValue = random.randint(ord('A'), ord('z'))
        secret = secret + chr(inputSecret)
        value = value + chr(inputValue)
        if _debug == True:
            log.info(str(i) + " - {} - ".format(int(str(dut.pbuffer1.i), 2)) + " {}".format(convert_hex(dut.pbuffer1.test_word_2)) + " {}".format(convert_hex(dut.pbuffer1.test_word_3)))

    if mockObject != None:
        mockObject.load(secret, value)
        
    if dut != None:
        for i in range(bytes / 4):
            dut.secret_i <= secret[(i * 4):((i * 4) + 3)]
            yield RisingEdge(dut.clk_i)
        if bytes % 4 > 0:
            dut.secret_i <= secret[-1 * (bytes % 4):]
            yield RisingEdge(dut.clk_i)
        dut.load_secret_i <= 0
        
        
        
@cocotb.coroutine
def reset(dut):
    dut.rst_i <= 1
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0
    #yield RisingEdge(dut.clk_i)
    #log.info("Reset!")

@cocotb.test()
def A_cache_data_test(dut):
    """
    Tests that initial data cache
    gets built and latched properly
    """
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockSha1 = Sha1Model()
    mockObject = HmacModel(mockSha1)
    
    yield reset(dut)
    size = random.randint(8, 64)
    print "Length: {:d}".format(size)
    yield load_random_data(dut, log, mockObject, size)

    #mockObject.displayAll()
    mockOut = "{}".format(mockObject.shaBo)

    print convert_hex(dut.test_word_1) + " " + convert_hex(dut.test_word_2) + " " + convert_hex(dut.test_word_3) + " " + convert_hex(dut.test_word_4) + " " + convert_hex(dut.test_word_5)

    if convert_hex(dut.test_word_1).zfill(8) != mockOut:
        raise TestFailure(
            "Load data is incorrect: {0} != {1}".format(convert_hex(dut.test_word_1), mockOut))
    else:
        log.info("Ok!")

        
#@cocotb.test()
def Z_wavedrom_test(dut):
    """
    Generate a JSON wavedrom diagram of a trace
    """
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 100).start())
    
    mockSha1 = Sha1Model()
    mockObject = HmacModel(mockSha1)
    shaObject = HmacDriver(dut, None, dut.clk_i)
    
    #yield load_random_data(dut, log, mockObject, 80)
    
    
    args = [
            dut.rst_i,
            dut.dat_i,
            dut.i,
            dut.i_mux
            ]

    with cocotb.wavedrom.trace(*args, clk=dut.clk_i) as waves:
    
        yield RisingEdge(dut.clk_i)
        yield reset(dut)
        yield load_random_data(dut, log, mockObject, 16)
        mockObject.processInput()
        mockObject.processBuffer()
        
        if _debug == True:
            log.info(convert_hex(dut.pbuffer1.test_word_3).zfill(8))
        yield load_random_data(dut, log, mockObject, 60)
        
        
            
        if _debug == True:
            log.info(convert_hex(dut.pbuffer1.test_word_3).zfill(8))
            
        yield load_random_data(dut, log, mockObject, 90)
        
        if _debug == True:
            log.info(convert_hex(dut.pbuffer1.test_word_3).zfill(8))
            log.info(convert_hex(dut.pbuffer1.test_word_4).zfill(8))
            
        waves.write('wavedrom.json', header = {'text':'D_wavedrom_test', 'tick':-1}, config = {'hscale':5})
        

        
def convert_hex(input):
    input = str(input)
    replaceCount = []
    while 'UUUU' in input: 
        replaceCount.append(input.find('UUUU') / 4)
        input = input.replace('UUUU', '1111', 1)
    
    try:
        output = list("{:x}".format(int(str(input), 2)))
    except:
        output = list("{}".format(str(input)))
    
    
    for x in replaceCount:
        if len(output) > x:
            output[x] = 'U'
        else:
            output.append('U')
        
    return "".join(output)