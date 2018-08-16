classdef daq
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
    end
    
    methods
        function obj = daq()
            fprintf('Initializing DAQ channels for laser dissection.');
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
            
            % Make sure they are closed
            obj.closeTableShutter();
            obj.closeAllSolenoids();            
            
            % Set non-dissection status
            obj.table_shutter_open = false;
            obj.laser_solenoid_open = false;
            obj.prep_solenoid_open = false;
            
            % Initalize dissection values to throw an error
            obj.nShutteredPulses = nan;
            obj.nDeliveredPulses = nan;
            obj.pulseFrequency = nan;
            obj.purgeDurSeconds = nan;
            
            fprintf('.. Done\n');
        end
        
        function obj = runDissection(obj)
            fprintf('Running dissection:');

            % Construct and queue digital output data first

            % Short buffer for the beginning and end
            pre = 0*ones(1,obj.session.Rate * .05);
            post = 0*ones(1,obj.session.Rate * .05);

            % Make each pulse a single sample, needs to be shorter than 50ns
            pulse = [0*ones(1,(obj.session.Rate * 1/obj.pulseFrequency)-2) 1 0 ];

            % Append and format for queue data
            pulsesDataOut = [pre repmat(pulse,1,obj.nShutteredPulses + obj.nDeliveredPulses)];

            % Open the shutter after initial stabilizing laser pulses
            nShutterClosedSamples = obj.nShutteredPulses * length(pulse);
            shutterDataClosed = [pre 0*ones(1,nShutterClosedSamples)];
            shutterDataOut = [shutterDataClosed 1*ones(1,length(pulsesDataOut) - (length(shutterDataClosed))-1) 0];

            % Purge laser line continuously, and specimen only just before opening the shutter
            laserLineSolenoidDataOut = ones(1,length(pulsesDataOut));
            specimenSolenoidClosed = 0*ones(1,length(shutterDataClosed)-(obj.session.Rate*obj.specimen_purge_time_s));
            specimenSolenoidDataOut = [specimenSolenoidClosed ones(1,length(pulsesDataOut)-length(specimenSolenoidClosed))];

            dataOut = [[pulsesDataOut post]',...
                       [shutterDataOut post]',...
                       [laserLineSolenoidDataOut post]'
                       [specimenSolenoidDataOut post]'];
            obj.daq.queueOutputData(dataOut);

            fprintf('\n\tPurging Laser Line for %d seconds',obj.purgeDurSeconds);
            obj.openLaserLineSolenoid();
            pause(obj.purgeDurSeconds);
            fprintf('.. Done\n');

            fprintf('\n\tRunning Laser\n\t\tPulses Shuttered %d\n\t\tPulses Delivered %d\n\t\tPulseFrequency %d',...
                obj.nShutteredPulses,obj.nDeliveredPulses,obj.pulseFrequency);
            obj.daq.startForeground();

            % Make sure they are set to / are closed
            obj.closeTableShutter();
            obj.closeAllSolenoids();

            fprintf('.. Done\n');
        end

        % -------------------------------------------------------------------
        % Utility functions to use for testing and for outside of dissections
        % -------------------------------------------------------------------
        function obj = openTableShutter(obj)
            % Open (and leave open)
            fprintf('Opening table shutter');
            
            % Assert previous state
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])
            % Set new state
            obj.table_shutter_open = true;
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])
            fprintf('.. Done\n');
        end
        
        function obj = closeTableShutter(obj)
            % Close (and leave closed)
            fprintf('Closing table shutter');
            % Assert previous state
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])
            % Set new state
            obj.table_shutter_open = false;
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])
            fprintf('.. Done\n');
        end
        
        % Solenoid control functions (static to simplify / make less elegant)
        function obj = closeAllSolenoids(obj)
            % Both Off
            fprintf('Closing all solenoids');
            % Assert previous state
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])
            % Set new state
            obj.laser_solenoid_open = false;
            obj.prep_solenoid_open = false;
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])
            fprintf('.. Done\n');
        end
        
        function obj = openAllSolenoids(obj)
            % Both On
            fprintf('Opening laser line and dissection line purge solenoids'); 
            % Assert previous state
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])            
            % Set new state
            obj.laser_solenoid_open = true;
            obj.prep_solenoid_open = true;
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])
            fprintf('.. Done\n');
        end
        
        function obj = openLaserLineSolenoid(obj)
            % Only Laser Line Purge On
            fprintf('Opening excimer laser line purge solenoid only');
            % Assert previous state
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])
            % Set new state
            obj.laser_solenoid_open = true;
            obj.prep_solenoid_open = false;
            obj.session.outputSingleScan([0 obj.table_shutter_open,... 
                                            obj.laser_solenoid_open,...
                                            obj.prep_solenoid_open])
            fprintf('.. Done\n');
        end

    end
end
