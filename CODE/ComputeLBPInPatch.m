function [LBP_features, displayResultsLBP] = ComputeLBPInPatch(Xray,Xray_info,Xray_mask,x, y, sizeInMM,displayData)

%[LBP_Features,displayResultsLBP]    = ComputeLBPInPatch(XrayR,Xray_info,stats.row_LBP-40,stats.col_LBP+50,sizeInMM,displayData);


% % Load the image and get header
% I = dicomread(filename);
% info = dicominfo(filename);

% Flip image intensities if needed
% if (strcmp(Xray_info.PhotometricInterpretation, 'MONOCHROME1'))
%     Xray = max(Xray(:)) - Xray;
% end

% Locate the mask, and the centroids of the landmarks
Xray_maskP          = regionprops(Xray_mask,'Area','Centroid');


% Trace a line between the lunate and the radial styloid and then one at 20,40 degrees down
% Determine the x,y (or rows,cols) location of lunate and radial styloid
c_lunate                = Xray_maskP(1).Centroid(1); % (1),(1)
c_radial                = Xray_maskP(2).Centroid(1); % (2),(1)
%Move the mark closer towards the centre.
if c_lunate>c_radial
    x = x-40;
else
    x = x-40;
end


% Get a patch (in pixels) based on the size in mm
spacing             = Xray_info.ImagerPixelSpacing;
sizeInPixels        = round(sizeInMM ./ spacing');
Wx                  = sizeInPixels(1);
Wy                  = sizeInPixels(2);
r_Init              = y-Wy;
r_Fin               = y+Wy;
c_Init              = x-Wx;
c_Fin               = x+Wx; 
PatchExtracted      = Xray(y-Wy:y+Wy,x-Wx:x+Wx);

Xray_out            = double(Xray) / double(max(Xray(:)));
Xray_out(r_Init:r_Init+15,c_Init:c_Fin)  =1;
Xray_out(r_Fin-15:r_Fin,c_Init:c_Fin)    =1;
Xray_out(r_Init:r_Fin,c_Init:c_Init+15)  =1;
Xray_out(r_Init:r_Fin,c_Fin-15:c_Fin)  =1;

% Get LBP features on patch
LBP_features        = extractLBPFeatures(uint16(PatchExtracted), 'Upright', false);

displayResultsLBP.Xray_out          = Xray_out;
displayResultsLBP.PatchExtracted      = PatchExtracted;

% Show image
if (displayData)
    figure;
    subplot(121)
    imagesc(double(Xray) / double(max(Xray(:))));
    colormap gray
    title(Xray_info.PatientID);
    hold on;
    %    scatter (x, y);
    plot(x,y,'ro','markersize',9,'linewidth',2)
    plot(x,y,'rx','markersize',9,'linewidth',2)
    % Show patch
    subplot(222)
    imshow(double(PatchExtracted) / double(max(Xray(:))));
    title('Extracted patch');
    subplot(224)
    bar(LBP_features)
    axis tight
    grid on
end


end

