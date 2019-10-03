function Xray6 = removeEdgesCollimator2(Xray,sizeDilation)


if ~exist('sizeDilation','var')
    sizeDilation = 25;
end

%% Detect the regions of zero, and erode
Xray_NonZero            = Xray>0;
% The majority of cases are surrounded by a regions of zeros and even the darkest
% pixels of the X-ray are above zero, however, there may be cases when the image
% itself has zeros, this method does not work in those cases.

% First of all, check how many regions are above 0, if there is only one, fine,
% proceed

q=regionprops(Xray_NonZero,'solidity');
numRegs = size(q,1);

if numRegs>1
    Xray_NonZeroF           = imfill(Xray_NonZero,'holes');
    Xray_NonZeroL           = bwlabel(Xray_NonZeroF);
    
    q2=regionprops(Xray_NonZeroL,'solidity','Area');
    numRegs2 = size(q2,1);
    %disp([numRegs  numRegs2 mean([q2.Solidity]) ])
    
    if numRegs2>1
        % Find the largest, discard all the rest and close that
        [q3,q4]=max([q2.Area]);
        Xray_NonZeroLarge       = (Xray_NonZeroL==q4);
        Xray_NonZeroF           =imclose(Xray_NonZeroLarge,strel('disk',75));
        
        %imagesc(Xray_NonZeroF)

    end
else
    Xray_NonZeroF = Xray_NonZero;
end



Xray_NonZeroD           = imerode(Xray_NonZeroF,ones(sizeDilation));
Xray6                   = Xray.*Xray_NonZeroD;




