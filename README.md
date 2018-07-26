microdissection-control
===================================================
Control functions for microdissection, to expand shortly.

## P.U.M.P.
*P*recision *U*V *M*icrodissection *P*latform

## Components
- GAM EX5 Excimer Laser with Aperture to promote TEM00 mode ouput
- PtGrey (FLIR) NIR Camera for viewing and placing dissection
- Uniblitz laser line shutter for gating laser output once stabilized
- Soleniods and gas distributor for purging laser line with high purity dry Nitrogen
- Sutter MP-225 for manually moving the prep (can potentially be automated)
- (currently unused) Thorlabs photodiode for calibration 
- (currently unused) Oxygen sensor for monitoring purge line

## Basic Useage
- TODO: update this
- Open EX5 Laser Control Software and Matlab
- Ensure EX5 software interlock, high-speed shutter and gas purge lines are enabled and working correctly
- Set desired energy level in EX5 software while in the "Const. E" (constant energy) mode.
- Align sample with higher magn objective, then switch to CaF2 lens (dissection objective)
- Select "Start Laser With EXT Trigger" and run the control function in Matlab
