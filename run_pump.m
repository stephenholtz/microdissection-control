%% Set up workspace
clear all force; %#ok<*CLALL>
close all force; clc;
% Assert checkpoints for manual configuration steps
pump.initWarningDlgs()

%% Initalize national instruments daq interface
L = pump.LaserIO();

%% Open up ROI/Camera GUI
%R = pump.roiGUI();

%% configure/run dissection

% Set number of shuttered pulses (stabilization time)
L.nShutteredPulses = 250;
% Set number of delivered (unshuttered) pulses
L.nDeliveredPulses = 160;
% Set the frequency of pulses
L.pulseFrequency = 100; % 60-100Hz is stable for closed loop / ext trig
% Set duration of the N2 purge prior to lasing (10 seconds is OK)
L.purgeDurSeconds = 5;

% Prompt manual entry into laser control software
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + L.nShutteredPulses);
if config_complete
    % daq data in/out for debugging
    [dataIn,dataOut] = L.runDissection();
end