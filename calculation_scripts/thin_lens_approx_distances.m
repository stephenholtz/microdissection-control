%% Known Measurements:

% From Thorlabs tech support re: "wrong" working distance:
% """
% The LMU-10X objective is a monochromatic objective and shows a 
% significant chromatic focal shift especially for DUV wavelengths. For 
% 193nm the focal length is 18.2mm and the working distance is reduced 
% nominal to 13.17mm. So the measured 12.9mm working distance is within 
% the tolerance range.
% """ 
%
% Assuming I slightly underestimated the WD assume @ 193nm
%   WD = 12.9 +/-0.2mm -(+100um)-> 13 +/- 0.1mm
%   f = 17.93 +/-0.2mm -(+100um)-> 18.03 +/- 0.1mm

% objective: LMU-10X-193
f_obj = 18.03;
length_obj = 32.6;
wd_obj = 13;

% table optics distances

% flexible distance from aperture to front face of 2" cube assembly
% aperture sits 20.5mm from font face of aperture holder in current config
% practical minimum is ~20mm + aperture holder dist (20.5mm)
d0 = 25 + 20.5; 

% from entry face of 2" cube assembly to front face of UV obj
d1 = 101.5+71.5; % error likely as bad as +/-0.25mm!!!

% Idealized dist bn center of the obj lens and rear end of obj
%lens_dist_from_obj_rear = length_obj + wd_obj - f_obj; % 
lens_dist_from_obj_front = f_obj - wd_obj; % 

% total dist bn aperture and obj idealized lens
aperture_to_lens_dist = d0+d1-lens_dist_from_obj_front; % d0 flexible

%% Calculate required distances

% Can fill ~5000um aperture with relatively uniform beam
% empirically ~8x demag is good for the small dissections
% set to 11x now due to space constraints and exp urgency
demag = 11;

disp(['Distances for components with demag = ' num2str(demag)])

% thin lens eq. distance to projected image (from lens)
dist_img = f_obj * (demag+1) / demag;
disp(['demag = ' num2str(demag) ' -> dist_img = ' num2str(dist_img)])

% thin lens eq. distance to aperture (from lens)
dist_apt = dist_img * demag;
disp(['demag = ' num2str(demag) ' -> dist_apt = ' num2str(dist_apt)])

dist_img_from_obj_front = dist_img - lens_dist_from_obj_front;
disp(['demag = ' num2str(demag) ' -> dist_img_from_obj_front = ' num2str(dist_img_from_obj_front)])