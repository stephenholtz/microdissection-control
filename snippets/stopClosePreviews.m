function stopClosePreviews(cam)

cameras = fieldnames(cam);

for i = 1 : length(cameras)
    stoppreview(cam.(cameras{i}).vid)
    closepreview(cam.(cameras{i}).vid)
    
    delete(cam.(cameras{i}).vid)
end

end

