function fp = filepath()
    mfn = mfilename('fullpath');
    fps = regexp(mfn, filesep, 'split');
    fp = [fullfile(fps{1:end-2}) filesep];