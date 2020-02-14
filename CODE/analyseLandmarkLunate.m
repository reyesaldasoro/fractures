function    [edgesArm,widthAtCM,displayResultsLunate,dataOutput]=analyseLandmarkLunate(Xray,Xray_mask,Xray_info,currentFile,displayData)

% Analyse the Xray from below the lunate to determine the level of inflammation of
% the fracture. The data has already been rotated previously so the bones should be
% as vertical as possible

[rows,cols,levs]                        = size(Xray);

% Calibration of Distances CM in Pixels
CmInPixels                              = round((10/Xray_info.PixelSpacing(1)));
if ~isfield(Xray_info,'PixelSpacing')
    Xray_info.PixelSpacing=[    0.1440;     0.1440];
end

%minIntensity = min(Xray2(:));
Xray_maskP                              = regionprops(Xray_mask,Xray,'Area','Centroid','meanIntensity');
%    Xray_maskP2                        = regionprops(imdilate(Xray_mask,ones(70)),Xray,'Area','Centroid','meanIntensity','minIntensity','maxIntensity');

% Remove zeros from the xrays as these may come from the rotations, this is important
% when finding the minimum values of the Xray which are not zeros.
% some WEIRD cases have a large region with values more than zero but far lower than
% the Xrays, for those cases, sort all the values and remove all pixels below the
% SECOND lowest value, for normal cases, it shld not affect.

sortedValues_Xray                       = unique(Xray);

Xray_nans                               = Xray;
%Xray_nans(Xray==0)                      = nan;
Xray_nans(Xray<=sortedValues_Xray(2))   = nan;





% Remove those pixels that are EXACTLY the maximum intensity, most likely they are
% the indications of left-right
maxIntensity                            = max(Xray(:));
maxPixels                               = imdilate(Xray>=(0.99*maxIntensity),ones(9));
maxPixels                               = imfill(maxPixels,'holes');
maxPixels                               = imopen(maxPixels,ones(17));
cMaxPixels                              = mean(find(sum(maxPixels)));

% Project the intensity from the lunate downwards, there should be two peaks with
% subpeaks corresponding to the bones a large valley in between the bones and then
% two drops of muscle towards the edge of the arm.

rLunate                                 = round(Xray_maskP(1).Centroid(2));
cLunate                                 = round(Xray_maskP(1).Centroid(1));

% remove the edge of the border
Xray_border                             = 1-imdilate(imopen(Xray<=1,ones(6)),ones(35));
if abs(cLunate-cMaxPixels)>150
    Xray_LPF                            = imfilter(Xray,gaussF(5,5,1)).*(1-maxPixels).*Xray_border;
else
    Xray_LPF                            = imfilter(Xray,gaussF(5,5,1)).*Xray_border;
end
Xray_border2                            = imerode(Xray_border,ones(35));
borderValues                            = sort(Xray_LPF((Xray_border-Xray_border2)>0));
borderValues1                           = diff(borderValues);

[valBackground,edgeBackground]          = findpeaks(borderValues1,'SortStr','descend','Npeaks',1);
otherThreshold                          = borderValues(edgeBackground);
% Crop the X-ray to remove the hand and above, one option is to start from the
% rLunate another is to go slightly higher to have one line above the lunate.
% regionBelowLunate                       = Xray_LPF(rLunate:end-100,:);
% regionBelowLunate_nan                   = Xray_nans(rLunate:end-100,:);
 regionBelowLunate                       = Xray_LPF(rLunate-CmInPixels:end-100,:);
 regionBelowLunate_nan                   = Xray_nans(rLunate-CmInPixels:end-100,:);


%%
minIntensity                            = min(regionBelowLunate_nan(:));
% find the marginal distributions
armProfile_mean                         = mean(regionBelowLunate);%./sum(regionBelowLunate>0);
armProfile_min                          =  min(regionBelowLunate_nan);
armProfile_max                          =  max(regionBelowLunate);

% LPF the distributions
armProfile_mean2                        = imfilter(armProfile_mean,gaussF(35,1,1));
armProfile_min2                         = imfilter(armProfile_min, gaussF(35,1,1));
armProfile_max2                         = imfilter(armProfile_max, gaussF(35,1,1));


