function displayXrayMetrics(displayResults,dataOut)


 set(gcf,'Position', [   247   168   927   780])
subplot(241)
%imagesc(displayResults.Xray)
    sizeDilate = 55;
    Xray_mask2          = imdilate (displayResults.Xray_mask,ones(sizeDilate));   
    Xray_norm           = (Xray_mask2==0).*displayResults.Xray/max(displayResults.Xray(:));
%     Xray_RGB(:,:,1)     = (Xray_mask2==1)+(Xray_mask2~=3).*());
%     Xray_RGB(:,:,2)     = (Xray_mask2==2)+(Xray_mask2~=3).*(displayResults.Xray/max(displayResults.Xray(:)));
%     Xray_RGB(:,:,3)     = (Xray_mask2==3)+(Xray_mask2~=3).*(displayResults.Xray/max(displayResults.Xray(:)));
    Xray_RGB(:,:,1)     = (Xray_mask2==1)+Xray_norm;
    Xray_RGB(:,:,2)     = (Xray_mask2==2)+Xray_norm;
    Xray_RGB(:,:,3)     = (Xray_mask2==3)+Xray_norm;
imagesc(Xray_RGB)


title(displayResults.nameFile,'interpreter','none')
% Add the results of the finger
subplot(3,4,2)
imagesc(displayResults.displayResultsFinger.Xray2)
subplot(3,4,3)
imagesc(displayResults.displayResultsFinger.Combined)
subplot(3,4,4)
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

% add the LBP Results
subplot(3,4,6)
imagesc(displayResults.displayResultsLBP.Xray_out)
% zoom in a little bit
[rows,cols,levs]=size(displayResults.displayResultsLBP.Xray_out);
 axis(round([0.2*cols 0.8*cols 0.3*rows 0.9*rows ]))

subplot(3,4,7)
imagesc(displayResults.displayResultsLBP.PatchExtracted)
subplot(3,4,8)
bar(dataOut.LBP_Features)
axis tight
grid on

% add the profiles
subplot(3,4,10)
imagesc(displayResults.displayResultsRadial.dataOutput)
% zoom in a little bit
[rows,cols,levs]=size(displayResults.displayResultsRadial.dataOutput);
 axis(round([0.2*cols 0.8*cols 0.3*rows 0.9*rows ]))


subplot(3,4,11)
hold off
plot(displayResults.displayResultsRadial.prof_radial_new1,'r')
hold on
plot(displayResults.displayResultsRadial.prof_radial_new2,'b')
grid on
axis tight
subplot(3,4,12)
hold off
plot(displayResults.displayResultsRadial.prof2_radial_new1,'r')
hold on
plot(displayResults.displayResultsRadial.prof2_radial_new2,'b')
grid on
axis tight

% Add the lines
subplot(2,4,5)
imagesc(displayResults.displayResultsLunate)


