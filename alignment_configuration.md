Laser alignment and general configuration notes
===============================================

## Current Stats
- *Max energy* (post-refill 100Hz@15kV): 1.95mJ 
    - [GAM Laser factory measurement: 4.0mJ]
- *Max power* (post-refill 250Hz@15kV): 0.36W
    - [GAM Laser factory measurement: 3.0W] 
- Max energy at sample without aperture: 

## Full Alignment
A "full" alignment of the system involves:
1. Aligning the laser cavity optics / position on table.
2. Aligning mirrors, telescope, and dichroic.
3. Setting the UV objective and aperture.
4. Setting the position of visible collection optics (this shouldn't need to change).
5. Co-aligning UV and visible light paths.

**1. Laser Cavity and Laser**
    - See the GAM documentation for more complete notes
    - Remove both front and rear panels to access both mirrors (front mirror is where the beam exits, rear mirror acts as a pick off for closed loop energy mode)
    - Use both a white card and the energy meter to get a uniform circle and high energy
**2. UV Mirrors, Telescope, and Dichroic**
    - Paraxial along the full path up to telescope.
    - Check telescope for divergence by extending path out (e.g. by removing both aperture and dichroic, then looking for minimal expansion).
    - Paraxial from telescope and out of objective (without objective in place, then with it in place for centering).
**3. UV Projection System**
    - Use a large aperture and find a demagnification that results in a crisp shape.
    - This is largely empirical, but movements are limited practically so it is a small search space.
**4: Visible Collection Optics**
    - Make sure at the WD of the UV path the image in the visible channel is clear, adjust distance from tube lens if needed.
**5: Co-aligning UV and Visible Paths**
    - Burn a test mark and make sure it is in the center of the camera FOV.


