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
%%

load results_2019_11_25

%%
% calculate p values
statDifferencePaper(2,numResults) = 0;

for kk=3:numResults
    % this is healthy v patients
    [h,p,ci,stats] = ttest2(results(results(:,numResults)==5,kk),results( (results(:,numResults)>0)&(results(:,numResults)<5)  ,kk));
    statDifferencePaper(1,kk)=p;
    % This is PRE - Post
    [h,p,ci,stats] = ttest2(results( (results(:,numResults)==1)|(results(:,numResults)==2)   ,kk),results( (results(:,numResults)==3)|(results(:,numResults)==4)  ,kk));
    statDifferencePaper(2,kk)=p;
    % This is MUA - ORIF 
    [h,p,ci,stats] = ttest2(results( (results(:,numResults)==1)|(results(:,numResults)==3)   ,kk),results( (results(:,numResults)==2)|(results(:,numResults)==4)  ,kk));
    statDifferencePaper(3,kk)=p;
    % This is Pre-MUA v Pre ORIF
    [h,p,ci,stats] = ttest2(results(results(:,numResults)==1,kk),results(results(:,numResults)==2,kk));
    statDifferencePaper(4,kk)=p;
    % This is Post-MUA v Post-ORIF
    [h,p,ci,stats] = ttest2(results(results(:,numResults)==3,kk),results(results(:,numResults)==4,kk));
    statDifferencePaper(5,kk)=p;

    % This is Pre-MUA v Post-MUA
    [h,p,ci,stats] = ttest2(results(results(:,numResults)==1,kk),results(results(:,numResults)==3,kk));
    statDifferencePaper(4,kk)=p;
    % This is Pre ORIF v Post-ORIF
    [h,p,ci,stats] = ttest2(results(results(:,numResults)==2,kk),results(results(:,numResults)==4,kk));
    statDifferencePaper(5,kk)=p;
    
    
end
%save results_2019_10_11 results statDifference numResults
%%
kk=4;
case1 = 1;

case2 = 2;

boxplot([results(results(:,numResults)==case1,kk);results(results(:,numResults)==case2,kk)],[results(results(:,numResults)==case1,numResults);results(results(:,numResults)==case2,numResults)])
title (strcat('Metric= ',num2str(kk),', p= ',num2str(statDifferencePaper(case2/2,kk))));
%%
plot(3:numResults-1,statDifferencePaper(1,3:end-1),'b-o',3:numResults-1,statDifferencePaper(2,3:end-1),'r-x',3:numResults-1,statDifferencePaper(3,3:end-1),'m-d',3:numResults-1,statDifferencePaper(4,3:end-1),'k-v',[1 numResults],[0.05 0.05],'k-');grid on
legend({'Pre 0 v 1','Post 0 v 1','Norm v pat','Pre v Post'})

xlabel('Number Metric')
ylabel('p-value')
filename = strcat('group_difference_',datestr(date,'yyyy_mm_dd'));
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


kk=17;
case1 = 1;
case2 = 3;

boxplot(results(results(:,numResults)>0,kk), results(results(:,numResults)>0,numResults));
title (strcat('Metric= ',num2str(kk),'; ',32,32,nameMetrics{kk},',  p= ',num2str(statDifferencePaper(case2,kk))),'interpreter','none');
grid on
set(gca,'XTickLabel',{'Pre_0','Pre_1','Post_0','Post_1','Norm'})
filename=strcat('Box_Metric_',num2str(kk),'.png');


%%


kk=4;
case1 = 1;
case2 = 3;

boxplot(results(results(:,numResults)>0,kk), results(results(:,numResults)>0,numResults));
title (strcat('Metric= ',num2str(kk),'; ',32,32,nameMetrics{kk},',  p= ',num2str(statDifferencePaper(case2,kk))),'interpreter','none');
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
