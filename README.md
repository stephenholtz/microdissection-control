microdissection-control
===================================================
Control functions for microdissection, to expand shortly.

## P.U.M.P.
*P*recision *U*V *M*icrodissection *P*latform

## Basic Useage
- Open EX5 Laser Control Software and Matlab. Use the `run_pump.m` script to initialize the interface.
- A series of prompts will make sure the following steps happen:
  - Ensure EX5 software interlock, high-speed shutter and gas purge lines are enabled and working correctly
  - Set desired energy level in EX5 software while in the "Const. E" (constant energy) mode.
  - Align sample with higher magn objective, then switch to CaF2 lens (dissection objective)
  - Select "Start Laser With EXT Trigger" and run the control function in Matlab
- If using for physiology, add saline to the sample to prevent dessication immediately after dissection.

## Main Components
- GAM EX5 Excimer Laser with Aperture to promote TEM00 mode ouput
- PtGrey (FLIR) NIR Camera for viewing and placing dissection
- Uniblitz laser line shutter for gating laser output once stabilized
- Soleniods and gas distributor for purging laser line with high purity dry Nitrogen
- Sutter MP-225 for manually moving the prep (can potentially be automated)
- (currently unused) Thorlabs photodiode for calibration

## Light path components
 - ArF Excimer Laser
 - Post-Laser Cleanup Iris
 - Nitrogen Purge Lines and Housing
 - Purge Line Solenoids and Drivers
 - High Speed Laser Shutter
 - Steering Periscope
 - Pre-Telescope Cleanup Iris
 - Beam Expander 3.33x
 - Projection Aperture (swappable)
 - UV-Visible Dichroic
 - UV and Visible Objectives
 - Sample Purge Line
 - Sample Illumination Optics
 - Visible Light Tube Lens
 - Visible Light Image Mirrors
 - NIR-CMOS Camera

## Ancillary Rig Components
 - Gas Safety Cabinet
 - Motorized Micromanipulator
 - Energy/Power Meter
 - National Instruments DAQ
