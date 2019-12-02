function allHandles = displayXrayMetrics(displayResults,dataOut)
% display all the metrics that have been extracted from an x-ray
% ***************in several figures ************
% First figure, the original image, plus landmarks, rotation and lines of width
figure(1)
set(gcf,'Position', [   250   600   927   280])
ha = subplot(1,3,1);
%imagesc(displayResults.Xray)
    sizeDilate = 55;
    Xray_mask2          = imdilate (displayResults.Xray_mask,ones(sizeDilate));   
    Xray_norm           = (Xray_mask2==0).*displayResults.Xray/max(displayResults.Xray(:));
    Xray_RGB(:,:,1)     = (Xray_mask2==1)+Xray_norm;
    Xray_RGB(:,:,2)     = (Xray_mask2==2)+Xray_norm;
    Xray_RGB(:,:,3)     = (Xray_mask2==3)+Xray_norm;
imagesc(Xray_RGB)
title('(a)','fontsize',12)


hb = subplot(1,3,2);

imagesc(displayResults.XrayR2)
title('(b)','fontsize',12)
colormap gray
hc = subplot(1,3,3);

imagesc(displayResults.displayResultsLunate2)
title('(c)','fontsize',12)

ha.Position = [ 0.035    0.1    0.285    0.801];
hb.Position = [ 0.37    0.1    0.285    0.801];
hc.Position = [ 0.7    0.1    0.285    0.801];



%% Second row, Add the results of the finger
figure(2)
set(gcf,'Position', [   300   550   927   280])
hd = subplot(1,3,1);
imagesc(displayResults.displayResultsFinger.Xray2)
title('(a)','fontsize',12)
he = subplot(1,3,2);
imagesc(displayResults.displayResultsFinger.Combined)
title('(b)','fontsize',12)
hf = subplot(1,3,3);
plot(displayResults.displayResultsFinger.CorticalProfile{1},'k')
hold on
plot(displayResults.displayResultsFinger.centValleyLoc,displayResults.displayResultsFinger.centValley,'ro','markersize',8)
plot(displayResults.displayResultsFinger.leftPeakLoc,displayResults.displayResultsFinger.leftPeak,'b*','markersize',8)
plot(displayResults.displayResultsFinger.rightPeakLoc,displayResults.displayResultsFinger.rightPeak,'b*','markersize',8)
plot(displayResults.displayResultsFinger.leftEdgeLoc,displayResults.displayResultsFinger.leftEdge,'md','markersize',8)
plot(displayResults.displayResultsFinger.rightEdgeLoc,displayResults.displayResultsFinger.rightEdge,'md','markersize',8)
grid on
axis tight

colormap gray
title('(c)','fontsize',12)

hd.Position = [ 0.035    0.1    0.285    0.801];
he.Position = [ 0.37    0.1    0.285    0.801];
hf.Position = [ 0.699   0.1    0.285    0.801];

%% Third row,  add the LBP Results
figure(3)
set(gcf,'Position', [   350   500   927   280])

hg = subplot(4,3,7);
imagesc(displayResults.displayResultsLBP.Xray_out)
% zoom in a little bit
[rows,cols,levs]=size(displayResults.displayResultsLBP.Xray_out);
 axis(round([0.2*cols 0.8*cols 0.3*rows 0.9*rows ]))
title('(a)','fontsize',12)

hh = subplot(4,3,8);
imagesc(displayResults.displayResultsLBP.PatchExtracted)
title('(b)','fontsize',12)

hi = subplot(4,3,9);
bar(dataOut.LBP_Features)
axis tight
grid on
title('(c)','fontsize',12)
hg.Position = [ 0.035    0.1    0.285    0.801];
hh.Position = [ 0.37    0.1    0.285    0.801];
hi.Position = [ 0.699   0.1    0.285    0.801];
colormap gray
%% Fourth row add the profiles
figure(4)
set(gcf,'Position', [   400   450   927   280])

hj = subplot(1,3,1);
imagesc(displayResults.displayResultsRadial.dataOutput)
% zoom in a little bit
[rows,cols,levs]=size(displayResults.displayResultsRadial.dataOutput);
 axis(round([0.2*cols 0.8*cols 0.3*rows 0.9*rows ]))
title('(a)','fontsize',12)

hk = subplot(1,3,2);
hold off
plot(displayResults.displayResultsRadial.prof_radial_new1,'r')
hold on
plot(displayResults.displayResultsRadial.prof_radial_new2,'b')
grid on
axis tight
title('(b)','fontsize',12)

hl = subplot(1,3,3);
hold off
plot(displayResults.displayResultsRadial.prof2_radial_new1,'r')
hold on
plot(displayResults.displayResultsRadial.prof2_radial_new2,'b')
grid on
axis tight
title('(c)','fontsize',12)
% Add the lines
%h = subplot(2,4,5)
%imagesc(displayResults.displayResultsLunate)

hj.Position = [ 0.035    0.1    0.285    0.801];
hk.Position = [ 0.36    0.1    0.285    0.801];
hl.Position = [ 0.69    0.1    0.285    0.801];
%%
