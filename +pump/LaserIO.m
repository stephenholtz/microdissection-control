
% TODO: convert to using digital line for ATL laser command
% TODO: remove 'extra' pulse required on the GAM
% TODO: update dialog to set the Energy and "MODE to Energy stab."
% TODO: update all the dialog boxes to just say "under TRIGGER select
% External Trigger and click RUN"
% TODO: tidy all mess below

classdef LaserIO
    properties
        session
        daq_dev
        savepath
    end

    properties (Constant)
        % DAQ settings. Works for a number of systems, tested are:
        % 1) NI PCIe-6361 w/ BNC-2090A
        %   2 AO  @ 2.86 MS/s, 16 AI 16-Bit @ 2 MS/s, 24 DIO
        % 2) USB-6343
        %   2AO @ ~1 MS/s, 16 AI @ .5 MS/s, 48 DIO

        % Photodiode signal is RC filtered, so this 10kHz is fine
        rate = 10000;

        % Analog input names
        ai_0_name = 'Table Photodiode In';
        ao_0_name = 'Laser Ext. Trig. Out'

        % Digital IO names
        dio_p0_l0_name = 'Prep Area N2 Purge Solenoid Gate';% OK
        dio_p0_l1_name = 'Laser Line N2 Purge Solenoid Gate'; % OK (grounding issue)
        dio_p0_l2_name = 'Laser Table Shutter Gate'; % 

        % seconds prior to dissection to begin specimen purge
        % means the shuttered pulses must be at least this duration
        specimen_purge_time_s = 1; % a second is enough

        % time between clicking "START LASER" or "START LASER EXT. TRIG"
        % and when lasing or closed loop feed back starts, respectively
        laser_start_delay_s = 8; % previously set to 7.25
    end

    properties
        % System State
        table_shutter_open
        laser_solenoid_open
        prep_solenoid_open % requires laser_solenoid_open = true to work
        
        % Dissection settings
        nShutteredPulses % NOTE: one extra is added to initalize laser
        nDeliveredPulses
        pulseFrequency
        purgeDurSeconds
        energyLevelMiliJoules
    end

    methods
        function obj = LaserIO(daq_dev, savepath)
            obj.savepath = savepath;

            fprintf('Initializing DAQ channels for laser dissection');
            close all force; daqreset;
            obj.daq_dev = daq_dev;
            obj.session = daq('ni');
            obj.session.Rate = obj.rate;

            ch_ = obj.session.addinput(obj.daq_dev, 0, 'Voltage');
            ch_.Name = obj.ai_0_name;

            ch_ = obj.session.addoutput(obj.daq_dev,0,'Voltage');
            ch_.Name = obj.ao_0_name;

            ch_ = obj.session.addoutput(obj.daq_dev,'port0/line0','Digital');
            ch_.Name = obj.dio_p0_l0_name;

            ch_ = obj.session.addoutput(obj.daq_dev,'port0/line1','Digital');
            ch_.Name = obj.dio_p0_l1_name;

            ch_ = obj.session.addoutput(obj.daq_dev,'port0/line2','Digital');
            ch_.Name = obj.dio_p0_l2_name;

            fprintf('.. Done\n');

            % Set non-dissection statuses
            obj.table_shutter_open = false;
            obj.laser_solenoid_open = false;
            obj.prep_solenoid_open = false;

            % Make sure they are closed
            obj.closeTableShutter();
            obj.closeAllSolenoids();            

            % Initalize dissection values to throw an error
            obj.nShutteredPulses = nan;
            obj.nDeliveredPulses = nan;
            obj.pulseFrequency = nan;
            obj.purgeDurSeconds = nan;

            fprintf('Initalization Complete.\n');
        end

        function [dataIn,dataOut,obj] = runDissection(obj)
            obj.closeTableShutter();
            obj.closeAllSolenoids();
            
            % Approximate time of function call
            t_start = tic();

            fprintf('Running dissection:');

            % Construct and queue digital output data first

            % Short buffer for the beginning and end
            pre = 0*ones(1,obj.session.Rate * .05);
            post = 0*ones(1,obj.session.Rate * .05);

            % Make each 10us minimum, 5V with no negative going parts, 
            % impedance is 2kOhm using 5V analog output fixes noise issues
            %pulse = 5.1*[0*ones(1,(obj.session.Rate * 1/obj.pulseFrequency)-40) ones(1,20)  0.*ones(1,20)];

            pulse = 1*[0*ones(1,(obj.session.Rate * 1/obj.pulseFrequency)-100) ones(1,1)  0.*ones(1,99)];

            % Append and format for queue data NOTE: requires one "extra"
            pulsesDataOut = [pre repmat(pulse,1,obj.nShutteredPulses + 1 + obj.nDeliveredPulses)];

            % Open the shutter after initial stabilizing laser pulses
            nShutterClosedSamples = (obj.nShutteredPulses + 1) * length(pulse);
            shutterDataClosed = [pre 0*ones(1,nShutterClosedSamples)];
            shutterDataOut = [shutterDataClosed 1*ones(1,length(pulsesDataOut) - (length(shutterDataClosed))-1) 0];

            % Purge laser line continuously, and specimen only just before opening the shutter
            laserLineSolenoidDataOut = ones(1,length(pulsesDataOut));
            specimenSolenoidClosed = 0*ones(1,length(shutterDataClosed)-(obj.session.Rate*obj.specimen_purge_time_s));
            specimenSolenoidDataOut = [specimenSolenoidClosed ones(1,length(pulsesDataOut)-length(specimenSolenoidClosed))];

