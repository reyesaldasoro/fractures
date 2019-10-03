function   dataOut = extract_measurements_xray(currentFile)


if  isa(currentFile,'char')
    % current file is a file name
    currentData                     = load(currentFile);
elseif isa(currentFile,'struct')
    % current file is a struct with the input data
    currentData                     = currentFile;
end

% allocate to current variables that will be used for saving later on
Xray                            = currentData.Xray;
Xray_info                       = currentData.Xray_info;
Xray_mask                       = currentData.Xray_mask;

displayData =0;

% Analyse the parameters to extract separately, in all cases the input will be
% the rotated Xray and the mask for the landmarks and the DICOM Info.
% Additionally the name of the file is passed in case it is used to display, the
% fourth parameter 1/0 is used to indicate display (1) or not (0)

% First step, rotate the xray and the mask if necessary, return the angle and
% rotations
[XrayR,Xray_maskR,angleRot]     = alignXray (Xray,Xray_mask,currentFile,displayData);

% Determine the ratio of trabecular / cortical to total bone in a region of the
% central finger
[TrabecularToTotal,WidthFinger] = analyseLandmarkFinger (XrayR,Xray_maskR,Xray_info,currentFile,displayData);

% Determine two profiles from the radial styloid to the edge of the radius at 30
% and 45 degrees below the line between the radial styloid and the lunate
[stats,profile_rad_1,profile_rad_2]   = analyseLandmarkRadial (XrayR,Xray_maskR,Xray_info,currentFile,displayData);

% Determine the profiles of bones and arm below the lunate to distinguish
% inflammation of the arm, but first remove the edges of the collimator
XrayR2                          = removeEdgesCollimator2(XrayR,70);
[AreaInflammation,widthAtCM,inflammationLines,inflamationLimits]    = analyseLandmarkLunate (XrayR2,Xray_maskR,Xray_info,currentFile,displayData);
%set(gcf,'position',[321         381        1000         400]);

% Add the texture analysis previously done by Greg and Julia select automatically
% a point drawn from the profiles
sizeInMM                        = [5, 5];
[LBP_Features,PatchSelected]    = ComputeLBPInPatch(XrayR,Xray_info,stats.row_LBP,stats.col_LBP+50,sizeInMM,displayData);

dataOut.TrabecularToTotal   = TrabecularToTotal;
dataOut.WidthFinger         = WidthFinger;
dataOut.stats               = stats;
dataOut.LBP_Features        = LBP_Features;
dataOut.widthAtCM           = widthAtCM;
dataOut.inflamationLimits   =inflamationLimits;