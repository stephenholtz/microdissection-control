delete(imaqfind);
imaqreset;

camH = figure('MenuBar', 'none',...
    'Name', 'PUMP GUI',...
    'NumberTitle', 'off');

adaptorName = 'pointgrey';
deviceID = 1;
vidFormat = 'F7_Mono8_1024x1024_Mode1';

vid = videoinput(adaptorName, deviceID, vidFormat);
ax = axes(camH);
ax.Box = 'off';
frame = getsnapshot(vid);
camImage = imshow(frame,[],'InitialMagnification','fit','Parent',ax);
preview(vid, camImage); hold on
plot(1024/2,1024/2,'c+','MarkerSize',14,'LineWidth',2,'Parent',ax);