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
   


%% Complete directories with folders
% Move the to folder where the DICOM files are stored.

XrayDir             = dir('D*/*/*/P*/S*/S*/I*');
numXrays            = size(XrayDir,1);

%NormalDir           = dir('Normals/N*/P*/S*/S*/I*');
%PatientDir          = dir('Patients/T*/P*/S*/S*/I*');
%numNormal           = size(NormalDir,1);
%numPatient          = size(PatientDir,1);


% Important Fields: 
%       Xray_info.PatientID             anonimised value e.g. ANON3505
%       Xray_info.PhotometricInterpretation  
%                                       'MONOCHROME2', 'MONOCHROME1' white
%                                       or black background
%       Xray_info.PatientBirthDate      e.g. 19770807
%       Xray_info.BodyPartExamined      HAND, ARM, WRIST, PELVIS, HIP
%       Xray_info.StudyDate             e.g. 20140909
%       Xray_info.PatientAge            036Y  Not always present
%       Xray_info.SeriesDescription     view point, with many options
%                                       Lateral, LATERAL, Lateral Wireless,
%                                       AP, PA, AP Wireless, TWO VIEWS, 
%                                       Wrist AP/LAT, Wrist PA,
%                                       Wrist LAT, HBL (hip beam lateral
%                                       view), DP Wireless, Oblique,
%                                       Forearm AP/LAT, Thumb AP/LAT
%       Xray_info.PatientSex            F, M
%       Xray_info.ViewPosition          PA, AP, RL, LL, LATERAL, ' ', TWO
%                                       VIEWS
%       Xray_info.PatientOrientation    P\H, ' ', A\H, L\H, L\F
%       Xray_info.Laterality            L, R, ' ', sometimes not present
%       Xray_info.PixelSpacing          [0.139000000000000;0.139000000000000]
%       Xray_info.ImagerPixelSpacing    [0.1390,0.1390]
%       Xray_info.PixelAspectRatio      [1,1]
%       Xray_info.Modality              CR (Computed Radiography Reader),
%                                       Dx (Digital)
%       Xray_info.ProtocolName          Wrist R, Wrist L, XR WRIST LT,
%                                       Scaphoid R, XR WRIST RT, Wrists
%                                       Both, Forearm R, WRIST-RIGHT, WRIST
%                                       PA, XR SCAPHOID LT
%       Xray_info.Laterality            L, R, ' ' in some cases is not
%                                       present




XrayDir2 = XrayDir;



%% Read, select and convert if necessary
%for k =1:numNormal % k=10;

CasesKept =[];
CasesNotKept = [];
for k =1:numXrays    
    %disp(k)
    % Determine name based on the folders
    
    %originalName    = strcat(NormalDir(k).folder,'/',NormalDir(k).name);
    %originalName = strcat(PatientDir(k).folder,'/',PatientDir(k).name);
    originalName = strcat(XrayDir(k).folder,'/',XrayDir(k).name);

    % Read the current image and dicom data
    Xray            = double(dicomread(originalName));
    Xray_info       = dicominfo(originalName);
    
    % Invert if necessary to have all with black background
    maxIntensity = max(Xray(:));
    if strcmp(Xray_info.PhotometricInterpretation,'MONOCHROME1')
        Xray = (maxIntensity - Xray);
    end    

    % Prepare the new name using
    %       Normals or Patients
    %       PatientID and SeriesDescription (but
    %       summarised) and only save HAND or WRIST
    
    if contains(originalName,'Normals','IgnoreCase',true)
        DescCase = 'NORMAL';
    else
        DescCase = 'PATIENT';
    end
    
    
    
    if contains(Xray_info.SeriesDescription,'AP/LAT','IgnoreCase',true)
        % Two views, discard
        DescXR =[];
        %disp(strcat(num2str(k),'_',Xray_info.SeriesDescription))
    elseif contains(Xray_info.SeriesDescription,'PA','IgnoreCase',true)
        DescXR = 'PA';
    elseif contains(Xray_info.SeriesDescription,'AP','IgnoreCase',true)
        DescXR = 'PA';
    elseif endsWith(Xray_info.SeriesDescription,'wrist','IgnoreCase',true)&&startsWith(Xray_info.SeriesDescription,'wrist','IgnoreCase',true)
        DescXR = 'PA';        
    elseif contains(Xray_info.SeriesDescription,'LAT','IgnoreCase',true)
        %DescXR = 'LA';
        DescXR =[];
    else 
        % Any other case, discard
        %disp(strcat(num2str(k),'_',Xray_info.SeriesDescription))
        DescXR =[];
    end
        
    switch Xray_info.BodyPartExamined
        % Only cases accepted are HAND, ARM and WRIST
        case 'HAND'
            %disp('1')
        case 'ARM'
            %disp(strcat(num2str(k),'_',originalName))
        case 'EXTREMITY'
            
        case 'WRIST'
            
        case 'FOREARM'
            %disp('3')
        otherwise
            % Any other case, discard
            %disp(strcat(num2str(k),'_',originalName))
            DescXR =[];
    end

    % Discard patients that are younger than 16
    if isfield(Xray_info,'PatientAge')
        age = str2double(Xray_info.PatientAge(1:end-1));
    else
        % rough calculation of the age based on dates
        age = (str2double(Xray_info.StudyDate(1:4))-str2double(Xray_info.PatientBirthDate(1:4)) + ...
            (str2double(Xray_info.StudyDate(5:6))-str2double(Xray_info.PatientBirthDate(5:6)))/12 + ...
            (str2double(Xray_info.StudyDate(7:8))-str2double(Xray_info.PatientBirthDate(7:8)))/365 );
    end
    if age<16
        DescXR =[];
    end
    
    XrayDir2(k).PatientID                   = Xray_info.PatientID;
    XrayDir2(k).SeriesDescription           = Xray_info.SeriesDescription;
    XrayDir2(k).BodyPartExamined            = Xray_info.BodyPartExamined;
    XrayDir2(k).PhotometricInterpretation   = Xray_info.PhotometricInterpretation;
    XrayDir2(k).PatientAge                  = age;
    
    
    
    if ~isempty(DescXR)
        newName = strcat(Xray_info.PatientID,'_',DescCase,'_',DescXR,'_',num2str(k));
        save(strcat('DICOM_MATLAB/',newName),'Xray','Xray_info')
        disp(newName)
        XrayDir2(k).Keep = 1;
        CasesKept =[CasesKept;[k str2num(Xray_info.PatientID(5:end))]];
    else
        XrayDir2(k).Keep = 0;
        CasesNotKept =[CasesNotKept;[k str2num(Xray_info.PatientID(5:end))]];
    end

end
        
        
