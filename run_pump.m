%% Initalize system
addpath(genpath('C:\code\microdissection-control'));
clear all force; close all force; clc; %#ok<*CLALL>

if ~pump.initWarningDlgs(); return; end
L = pump.LaserIO('Dev3','B:\pump_prep_data_images\');

% Open up ROI/Camera GUI (now not working)
% R.saveImg(fullfile(savepath,[datestr(now,30) '_image']));

%% configure/run dissection
L.nDeliveredPulses = 110;       % number of dissection pulses (w/ beam shutter open)

% Usually unchanged:
L.energyLevelMiliJoules = 8;    % manually entered in GAM software, this sets prompt text
L.nShutteredPulses = 200;       % number of shuttered pulses, a for energy stabilization
L.pulseFrequency = 100;         % laser pulse freq, >60Hz is stable for closed loop mode
L.purgeDurSeconds = 3;          % duration of N2 purge prior to lasing (3+ seconds is OK)

% Prompt manual entry into laser control software
dissection_time = datestr(now,30);
% R.saveImg(fullfile(L.savepath,[dissection_time '_pre_dissection']));
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + L.nShutteredPulses,L.energyLevelMiliJoules);
if config_complete
    [dataIn,dataOut] = L.runDissection();
end

%% Save notes / data on server for documentation
save(fullfile(L.savepath, ['data_' dissection_time '.mat']),'dataIn','-v7')