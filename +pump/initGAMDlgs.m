function complete = initGAMDlgs(total_pulses, energy_level)
% Walk through GAM Software data entry
    r1 = questdlg({'  ~!~ VERIFY UV OBJECTIVE IS CLEAN ON SECOND CAMERA ~!~  ',' ','In GAM Laser Control Software: ',['  - select "SET MAXIMUM NUMBER OF PULSES" and enter '  num2str(total_pulses)],['  - change "SET ENERGY LEVEL" to ' num2str(energy_level) '.'],''},'P.U.M.P. Dissection','Complete','Abort','Abort');
    
    if strcmp(r1,'Complete')
        r2 = questdlg({'Change from Visible to UV Objective AND in GAM Software','Select "START LASER EXT. TRIG".'},'P.U.M.P. Dissection','Complete','Abort','Abort');
        complete = true;
        
        if ~strcmp(r2,'Complete')
           warndlg('Dissection Aborted.','P.U.M.P. Dissection');
           complete = false;
        end
    else
        warndlg('Dissection Aborted.','P.U.M.P. Dissection');
        complete = false;
    end
    
end