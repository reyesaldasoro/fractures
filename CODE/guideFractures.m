%% Reading DICOM files
% If your data is in DICOM format, you can read into Matlab using the functions dicomread and dicominfo like
% this 

dicom_header = dicominfo('D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture\DICOM\Normals\N1\PAT1\STD1\SER1\IMG0');

dicom_image = dicomread('D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture\DICOM\Normals\N1\PAT1\STD1\SER1\IMG0');

%%
dicom_header

%%
imagesc(dicom_image)
colormap gray
%%

clear
%% 
% If you are going to handle numerous images, it can be convenient to read the dicom and then save in Matlab
% format as a *.mat file. You can save the header and the image into a single file, the image with the name
% "Xray" and the header with the name "Xray_info". Later on you can also add the mask (the three landmarks) as
% "Xray_mask". Then these can be loaded together from one file, e.g.
clear
load('D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture\DICOM_Karen\ANON8865_PATIENT_PA_301.mat')
 
whos
%% Alignment of the forearm
% To rotate the Xray so that the forearm is aligned vertically, use the function alingXray. If you are already
% using a mask, the mask should also be b provided so that it is rotated with the same angle. The actual angle
% of rotation is one output parameter.

[XrayR,Xray_maskR,angleRot]     = alignXray (Xray,Xray_mask);

disp(angleRot)

figure(1)
subplot(121)
imagesc(Xray)
subplot(122)
imagesc(XrayR)

%% Remove lines of collimator
% In case the image has lines due to the collimator and these should be removed, use the function
% removeEdgesCollimator. The function receives the Xray as input, and if desired a second parameter that
% controls the width of the removal, if the default does not work, try increasing it.
load('D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture\DICOM_Karen\ANON8949_PATIENT_PA_594.mat')


XrayR2                          = removeEdgesCollimator2(Xray);
figure(1)
subplot(121)
imagesc(Xray)
subplot(122)
imagesc(XrayR2)


XrayR2                          = removeEdgesCollimator2(Xray,70);
figure(2)
subplot(121)
imagesc(Xray)
subplot(122)
imagesc(XrayR2)
colormap gray


%%

[XrayR,Xray_maskR,angleRot]     = alignXray (Xray,Xray_mask);
XrayR2                          = removeEdgesCollimator2(XrayR,70);

%% Analysis based on the landmark of the radial styloid
% To determine two profiles from the radial styloid to the edge of the radius at 30
% and 45 degrees below the line between the radial styloid and the lunate the function analyseLandmarkRadial
% is used in the following way:
[stats,displayResultsRadial]    = analyseLandmarkRadial (XrayR2,Xray_maskR,Xray_info);

%%
% The results contain values about the lines (slope, standard deviation, etc)
stats

%%
% In addition displayResultsRadial contains the actual profiles of the lines, as well as the data with the
% profiles and the landmarks. You can display displayResultsRadial.dataOut, or use the fourth parameter to
% request the display (the third parameter is the name of the file, in case you are using it)

displayData                     = 1; 
[stats,displayResultsRadial]    = analyseLandmarkRadial (XrayR2,Xray_maskR,Xray_info,[],displayData);



%% Analysis based on the landmark of the lunate
% The landmark of the lunate is used to determine the forearm, and from there delineate the edges of the arm,
% and trace 8 lines that measure the width of the forearm, each at one cm if separation. The widths are
% displayed on the figure when you select to display.
[AreaInflammation,widthAtCM,displayResultsLunate,dataOutput,coordinatesArm]    = analyseLandmarkLunate (XrayR2,Xray_maskR,Xray_info,[],displayData);

%% Analysis of the texture a region of interest 
% A region of interest is detected and the Local Binary Pattern is calculated, the location of the region is
% selected as an intermediate point of the previously located profiles, so these are necessary input
% parameters.
sizeInMM                        = [5, 5];
[LBP_Features,displayResultsLBP]    = ComputeLBPInPatch(XrayR2,Xray_info,Xray_maskR,stats.row_LBP,stats.col_LBP+50,sizeInMM,displayData);


%% Determine the ratio of trabecular / cortical to total bone 
% The analysis of the landmark of the central finger segments the bone according to the trabecular and
% cortical regions and then calculates the ratio.

[TrabecularToTotal,WidthFinger,displayResultsFinger] = analyseLandmarkFinger (XrayR,Xray_maskR,Xray_info,[],displayData);



