%% solenoid-only commands
close all force
daq.reset();

S = daq.createSession('ni');
S.Rate = 100E3;

dio(1) = S.addDigitalChannel('Dev1','port0/line1','OutputOnly');
dio(1).Name = 'Laser Line N2 Purge Solenoid Gate';
dio(2) = S.addDigitalChannel('Dev1','port0/line3','OutputOnly');
dio(2).Name = 'Prep Area N2 Purge Solenoid Gate';

%% Both Off
S.outputSingleScan([ 0 0 ]);

%% Line Purge On
S.outputSingleScan([ 1 0 ]);

%% Both On
S.outputSingleScan([ 1 1 ]);
