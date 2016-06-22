# Simple tests for an adder module
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge
from cocotb.result import TestFailure
import random
from wishbone_monitor import WishboneSlave
from wishbone_driver import Wishbone, WishboneMaster

@cocotb.test()
def wavedrom_test(dut):
    """
    I don't know what I'm doing!
    """
    cocotb.fork(clock_gen(dut.clk_i))
    yield RisingEdge(dut.clk_i)
    tb = ShaTB(dut)
    yield tb.reset()
    

 
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



def adder_model(a, b):
    """ model of adder """
    return a + b
        
@cocotb.coroutine
def clock_gen(signal):
    while True:
        signal <= 0
        yield Timer(5000)
        signal <= 1
        yield Timer(5000)
        
@cocotb.test()
def simple_wb_test(dut):
    """Test for basic Wishbone operation"""
    cocotb.fork(Clock(dut.clk_i, 1000).start())


    for i in range(10):
        input = random.randint(0, 255)
        dut.dat_i <= input
        yield RisingEdge(dut.clk_i)
        dut.log.info(str(dut.dat_o))
        
        
@cocotb.test()
def stream_passthrough(dut):
    """Test for basic input and output stream"""
    yield Timer(2)
    input = random.randint(0, 255)

    dut.dat_i <= input
    
    dut.a = 5
    dut.b = 6
    
    yield Timer(2)
    #yield RisingEdge(dut.clk_i)

    if int(dut.dat_o) != input:
        raise TestFailure(
            "Adder result is incorrect: %s != %s" % str(dut.dat_o), str(input))
    else:  # these last two lines are not strictly necessary
        dut.log.info("Ok!")
        
        
@cocotb.test()
def adder_basic_test(dut):
    """Test for 5 + 10"""
    yield Timer(2)
    A = 5
    B = 10

    dut.a = A
    dut.b = B

    yield Timer(2)

    if int(dut.x) != adder_model(A, B):
        raise TestFailure(
            "Adder result is incorrect: %s != 15" % str(dut.x))
    else:  # these last two lines are not strictly necessary
        dut.log.info("Ok!")


@cocotb.test()
def adder_randomised_test(dut):
    """Test for adding 2 random numbers multiple times"""
    yield Timer(2)

    for i in range(10):
        A = random.randint(0, 15)
        B = random.randint(0, 15)

        dut.a = A
        dut.b = B

        yield Timer(2)

        if int(dut.x) != adder_model(A, B):
            raise TestFailure(
                "Randomised test failed with: %s + %s = %s" %
                (int(dut.a), int(dut.b), int(dut.x)))
        else:  # these last two lines are not strictly necessary
            dut.log.info("Ok!")