


% If points are selected, dilate and add to the mask
if exist('LM_Y','var')
    
    Xray_mask(round(LM_X(1)),round(LM_Y(1)))=1;
    Xray_mask(round(LM_X(2)),round(LM_Y(2)))=2;
    Xray_mask(round(LM_X(3)),round(LM_Y(3)))=3;

    
% else
%     
%     Xray_RGB(:,:,1)     = Xray/max(Xray(:));
%     Xray_RGB(:,:,2)     = Xray/max(Xray(:));
%     Xray_RGB(:,:,3)     = Xray_mask+(Xray/max(Xray(:)));
    
end
if ~exist('sizeDilate','var')
    sizeDilate = 15;
end
clear Xray_mask2 Xray_RGB
    Xray_mask2 = imdilate (Xray_mask,ones(sizeDilate)); 
    Xray2               =  (Xray/max(Xray(:))).*(Xray_mask2==0);
%     Xray_RGB(:,:,1)     = (Xray_mask2==1)+(Xray_mask2~=3).*(Xray/max(Xray(:)));
%     Xray_RGB(:,:,2)     = (Xray_mask2==2)+(Xray_mask2~=3).*(Xray/max(Xray(:)));
%     Xray_RGB(:,:,3)     = (Xray_mask2==3)+(Xray_mask2~=3).*(Xray/max(Xray(:)));
    Xray_RGB(:,:,1)     = (Xray_mask2==1)+(Xray_mask2==4)+Xray2;
    Xray_RGB(:,:,2)     = (Xray_mask2==2)+(Xray_mask2==4)+Xray2;
    Xray_RGB(:,:,3)     = (Xray_mask2==3)+Xray2;

Xray_RGB(Xray_RGB>1)=1;
imagesc(Xray_RGB)
%axis equal
%grid on
colormap gray
if exist('XrayDir','var')
title(XrayDir(k).name,'fontsize',18,'interpreter','none')
end