%             dataOut = [
%                 pulsesDataOut post; 
%                 specimenSolenoidDataOut post;
%                 laserLineSolenoidDataOut post; 
%                 shutterDataOut post
%             ];

            % requires a digital line to work -- 
            % also needs to take out the single 
            dataOut = [
                pulsesDataOut post; 
                pulsesDataOut post;
                laserLineSolenoidDataOut post; 
                shutterDataOut post
            ];

            obj.session.stop();
            obj.session.flush();

            % Make sure the laser has enough time to start up, delay if not
            if toc(t_start) + obj.purgeDurSeconds < obj.laser_start_delay_s
                fprintf('\n\tWaiting for laser to initalize');
                while toc(t_start) + obj.purgeDurSeconds < obj.laser_start_delay_s
                    pause(0.05);
                end
                fprintf('.. Done\n');
            else
                warning('Purge duration is too long, laser may time out!')
            end
            
            obj.openLaserLineSolenoid(true);
            fprintf('\n\tPurging Laser Line for %d seconds',obj.purgeDurSeconds);
            pause(obj.purgeDurSeconds);
            fprintf('.. Done\n');

            % new interface is a bit different for preloading...
            % https://www.mathworks.com/help/daq/daq.interfaces.dataacquisition.html
            fprintf('\n\tRunning Laser\n\t\tPulses Shuttered %d\n\t\tPulses Delivered %d\n\t\tPulse Frequency %d',...
                obj.nShutteredPulses,obj.nDeliveredPulses,obj.pulseFrequency);
            dataIn = obj.session.readwrite(dataOut');
            obj.session.stop();

            % Make sure they are set to / are closed
            obj.closeTableShutter();
            obj.closeAllSolenoids();

            fprintf('.. Done\n');

        end

        % -------------------------------------------------------------------
        % Utility functions to use for testing and for outside of dissections
        % -------------------------------------------------------------------
        function obj = openTableShutter(obj,verbose)
            % Open (and leave open)
            if exist('verbose','var') && verbose
                fprintf('Opening table shutter');
            end
            % Assert previous state
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])

            % Set new state
            obj.table_shutter_open = true;
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])
            if exist('verbose','var') && verbose
                fprintf('.. Done\n');
            end
        end

        function obj = closeTableShutter(obj,verbose)
            % Close (and leave closed)
            if exist('verbose','var') && verbose
                fprintf('Closing table shutter');
            end
            % Assert previous state
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])

            % Set new state
            obj.table_shutter_open = false;
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])

            if exist('verbose','var') && verbose
                fprintf('..Done\n');
            end
        end

        % Solenoid control functions (static to simplify / make less elegant)
        function obj = closeAllSolenoids(obj,verbose)
            % Both Off
            if exist('verbose','var') && verbose
                fprintf('Closing all solenoids');
            end
            % Assert previous state
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])

            % Set new state
            obj.laser_solenoid_open = false;
            obj.prep_solenoid_open = false;
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])

            if exist('verbose','var') && verbose
                fprintf('.. Done\n');
            end
        end

        function obj = openAllSolenoids(obj,verbose)
            % Both On
            if exist('verbose','var') && verbose
                fprintf('Opening laser line and dissection line purge solenoids');
            end
            % Assert previous state
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])

            % Set new state
            obj.laser_solenoid_open = true;
            obj.prep_solenoid_open = true;
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])

            if exist('verbose','var') && verbose
                fprintf('.. Done\n');
            end
        end

        function obj = openLaserLineSolenoid(obj,verbose)
            % Only Laser Line Purge On
            if exist('verbose','var') && verbose
                fprintf('Opening excimer laser line purge solenoid only');
            end
            % Assert previous state
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])

            % Set new state
            obj.laser_solenoid_open = true;
            obj.prep_solenoid_open = false;
            obj.session.write([0,...
                obj.prep_solenoid_open,...
                obj.laser_solenoid_open,...
                obj.table_shutter_open])

            if exist('verbose','var') && verbose
                fprintf('.. Done\n');
            end
        end
    end
end
