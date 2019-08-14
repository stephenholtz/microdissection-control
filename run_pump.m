%% Initalize system
addpath(genpath('C:\code\microdissection-control'));
clear all force; close all force; clc; %#ok<*CLALL>
set(0,'DefaultFigureWindowStyle','docked');
% Assert checkpoints for manual configuration steps
pump.initWarningDlgs(); 

% Initalize daq interface
L = pump.LaserIO();

% Open up ROI/Camera GUI
R = pump.roiGUI();
savepath = 'Z:\holtz\pump_prep_images\';

%% Snap a picture
R.saveImg(fullfile(savepath,[datestr(now,30) '_image']));

%% configure/run dissection
dissection_time = datestr(now,30);

% Set number of shuttered pulses (stabilization time)
L.nShutteredPulses = 350;
% Set number of delivered (unshuttered) pulses
L.nDeliveredPulses = 160;
% Set the frequency of pulses
L.pulseFrequency = 200; % 60-100Hz is stable for closed loop / ext trig
% Set duration of the N2 purge prior to lasing (5 seconds is OK)
L.purgeDurSeconds = 3;

% Prompt manual entry into laser control software
R.saveImg(fullfile(savepath,[dissection_time '_pre_dissection']));
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + L.nShutteredPulses);
if config_complete
    [dataIn,dataOut] = L.runDissection();
end

%% Save notes / data on server for documentation
save(fullfile(savepath, ['data_' dissection_time '.mat']),'dataIn','-v7')
copyfile(fullfile(pump.filepath,'temp_notes.txt'),fullfile(savepath,['dissection_notes_' dissection_time '.txt']));