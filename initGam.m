% initGam.m
% Send commands to laser and shutter

% Make gui with aperture projection images

%% Set up daq session and channels
fprintf('\nGAM Laser Control Script')
fprintf('\n************************\n');
fprintf('Initializing DAQ channels ');

daqreset;
S = daq.createSession('ni');
S.Rate = 100E3;

% Analog Input -- currently unused
ai(1) = S.addAnalogInputChannel('Dev1',0','Voltage');
ai(1).Name = 'Laser Sync Out';

% use02sensor = 0;
% if use02sensor 
%     ai(2) = S.addAnalogInputChannel('Dev1',1,'Voltage');
%     ai(2).Name = 'Trace 02 4-20ma out w/ 250Ohm Resistor'; % 4-20 mA out w/a 250 Ohm resistor (~5V)
%     S.Rate = 125E3;
% else
%     % Set rate higher if not using the 02 sensors
%     S.Rate = 250E3;
% end

% Digital IO
dio(1) = S.addDigitalChannel('Dev1','port0/line0','OutputOnly');
dio(1).Name = 'Laser External Trigger Output';
dio(2) = S.addDigitalChannel('Dev1','port0/line1','OutputOnly');
dio(2).Name = 'Laser Line N2 Purge Solenoid Gate';
dio(3) = S.addDigitalChannel('Dev1','port0/line2','OutputOnly');
dio(3).Name = 'Laser Table Shutter Gate';
dio(4) = S.addDigitalChannel('Dev1','port0/line3','OutputOnly');
dio(4).Name = 'Prep Area N2 Purge Solenoid Gate';

fprintf('\t\t\t[Done]\n');
fprintf('Set Uniblitz shutter driver to STD, N.O., and Remote\n');
fprintf('Verify laser interlock is functional.\n');
fprintf('Verify nitrogen purge valves configured correctly.\n');

%% Make/send signals
% Pulse frequency etc.,
pulseFreqHz = 20;
nPulsesShuttered = 200; % @100Hz, typically takes 150 pulses to stabilize, fewer if going <100Hz
%nPulsesOpened = 300; % muscle ablation >200
nPulsesOpened = 45; % JO dissection ~20-40

% Time before sending data to daq (to purge laser line)
durPurgeSeconds = 5;

% Short buffer in the beginning baseline period
pre = 0*ones(1,S.Rate * .05);

% Make each pulse a single sample, needs to be shorter than 50ns
pulse = [0*ones(1,(S.Rate * 1/pulseFreqHz)-2) 1 0 ];

% Append and format for queue data
dioPulses = [pre repmat(pulse,1,nPulsesShuttered+nPulsesOpened)];

%Open the shutter after a some laser pulses
nWaitSamples = nPulsesShuttered*length(pulse);
dioShutter = [pre 0*ones(1,nWaitSamples)];
dioShutter = [dioShutter 1*ones(1,length(dioPulses) - (length(dioShutter))-1) 0];
% Add slop for the laser-shutter timing
%dioShutter = circshift(dioShutter,[0.001*S.Rate,0]);

% Add beginning padding and off ending
post = 0*ones(1,S.Rate * .1);
dioPulses = [dioPulses post]';
dioShutter = [dioShutter post]';
dioSolenoid = 0.*dioPulses;

% Final command
dataOut = [dioPulses dioSolenoid dioShutter];

% Make sure we start at zero
S.outputSingleScan([ 0 0 0 ]);

% Queue output data
S.queueOutputData(dataOut);

% Warn user + start data trans
fprintf('\nPrepare for lasing\n**********************\n')
fprintf('Press "START LASER EXT. TRIG" with %d MAX PULSES @%dHz\n',nPulsesShuttered+nPulsesOpened,pulseFreqHz)
fprintf('Ensure purge line is open\n')
fprintf('Press any key to continue\n')
pause()
fprintf('\t\tRunning\n')

% Allow laser line to purge
fprintf('\t\tPurging Line\n')
pause(durPurgeSeconds)

% Requires one pulse to initiate (not well documented)
S.outputSingleScan([ 1 0 0 ]);
fprintf('\t\tLasing\n')
dataIn = S.startForeground();
S.outputSingleScan([ 0 0 0 ]);
fprintf('\t\tDone!\n')

%% Display output
close all;

figure;
plot(dataOut);
hold on
plot(dataIn);