function    [XrayR,Xray_maskR,angleRot]=alignXray(Xray,Xray_mask,currentFile,displayData)

% Regular dimensions check
[rows,cols]            = size(Xray);

% Locate the mask, and the centroids of the landmarks

Xray_maskP                  = regionprops(Xray_mask,Xray,'Area','Centroid','meanIntensity');
%    Xray_maskP2                 = regionprops(imdilate(Xray_mask,ones(70)),Xray,'Area','Centroid','meanIntensity','minIntensity','maxIntensity');

cc2                         = 10*round(cols/60);
rr2                         = 10*round(rows/150);
% Determine a square region around the landmark of the central finger
rr                          = round(Xray_maskP(1).Centroid(2))-rr2:round(Xray_maskP(1).Centroid(2))+rr2;
cc                          = round(Xray_maskP(1).Centroid(1))-cc2:round(Xray_maskP(1).Centroid(1))+cc2;
rr3                         = round(Xray_maskP(1).Centroid(2))-90:rows-rr2;
% imagesc(Xray(rr3,cc))
%
% Determine the orientation of the arm, select a region of interest based on the
% lunate and downwards, this should capture ulnea and radius and discard the
% wrist and the fingers

Xray2                       = double(Xray(rr3,cc));
% Find the edges, mainly of the bones to determine the orientation
Xray4                       = edge(Xray2,'canny',[],5);
% use the hough transform to find strongest lines
[HoughBones,HoughAngles,HoughDist]  = hough(Xray4,'ThetaResolution',1);
PeaksHough                  = houghpeaks(HoughBones,5,'threshold',ceil(0.3*max(HoughBones(:))));
angleRot                    = median(HoughAngles(PeaksHough(:,2)));

% Once the angle of rotation has been determined, Rotate the Xray and the mask
%Xray5                       = imrotate(Xray2,angleRot);
%Xray44                      = imrotate(Xray4,angleRot);
XrayR                       = imrotate(Xray,angleRot);
Xray_maskR                  = imrotate(Xray_mask,angleRot);

if ~exist('displayData','var')
    displayData=0;
end
if ~exist('currentFile','var')
    currentFile='                   ';
end

if displayData==1
    
    figure
    subplot(121)
    %    imagesc(Xray2.*(1-Xray4))
    imagesc(Xray)
    
    title(currentFile(13:end),'interpreter','none')
    %
    %caxis([minIntensity maxIntensity ])
    
    %P  = houghpeaks(round(imfilter(HoughBones,gaussF(35,35,1))),3,'threshold',ceil(0.3*max(HoughBones(:))));
    %angleRot = median(HoughAngles(P(:,2)))
    %disp([rows cols])
    subplot(122)
    %    imagesc(Xray5.*(1-Xray44))
    imagesc(XrayR)
    title(num2str(angleRot))
    colormap gray
end
%%
