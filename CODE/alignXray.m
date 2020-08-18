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
%in some cases of rotation, a landmark disappears, dilate and erode
Xray_maskR                  = imrotate(imdilate(Xray_mask,ones(3)),angleRot);
Xray_maskR2                  = bwmorph(Xray_maskR,'shrink','inf');
Xray_maskR                  = Xray_maskR2.*Xray_maskR;

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
elseif displayData==2
    
    sizeFont = 13;
    h1=subplot(231);
    imagesc(Xray)
    title('(a) Original','fontsize',sizeFont)
    
    h2=subplot(232);
    Xray2B = zeros(size(Xray));
    Xray2B(rr3,cc)=Xray(rr3,cc);
    imagesc(Xray2B)
    title('(b) Bones of forearm','fontsize',sizeFont)
    
    h3=subplot(233);
        Xray2B(rr3,cc)=imdilate(Xray4,ones(7));
    imagesc(Xray2B)
    title('(c) Edges detected','fontsize',sizeFont)
    
    h4=subplot(234);

    [HoughBones,HoughAngles,HoughDist]  = hough(Xray2B,'ThetaResolution',1);
    PeaksHough                  = houghpeaks(HoughBones,5,'threshold',ceil(0.3*max(HoughBones(:))));
    
    lines = houghlines(Xray2B,HoughAngles,HoughDist,PeaksHough,'FillGap',5,'MinLength',27);
    imagesc(Xray2B)
    hold
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    end
    title('(d) Strongest Hough lines','fontsize',sizeFont)
    
%     h4=subplot(234);
%     imagesc(HoughBones)
%     hold
%     plot(PeaksHough(:,2),PeaksHough(:,1),'ro','markersize',9)
%     
%     caxis([0 max(HoughBones(:))/2])
    
    h5=subplot(235);
    imagesc(XrayR)
    title(strcat('(e) Rotation by ',32,num2str(angleRot),32,'^o'),'fontsize',sizeFont)
    
    h6=subplot(236);
    imagesc(XrayR==0)
    title('(f) Region outside Collimator','fontsize',sizeFont)
    
    set(h1,'position',[   0.02    0.51    0.3    0.45]);
    set(h2,'position',[   0.35    0.51    0.3    0.45]);
    set(h3,'position',[   0.68    0.51    0.3    0.45]);
    set(h4,'position',[   0.02    0.01    0.3    0.45]);
    set(h5,'position',[   0.35    0.01    0.3    0.45]);
    set(h6,'position',[   0.68    0.01    0.3    0.45]);
    colormap(gray)
    h1.XTick=[];    h1.YTick=[];
    h2.XTick=[];    h2.YTick=[];
    h3.XTick=[];    h3.YTick=[];
    h4.XTick=[];    h4.YTick=[];
    h5.XTick=[];    h5.YTick=[];
    h6.XTick=[];    h6.YTick=[];


end
%%
