classdef LaserIO
    properties
        session
    end
    
    properties (Constant)
        % DAQ settings
        rate = 100E3
        
        % Analog input names
        ai_0 = 'Laser Sync Input';
        ai_1 = 'Laser Energy Input';
        
        % Digital IO names
        dio_p0_l0 = 'Laser External Trigger Output';
        dio_p0_l1 = 'Laser Line N2 Purge Solenoid Gate';
        dio_p0_l2 = 'Laser Table Shutter Gate';
        dio_p0_l3 = 'Prep Area N2 Purge Solenoid Gate';
        
        % seconds prior to dissection to begin specimen purge
        % means the shuttered pulses must be at least this duration
        specimen_purge_time_s = 0.500; % half a second is fine
        
        % time between clicking "START LASER" or "START LASER EXT. TRIG"
        % and when lasing or closed loop feed back starts, respectively
        laser_start_delay_s = 7.25;
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
    end
    
    methods
        function obj = daq()
            fprintf('Initializing DAQ channels for laser dissection');
            close all force;
            daqreset;
            
            obj.session = daq.createSession('ni');
            obj.session.Rate = obj.rate;
            
            % Analog Input
            obj.session.addAnalogInputChannel('Dev1',0','Voltage');
            
            % Digital IO
            obj.session.addDigitalChannel('Dev1','port0/line0','OutputOnly');
            obj.session.addDigitalChannel('Dev1','port0/line1','OutputOnly');
            obj.session.addDigitalChannel('Dev1','port0/line2','OutputOnly');
            obj.session.addDigitalChannel('Dev1','port0/line3','OutputOnly');
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
        
        function [dataIn,obj] = runDissection(obj)
            % Approximate time of function call
            t_start = tic();
            
            fprintf('Running dissection:');

            % Construct and queue digital output data first

            % Short buffer for the beginning and end
            pre = 0*ones(1,obj.session.Rate * .05);
            post = 0*ones(1,obj.session.Rate * .05);

            % Make each pulse a single sample, needs to be shorter than 50ns
            pulse = [0*ones(1,(obj.session.Rate * 1/obj.pulseFrequency)-2) 1 0 ];

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

            dataOut = [pulsesDataOut post; laserLineSolenoidDataOut post; shutterDataOut post; specimenSolenoidDataOut post];
            obj.session.queueOutputData(dataOut');

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
            
            fprintf('\n\tPurging Laser Line for %d seconds',obj.purgeDurSeconds);
            obj.openLaserLineSolenoid(false);
            pause(obj.purgeDurSeconds);
            fprintf('.. Done\n');

            fprintf('\n\tRunning Laser\n\t\tPulses Shuttered %d\n\t\tPulses Delivered %d\n\t\tPulseFrequency %d',...
                obj.nShutteredPulses,obj.nDeliveredPulses,obj.pulseFrequency);
            dataIn = obj.session.startForeground();

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
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
                                            obj.prep_solenoid_open])
            % Set new state
            obj.table_shutter_open = true;
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
                                            obj.prep_solenoid_open])
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
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
                                            obj.prep_solenoid_open])
            % Set new state
            obj.table_shutter_open = false;
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
                                            obj.prep_solenoid_open])
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
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
                                            obj.prep_solenoid_open])
            % Set new state
            obj.laser_solenoid_open = false;
            obj.prep_solenoid_open = false;
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
                                            obj.prep_solenoid_open])
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
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
                                            obj.prep_solenoid_open])          
            % Set new state
            obj.laser_solenoid_open = true;
            obj.prep_solenoid_open = true;
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
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
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
                                            obj.prep_solenoid_open])
            % Set new state
            obj.laser_solenoid_open = true;
            obj.prep_solenoid_open = false;
            obj.session.outputSingleScan([0 obj.laser_solenoid_open,...
                                            obj.table_shutter_open,...
                                            obj.prep_solenoid_open])
            if exist('verbose','var') && verbose
                fprintf('.. Done\n');
            end
        end

    end
end
