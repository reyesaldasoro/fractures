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
%% Allocate Joint Clinical Outcome (successful/unsuccessful MUA and PRE / POST)
Pre_0   = [8845	8849	8853	8861	8865	8869	8873	8881	8893	8897	8909	8917	8921	8923	8929	8937	8945	8949	8953	8957	8965	8969	8973	8977	8989	8993	9001	9029	9057	9131	9135	9139	9151	9155	9159	9167	9179	9183	9191	9203	9207	9215	9219	9223	9243	9251	9259	9263	9267	9271	9279	9291	9295	9299	9319	9327	9343	9347	9355	9359	9363	9367	9385	9393	9397	9401	9413];
Pre_1	= [8857	8885	8901	8905	8913	8933	8941	8981	8985	8997	9013	9017	9021	9025	9033	9037	9049	9053	9143	9147	9163	9171	9187	9195	9199	9211	9227	9235	9239	9249	9275	9287	9303	9307	9311	9315	9323	9331	9335	9339	9351	9381	9389	9405	9409																				];
Post_0	= [8847	8851	8855	8863	8867	8871	8875	8883	8895	8899	8911	8919	8925	8927	8931	8939	8947	8951	8955	8959	8967	8971	8975	8979	8991	8995	9003	9031	9133	9137	9141	9153	9157	9161	9169	9181	9185	9193	9205	9209	9217	9221	9225	9245	9253	9261	9265	9269	9273	9281	9293	9297	9301	9321	9329	9345	9349	9361	9365	9369	9387	9395	9399	9403	9415		];
Post_1	= [8859	8887	8903	8907	8915	8935	8943	8983	8987	8999	9015	9019	9023	9027	9035	9039	9051	9055	9145	9149	9165	9173	9189	9197	9201	9213	9229	9237	9241	9277	9289	9305	9309	9313	9317	9325	9333	9337	9341	9353	9383	9391	9407	9411																						];
Norm    = [9737 9753 9759 9761 9765 9773 9777  10171 10179 10185 10191 10195 10201 10207 10211 10217 10219 10227 10229 10233 10239 10241 ];

maxCases = max([numel(Pre_0) numel(Pre_1) numel(Post_0) numel(Post_1) numel(Norm)]);

Pre_1(maxCases)=0;
Post_1(maxCases)=0;
Post_0(maxCases)=0;
Norm(maxCases)=0;

AllCasesANON = [Pre_0;Pre_1;Post_0;Post_1;Norm];

%% Read the file, this can be done iteratively by changing "k"
clear results
numResults              = 39;
results(numXrays,numResults)    = 0;
displayData             = 0;
done                    = [];
remaining               = [];
for k=   1:numXrays
    try
        %
        %k=174;
        
        currentName                     = CXrayDir(k).name;
        currentFile                     = strcat(baseDir,currentName);
        
        saveName                        = strcat('DICOM_Results/',currentName(1:end-3),'jpg');
        
        initANON                        = 4+strfind(currentName,'ANON');
        finANON                         = strfind(currentName,'_')-1;
        CaseANON                        = str2double(currentName(initANON:finANON));
        
        [x,y]                           = find(CaseANON==AllCasesANON(:,:));
        %
        if ~isempty(x)
            disp([k CaseANON x y])
           % [dataOut,qq2,displayResults]                        = extract_measurements_xray(currentFile);
           % results(k,:)                    = [qq2 x];
            
            done=[done;k CaseANON x y];
           % figure;             displayXrayMetrics(displayResults,dataOut)
           % print(saveName,'-djpeg')
           % close all;
            
        else
            %disp([k CaseANON ])
            remaining=[remaining;k CaseANON];
            
        end
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
        
    catch
        
        disp(strcat('error:',num2str(k)))
    end
    
    %  close all
end

%%
Pre_0_done = done(done(:,3)==1,2)';
Pre_1_done = done(done(:,3)==2,2)';
Post_0_done = done(done(:,3)==3,2)';
Post_1_done = done(done(:,3)==4,2)';
Pre_0_done(67)=0;
Pre_1_done(67)=0;
Post_0_done(67)=0;
Post_1_done(67)=0;

AllCasesANON_done = [Pre_0_done;Pre_1_done;Post_0_done;Post_1_done];
%%
% calculate p values
statDifference(2,numResults) = 0;

for kk=3:numResults
    [h,p,ci,stats] = ttest2(results(results(:,numResults)==1,kk),results(results(:,numResults)==2,kk));
    statDifference(1,kk)=p;
    [h,p,ci,stats] = ttest2(results(results(:,numResults)==3,kk),results(results(:,numResults)==4,kk));
    statDifference(2,kk)=p;
    [h,p,ci,stats] = ttest2(results(results(:,numResults)==5,kk),results( (results(:,numResults)>0)&(results(:,numResults)<5)  ,kk));
    statDifference(3,kk)=p;
    
end
save results_2019_10_11 results statDifference numResults
%%
kk=4;
case1 = 1;
case2 = 2;

