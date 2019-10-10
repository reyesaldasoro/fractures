function    [TrabecularToTotal,WidthFinger,displayResultsFinger]=analyseLandmarkFinger(Xray,Xray_mask,Xray_info,currentFile,displayData)
%
% Regular dimensions check
[rows,cols,levs]    = size(Xray);

% Locate the mask, and the centroids of the landmarks
% In addition dilate 

Xray_maskP          = regionprops(Xray_mask,Xray,'Area','Centroid','meanIntensity');
%Xray_maskP2         = regionprops(imdilate(Xray_mask,ones(70)),Xray,'Area','Centroid','meanIntensity','minIntensity','maxIntensity');

% The width should contain a finger, but the xrays have different sizes so use the
% DICOM field of PixelSpacing to cover around 16 mm

%cc2     = 10*round(cols/150);
%cc2     = 70;


% Determine a square region around the landmark of the central finger if the landmark
% is too close to the upper border, use a smaller region

% Check that the field PixelSpacing exists, if not use values of other xrays
if ~isfield(Xray_info,'PixelSpacing')
    Xray_info.PixelSpacing=[    0.1440;     0.1440];
end

if Xray_maskP(3).Centroid(2)<100
    rr      = round(Xray_maskP(3).Centroid(2))+10:round(Xray_maskP(3).Centroid(2))+40;
    cc2     = 7*round(10/Xray_info.PixelSpacing(1)/10);
else
    rr      = round(Xray_maskP(3).Centroid(2))+0:round(Xray_maskP(3).Centroid(2))+50;
    cc2     = 8*round(10/Xray_info.PixelSpacing(1)/10);
end
cc      = round(Xray_maskP(3).Centroid(1))-cc2:round(Xray_maskP(3).Centroid(1))+cc2;
% imagesc(Xray(rr,cc))

% Determine the orientation of the finger


%[rows,columns,levels]=size(Xray);
%return
Xray2 = double(Xray(rr,cc));
[rowsF,colsFr] = size(Xray2);


maxIntensity = max(Xray2(:));
%minIntensity = min(Xray2(:));

% This is a single otsu level for the finger region
%otsuLevel   = maxIntensity*(graythresh(Xray2/maxIntensity));
%    otsuLevel2   = maxIntensity*(graythresh(Xray_Centre/maxIntensity));
%otsuLevel3   = otsuLevel*0.5;
%Xray3   = imclose(Xray2>(otsuLevel),strel('disk',15));

% This is TWO otsu levels for the finger region, one left one right
otsuLevelA   = maxIntensity*(graythresh(Xray2(:,1:floor(colsFr/2))/maxIntensity));
otsuLevelB   = maxIntensity*(graythresh(Xray2(:,ceil(colsFr/2):end)/maxIntensity));


Xray2A      = Xray2(:,1:floor(colsFr/2))>otsuLevelA;
Xray2B      = Xray2(:,ceil(colsFr/2):end)>otsuLevelB;
Xray2C       = [Xray2A Xray2B];
Xray3       = imopen(Xray2C,ones(3));
Xray3       = imclose(Xray3,strel('disk',15));

% In some cases, there are 2 regions as the fingers next to the others appear, keep central region
[Xray3_L,numReg]     = bwlabel(Xray3);
if numReg>1
    Xray3_R         = regionprops(Xray3_L,'area','centroid');
    [maxRegion, indMax]       = max([Xray3_R.Area]);
    casesXray3      = unique(Xray3_L);
    Xray3           = (Xray3_L==indMax);
    casesXray3(casesXray3==indMax)=[];
    casesXray3(casesXray3==0)=[];
    
    Xray2(Xray3_L==casesXray3)=0.9*min(otsuLevelA,otsuLevelB);
    
end

Xray4   = edge(Xray3,'canny');
% Xray44(:,:,1) = Xray2;
% Xray44(:,:,2) = Xray2;
% Xray44(:,:,3) = Xray2.*(1-Xray4);% + Xray4*otsuLevel;

 [HoughFinger,HoughAngles,HoughDist] = hough(Xray4,'ThetaResolution',1);
