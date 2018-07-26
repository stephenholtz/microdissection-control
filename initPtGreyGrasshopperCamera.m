function I = initPtGreyGrasshopperCamera
% initPtGreyGrasshopperCamera.m
% Requires image acquisition adapter support package from mathworks
%
% NOTE: uninstall everything that was "manually installed" including old
%       matlab installations, then install new version of matlab and FLIR/
%       pointgrey adapters via the gui only.

% >> imaq.VideoDevice 
%
%   imaq.VideoDevice with properties:
% 
%                 Device: 'Grasshopper3 GS3-U3-41C6NIR (pointgrey-1)'
%            VideoFormat: 'F7_Raw8_2048x2048_Mode0'
%                    ROI: [1 1 2048 2048]
%     HardwareTriggering: 'off'
%     ReturnedColorSpace: 'grayscale'
%       ReturnedDataType: 'single'
%       DeviceProperties: [1×1 imaq.internal.DeviceProperties]

% imaqtool helps get a better idea of the options
fprintf('Initializing PtGrey camera... ');
delete(imaqfind);
imaqreset;

% Device Properties from imaqtool
adaptorName = 'pointgrey';
deviceID = 1;
vidFormat = 'F7_Mono16_2048x2048_Mode0';

I = imaq.VideoDevice(adaptorName,deviceID,vidFormat);
I.DeviceProperties.FrameRate = 30;
I.DeviceProperties.TriggerDelayMode = 'Off';

fprintf('Done\n');
