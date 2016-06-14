% initPtGreyGigE.m
% Requires image acquisition adapter support package from mathworks
% e.g. imaq.VideoDevice; should return current camera
% imaqtool helps get a better idea of the options

fprintf('Initializing PtGrey camera ');
delete(imaqfind);
imaqreset;

% Device Properties from imaqtool
adaptorName = 'pointgrey';
deviceID = 1;
vidFormat = 'F7_Mono8_1280x960_Mode0';
I = imaq.VideoDevice(adaptorName,deviceID,vidFormat);
%disp(I.DeviceProperties)
fprintf('\t\t\t[Done]\n');

%% Normal Settings 
I.release();
I.DeviceProperties.FrameRateMode = 'Manual';
I.DeviceProperties.FrameRate = 30;
I.DeviceProperties.SharpnessMode = 'Manual';
I.DeviceProperties.Sharpness = 0;
I;

%%