% find the valleys of the MAXIMUM of each column, that will cover all the background
% on each side

%[ProfilePeaks,ProfilePLocs]             = findpeaks(armProfile_max2,'MinPeakDistance',10);
[ProfileValleys,ProfileVLocs]           = findpeaks(1-armProfile_max2,'MinPeakDistance',10);
ProfileValleys =-ProfileValleys;


% The profile at the position of the Lunate should be above bone thus the background
% will be below that

ProfileVLocs(ProfileValleys  > 0.9*min(armProfile_min2(cLunate-20:cLunate+20)) )  = [];
ProfileValleys(ProfileValleys> 0.9*min(armProfile_min2(cLunate-20:cLunate+20)) )  = [];

% Then, the closest to the column of the lunate should be the edges
leftEdge                                = max(ProfileVLocs(ProfileVLocs<cLunate));
rightEdge                               = min(ProfileVLocs(ProfileVLocs>cLunate));

% It may be that no edge was detected due to the fact that instead of a sharp
% boundary with the background a smooth decrease is detected.
if isempty(leftEdge)
    % first point where the line crosses the alternate position
    leftEdge                            = find(armProfile_min2>minIntensity,1,'first');
end
if isempty(rightEdge)
    % first point where the line crosses the alternate position
    rightEdge                            = find(armProfile_min2>minIntensity,1,'last');
end
%
% figure(11)
% hold off
% plot(ProfileVLocs,ProfileValleys,'m*')
% hold on
% plot(armProfile_mean2,'r'); plot(armProfile_max2,'b');plot(armProfile_min2,'m')



ProfileValleys(ProfileVLocs>rightEdge)  = [];
ProfileValleys(ProfileVLocs<leftEdge)   = [];
ProfileVLocs(ProfileVLocs<leftEdge)     = [];
ProfileVLocs(ProfileVLocs>rightEdge)    = [];

% if there is a fourth landmark, use that as threshold, otherwise, calculate as
% before
if max(Xray_mask(:))==4
    backgroundThreshold                 = mean(Xray(Xray_mask==4));
else
    if isempty(ProfileValleys)
        backgroundThreshold                 = max(armProfile_min2([leftEdge rightEdge]));
    else
        backgroundThreshold                 = max(ProfileValleys);
    end
end
%disp([otherThreshold backgroundThreshold])
% Remove the background
regionBelowLunate_sides0                = (regionBelowLunate>backgroundThreshold);
regionBelowLunate_sides0_L              = bwlabel(regionBelowLunate_sides0);
regionBelowLunate_sides0_R              = regionprops(regionBelowLunate_sides0_L,'area');
% Remove small regions on sides
regionBelowLunate_sides0_F              = ismember(regionBelowLunate_sides0_L,find([regionBelowLunate_sides0_R.Area]>3000));
% Close slightly 
regionBelowLunate_sides0_C              = imfill(imclose(regionBelowLunate_sides0_F, ones(5,15)),'holes');
regionBelowLunate_sides1                = regionBelowLunate.*(regionBelowLunate_sides0_C);
% Open to remove regions to the sides
regionBelowLunate_sides2                = imopen(regionBelowLunate_sides1>0,ones(10,205));
regionBelowLunate_sides              	= imclose(regionBelowLunate_sides2>0,ones(15,2));

if max(Xray_mask(:))==4
    leftEdge                            = find(sum(regionBelowLunate_sides)>0,1,'first');
    rightEdge                            = find(sum(regionBelowLunate_sides)>0,1,'last');
end

    
    
% Ensure that nothing on the sides of the background remains (the collimator)
regionBelowLunate_sides(:,1:leftEdge)   = 0;
regionBelowLunate_sides(:,rightEdge:end)= 0;

