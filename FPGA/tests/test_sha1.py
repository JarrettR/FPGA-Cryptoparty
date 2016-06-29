# Simple tests for an adder module
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
from cocotb.result import TestFailure
import random
from wishbone_monitor import WishboneSlave
from wishbone_driver import Wishbone, WishboneMaster
from python_sha1 import Sha1Model

@cocotb.test()
def load_data_test(dut):
    """Test for data properly shifted in"""
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()

    for i in range(16):
        #input = 0xffffffff 
        input = random.randint(0, 0xffffffff)
        mockObject.addWord(input)
        dut.dat_i <= input
        yield RisingEdge(dut.clk_i)
        dut.log.info(str(i) + " {:08x} - ".format(input) + convert_hex(dut.dat_1_o) + " " + convert_hex(dut.dat_2_o) + " " + convert_hex(dut.dat_3_o))

    mockObject.processInput()
    mockObject.displayAll()
    mockOut = "{:08x}".format(mockObject.W[16])

    #yield RisingEdge(dut.clk_i)
    #yield RisingEdge(dut.clk_i)
    
    print convert_hex(dut.dat_1_o) + " " + convert_hex(dut.dat_2_o) + " " + convert_hex(dut.dat_3_o) + " " + convert_hex(dut.dat_4_o) + " " + convert_hex(dut.dat_5_o)

    if convert_hex(dut.dat_1_o).zfill(8) != mockOut:
        raise TestFailure(
            "Adder result is incorrect: {0} != {1}".format(convert_hex(dut.dat_1_o), mockOut))
    else:
        dut.log.info("Ok!")
        
        
#@cocotb.test()
def process_data_test(dut):
    """Test input data properly processed during first stage"""
    cocotb.fork(Clock(dut.clk_i, 10000).start())
    
    mockObject = Sha1Model()

    for i in range(80):
        #input = 0xffffffff 
        input = random.randint(0, 0xffffffff)
        mockObject.addWord(input)
        dut.dat_i <= input
        yield RisingEdge(dut.clk_i)
        dut.log.info(str(i) + " {:08x} - ".format(input) + convert_hex(dut.dat_1_o) + " " + convert_hex(dut.dat_2_o) + " " + convert_hex(dut.dat_3_o))
        
    
    
    mockObject.processInput()
    mockObject.displayAll()
    mockOut = "{:08x}".format(mockObject.W[16])

    #yield RisingEdge(dut.clk_i)
    #yield RisingEdge(dut.clk_i)
    
    print convert_hex(dut.dat_1_o) + " " + convert_hex(dut.dat_2_o) + " " + convert_hex(dut.dat_3_o) + " " + convert_hex(dut.dat_4_o) + " " + convert_hex(dut.dat_5_o)

    if convert_hex(dut.dat_1_o).zfill(8) != mockOut:
        raise TestFailure(
            "Adder result is incorrect: {0} != {1}".format(convert_hex(dut.dat_1_o), mockOut))
    else:
        dut.log.info("Ok!")
        
        
 
class ShaTB(object):

    def __init__(self, dut, debug=False):
        self.dut = dut
        self.stream_in = Wishbone(dut, "stream_in", dut.clk_i)
        self.stream_out = WishboneSlave(dut, "stream_out", dut.clk_i, config={'firstSymbolInHighOrderBits': True})

        self.csr = WishboneMaster(dut, "csr", dut.clk_i)

        # Create a scoreboard on the stream_out bus
        self.pkts_sent = 0
        self.expected_output = []
        self.scoreboard = Scoreboard(dut)
        self.scoreboard.add_interface(self.stream_out, self.expected_output)

        # Reconstruct the input transactions from the pins
        # and send them to our 'model'
        self.stream_in_recovered = WishboneSlave(dut, "stream_in", dut.clk_i, callback=self.model)

        # Set verbosity on our various interfaces
        level = logging.DEBUG if debug else logging.WARNING
        self.stream_in.log.setLevel(level)
        self.stream_in_recovered.log.setLevel(level)

    def model(self, transaction):
        """Model the DUT based on the input transaction"""
        self.expected_output.append(transaction)
        self.pkts_sent += 1

    @cocotb.coroutine
    def reset(self, duration=10000):
        self.dut.log.debug("Resetting DUT")
        self.dut.reset_n <= 0
        self.stream_in.bus.valid <= 0
        yield Timer(duration)
        yield RisingEdge(self.dut.clk_i)
        self.dut.reset_n <= 1
        self.dut.log.debug("Out of reset")



@cocotb.coroutine
def clock_gen(signal):
    while True:
        signal <= 0
        yield Timer(5000)
        signal <= 1
        yield Timer(5000)
        
        
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
        
        
 