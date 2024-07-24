classdef LaserIO
    properties
        session
        daq_dev
        savepath
    end

    properties (Constant)
        % DAQ settings

        % Photodiode signal is RC filtered, so this 10kHz is fine
        rate = 10000;

        % seconds prior to dissection to begin specimen purge
        % means the shuttered pulses must be at least this duration
        specimen_purge_time_s = 0.5; % half a second is enough
    end

    properties
        % System State
        table_shutter_open
        laser_solenoid_open
        prep_solenoid_open % requires laser_solenoid_open = true to work
        
        % Dissection settings
        nShutteredPulses
        nDeliveredPulses
        pulseFrequency
        purgeDurSeconds
        energyLevelMiliJoules
    end

    methods
        function obj = LaserIO(daq_dev, savepath)
            obj.savepath = savepath;

            fprintf('Initializing DAQ channels for laser dissection... ');
            close all force; daqreset;
            obj.daq_dev = daq_dev;
            obj.session = daq('ni');
            obj.session.Rate = obj.rate;

            % Analog Inputs
            ch_ = obj.session.addinput(obj.daq_dev, 'ai0', 'Voltage');
            ch_.Name = 'Laser Table Photodiode';

            % Digital Inputs/Outputs

            % Outputs [Laser Cmd, Shutter Cmd, Line Purge Cmd, Sample Purge Cmd]
            ch_ = obj.session.addoutput(obj.daq_dev,'port0/line0','Digital');
            ch_.Name = 'Laser Ext Trig';
            
            ch_ = obj.session.addoutput(obj.daq_dev,'port0/line6','Digital');
            ch_.Name = 'Shutter Gate';

            ch_ = obj.session.addoutput(obj.daq_dev,'port0/line8','Digital');
            ch_.Name = 'Laser Path N2 Purge Gate';

            ch_ = obj.session.addoutput(obj.daq_dev,'port0/line12','Digital');
            ch_.Name = 'Sample Area N2 Purge Gate';

            % Inputs [Laser Cmd, Laser Fbk, Shutter Fbk]
            ch_ = obj.session.addinput(obj.daq_dev,'port0/line1','Digital');
            ch_.Name = 'Laser Ext Trig Copy';

            ch_ = obj.session.addinput(obj.daq_dev,'port0/line10','Digital');
            ch_.Name = 'Laser Sync Out';

            ch_ = obj.session.addinput(obj.daq_dev,'port0/line4','Digital');
            ch_.Name = 'Shutter Sync Out';

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

            fprintf(' Complete.\n');
        end

        function [dataIn,dataOut,obj] = runDissection(obj, check_conf)
            if ~exist('check_conf','var')
                check_conf = true;
            end

            if check_conf
                obj.checkConfPreDissection()
            end

            obj.closeTableShutter();
            obj.closeAllSolenoids();

            fprintf('Running dissection:');

            % Construct and queue digital output data first

            % Short buffer for the beginning and end
            pre = 0*ones(1,obj.session.Rate * .05);
            post = 0*ones(1,obj.session.Rate * .05);

            pulse = 1*[0*ones(1,(obj.session.Rate * 1/obj.pulseFrequency)-100) ones(1,1)  0.*ones(1,99)];

            % Append and format for queue data
            pulsesDataOut = [pre repmat(pulse,1,obj.nShutteredPulses + obj.nDeliveredPulses)];

            % Open the shutter after initial stabilizing laser pulses
            nShutterClosedSamples = (obj.nShutteredPulses) * length(pulse);
            shutterDataClosed = [pre 0*ones(1,nShutterClosedSamples)];
            shutterDataOut = [shutterDataClosed 1*ones(1,length(pulsesDataOut) - length(shutterDataClosed))];

            % Purge laser line continuously, and specimen only just before opening the shutter
            laserLineSolenoidDataOut = ones(1,length(pulsesDataOut));
            specimenSolenoidClosed = 0*ones(1,length(shutterDataClosed)-(obj.session.Rate*obj.specimen_purge_time_s));
            specimenSolenoidDataOut = [specimenSolenoidClosed ones(1,length(pulsesDataOut)-length(specimenSolenoidClosed))];

            dataOut = [
                pulsesDataOut post; 
                shutterDataOut post;
                laserLineSolenoidDataOut post; 
                specimenSolenoidDataOut post
            ];

            obj.session.stop();
            obj.session.flush();

            obj.openLaserLineSolenoid(true);
            fprintf('\n\tPurging Laser Line for %d seconds',obj.purgeDurSeconds);
            pause(obj.purgeDurSeconds);
            fprintf('.. Done\n');

            fprintf('\n\tRunning Laser\n\t\tPulses Shuttered %d\n\t\tPulses Delivered %d\n\t\tPulse Frequency %d',...
                obj.nShutteredPulses,obj.nDeliveredPulses,obj.pulseFrequency);
            dataIn = obj.session.readwrite(dataOut');
            obj.session.stop();

            % Make sure they are set to / are closed
            obj.closeTableShutter();
            obj.closeAllSolenoids();

            fprintf('.. Done\n');

        end

        function complete = checkConfPreDissection(obj)
            % Manually verify and set some values in software

            complete = false;
        
            % Check the objective and move it into the light path
            r1 = questdlg(...
                {'1) Verify UV objective is clean with secondary camera,',...
                 '2) Switch UV objective into light path',...
                 '3) Clear External Interlock error'}, ...
                 'P.U.M.P. Dissection','Complete','Abort','Abort');
        
            if ~strcmp(r1,'Complete')
               warndlg('Dissection Aborted.','P.U.M.P. Dissection');
               return
            end
        
            % Set software parameters
            r2 = questdlg(...
                {'In ATLEX Laser Control Software: ',...
                 '   Set MODE to Energy stab.',...
                 '   Set STANDBY to ON',...
                 '   Set TIRGGER to External Trigger',...
                 '   Set TRIGGER to RUN',...
                ['   Set Energy[mJ] to ' num2str(obj.energyLevelMiliJoules) ''],...
                 '  '}, ...
                 'P.U.M.P. Dissection','Complete','Abort','Abort');
        
            if ~strcmp(r2,'Complete')
               warndlg('Dissection Aborted.','P.U.M.P. Dissection');
               return
            end
        
            complete = true;
            
        end

        function saveDissectionData(obj,dissection_name, data_in, data_out)
            % simple save function as starting point
            save(fullfile(obj.savepath, ['dissection_data_' dissection_name '.mat']), ...
                "data_in","data_out",'-v7')
        end
        % -------------------------------------------------------------------
        % Utility functions to use for testing and for outside of dissections
        % -------------------------------------------------------------------
        function obj = openTableShutter(obj,verbose)
            % Digital Outputs [Laser, Shutter, Line, Sample]

            % Open (and leave open)
            if exist('verbose','var') && verbose
                fprintf('Opening table shutter');
            end

            % Assert previous state
            obj.session.write([0,...
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

            % Set new state
            obj.table_shutter_open = true;
            obj.session.write([0,...
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

            if exist('verbose','var') && verbose
                fprintf('.. Done\n');
            end
        end

        function obj = closeTableShutter(obj,verbose)
            % Digital Outputs [Laser, Shutter, Line, Sample]

            % Close (and leave closed)
            if exist('verbose','var') && verbose
                fprintf('Closing table shutter');
            end
            
            % Assert previous state
            obj.session.write([0,...
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

            % Set new state
            obj.table_shutter_open = false;
            obj.session.write([0,...
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

            if exist('verbose','var') && verbose
                fprintf('..Done\n');
            end
        end

        function obj = closeAllSolenoids(obj,verbose)
            % Digital Outputs [Laser, Shutter, Line, Sample]

            % Both Off
            if exist('verbose','var') && verbose
                fprintf('Closing all solenoids');
            end

            % Assert previous state
            obj.session.write([0,...
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

            % Set new state
            obj.laser_solenoid_open = false;
            obj.prep_solenoid_open = false;
            obj.session.write([0,...
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

            if exist('verbose','var') && verbose
                fprintf('.. Done\n');
            end

        end

        function obj = openAllSolenoids(obj,verbose)
            % Digital Outputs [Laser, Shutter, Line, Sample]
            
            % Both On
            if exist('verbose','var') && verbose
                fprintf('Opening laser line and dissection line purge solenoids');
            end

            % Assert previous state
            obj.session.write([0,...
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

            % Set new state
            obj.laser_solenoid_open = true;
            obj.prep_solenoid_open = true;
            obj.session.write([0,...
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

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
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

            % Set new state
            obj.laser_solenoid_open = true;
            obj.prep_solenoid_open = false;
            obj.session.write([0,...
                obj.table_shutter_open,...
                obj.laser_solenoid_open,...
                obj.prep_solenoid_open])

            if exist('verbose','var') && verbose
                fprintf('.. Done\n');
            end

        end
    end
end
