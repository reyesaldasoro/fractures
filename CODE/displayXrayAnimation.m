function allHandles = displayXrayAnimation(displayResults,dataOut)
% display all the metrics that have been extracted from an x-ray ANIMATION
% Check that the data is received as structs
if nargin==1
    if isa(displayResults,'char')
        [dataOut,qq2,displayResults]       = extract_measurements_xray(displayResults);
    else
        disp('Data has to be 2 structures or one file name to be processed')
        allHandles =[];
        return;
    end
elseif nargin ==2
    if ~(isa(displayResults,'struct')&&isa(dataOut,'struct'))
            disp('Data has to be 2 structures or one file name to be processed')
        allHandles =[];
        return;
    end
else
    disp('Data has to be 2 structures or one file name to be processed')
    allHandles =[];
    return;
end



% First row, the original image, plus landmarks, rotation and lines of width
set(gcf,'Position', [   1000 500 500 400])
handleAx = gca;
imagesc(displayResults.Xray)
colormap gray

Xray_gray               = repmat(displayResults.Xray./max(displayResults.Xray(:)),[1 1 3]);

sizeDilate = 55;
    Xray_mask2          = imdilate (displayResults.Xray_mask,ones(sizeDilate));   
    Xray_norm           = (Xray_mask2==0).*displayResults.Xray/max(displayResults.Xray(:));
    Xray_RGB(:,:,1)     = (Xray_mask2==1)+Xray_norm;
    Xray_RGB(:,:,2)     = (Xray_mask2==2)+Xray_norm;
    Xray_RGB(:,:,3)     = (Xray_mask2==3)+Xray_norm;
    
% Number of steps
numSteps = 20;
stepAnim = 1/numSteps;

% First animation, add the manual landmarks
for k=0:stepAnim:1
    imagesc(k*Xray_RGB+(1-k)*Xray_gray)
    drawnow
    pause(0.01)    
end
for k=0:stepAnim:1
    imagesc((1-k)*Xray_RGB+(k)*Xray_gray)
    drawnow
    pause(0.01)    
end

[rowsPre,colsPre,levsPre] = size(displayResults.Xray);
[rowsPos,colsPos,levsPos] = size(displayResults.XrayR);

diffRows    = floor((rowsPos-rowsPre)/2);
diffCols    = floor((colsPos-colsPre)/2);


Xray_preRot = zeros(size(displayResults.XrayR));
Xray_preRot (diffRows:diffRows+rowsPre-1,diffCols:diffCols+colsPre-1) = displayResults.Xray;


% Second animation, the rotation process
for k=0:stepAnim:1
    imagesc(k*displayResults.XrayR2+(1-k)*Xray_preRot)
    drawnow
    pause(0.01)    
end

imagesc(displayResults.XrayR2)
title('(b)','fontsize',12)
hc = subplot(4,3,3)

imagesc(displayResults.displayResultsLunate2)
title('(c)','fontsize',12)
%% Second row, Add the results of the finger
hd = subplot(4,3,4)
imagesc(displayResults.displayResultsFinger.Xray2)
title('(d)','fontsize',12)
he = subplot(4,3,5)
imagesc(displayResults.displayResultsFinger.Combined)
title('(e)','fontsize',12)
hf = subplot(4,3,6)
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
hg = subplot(4,3,7)
imagesc(displayResults.displayResultsLBP.Xray_out)
% zoom in a little bit
[rows,cols,levs]=size(displayResults.displayResultsLBP.Xray_out);
 axis(round([0.2*cols 0.8*cols 0.3*rows 0.9*rows ]))
title('(g)','fontsize',12)

hh = subplot(4,3,8)
imagesc(displayResults.displayResultsLBP.PatchExtracted)
title('(h)','fontsize',12)

hi = subplot(4,3,9)
bar(dataOut.LBP_Features)
axis tight
grid on
title('(i)','fontsize',12)

%% Fourth row add the profiles
hj = subplot(4,3,10)
imagesc(displayResults.displayResultsRadial.dataOutput)
% zoom in a little bit
[rows,cols,levs]=size(displayResults.displayResultsRadial.dataOutput);
 axis(round([0.2*cols 0.8*cols 0.3*rows 0.9*rows ]))
title('(j)','fontsize',12)

hk = subplot(4,3,11)
hold off
plot(displayResults.displayResultsRadial.prof_radial_new1,'r')
hold on
plot(displayResults.displayResultsRadial.prof_radial_new2,'b')
grid on
axis tight
title('(k)','fontsize',12)

hl = subplot(4,3,12)
hold off
plot(displayResults.displayResultsRadial.prof2_radial_new1,'r')
hold on
plot(displayResults.displayResultsRadial.prof2_radial_new2,'b')
grid on
axis tight
title('(l)','fontsize',12)
% Add the lines
%h = subplot(2,4,5)
%imagesc(displayResults.displayResultsLunate)



hTit = annotation(gcf,'textbox',...
    [0.345199568500538 0.955709957258268 0.327939580623643 0.0292207786724681],...
    'String',displayResults.nameFile,'interpreter','none',...
    'FitBoxToText','on','linestyle','none');

allHandles.ha = ha;
allHandles.hb = hb;
allHandles.hc = hc;
allHandles.hd = hd;
allHandles.he = he;
allHandles.hf = hf;
allHandles.hg = hg;
allHandles.hh = hh;
allHandles.hi = hi;
allHandles.hj = hj;
allHandles.hk = hk;
allHandles.hl = hl;



%title(displayResults.nameFile,'interpreter','none')