%figure(1)
%imagesc(Xray2.*(1-Xray4))
%caxis([minIntensity maxIntensity ])
PeaksHough  = houghpeaks(HoughFinger,2,'threshold',ceil(0.3*max(HoughFinger(:))));

%PeaksHough  = houghpeaks(round(imfilter(HoughFinger,gaussF(35,35,1))),3,'threshold',ceil(0.3*max(HoughFinger(:))));
%angleRot = median(HoughAngles(PeaksHough(:,2)))
angleRot = mean(HoughAngles(PeaksHough(:,2)));
%disp([rows cols])

% In some cases, the angles seem to be very large and that may be when the landmark
% is too high up and close to the edge, especially when the edge of the cassette is
% close to the finger, so just set to zero in those cases.
if Xray_maskP(3).Centroid(2)<100
    Xray5 = Xray2;
    angleRot = 0;
else
    Xray5 = imrotate(Xray2,angleRot);
end

Cortical = sum(Xray5)./sum(Xray5>0);

rows2                       = size(Xray5,1);
cols2                       = numel(Cortical);
% Determine position of peaks, valleys and from there the edges of the bone, the
% thickness of the cortical bone and the thickness of the marrow.
[CorticalPeaks,CorticalPLocs,widthP,prominenceP]         = findpeaks(Cortical,'MinPeakDistance',10,'MinPeakHeight',min(otsuLevelA,otsuLevelB));

% Refine the location of the peaks by detecting their prominence, take the 2 most prominent
if numel(CorticalPeaks>2)
    [mp,mp2]=sort(prominenceP);
    CorticalPeaks = CorticalPeaks(sort(mp2(end-1:end)));
    CorticalPLocs = CorticalPLocs(sort(mp2(end-1:end)));
end
    
[CorticalValleys,CorticalVLocs,widthV,prominenceV]       = findpeaks(1-Cortical,'MinPeakDistance',10);
CorticalValleys =-CorticalValleys;

%
% The valley closest to the centre of the bone (cc2) should indicate the the lowest
% intensity and centre of marrow, then each way there should be a peak, centre of the
%  cortical bone, then a minimum, edge of the bone.

% In some rare cases, the finger is shifted towards one side (when it was on a certain angle)
% in those cases, the centre is not very good location try replacing with the mean of the 
% peaks detected
%[temp1,temp2]               = min(abs(CorticalVLocs-cc2));

[temp1,temp2]               = min(abs(CorticalVLocs-mean(CorticalPLocs)));
centValley                  = CorticalValleys(temp2);
centValleyLoc               = CorticalVLocs(temp2);

% remove all valleys ABOVE the central valley
%CorticalVLocs(CorticalValleys>centValley) =[];
%CorticalValleys(CorticalValleys>centValley) =[];

% Peak to the left
CorticalPeaksL              = CorticalPeaks(CorticalPLocs<centValleyLoc);
CorticalPeaksLL             = CorticalPLocs(CorticalPLocs<centValleyLoc);

[temp3,temp4]               = max(CorticalPeaksL);
leftPeak                    = CorticalPeaks(temp4);
leftPeakLoc                 = CorticalPLocs(temp4);
%
% Peak to the right
CorticalPeaksR              = CorticalPeaks(CorticalPLocs>centValleyLoc);
CorticalPeaksRL              = CorticalPLocs(CorticalPLocs>centValleyLoc);

[temp5,temp6]               = max(CorticalPeaksR);
rightPeak                    = CorticalPeaksR(temp6);
rightPeakLoc                 = CorticalPeaksRL(temp6);

% Edge to the left
[temp7]                     = find(CorticalVLocs<leftPeakLoc,1,'last');
leftEdge                    = CorticalValleys(temp7);
leftEdgeLoc                 = CorticalVLocs(temp7);

% Edge to the right
[temp8]                         = find(CorticalVLocs>rightPeakLoc,1,'first');
if isempty(temp8)
    % no edge detected, set at the extreme
    rightEdgeLoc                    = cols2-1;
    rightEdge                       = Cortical(rightEdgeLoc);
