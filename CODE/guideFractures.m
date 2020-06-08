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
