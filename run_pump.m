%% Initalize system
clear all force; close all force; clc; %#ok<*CLALL>
set(0,'DefaultFigureWindowStyle','normal');
% Assert checkpoints for manual configuration steps
pump.initWarningDlgs(); 

% Initalize daq interface
L = pump.LaserIO();

% Open up ROI/Camera GUI
use_roi_gui = 1;
if use_roi_gui; R = pump.roiGUI(); end %#ok<*UNRCH>

%% configure/run dissection
savepath = 'Z:\Wilson Lab\holtz\pump_prep_images\';
currtime = datestr(now,30);

% Set number of shuttered pulses (stabilization time)
L.nShutteredPulses = 250;
% Set number of delivered (unshuttered) pulses
L.nDeliveredPulses = 190;
% Set the frequency of pulses
L.pulseFrequency = 100; % 60-100Hz is stable for closed loop / ext trig
% Set duration of the N2 purge prior to lasing (5 seconds is OK)
L.purgeDurSeconds = 5;

% Prompt manual entry into laser control software
if use_roi_gui; R.saveImg(fullfile(savepath,[currtime '_pre_dissection'])); end
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + L.nShutteredPulses);
if config_complete
    [dataIn,dataOut] = L.runDissection();
end

%% Save notes / data on server for documentation
save(fullfile(savepath, ['data_' currtime '.mat']),'dataIn','-v7')
copyfile('C:\Users\user\Desktop\temp_notes.txt',fullfile(savepath,['notes_' currtime '.txt']));