%% Initalize system
addpath(genpath('C:\code\microdissection-control'));
clear all force; close all force; clc; %#ok<*CLALL>
set(0,'DefaultFigureWindowStyle','docked');

% Second camera for looking for splatter on the lens
imaqtool();

% Assert checkpoints for manual configuration steps
if ~pump.initWarningDlgs(); return; end

% Initalize daq interface
L = pump.LaserIO();

% Open up ROI/Camera GUI
R = pump.roiGUI();
savepath = 'D:\pump_prep_data_images\';

%% Snap a picture
R.saveImg(fullfile(savepath,[datestr(now,30) '_image']));

%% configure/run dissection

% Set number of delivered (unshuttered) pulses
L.nDeliveredPulses = 650;
%L.nDeliveredPulses = 115;

% VT008470 - 126? for central and relatively dorsal cluster
% VT050226 - 104 (in young, for dorsal), 118-120 for dorso-lateral group
% VT002210 - 130
% VT001599 - 100 dorsal, 145 mid
% VT060195 - 136 for the very medial group (nonstandard angle of approach required though)

% -----------------------------
% Usually unchanged below here:
% -----------------------------
% Set here to prompt manual setting/record keeping
L.energyLevelMiliJoules = 9.2;
% Set number of shuttered pulses (stabilization time)
L.nShutteredPulses = 200;
% Set the frequency of pulses
L.pulseFrequency = 200; % >60Hz is stable for closed loop / ext trig
% Set duration of the N2 purge prior to lasing (5 seconds is OK)
L.purgeDurSeconds = 4;

% Prompt manual entry into laser control software
dissection_time = datestr(now,30);
R.saveImg(fullfile(savepath,[dissection_time '_pre_dissection']));
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + L.nShutteredPulses,L.energyLevelMiliJoules);
if config_complete
    [dataIn,dataOut] = L.runDissection();
end

%% Save notes / data on server for documentation
save(fullfile(savepath, ['data_' dissection_time '.mat']),'dataIn','-v7')
copyfile(fullfile(pump.filepath,'temp_notes.txt'),fullfile(savepath,['dissection_notes_' dissection_time '.txt']));