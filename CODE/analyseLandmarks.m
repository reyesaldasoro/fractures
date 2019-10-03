%% Clear all variables and close all figures
clear all
close all
clc
%% Prepare folders
if strcmp(filesep,'/')
    % Running in Mac
    cd ('/Users/ccr22/OneDrive - City, University of London/Acad/Research/Exeter_Fracture')
else
    % running in windows
    cd ('D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture')
end
%% Read the files that have been stored in the current folder
baseDir                             = 'DICOM_Karen/';
%XrayDir                            = dir('DICOM_MATLAB/*_PA_*.mat');
CXrayDir                            = dir(strcat(baseDir,'*_PA_*.mat'));
numXrays                            = size(CXrayDir,1);


%% Read the file, this can be done iteratively by changing "k"
results(numXrays,30)=0;
displayData =0;
for k=31:40%:numXrays
    try
    %k=19;
    clear stats
    disp(k)
    currentName                     = CXrayDir(k).name;
    currentFile                     = strcat(baseDir,currentName);
    
    [qq,qq2]                        = extract_measurements_xray(currentFile);
    results(k,:)                    = qq2; 

    initANON                        = 4+strfind(currentName,'ANON');
    finANON                         = strfind(currentName,'_')-1;
    CaseANON                        = str2double(currentName(initANON:finANON));
    
%     
%     % Collect all the metrics extracted
%     % First the number of the patient
%     results(k,1)                    = str2double(currentFile(initANON:finANON));
%     % Now metrics that come from the DICOM file
%     
%     % Age, the field is not always present
%     if isfield(Xray_info,'PatientAge')
%         age = str2double(Xray_info.PatientAge(1:end-1));
%     else
%         % rough calculation of the age based on dates
%         age = (str2double(Xray_info.StudyDate(1:4))-str2double(Xray_info.PatientBirthDate(1:4)) + ...
%             (str2double(Xray_info.StudyDate(5:6))-str2double(Xray_info.PatientBirthDate(5:6)))/12 + ...
%             (str2double(Xray_info.StudyDate(7:8))-str2double(Xray_info.PatientBirthDate(7:8)))/365 );
%     end
%     results(k,2)=round(age);
%     % Gender Female - 1, Male - 0
%     if isfield(Xray_info,'PatientSex')
%         if strcmp(Xray_info.PatientSex,'M')
%             results(k,3)                     = 0;
%         else
%             results(k,3)                     = 1;
%         end
%     else
%         results(k,3)                     = -1;
%     end
%     
%     % now all other measurements
%     results(k,12)                    = TrabecularToTotal;
%     results(k,13)                    = WidthFinger;
% 
%     results(k,14)                    = stats.slope_1;  
%     results(k,15)                    = stats.slope_2;
%     results(k,16)                    = stats.slope_short_1;    
%     results(k,17)                    = stats.slope_short_2;
%     results(k,18)                    = stats.std_1;      
%     results(k,19)                    = stats.std_2;
%     results(k,20)                    = stats.std_ad_1;      
%     results(k,21)                    = stats.std_ad_2;
%     results(k,23:22+numel(widthAtCM))= widthAtCM;
%     results(k,31:30+numel(widthAtCM))= widthAtCM./widthAtCM(1);
%     
%     
%     results(k,41:50)                 = stats.LBP_Features;
%     results(k,51:60)                 = stats.LBP_Features./stats.LBP_Features(end);
%     
%    % set(figure(1),'position',[23   496   632   309]);
%    % set(figure(2),'position',[36   183   616   316]);
%    % set(figure(3),'position',[760   544   622   261]);
%    % set(figure(4),'position',[754   195   655   267]);
%     
%      x=input('a');
%      close all
    catch
        
        disp(strcat('error:',num2str(k)))
    end
    
  %  close all
end

%% Allocate Joint Clinical Outcome (successful/unsuccessful MUA)

 load('FracturesXray_FileDirectory_2018_03_26.mat')
numXrays                            = size(results,1);
for k=1:numXrays
    
    patientID       = results(k,1);
    tempValue       =([XrayDir3.PatientID2]==patientID);
    if sum(tempValue)>=1
        caseXray    = find(tempValue);
        if ~isempty(XrayDir3(caseXray(1)).JointClinicalOutcome)
            results(k,4) = XrayDir3(caseXray(1)).JointClinicalOutcome;
        else
            results(k,4) = -1;
        end
    end
end
%%
k1=23;k2=18;
men=find(results(:,3)==0);
women=find(results(:,3)==1);

hold off
scatter3(results(men,4),results(men,k1),results(men,k2),'markeredgecolor','r')
hold on
scatter3(results(women,4),results(women,k1),results(women,k2),'markeredgecolor','b')

%%

%%
k1=20;k2=13;
Suc     =find(results(:,4)==1);
Unsuc   =find(results(:,4)==0);

hold off
scatter3(results(Suc,2),results(Suc,k1),results(Suc,k2),'markeredgecolor','r')
hold on
scatter3(results(Unsuc,2),results(Unsuc,k1),results(Unsuc,k2),'markeredgecolor','b')
[h,p,ci]=ttest2(results(Suc,k1),results(Unsuc,k1));
title(num2str(p))
