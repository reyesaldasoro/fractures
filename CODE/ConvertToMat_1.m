clear all;
close all;

%%
%baseDir = 'C:\Users\aczf102\Documents\MATLAB\Data\Patients';
baseDir     = 'D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture\DICOM';
PatientsDir = strcat(baseDir,filesep,'Patients',filesep);

% read the first folder, use "T" as the first name is always TRANCHE 
dir0    = dir(strcat(PatientsDir,'T*'));
% It is good practice to use longer names than just i,t,j,etc.
numFolders_0 = size(dir0,1);

%%

%
% It is not good idea to use either i,j as variables as these can refer to
% imaginary numbers, better to use names like counter_0
for counter_0=1:numFolders_0
    % loop over folder like PAT1
    disp(strcat('----',PatientsDir,dir0(counter_0).name,'----'))
    dir1                    = dir(strcat(PatientsDir,dir0(counter_0).name,filesep,'P*'));
    numFolders_1            = size(dir1,1);
    for counter_1=1:numFolders_1
        disp(strcat(PatientsDir,dir0(counter_0).name,filesep,dir1(counter_1).name))
    end
end

%     for j=i:size(dir1)
%         % loop over folder like STD1
%         dir2 = dir(strcat(baseDir,filesep,dir0(1).name,filesep,'P*',filesep,'ST*'));
%         
%         for k=j:size(dir2)
%             %loop over folder like SER1
%             dir3    = dir(strcat(baseDir,filesep,dir0(1).name,filesep,'P*',filesep,'ST*',filesep,'SER*'));
%             dataSize = size(dir3,1);
%             for m=k:size(dir3)
%                 %identify dicom file name in each folder
%                 dir4=dir(strcat(baseDir,filesep,dir0(1).name,filesep,'P*',filesep,'ST*',filesep,'SER*',filesep,'I*'));
%                 % read dicom image and create empty mask
%                 readDicom=dicomread(dir4(m).name);
%                 infoDicom=dicominfo(dir4(m).name);
%                 maskDicom=zeros(size(readDicom));
%                 %maskDicom=double.empty;  %other alternatif mask 
%                 %disp(strcat(dir0(k).name,'/'dir1(k1).name,'/',dir2(k2).name,etc
%             end
%             % convert into .mat file
%             %save(['C:\Users\aczf102\Documents\MATLAB\DICOM_Karen_ANDUpdate\Tes4_' infoDicom.PatientID '_' infoDicom.SeriesDescription],'readDicom','infoDicom','maskDicom');
%             save('C:\Users\aczf102\Documents\MATLAB\DICOM_Karen_ANDUpdate\Tes4','readDicom','infoDicom','maskDicom');
%             imagesc(readDicom)
%         end
%     end
% end