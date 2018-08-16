function initWarningDlgs()

    r = questdlg('Change door sineage to hazardous.','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end

    r = questdlg('Switch laser on and open GAM Laser Software.','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end
    
    r = questdlg('Verify laser interlock is functional in GAM Laser Softwave.','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end
    
    r = questdlg('Set Uniblitz shutter driver to STD, N.O., and Remote','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end
    
    r = questdlg('Verify nitrogen purge main line and tanks are open.','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end
    
    warndlg('Allow laser to heat up to software specified temperature before dissecting.','P.U.M.P. Initalization');

end