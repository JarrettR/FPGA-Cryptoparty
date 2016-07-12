WaveDrom Display
================
This is a handy way to display the testing output waveforms (via WaveDrom) on a website.


== Why?!?! ==

I do all my testing in the cloud. This dumps test results on a website automagically.

== Todo ==

Currently the JSON-formatted waveform gets output in the `/FPGA/tests/sim_build/` folder. That file must be made available to this page, either via a step in the makefile copying it here, or some clever NGINX linking. Likewise, the `/tools/wavedrom/wavedrom.min.js` and `/tools/wavedrom/skins/default.js` need to be accessible.

