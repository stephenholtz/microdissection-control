%% Set up workspace
clear all force; %#ok<*CLALL>
close all force; clc;
% Assert checkpoints for manual configuration steps
pump.initWarningDlgs()

%% Initalize national instruments daq interface
L = pump.LaserIO();

%% Open up ROI/Camera GUI
use_roi_gui = 0;
if use_roi_gui
    R = pump.roiGUI();
end
%% configure/run dissection
savepath = 'Z:\Wilson Lab\holtz\pump_prep_images\';
currtime = datestr(now,30);

% Set number of shuttered pulses (stabilization time)
L.nShutteredPulses = 250;
% Set number of delivered (unshuttered) pulses
L.nDeliveredPulses = 215;
% Set the frequency of pulses
L.pulseFrequency = 100; % 60-100Hz is stable for closed loop / ext trig
% Set duration of the N2 purge prior to lasing (10 seconds is OK)
L.purgeDurSeconds = 5;

% Prompt manual entry into laser control software
if use_roi_gui
    savename = [currtime '_pre_dissection'];
    R.saveImg(fullfile(savepath,savename))
end
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + ...
                                    L.nShutteredPulses);
if config_complete
    % daq data in/out for debugging
    [dataIn,dataOut] = L.runDissection();
end

%% Save notes / data on server for documentation
save(fullfile(savepath, ['data_' currtime '.mat'],'dataIn','-v7')
copyfile('C:\Users\user\Desktop\temp_notes.txt',fullfile(savepath,['notes_' currtime '.txt']));