%% Add up known distances from measurments / spec sheets

% obj: LMU-10X-193
f_obj = 20;
length_obj = 31.2;
wd_obj = 15;

% from aperture (the "object") to exit of 2" cube
d1 = 113; % on a +/-20mm manipulator

% from exit of 2" cube to front of UV projection objective 
d2 = 58; % fixed

% Idealized dist bn center of the obj lens and rear end of obj
lens_dist_from_obj_rear = length_obj + wd_obj - f_obj; % 26.2mm
lens_dist_from_obj_front = f_obj - wd_obj; % 26.2mm

% total dist bn aperture and obj idealized lens
aperture_to_lens_dist = d1+d2-lens_dist_from_obj_rear; % 144.80

%% Calculate required distances

% Can fill ~5mm aperture, but "safely" only 2.5mm -->
% ~5-8x demag is good for the small dissections
demag = 12;

% thin lens eq. distance to projected image (from lens)
dist_img = f_obj * (demag+1) / demag;
disp(['demag = ' num2str(demag) ' -> dist_img = ' num2str(dist_img)])

% thin lens eq. distance to aperture (from lens)
dist_apt = dist_img * demag;
disp(['demag = ' num2str(demag) ' -> dist_apt = ' num2str(dist_apt)])

dist_img_from_obj_front = dist_img - lens_dist_from_obj_front;
disp(['demag = ' num2str(demag) ' -> dist_img_from_obj_front = ' num2str(dist_img_from_obj_front)])