boxplot([results(results(:,numResults)==case1,kk);results(results(:,numResults)==case2,kk)],[results(results(:,numResults)==case1,numResults);results(results(:,numResults)==case2,numResults)])
title (strcat('Metric= ',num2str(kk),', p= ',num2str(statDifference(case2/2,kk))));
%%
plot(3:numResults-1,statDifference(1,3:end-1),'b-o',3:numResults-1,statDifference(2,3:end-1),'r-x',3:numResults-1,statDifference(3,3:end-1),'m--d',[1 numResults],[0.05 0.05],'k-');grid on
legend({'Pre 0 v 1','Post 0 v 1','Norm v pat'})
xlabel('Number Metric')
ylabel('p-value')
%%
nameMetrics{1}=         'CaseANON';
nameMetrics{2}='age';
nameMetrics{3}='gender';
nameMetrics{4}='TrabecularToTotal';
nameMetrics{5}='WidthFinger';
nameMetrics{6}='widthAtCM/widthAtCM(4)';
nameMetrics{7}='widthAtCM/widthAtCM(4)';
nameMetrics{8}='widthAtCM/widthAtCM(4)';
nameMetrics{9}='widthAtCM/widthAtCM(4)';
nameMetrics{10}='widthAtCM/widthAtCM(4)';
nameMetrics{11}='widthAtCM/widthAtCM(4)';
nameMetrics{12}='widthAtCM/widthAtCM(4)';
nameMetrics{13}='widthAtCM/widthAtCM(4)';
nameMetrics{14}='min(widthAtCM)/max(widthAtCM)'; 
nameMetrics{15}='(widthAtCM(1)+widthAtCM(8))/(widthAtCM(4)+widthAtCM(5))'; 
nameMetrics{16}='(widthAtCM(1)+widthAtCM(2))/(widthAtCM(7)+widthAtCM(8))';
nameMetrics{17}='stats.slope_1'; 
nameMetrics{18}='stats.slope_2'; 
nameMetrics{19}='stats.slope_short_1'; 
nameMetrics{20}='stats.slope_short_2'; ...
nameMetrics{21}='stats.std_1'; 
nameMetrics{22}='stats.std_2'; 
nameMetrics{23}='stats.std_ad_1';
nameMetrics{24}='stats.std_ad_2 ';
nameMetrics{25}='stats.row_LBP'; 
nameMetrics{26}='stats.col_LBP';
nameMetrics{27}='LBP_Features';
nameMetrics{28}='LBP_Features';
nameMetrics{29}='LBP_Features';
nameMetrics{30}='LBP_Features';
nameMetrics{31}='LBP_Features';
nameMetrics{32}='LBP_Features';
nameMetrics{33}='LBP_Features';
nameMetrics{34}='LBP_Features';
nameMetrics{35}='LBP_Features';
nameMetrics{36}='LBP_Features';
nameMetrics{37}='distance of the profiles';
nameMetrics{38}='distance of the profiles';



%%


kk=3;
case1 = 1;
case2 = 3;

boxplot(results(results(:,numResults)>0,kk), results(results(:,numResults)>0,numResults));
title (strcat('Metric= ',num2str(kk),'; ',32,32,nameMetrics{kk},',  p= ',num2str(statDifference(case2,kk))),'interpreter','none');
grid on
set(gca,'XTickLabel',{'Pre_0','Pre_1','Post_0','Post_1','Norm'})
filename=strcat('Box_Metric_',num2str(kk),'.png');

%%
%  load('FracturesXray_FileDirectory_2018_03_26.mat')
% numXrays                            = size(results,1);
% for k=1:numXrays
%
%     patientID       = results(k,1);
%     tempValue       =([XrayDir3.PatientID2]==patientID);
%     if sum(tempValue)>=1
%         caseXray    = find(tempValue);
%         if ~isempty(XrayDir3(caseXray(1)).JointClinicalOutcome)
%             results(k,4) = XrayDir3(caseXray(1)).JointClinicalOutcome;
%         else
%             results(k,4) = -1;
%         end
%     end
% end
% %%
% k1=23;k2=18;
% men=find(results(:,3)==0);
% women=find(results(:,3)==1);
%
% hold off
% scatter3(results(men,4),results(men,k1),results(men,k2),'markeredgecolor','r')
% hold on
% scatter3(results(women,4),results(women,k1),results(women,k2),'markeredgecolor','b')
%
% %%
%
% %%
% k1=20;k2=13;
% Suc     =find(results(:,4)==1);
% Unsuc   =find(results(:,4)==0);
%
% hold off
% scatter3(results(Suc,2),results(Suc,k1),results(Suc,k2),'markeredgecolor','r')
% hold on
% scatter3(results(Unsuc,2),results(Unsuc,k1),results(Unsuc,k2),'markeredgecolor','b')
% [h,p,ci]=ttest2(results(Suc,k1),results(Unsuc,k1));
% title(num2str(p))
