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
    """Test for basic Wishbone operation"""
    cocotb.fork(Clock(dut.clk_i, 1000).start())
    
    mockObject = Sha1Model()

    for i in range(18):
        dut.log.info(str(i))
        mockOut = ''
        for x in mockObject.W:
            mockOut += "{:x}".format(int(x))
        dut.log.info(mockOut)
        dut.log.info(str(dut.dat_o))
        input = random.randint(0, 0xffffffff)
        mockObject.addWord(input)
        dut.dat_i <= input
        yield RisingEdge(dut.clk_i)
    
    mockOut = ''.join(str(x) for x in mockObject.W)
    
    
    dut.log.info("{:x}".format(int(mockOut)))
    dut.log.info("{:x}".format(int(str(dut.dat_o), 2)))
    
    if int(dut.dat_o) != int(mockOut):
        raise TestFailure(
            "Adder result is incorrect: {0} != {1}".format(str(int(dut.dat_o)), mockOut))
    else:  # these last two lines are not strictly necessary
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
        
        
 