else
    rightEdge                       = CorticalValleys(temp8);
    rightEdgeLoc                    = CorticalVLocs(temp8);
end

% area cortical is all above the average between central and peaks
CorticalThresholdC               = mean([mean([rightPeak leftPeak]) centValley]);
CorticalThresholdL               = mean([leftPeak leftEdge]);
CorticalThresholdR               = mean([rightPeak rightEdge]);

Xray5LPF                        = imfilter(Xray5,gaussF(7,3,1));
% Remove areas left and right of the edges
Xray5LPF(:,1:leftEdgeLoc)       = 0;
Xray5LPF(:,rightEdgeLoc:end)       = 0;


CorticalBoneC                    = Xray5LPF>CorticalThresholdC;
CorticalBoneL                    = Xray5LPF>CorticalThresholdL;
CorticalBoneR                    = Xray5LPF>CorticalThresholdR;


CorticalBoneC(:,centValleyLoc)   = 0;
CorticalBoneL(:,leftPeakLoc:end)   = 0;
CorticalBoneR(:,1:rightPeakLoc)   = 0;

CorticalBone0                   = ((CorticalBoneC+CorticalBoneL+CorticalBoneR)>0);
CorticalBone1                   = bwlabel(CorticalBone0);
CorticalBone1P                  = regionprops(CorticalBone1,'Area');
[temp9,temp10]                  = sort([CorticalBone1P.Area]);
CorticalBone2                   = ismember(CorticalBone1,temp10(end));
CorticalBone3                   = ismember(CorticalBone1,temp10(end-1));

CorticalBone4                    = imclose(CorticalBone2,ones(8,8));
CorticalBone5                    = imclose(CorticalBone3,ones(8,8));

CorticalBone                    = CorticalBone4 + CorticalBone5;
CorticalBone(:,centValleyLoc)   = 0;


%
TrabecularBone                 = imclose(CorticalBone,strel('line',5+rightPeakLoc-leftPeakLoc,angleRot))-CorticalBone;
TrabecularBone                 = imopen(TrabecularBone,ones(2,1));
Combined(:,:,3)                = Xray5/max(Xray5(:));
Combined(:,:,2)                = Xray5/max(Xray5(:)).*(1-TrabecularBone)+Xray5/max(Xray5(:)).*(0.79999*TrabecularBone);
Combined(:,:,1)                = Xray5/max(Xray5(:)).*(1-CorticalBone)+Xray5/max(Xray5(:)).*(0.79999*CorticalBone);

TrabecularArea                  = sum(TrabecularBone(:));
CorticalArea                    = sum(CorticalBone(:));
TrabecularToTotal               = TrabecularArea/(TrabecularArea+CorticalArea);
WidthFinger                     = (rightEdgeLoc-leftEdgeLoc) *Xray_info.PixelSpacing(1);
%
% 0.1*round(10*WidthArm(currentRow)*Xray_info.PixelSpacing(1))
% figure(2)
% hold off
% imagesc(Xray5)
% caxis([minIntensity maxIntensity ])
% hold on
% line([leftEdgeLoc leftEdgeLoc],[1 rows2],'color','m')
% line([rightEdgeLoc rightEdgeLoc],[1 rows2],'color','m')
% line([rightPeakLoc rightPeakLoc],[1 rows2],'color','c')
% line([leftPeakLoc leftPeakLoc],[1 rows2],'color','c')
% line([centValleyLoc centValleyLoc],[1 rows2],'color','r')


% figure(3)
% hold off
% plot(mean(Xray2(:,:)))
% hold on
% plot(1:cols2,Cortical,'b',CorticalPLocs,CorticalPeaks,'ro',CorticalVLocs,CorticalValleys,'m*')
% grid on
% axis tight
%
%
if ~exist('displayData','var') 
    displayData=0; 
end
if ~exist('currentFile','var') 
    currentFile='                   '; 
end



