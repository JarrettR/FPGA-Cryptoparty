#!/usr/bin/python
# -*- coding: utf-8 -*-
################################################################################
#                                test_gentenhex.py 
#    Tests for the master key generation module - Modify Makefile to run 
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
import logging
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.result import TestFailure
from cocotb.log import SimLog
from cocotb.wavedrom import Wavedrom
import random

import binstr

_debug = False

@cocotb.coroutine
def reset(dut):
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0

@cocotb.coroutine
def wait_process(dut):
    print "Processing"
    process = 1
    
    while process == 1:
    
        print_mk(dut) 
        yield RisingEdge(dut.clk_i)
        
        if int(str(dut.complete_o), 2) == 1:
            process = 0
            
    print "Processing done"
    
def print_mk(dut):
    print chr(int(str(dut.test_mk_val0), 2)) + \
        chr(int(str(dut.test_mk_val1), 2)) + \
        chr(int(str(dut.test_mk_val2), 2)) + \
        chr(int(str(dut.test_mk_val3), 2)) + \
        chr(int(str(dut.test_mk_val4), 2)) + \
        chr(int(str(dut.test_mk_val5), 2)) + \
        chr(int(str(dut.test_mk_val6), 2)) + \
        chr(int(str(dut.test_mk_val7), 2))
    print dut.complete_o #dut.carry#, dut.continue
        
@cocotb.test()
def A_load_config_test(dut):
    """
    Test correct start/end parameters get loaded into DUT
    """
    log = SimLog("cocotb.%s" % dut._name)
    #log.setLevel(logging.DEBUG)
    cocotb.fork(Clock(dut.clk_i, 1000).start())
    
    mk_start = '1222222222'
    mk_end = '12222222f2'
    
    dut.test_start_val0 <= ord(mk_start[0])
    dut.test_start_val1 <= ord(mk_start[1])
    dut.test_start_val2 <= ord(mk_start[2])
    dut.test_start_val3 <= ord(mk_start[3])
    dut.test_start_val4 <= ord(mk_start[4])
    dut.test_start_val5 <= ord(mk_start[5])
    dut.test_start_val6 <= ord(mk_start[6])
    dut.test_start_val7 <= ord(mk_start[7])
    
    dut.test_end_val0 <= ord(mk_end[0])
    dut.test_end_val1 <= ord(mk_end[1])
    dut.test_end_val2 <= ord(mk_end[2])
    dut.test_end_val3 <= ord(mk_end[3])
    dut.test_end_val4 <= ord(mk_end[4])
    dut.test_end_val5 <= ord(mk_end[5])
    dut.test_end_val6 <= ord(mk_end[6])
    dut.test_end_val7 <= ord(mk_end[7])
    
    dut.init_load_i <= 1
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 1
    
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0
    yield RisingEdge(dut.clk_i)
    dut.init_load_i <= 0
    
    yield wait_process(dut)
    #print_mk(dut) 
    
    # if ord(ssid[0]) != int(str(ssid_test1), 2):
        # raise TestFailure("ssid_test1 differs from mock")
    # elif ord(ssid[3]) != int(str(ssid_test2), 2):
        # raise TestFailure("ssid_test2 differs from mock")
    # elif ord(ssid[6]) != int(str(ssid_test3), 2):
        # raise TestFailure("ssid_test3 differs from mock")
    # elif ord(ssid[6]) == int(str(ssid_test1), 2):    #Todo: remove false positive if 1st and 7th chars equal
        # raise TestFailure("SSID comparisons failing.")
    # else:
        # log.info("SSID Ok!")

def lookup_state(state):
    stateList = {
        0: "STATE_IDLE",
        1: "STATE_PACKET",
        2: "STATE_START",
        3: "STATE_END",
        4: "STATE_PROCESS",
        5: "STATE_OUT",
    }
    return stateList.get(state, "Unknown")

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