# TG68_BasicTest
This is a test of the most basic implementation of a TG68 soft-core processor.

This project is a reimplementation of the "Experimenting with TG68: Part 1 - A Counter" exercise over at the Retro Ramblings (http://retroramblings.net/) website.  I recreated that project as a learning experience with the TG68 68K compatible soft-core processor.

Description:
This project takes a TG68 core and creates a simple up counter.  It uses "case" statment to simulate ROM and a destination register for the counter output.  The counter register is then outputted to the four 7-segment displays on the development board.  When working correctly, the displays should start counting upward from 0000 at a rate slightly quicker than one update per second.

KEY0 on the development board can be used to reset the TG68 core.  (Keep in mind that is only resets the TG68 core and does not affect the counter register, so pushing it will not reset the counter.)

I have also added a clock-divider to slow the CPU clock down to a useful speed so that the counter doesn't update too fast.

My Tools:
  * Intel Quartus Prime Lite 18.0
  * Terasic Cyclone V GX Starter Kit Development Board
  * Altera USB-Blaster II Download Cable
  * TG68 Source Code by Tobias Gubener (found at OpenCores.org)
	
As an added note...
One problem I see with most coding examples found on the net, they are very poorly commented. I will try add useful comments to all of my code so that everyone can understand what is supposed to be going on.  This first project probably has a overabundance of comments but I felt it was necessary as it is the first piece of code I uploaded.  Future project should be well commented but will assume the user has a working knowledge of the description language.

Also note that I am relatively new at FPGA development and the VHDL language.  Expect some errors, things that don't make sense and general goofs.
