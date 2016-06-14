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
vidFormat = 'F7_Mono16_2048x2048_Mode0';
I = imaq.VideoDevice(adaptorName,deviceID,vidFormat);
%disp(I.DeviceProperties)
I.release()
I.DeviceProperties.TriggerDelayMode = 'Off';
fprintf('\t\t\t[Done]\n');