% Create a meshgrid to later detect where each row begins and ends
[rows2,cols2]                           = size(regionBelowLunate);
[cc,rr]                                 = meshgrid(1:cols2,1:rows2);
% Find canny edges to detect the edges of the arm
edgesBelowLunate                        = edge(regionBelowLunate.*regionBelowLunate_sides(:,:),'canny',[],7);
edgesBelowFilled                        = imclose (((cumsum(edgesBelowLunate,2,'reverse')>0)+(cumsum(edgesBelowLunate,2)>0))==2, ones(3));
edgesFilledRanked                       = edgesBelowFilled.*cc;
edgesFilledRanked(edgesBelowFilled==0)  = nan;
edgesArm                                = edge(edgesBelowFilled,'canny');

leftEdgeLine1                           = min(edgesFilledRanked,[],2);
rightEdgeLine1                          = max(edgesFilledRanked,[],2);
%Filter the lines
leftEdgeLine                            = round(medfilt1(leftEdgeLine1,40,'omitnan','truncate'));
rightEdgeLine                           = round(medfilt1(rightEdgeLine1,40,'omitnan','truncate'));

%
% % remove the horizontal lines as some of the big edges can connect with them
% edgesBelowLunateVer0                    = (bwmorph(bwmorph(imopen(edgesBelowLunate,[1 1]'),'clean'),'diag'));
% %  = bwlabel(bwmorph(bwmorph(imopen(edgesBelowLunate,[1 1]'),'clean'),'diag'));
% %edgesBelowLunateVer  = bwlabel(imclose(edgesBelowLunateVer0,ones(3,3)));
% edgesBelowLunateVer                     = bwlabel(bwmorph(edgesBelowLunateVer0,'bridge'));
%
% % Find the extreme edges as those must be the arm-background
% edgesBelowLunateVerP                    = regionprops(edgesBelowLunateVer,'Centroid','Extrema','Area');
% edgesBelowLunateVer                     = bwlabel(ismember(edgesBelowLunateVer,find([edgesBelowLunateVerP.Area]>30)));
% edgesBelowLunateVerP                    = regionprops(edgesBelowLunateVer,'Centroid','Extrema','Area');
% % Project the edges down with a maximum value
% edgesBelow_proj                         = max(edgesBelowLunateVer,[],1);
% edgesBelow_proj(edgesBelow_proj==0)     = [];
%
%
% % Calculate the width of the arm based on the two edges previously traced.
% leftEdgeArm                             = (edgesBelowLunateVer==edgesBelow_proj(1));
% rightEdgeArm                            = (edgesBelowLunateVer==edgesBelow_proj(end));
%
%
% leftEdgeLine                            = round(max(leftEdgeArm.*cc,[],2));
% rightEdgeLine                           = round(max(rightEdgeArm.*cc,[],2));
WidthArm                                = rightEdgeLine-leftEdgeLine;% sum(filledEdges2,2);


% Calculate the width at 5 places, each at 1cm down the arm
locationsWidth                          = 5:CmInPixels:min(CmInPixels*8,rows2);


%edgesArm                                = (edgesBelowLunateVer==edgesBelow_proj(1))+(edgesBelowLunateVer==edgesBelow_proj(end));
%edgesArm                                = (leftEdgeArm)+(rightEdgeArm);

linesArm                                = zeros(rows2,cols2);
linesArm(:,cLunate)                     = 1;
widthAtCM                               = [];
for counterLine=1:numel(locationsWidth)
    currentRow                          = locationsWidth(counterLine);
    if ~isnan(WidthArm(currentRow))
        widthAtCM(counterLine)              = 0.1*round(10*WidthArm(currentRow)*Xray_info.PixelSpacing(1));
        linesArm(currentRow,leftEdgeLine(currentRow)+1:-1+rightEdgeLine(currentRow)) = 1;
    end
end
%q = imdilate(edgesBelowLunate,ones(3));

% In the case that there is no space for 8 lines, copy the last value down.
numberLines = numel(widthAtCM);
if numberLines<8
    widthAtCM (numberLines+1:8) = widthAtCM(numberLines);
end


if ~exist('displayData','var')
    displayData=0;
end
if ~exist('currentFile','var')
    currentFile='                   ';
end


c_init      = max(1,-5+find(sum(regionBelowLunate>0,1),1,'first'));
r_init      = max(1,-5+find(sum(regionBelowLunate>0,2),1,'first'));
c_fin       = min(cols,5+find(sum(regionBelowLunate>0,1),1,'last'));
r_fin       = min(rows,5+find(sum(regionBelowLunate>0,2),1,'last'));
q           = imdilate((edgesArm+linesArm)>0,ones(15,7));
linesMeasurement  = imdilate(q,ones(7));
dataOutput(:,:,3) = regionBelowLunate.*(1-linesMeasurement);
dataOutput(:,:,1) = regionBelowLunate.*(1-linesMeasurement)+linesMeasurement*maxIntensity;
dataOutput(:,:,2) = regionBelowLunate.*(1-linesMeasurement);
dataOutput          = dataOutput(max(1,r_init):min(rows2,r_fin),max(1,c_init):min(cols2,c_fin),:)/maxIntensity;
%pad with zeros to shift the image down.
dataOutput         = [zeros(15,size(dataOutput,2),3);dataOutput];

outputLimits        = [c_init c_fin r_init r_fin ];
wristWithLines1     = regionBelowLunate.*(1-q)+q*(maxIntensity*0.9);
wristWithLines      = wristWithLines1(max(1,r_init):min(rows2,r_fin),max(1,c_init):min(cols2,c_fin));





if displayData==1
    
    %     figure
    %
    %     hold off
    %     plot(ProfileVLocs,ProfileValleys,'m*')
    %     hold on
    %     plot(armProfile_max2,'b')
    %     plot(armProfile_min2,'m')
    %     plot(armProfile_mean2,'r')
    %     grid on
    %     axis tight
    %%
    
    %imagesc(dataOutput)
    %%
    figure
    subplot(121)
    imagesc(Xray)
    title(currentFile(13:end),'interpreter','none')
    subplot(122)

    imagesc(wristWithLines)
    %axis (outputLimits)
    colormap gray
    widthAtCM2 = num2str(widthAtCM);
    title(widthAtCM2,'interpreter','none')
    
end

displayResultsLunate        = wristWithLines;
%figure(3)
%imagesc(Xray)
%colormap gray



% cc2                         = 10*round(cols/60);
% rr2                         = 10*round(rows/150);
% % Determine a square region around the landmark of the central finger
% rr                          = round(Xray_maskP(1).Centroid(2))-rr2:round(Xray_maskP(1).Centroid(2))+rr2;
% cc                          = round(Xray_maskP(1).Centroid(1))-cc2:round(Xray_maskP(1).Centroid(1))+cc2;
% rr3                         = round(Xray_maskP(1).Centroid(2))-90:rows-rr2;
% % imagesc(Xray(rr3,cc))
% %
% % Determine the orientation of the arm, select a region of interest based on the
% % lunate and downwards, this should capture ulnea and radius and discard the
% % wrist and the fingers
%
% Xray2                       = double(Xray(rr3,cc));
% % Find the edges, mainly of the bones to determine the orientation
% Xray4                       = edge(Xray2,'canny',[],5);
% % use the hough transform to find strongest lines
% [HoughBones,HoughAngles,HoughDist]  = hough(Xray4,'ThetaResolution',1);
% PeaksHough                  = houghpeaks(HoughBones,5,'threshold',ceil(0.3*max(HoughBones(:))));
% angleRot                    = median(HoughAngles(PeaksHough(:,2)));
%
% Xray5                       = imrotate(Xray2,angleRot);
% Xray44                      = imrotate(Xray4,angleRot);
% XrayR                       = imrotate(Xray,angleRot);
% Xray_maskR                  = imrotate(Xray_mask,angleRot);
% maxIntensity = max(Xray2(:));
% %minIntensity = min(Xray2(:));
%
% otsuLevel   = maxIntensity*(graythresh(Xray2/maxIntensity));
% %    otsuLevel2   = maxIntensity*(graythresh(Xray_Centre/maxIntensity));
% %otsuLevel3   = otsuLevel*0.5;
%
% %Xray3   = imclose(Xray2>(otsuLevel),strel('disk',15));
% % Xray44(:,:,1) = Xray2;
% % Xray44(:,:,2) = Xray2;
% % Xray44(:,:,3) = Xray2.*(1-Xray4);% + Xray4*otsuLevel;
%
% if ~exist('displayData','var')
%     displayData=0;
% end
% if ~exist('currentFile','var')
%     currentFile='                   ';
% end
%
% if displayData==1
%
%     figure
%     subplot(121)
%     %    imagesc(Xray2.*(1-Xray4))
%     imagesc(Xray)
%
%     title(currentFile(13:end),'interpreter','none')
%     %
%     %caxis([minIntensity maxIntensity ])
%
%     %P  = houghpeaks(round(imfilter(HoughBones,gaussF(35,35,1))),3,'threshold',ceil(0.3*max(HoughBones(:))));
%     %angleRot = median(HoughAngles(P(:,2)))
%     %disp([rows cols])
%     subplot(122)
%     %    imagesc(Xray5.*(1-Xray44))
%     imagesc(XrayR)
%     title(num2str(angleRot))
%     colormap gray
% end
% %%
% % Cortical = sum(Xray5)./sum(Xray5>0);
% %
% % rows2                       = size(Xray5,1);
% % cols2                       = numel(Cortical);
% % % Determine position of peaks, valleys and from there the edges of the bone, the
% % % thickness of the cortical bone and the thickness of the marrow.
% % [CorticalPeaks,CorticalPLocs]         = findpeaks(Cortical,'MinPeakDistance',20);
% % [CorticalValleys,CorticalVLocs]       = findpeaks(1-Cortical,'MinPeakDistance',20);
% % CorticalValleys =-CorticalValleys;
% %
% % %
% % % The valley closest to the centre of the bone (cc2) should indicate the the lowest
% % % intensity and centre of marrow, then each way there should be a peak, centre of the
% % %  cortical bone, then a minimum, edge of the bone.
% %
% % [temp1,temp2]               = min(abs(CorticalVLocs-cc2));
% % centValley                  = CorticalValleys(temp2);
% % centValleyLoc               = CorticalVLocs(temp2);
% %
% % % Peak to the left
% % CorticalPeaksL              = CorticalPeaks(CorticalPLocs<centValleyLoc);
% % CorticalPeaksLL              = CorticalPLocs(CorticalPLocs<centValleyLoc);
% %
% % [temp3,temp4]               = max(CorticalPeaksL);
% % leftPeak                    = CorticalPeaks(temp4);
% % leftPeakLoc                 = CorticalPLocs(temp4);
% % %
% % % Peak to the right
% % CorticalPeaksR              = CorticalPeaks(CorticalPLocs>centValleyLoc);
% % CorticalPeaksRL              = CorticalPLocs(CorticalPLocs>centValleyLoc);
% %
% % [temp5,temp6]               = max(CorticalPeaksR);
% % rightPeak                    = CorticalPeaksR(temp6);
% % rightPeakLoc                 = CorticalPeaksRL(temp6);
% %
% % % Edge to the left
% % [temp7]                     = find(CorticalVLocs<leftPeakLoc,1,'last');
% % leftEdge                    = CorticalValleys(temp7);
% % leftEdgeLoc                 = CorticalVLocs(temp7);
% %
% % % Edge to the right
% % [temp8]                         = find(CorticalVLocs>rightPeakLoc,1,'first');
% % rightEdge                       = CorticalValleys(temp8);
% % rightEdgeLoc                    = CorticalVLocs(temp8);
% %
% % % area cortical is all above the average between central and peaks
% % CorticalThresholdC               = mean([mean([rightPeak leftPeak]) centValley]);
% % CorticalThresholdL               = mean([leftPeak leftEdge]);
% % CorticalThresholdR               = mean([rightPeak rightEdge]);
% %
% % Xray5LPF                        = imfilter(Xray5,gaussF(7,3,1));
% %
% % CorticalBoneC                    = Xray5LPF>CorticalThresholdC;
% % CorticalBoneL                    = Xray5LPF>CorticalThresholdL;
% % CorticalBoneR                    = Xray5LPF>CorticalThresholdR;
% %
% %
% % CorticalBoneC(:,centValleyLoc)   = 0;
% % CorticalBoneL(:,leftPeakLoc:end)   = 0;
% % CorticalBoneR(:,1:rightPeakLoc)   = 0;
% %
% % CorticalBone0                   = ((CorticalBoneC+CorticalBoneL+CorticalBoneR)>0);
% % CorticalBone1                   = bwlabel(CorticalBone0);
% % CorticalBone1P                  = regionprops(CorticalBone1,'Area');
% % [temp9,temp10]                  = sort([CorticalBone1P.Area]);
% % CorticalBone2                   = ismember(CorticalBone1,temp10(end));
% % CorticalBone3                   = ismember(CorticalBone1,temp10(end-1));
% %
% % CorticalBone4                    = imclose(CorticalBone2,ones(8,8));
% % CorticalBone5                    = imclose(CorticalBone3,ones(8,8));
% %
% % CorticalBone                    = CorticalBone4 + CorticalBone5;
% % CorticalBone(:,centValleyLoc)   = 0;
% %
% %
% % %
% % TrabecularBone                 = imclose(CorticalBone,strel('line',5+rightPeakLoc-leftPeakLoc,angleRot))-CorticalBone;
% % TrabecularBone                 = imopen(TrabecularBone,ones(2,1));
% % Combined(:,:,3)                = Xray5/max(Xray5(:));
% % Combined(:,:,2)                = Xray5/max(Xray5(:)).*(1-TrabecularBone)+Xray5/max(Xray5(:)).*(0.79999*TrabecularBone);
% % Combined(:,:,1)                = Xray5/max(Xray5(:)).*(1-CorticalBone)+Xray5/max(Xray5(:)).*(0.79999*CorticalBone);
% %
% % TrabecularArea                  = sum(TrabecularBone(:));
% % CorticalArea                    = sum(CorticalBone(:));
% % TrabecularToTotal               = TrabecularArea/(TrabecularArea+CorticalArea);
% % %
% % %
% % % figure(2)
% % % hold off
% % % imagesc(Xray5)
% % % caxis([minIntensity maxIntensity ])
% % % hold on
% % % line([leftEdgeLoc leftEdgeLoc],[1 rows2],'color','m')
% % % line([rightEdgeLoc rightEdgeLoc],[1 rows2],'color','m')
% % % line([rightPeakLoc rightPeakLoc],[1 rows2],'color','c')
% % % line([leftPeakLoc leftPeakLoc],[1 rows2],'color','c')
% % % line([centValleyLoc centValleyLoc],[1 rows2],'color','r')
% %
% %
% % % figure(3)
% % % hold off
% % % plot(mean(Xray2(:,:)))
% % % hold on
% % % plot(1:cols2,Cortical,'b',CorticalPLocs,CorticalPeaks,'ro',CorticalVLocs,CorticalValleys,'m*')
% % % grid on
% % % axis tight
% % %
% % %
% % figure(1)
% % subplot(131)
% % hold off
% % imagesc(Xray)
% % hold on
% % title(currentFile(13:end),'interpreter','none')
% %
% % line([cc(1) cc(1)],[rr(1) rr(end)],'linewidth',2 )
% % line([cc(end) cc(end)],[rr(1) rr(end)],'linewidth',2 )
% % line([cc(1) cc(end)],[rr(end) rr(end)],'linewidth',2 )
% % line([cc(1) cc(end)],[rr(1) rr(1)],'linewidth',2 )
% % subplot(132)
% % imagesc(Xray2)
% % colormap gray
% %
% % subplot(133)
% % hold off
% % imagesc(Combined)
% %
% % hold on
% % line([leftEdgeLoc leftEdgeLoc],[1 rows2],'color','m')
% % line([rightEdgeLoc rightEdgeLoc],[1 rows2],'color','m')
% % line([rightPeakLoc rightPeakLoc],[1 rows2],'color','c')
% % line([leftPeakLoc leftPeakLoc],[1 rows2],'color','c')
% % line([centValleyLoc centValleyLoc],[1 rows2],'color','r')
% % title(strcat('Ratio of Trabecular:',num2str(TrabecularToTotal)))
% % %
% %
