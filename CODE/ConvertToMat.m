clear all;
close all;

%%
baseDir = 'C:\Users\aczf102\Documents\MATLAB\Data\Patients';
dir0    = dir(strcat(baseDir,filesep,'T*'));
t = size(dir0);


for i=1:size(dir0)
    % loop over folder like PAT1
    dir1    = dir(strcat(baseDir,filesep,dir0(1).name,filesep,'P*'));
    t1=size(dir1);
    
    for j=i:size(dir1)
        % loop over folder like STD1
        dir2 = dir(strcat(baseDir,filesep,dir0(1).name,filesep,'P*',filesep,'ST*'));
        
        for k=j:size(dir2)
            %loop over folder like SER1
            dir3    = dir(strcat(baseDir,filesep,dir0(1).name,filesep,'P*',filesep,'ST*',filesep,'SER*'));
            dataSize = size(dir3,1);
            for m=k:size(dir3)
                %identify dicom file name in each folder
                dir4=dir(strcat(baseDir,filesep,dir0(1).name,filesep,'P*',filesep,'ST*',filesep,'SER*',filesep,'I*'));
                % read dicom image and create empty mask
                readDicom=dicomread(dir4(m).name);
                infoDicom=dicominfo(dir4(m).name);
                maskDicom=zeros(size(readDicom));
                %maskDicom=double.empty;  %other alternatif mask 
                %disp(strcat(dir0(k).name,'/'dir1(k1).name,'/',dir2(k2).name,etc
            end
            % convert into .mat file
            %save(['C:\Users\aczf102\Documents\MATLAB\DICOM_Karen_ANDUpdate\Tes4_' infoDicom.PatientID '_' infoDicom.SeriesDescription],'readDicom','infoDicom','maskDicom');
            save('C:\Users\aczf102\Documents\MATLAB\DICOM_Karen_ANDUpdate\Tes4','readDicom','infoDicom','maskDicom');
            imagesc(readDicom)
        end
    end
end