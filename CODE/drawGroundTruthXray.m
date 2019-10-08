%drawGroundTruthXray

clear all
close all
clc

%% Read the files that have been stored in the current folder
%baseDir             = 'DICOM_Karen/';
baseDir             = 'DICOM_MATLAB/';
%XrayDir             = dir('DICOM_MATLAB/*_PA_*.mat');
XrayDir             = dir(strcat(baseDir,'*_PA_*.mat'));
numXrays            = size(XrayDir,1);


%% 

Pre_0   =[8845	8849	8853	8861	8865	8869	8873	8881	8893	8897	8909	8917	8921	8923	8929	8937	8945	8949	8953	8957	8965	8969	8973	8977	8989	8993	9001	9029	9057	9131	9135	9139	9151	9155	9159	9167	9179	9183	9191	9203	9207	9215	9219	9223	9243	9251	9259	9263	9267	9271	9279	9291	9295	9299	9319	9327	9343	9347	9355	9359	9363	9367	9385	9393	9397	9401	9413];
Pre_1	=[8857	8885	8901	8905	8913	8933	8941	8981	8985	8997	9013	9017	9021	9025	9033	9037	9049	9053	9143	9147	9163	9171	9187	9195	9199	9211	9227	9235	9239	9249	9275	9287	9303	9307	9311	9315	9323	9331	9335	9339	9351	9381	9389	9405	9409																				];
Post_0	=[8847	8851	8855	8863	8867	8871	8875	8883	8895	8899	8911	8919	8925	8927	8931	8939	8947	8951	8955	8959	8967	8971	8975	8979	8991	8995	9003	9031	9133	9137	9141	9153	9157	9161	9169	9181	9185	9193	9205	9209	9217	9221	9225	9245	9253	9261	9265	9269	9273	9281	9293	9297	9301	9321	9329	9345	9349	9361	9365	9369	9387	9395	9399	9403	9415		];
Post_1	=[8859	8887	8903	8907	8915	8935	8943	8983	8987	8999	9015	9019	9023	9027	9035	9039	9051	9055	9145	9149	9165	9173	9189	9197	9201	9213	9229	9237	9241	9277	9289	9305	9309	9313	9317	9325	9333	9337	9341	9353	9383	9391	9407	9411																						];
Pre_1(67)=0;
Post_1(67)=0;
Post_0(67)=0;
% Cases in the excel file will be stored as a matrix in the following rows
% 1 - Pre-0
% 2 - Pre-1
% 3 - Post -0
% 4 - Post -1
AllCasesANON = [Pre_0;Pre_1;Post_0;Post_1];

AllCasesDone =[8845,8849,8869,8873,8897,8909,8923,8929,8937,8949,8953,8957,8973,8977,8989,9029,9135,9151,9155,9159,9167,9183,9191,9203,9219,9223,9243,9263,9267,9271,9291,9295,9299,9327,9343,9347,9363;8885,8905,8913,8933,8941,8981,8985,9017,9021,9025,9033,9037,9049,9053,9143,9171,9187,9239,9275,9303,9307,9311,9315,9323,9331,9351,0,0,0,0,0,0,0,0,0,0,0;8927,9225,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];



%% Read the file, this can be done iteratively by changing "k"

%
k3=[];
for k2=1:numXrays
    %k=121;
    %currentFile         = strcat('DICOM_MATLAB/',XrayDir(k).name);
    currentName         = XrayDir(k2).name;
    currentFile         = strcat(baseDir,currentName);
    
    initANON                        = 4+strfind(currentName,'ANON');
    finANON                         = strfind(currentName,'_')-1;
    CaseANON                        = str2double(currentName(initANON:finANON));
    % only process if is one of the cases need AND is not already done
    isNeeded            = any(AllCasesANON(3,:)==CaseANON);
    isDone              = any(AllCasesDone(3,:)==CaseANON);
    if isNeeded&(~isDone)
        disp([ k2 CaseANON])
        k3 = [k3;k2];
    end
end

%%
k=k3(1)
close all

    currentName         = XrayDir(k).name;
    currentFile         = strcat(baseDir,currentName);
%
clear               Xray Xray_info Xray_mask Xray_RGB LM_Y LM_X
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
%% Save the new file with the Xray, Xray_info (dicom) and mask


%% Draw mask over a region of interest
% %drawMask =1;
% [drawMask]= input('Draw a mask? (1 - yes/0 - no)');
% while drawMask==1   
%     XL = get(gca,'xlim');
%     YL = get(gca,'ylim');
% 
%     Xray_mask = roipoly();
%     displayXrayWithMask; 
%     axis([XL(1) XL(2) YL(1) YL(2)])
%     [drawMask]= input('Repeat mask? (1 - yes/0 - no)');
% end



