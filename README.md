FPGA-Cryptoparty
================
Old bitcoin mining rigs are useful again!

This is a low-level investigation on the WPA2 encryption scheme.
By implementing some clever routing schemes, modern FPGAs should be a strong contender against general purpose CUDA GPUs for hashing performance.

Some discussion, and a few approaches that have been experimented with are [here](http://jrainimo.com/build/?cat=6).

While this is written in VHDL and targeting Xilinx FPGAs, this project is being developed on the [GHDL](https://github.com/tgingold/ghdl) simulator with the [cocotb](https://github.com/potentialventures/cocotb) testing framework.
This has allowed me to use a lightweight Makefile-and-Python-based simulation and testing framework, accessible from the cloud. 

## General overview 

The target of this project is the ZTEX 1.15y bitcoin miner. Due to rising difficulty of the hashing algorithm, it is no longer financially viable to mine bitcoins using FPGAs. That means that there are a ton of these flooding the market, at below the cost of components.

This is ideal for building low-cost WPA2 hashing clusters, and pretty reliably proves that if the WPA2 Wifi authentication algorithm isn't broken yet, it is severely compromised.

The host software, written in Java, microcontroller (Cypress FX2) firmware, written in C, and top-level ZTEX wrapper, written in VHDL, are all specific to this device. Everything below this, which is the real meat, is device-agnostic, and really, really fast.

For convenience of debugging, I also wrote an implementation of the full algorithm in Python. It runs at about 0.25 hashes per second, and uses no crypto libraries (other than for verification that my own functions are correct).

## To develop 

For now, see [Issue #1](https://github.com/JarrettR/FPGA-Cryptoparty/issues/1) for a minimally compiling system.

If, like me, you're running this from a server with NGINX running, waveforms are automatically generated on unit testing, and can be viewed online.
Modify the file at `tools/www/wavedrom-nginx.conf` with appropriate paths, and then add the line `include <path to tools/www/wavedrom-nginx.conf>` (also with appropriate path) in `/etc/nginx/sites-enabled/default` (or your NGINX config, if different).

Leaving the webpage open will cause the waveforms to update a few seconds after you make your project.

See sample waveform outputs in the `docs` folder.