function   [dataOut,dataOut2] = extract_measurements_xray(currentFile)


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

%     
%     % Collect all the metrics extracted
%     % First the number of the patient
%     results(k,1)                    = str2double(currentFile(initANON:finANON));
%     % Now metrics that come from the DICOM file
%     
%     % Age, the field is not always present
    if isfield(Xray_info,'PatientAge')
        age = str2double(Xray_info.PatientAge(1:end-1));
    else
        % rough calculation of the age based on dates
        age = (str2double(Xray_info.StudyDate(1:4))-str2double(Xray_info.PatientBirthDate(1:4)) + ...
            (str2double(Xray_info.StudyDate(5:6))-str2double(Xray_info.PatientBirthDate(5:6)))/12 + ...
            (str2double(Xray_info.StudyDate(7:8))-str2double(Xray_info.PatientBirthDate(7:8)))/365 );
    end
%     results(k,2)=round(age);
    % Gender Female - 1, Male - 0
    if isfield(Xray_info,'PatientSex')
        if strcmp(Xray_info.PatientSex,'M')
            gender                     = 0;
        else
            gender                     = 1;
        end
    else
        gender                     = -1;
    end


dataOut2 = [age gender TrabecularToTotal WidthFinger  widthAtCM/widthAtCM(4) ...
            stats.slope_1 stats.slope_2 stats.slope_short_1 stats.slope_short_2 ...
            stats.std_1 stats.std_2 stats.std_ad_1 stats.std_ad_2 stats.row_LBP stats.col_LBP ...
            LBP_Features];
        
dataOut.age                 = age;
dataOut.gender              = gender;
dataOut.TrabecularToTotal   = TrabecularToTotal;
dataOut.WidthFinger         = WidthFinger;
dataOut.stats               = stats;
dataOut.LBP_Features        = LBP_Features;
dataOut.widthAtCM           = widthAtCM;
dataOut.inflamationLimits   =inflamationLimits;        