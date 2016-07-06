import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
from cocotb.result import TestFailure
from cocotb.log import SimLog
from cocotb.wavedrom import Wavedrom
import random
from python_sha1 import Sha1Model

@cocotb.coroutine
def load_data(dut, log, mockObject, words):
    for i in range(words):
        #input = 0xffffffff 
        input = random.randint(0, 0xffffffff)
        mockObject.addWord(input)
        dut.dat_i <= input
        yield RisingEdge(dut.clk_i)
        log.info(str(i) + " {:08x} - ".format(input) + convert_hex(dut.dat_1_o) + " " + convert_hex(dut.test_sha1_process_input_o) + " " + convert_hex(dut.test_sha1_load_o))

        
@cocotb.coroutine
def reset(dut):
    dut.rst_i <= 1
    yield RisingEdge(dut.clk_i)
    dut.rst_i <= 0
    yield RisingEdge(dut.clk_i)
    #log.info("Reset!")

@cocotb.test()
def A_load_data_test(dut):
    """Test for data properly shifted in"""
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()
    
    yield reset(dut)
    yield load_data(dut, log, mockObject, 16)

    #mockObject.displayAll()
    mockOut = "{:08x}".format(mockObject.W[15])

    #print convert_hex(dut.dat_1_o) + " " + convert_hex(dut.dat_2_o) + " " + convert_hex(dut.dat_3_o) + " " + convert_hex(dut.dat_4_o) + " " + convert_hex(dut.dat_5_o)

    if convert_hex(dut.test_sha1_load_o).zfill(8) != mockOut:
        raise TestFailure(
            "Adder result is incorrect: {0} != {1}".format(convert_hex(dut.test_sha1_load_o), mockOut))
    else:
        log.info("Ok!")
        
        
@cocotb.test()
def B_reset_test(dut):
    """Testing synchronous reset"""
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()
    
    yield reset(dut)
    if convert_hex(dut.dat_1_o) != '0':
        raise TestFailure(
            "Reset failed!")
    yield load_data(dut, log, mockObject, 18)
    if convert_hex(dut.dat_1_o) == '0':
        raise TestFailure(
            "Data not populated!")
    else:
        log.info("Testing reset")
    yield reset(dut)
    if convert_hex(dut.dat_1_o) != '0':
        raise TestFailure(
            "Reset failed!")
    else:
        log.info("Reset Ok!")
    yield load_data(dut, log, mockObject, 19)

    mockOut = "{:08x}".format(mockObject.W[15])

    if convert_hex(dut.test_sha1_load_o).zfill(8) != mockOut:
        raise TestFailure(
            "Adder result is incorrect: {0} != {1}".format(convert_hex(dut.test_sha1_load_o), mockOut))
    else:
        log.info("Ok!")
        
        
@cocotb.test()
def C_process_input_test(dut):
    """Test input data properly processed during first stage"""
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()

    yield reset(dut)
    yield load_data(dut, log, mockObject, 80)

    mockObject.processInput()
    mockObject.displayAll()
    mockOut = "{:08x}".format(mockObject.W[16])

    #yield RisingEdge(dut.clk_i)
    #yield RisingEdge(dut.clk_i)
    
    print convert_hex(dut.dat_3_o) + " " + convert_hex(dut.dat_2_o) + " " + convert_hex(dut.dat_1_o) + " " + convert_hex(dut.test_sha1_process_input_o) + " " + convert_hex(dut.test_sha1_load_o)

    if convert_hex(dut.test_sha1_process_input_o).zfill(8) != mockOut:
        raise TestFailure(
            "Adder result is incorrect: {0} != {1}".format(convert_hex(dut.test_sha1_process_input_o), mockOut))
    else:
        log.info("Ok!")
        

def convert_hex(input):
    input = str(input)
    replaceCount = []
    while 'UUUU' in input: 
        replaceCount.append(input.find('UUUU') / 4)
        input = input.replace('UUUU', '1111', 1)
    
    output = list("{:x}".format(int(str(input), 2)))
    
    for x in replaceCount:
        if len(output) > x:
            output[x] = 'U'
        else:
            output.append('U')
        
    return "".join(output)
        
        
 
#Todo: Figure out
#@cocotb.test()
def wavedrom_test(dut):
    """
    Generate a JSON wavedrom diagram of a trace
    """
    log = SimLog("cocotb.%s" % dut._name)
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()
    
    yield load_data(dut, log, mockObject, 80)

    with cocotb.wavedrom.trace(dut.rst_i, [dut.test_sha1_process_input_o, dut.test_sha1_load_o], clk=dut.clk_i) as waves:
        yield RisingEdge(dut.clk_i)
        yield RisingEdge(dut.clk_i)
        yield RisingEdge(dut.clk_i)
        log.info(waves.dumpj())