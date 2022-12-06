microdissection-control
===================================================
Simple scripts and high-level documentation on the **P.U.M.P.** (or **P**recision **U**V **M**icrodissection **P**latform), used for dissections.

# Basic Useage
- Open EX5 Laser Control Software and Matlab. Use the `run_pump.m` script to initialize the interface.
- A series of prompts will make sure the following steps happen:
  - Ensure EX5 software interlock, high-speed shutter and gas purge lines are enabled and working correctly
  - Set desired energy level in EX5 software while in the "Const. E" (constant energy) mode.
  - Align sample with higher magn objective, then switch to CaF2 lens (dissection objective)
  - Select "Start Laser With EXT Trigger" and run the control function in Matlab
- If using for physiology, add saline to the sample to prevent dessication immediately after dissection.

# Alignment
This is a brief outline of what a "full" alignment of the system involves.

1. **Laser Cavity and Laser**
    - See the GAM documentation for more complete notes
    - Remove both front and rear panels to access both mirrors (front mirror is where the beam exits, rear mirror acts as a pick off for closed loop energy mode)
    - Use both a white card and the energy meter to get a uniform circle and high energy
2. **UV Mirrors, Telescope, and Dichroic**
    - Paraxial along the full path up to telescope.
    - Check telescope for divergence by extending path out (e.g. by removing both aperture and dichroic, then looking for minimal expansion).
    - Paraxial from telescope and out of objective (without objective in place, then with it in place for centering).
3. **UV Projection System**
    - Use a large aperture and find a demagnification that results in a crisp shape.
    - This is largely empirical, but movements are limited practically so it is a small search space.
4. **Visible Collection Optics**
    - Make sure at the WD of the UV path the image in the visible channel is clear, adjust distance from tube lens if needed.
5. **Co-aligning UV and Visible Paths**
    - Burn a test mark and make sure it is in the center of the camera FOV.

# Rig Components
## Main
- GAM EX5 Excimer Laser with Aperture to promote TEM00 mode ouput
- PtGrey (FLIR) NIR Camera for viewing and placing dissection
- Uniblitz laser line shutter for gating laser output once stabilized
- Soleniods and gas distributor for purging laser line with high purity dry Nitrogen
- Sutter MP-225 for manually moving the prep (can potentially be automated)
- (currently unused) Thorlabs photodiode for calibration

## Light path
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

## Ancillary
 - Gas Safety Cabinet
 - Motorized Micromanipulator
 - Energy/Power Meter
 - National Instruments DAQ
