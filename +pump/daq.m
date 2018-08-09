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
            
            fprintf('.. Done\n');
        end
    end
    
    methods (Static)
        % Solenoid control functions
        
        function closeAllSoleniods
            % Both Off
            fprintf('Closing all solenoids');
            obj.session.outputSingleScan([ 0 0 0 0 ]);
            obj.session.outputSingleScan([ 0 0 0 0 ]);
            fprintf('.. Done\n');
        end
        
        function openAllSolenoids
            % Both On
            fprintf('Opening laser line and dissection line purge solenoids'); 
            obj.session.outputSingleScan([ 0 0 0 0 ]);
            obj.session.outputSingleScan([ 0 1 0 1 ]);
            fprintf('.. Done\n');
        end
        
        function openLaserLineSolenoid
            % Line Purge On
            fprintf('Opening excimer laser line purge solenoid only.');
            obj.session.outputSingleScan([ 0 0 0 0 ]);
            obj.session.outputSingleScan([ 0 1 0 0 ]);
            fprintf('.. Done\n');
        end

    end
end
