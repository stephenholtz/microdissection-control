function complete = initGAMDlgs(total_pulses)
% Walk through GAM Software data entry
    r1 = questdlg(['In SET MAXIMUM NUMBER OF PULSES (GAM Software) Enter: ' num2str(total_pulses)],'P.U.M.P. Dissection','Complete','Abort','Abort');
    
    if strcmp(r1,'Complete')
        r2 = questdlg('Select START LASER EXT. TRIG (GAM Software).','P.U.M.P. Dissection','Complete','Abort','Abort');
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