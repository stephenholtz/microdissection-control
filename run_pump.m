%% Initalize system
addpath(genpath('C:\code\microdissection-control'));
clear all force; close all force; clc; %#ok<*CLALL>

if ~pump.initWarningDlgs(); return; end
L = pump.LaserIO('Dev3','B:\pump_prep_data_images\');

% Constant dissection settings
L.energyLevelMiliJoules = 7.5;  % manually entered in ATL software, this sets prompt text
L.nShutteredPulses = 50;        % number of shuttered pulses, a for energy stabilization
L.pulseFrequency = 100;         % laser pulse freq, >60Hz is stable for closed loop mode
L.purgeDurSeconds = 3;          % duration of N2 purge prior to lasing (3+ seconds is OK)

%% Run a test cut on thorax for centering cut
L.nDeliveredPulses = 100;       % number of dissection pulses (w/ beam shutter open)
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + L.nShutteredPulses,L.energyLevelMiliJoules);
if config_complete; [dataInTestCut,dataOutTestCut] = L.runDissection(); end

%% Cut into head capsule to help remove muscles + improve superfusion
L.nDeliveredPulses = 400;       % number of dissection pulses (w/ beam shutter open)
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + L.nShutteredPulses,L.energyLevelMiliJoules);
if config_complete; [dataInHeadCut,dataOutHeadCut] = L.runDissection(); end

%% Antenna a2 dissection. See notes for numbers, should be at least 75
L.nDeliveredPulses = 106; % (75a2)/85/93/117      % number of dissection pulses (w/ beam shutter open)
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + L.nShutteredPulses,L.energyLevelMiliJoules);
if config_complete; [dataInA2Cut,dataOutA2Cut] = L.runDissection(); end

%% Antenna a3 dissection. See notes for numbers, should be at least 30
L.nDeliveredPulses = 50; % 
config_complete = pump.initGAMDlgs(L.nDeliveredPulses + L.nShutteredPulses,L.energyLevelMiliJoules);
if config_complete; [dataInA2Cut,dataOutA2Cut] = L.runDissection(); end

%% Save notes / data on server for documentation
save(fullfile(L.savepath, ['data_' dissection_time '.mat']), ...
    "dataInTestCut","dataInA2Cut","dataInHeadCut",'-v7')