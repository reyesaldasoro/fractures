%% drawGroundTruthXray
% A routine to select three landmarks on a wrist to process and extract metrics
% Requires the file displayXrayWithMask

clear all
close all
clc

%% Read the files that have been stored in the current folder
% These are Matlab files with the x-rays and the dicom info
baseDir             = 'DICOM_MATLAB/';
% only read the files that have a PA orientation, for other cases remove the PA
XrayDir             = dir(strcat(baseDir,'*_PA_*.mat'));
numXrays            = size(XrayDir,1);



%% Read the file, this can be done iteratively by changing "k"
k=157;
close all
clear               Xray Xray_info Xray_mask Xray_RGB LM_Y LM_X

currentName         = XrayDir(k).name;
currentFile         = strcat(baseDir,currentName);
disp(currentFile)

currentData         = load(currentFile);


% allocate to current variables that will be used for saving later on
Xray                = currentData.Xray;
Xray_info           = currentData.Xray_info;

[rows,cols,levs]    = size(Xray);

% If there is already a mask, read it if not, create with zeros
if isfield(currentData,'Xray_mask')
    Xray_mask       = currentData.Xray_mask;
else
    Xray_mask       = zeros(size(Xray));
end

% Display the PA Xray from the MATLAB file

figure
set(gcf,'Position',[   560   189   838   759]);

displayXrayWithMask
zoom on
% The figure is displayed, you can zoom if necessary


%% Select points,
%       1 - lowest of the lunate,
%       2 - edge of the radial
%       3 - centre of middle finger
[selectPoints]      = input('Select 3 landmark points? (1 - yes/0 - no)');
while selectPoints==1
    
    XL              = get(gca,'xlim');
    YL              = get(gca,'ylim');
    
    Xray_mask       = zeros(size(Xray));
    [LM_Y,LM_X]     = ginput(3);
    displayXrayWithMask;
    if (diff(XL)==cols)&(diff(YL)==rows)
        axis([ 0.9*min(LM_Y) 1.1*max(LM_Y) 0.9*min(LM_X) 1.1*max(LM_X)])
    else
        axis([XL(1) XL(2) YL(1) YL(2)])
    end
    [selectPoints]  = input('Repeat landmark points? (1 - yes/0 - no)');
end



%% Save the new file with the Xray, Xray_info (dicom) and mask
save(currentFile,'Xray','Xray_info','Xray_mask');
clear               Xray Xray_info Xray_mask Xray_RGB LM_Y LM_X rows cols levs XL YL selectPoints drawMask current*
close






