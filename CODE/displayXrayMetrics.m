function displayXrayMetrics(displayResults,dataOut)
% display all the metrics that have been extracted from an x-ray

% First row, the original image, plus landmarks, rotation and lines of width
 set(gcf,'Position', [   247   68   927   880])
subplot(4,3,1)
%imagesc(displayResults.Xray)
    sizeDilate = 55;
    Xray_mask2          = imdilate (displayResults.Xray_mask,ones(sizeDilate));   
    Xray_norm           = (Xray_mask2==0).*displayResults.Xray/max(displayResults.Xray(:));
    Xray_RGB(:,:,1)     = (Xray_mask2==1)+Xray_norm;
    Xray_RGB(:,:,2)     = (Xray_mask2==2)+Xray_norm;
    Xray_RGB(:,:,3)     = (Xray_mask2==3)+Xray_norm;
imagesc(Xray_RGB)
title('(a)','fontsize',12)


subplot(4,3,2)

imagesc(displayResults.XrayR2)
title('(b)','fontsize',12)
subplot(4,3,3)

imagesc(displayResults.displayResultsLunate2)
title('(c)','fontsize',12)
%% Second row, Add the results of the finger
subplot(4,3,4)
imagesc(displayResults.displayResultsFinger.Xray2)
title('(d)','fontsize',12)
subplot(4,3,5)
imagesc(displayResults.displayResultsFinger.Combined)
title('(e)','fontsize',12)
subplot(4,3,6)
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
title('(f)','fontsize',12)
%% Third row,  add the LBP Results
subplot(4,3,7)
imagesc(displayResults.displayResultsLBP.Xray_out)
% zoom in a little bit
[rows,cols,levs]=size(displayResults.displayResultsLBP.Xray_out);
 axis(round([0.2*cols 0.8*cols 0.3*rows 0.9*rows ]))
title('(g)','fontsize',12)

subplot(4,3,8)
imagesc(displayResults.displayResultsLBP.PatchExtracted)
title('(h)','fontsize',12)

subplot(4,3,9)
bar(dataOut.LBP_Features)
axis tight
grid on
title('(i)','fontsize',12)

%% Fourth row add the profiles
subplot(4,3,10)
imagesc(displayResults.displayResultsRadial.dataOutput)
% zoom in a little bit
[rows,cols,levs]=size(displayResults.displayResultsRadial.dataOutput);
 axis(round([0.2*cols 0.8*cols 0.3*rows 0.9*rows ]))
title('(j)','fontsize',12)

subplot(4,3,11)
hold off
plot(displayResults.displayResultsRadial.prof_radial_new1,'r')
hold on
plot(displayResults.displayResultsRadial.prof_radial_new2,'b')
grid on
axis tight
title('(k)','fontsize',12)

subplot(4,3,12)
hold off
plot(displayResults.displayResultsRadial.prof2_radial_new1,'r')
hold on
plot(displayResults.displayResultsRadial.prof2_radial_new2,'b')
grid on
axis tight
title('(l)','fontsize',12)
% Add the lines
%subplot(2,4,5)
%imagesc(displayResults.displayResultsLunate)



hTit = annotation(gcf,'textbox',...
    [0.345199568500538 0.955709957258268 0.327939580623643 0.0292207786724681],...
    'String',displayResults.nameFile,'interpreter','none',...
    'FitBoxToText','on','linestyle','none');

%title(displayResults.nameFile,'interpreter','none')