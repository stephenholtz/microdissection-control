function out = startupWarnings()
    out = false;
    
    r = questdlg('Change door sineage to hazardous and enable warning light.','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end

    r = questdlg('Switch laser on and open ATL Laser Control Software.','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end
    
    r = questdlg('Verify laser interlock is functional in ATL Laser Control Softwave.','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end
    
    r = questdlg('Verify Uniblitz shutter driver set to STD, N.C., and Remote','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end
    
    r = questdlg('Verify nitrogen purge main line and tanks are open.','P.U.M.P. Initalization','Complete','Abort','Abort');
    if ~strcmp(r,'Complete')
        return
    end

    out = true;
end