linesMeasurement                        = zeros(rows,cols);
linesMeasurement (rr(1):rr(end),cc(1):cc+3)  =1;
linesMeasurement (rr(1):rr(end),cc(end)-1:cc(end))=1;
linesMeasurement (rr(1):rr(1)+3,cc(1):cc(end))  =1;
linesMeasurement (rr(end)-3:rr(end),cc(1):cc(end))=1;

    dataOutput(:,:,1) = Xray.*(1-linesMeasurement);
    dataOutput(:,:,3) = Xray.*(1-linesMeasurement)+linesMeasurement*maxIntensity;
    dataOutput(:,:,2) = Xray.*(1-linesMeasurement);
    dataOutput          = dataOutput/maxIntensity;

CorticalProfile ={Cortical,{centValleyLoc,centValley,...
    leftPeakLoc,leftPeak,...
    rightPeakLoc,rightPeak,...
    leftEdgeLoc,leftEdge,...
    rightEdgeLoc,rightEdge}};

if displayData==1
    
    figure
    subplot(131)
    hold off
    imagesc(Xray)
    hold on
    title(currentFile(13:end),'interpreter','none')
    
    line([cc(1) cc(1)],[rr(1) rr(end)],'linewidth',2 )
    line([cc(end) cc(end)],[rr(1) rr(end)],'linewidth',2 )
    line([cc(1) cc(end)],[rr(end) rr(end)],'linewidth',2 )
    line([cc(1) cc(end)],[rr(1) rr(1)],'linewidth',2 )
    subplot(232)
    imagesc(Xray2)
    colormap gray
    subplot(235)
    hold off
    plot(Cortical)
    hold on
    plot(centValleyLoc,centValley,'ro')
    plot(leftPeakLoc,leftPeak,'bx')
    plot(rightPeakLoc,rightPeak,'bx')
    plot(leftEdgeLoc,leftEdge,'md')
    plot(rightEdgeLoc,rightEdge,'md')
    grid on
    axis tight
    
    subplot(133)
    hold off
    imagesc(Combined)
    
    hold on
    line([leftEdgeLoc leftEdgeLoc],[1 rows2],'color','m')
    line([rightEdgeLoc rightEdgeLoc],[1 rows2],'color','m')
    line([rightPeakLoc rightPeakLoc],[1 rows2],'color','c')
    line([leftPeakLoc leftPeakLoc],[1 rows2],'color','c')
    line([centValleyLoc centValleyLoc],[1 rows2],'color','r')
    title({strcat('Ratio of Trabecular:',num2str(TrabecularToTotal));strcat('Width Finger:',num2str(WidthFinger),' [mm]')})
    %
    %    filename = strcat('Cortical',num2str(k),'.jpg');
end

% save results in a single variable
displayResultsFinger.Combined             = Combined;
displayResultsFinger.dataOutput           = dataOutput;
displayResultsFinger.CorticalProfile      = CorticalProfile;
displayResultsFinger.WidthFinger          = WidthFinger;
displayResultsFinger.Xray2                = Xray2 ;
displayResultsFinger.cc                   = cc;
displayResultsFinger.rr                   = rr;
displayResultsFinger.TrabecularToTotal    = TrabecularToTotal;
displayResultsFinger.centValleyLoc        = centValleyLoc;
displayResultsFinger.centValley           = centValley;
displayResultsFinger.leftPeakLoc          = leftPeakLoc ;
displayResultsFinger.leftPeak             = leftPeak ;
displayResultsFinger.rightPeakLoc         = rightPeakLoc;
displayResultsFinger.rightPeak            = rightPeak;
displayResultsFinger.leftEdgeLoc          = leftEdgeLoc;
displayResultsFinger.leftEdge             = leftEdge;
displayResultsFinger.rightEdgeLoc         = rightEdgeLoc;
displayResultsFinger.rightEdge            = rightEdge;



% displayResultsFinger.leftEdgeLoc  = leftEdgeLoc;
% displayResultsFinger.rightEdgeLoc = rightEdgeLoc ;
% displayResultsFinger.rightPeakLoc = rightPeakLoc;
% displayResultsFinger.leftPeakLoc  = leftPeakLoc ;
% displayResultsFinger.centValleyLoc= centValleyLoc ;
% displayResultsFinger.Cortical = Cortical ;

