clear
try
    cd('D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture')
catch
    cd('C:\Users\sbbk034\OneDrive - City, University of London\Acad\Research\Exeter_Fracture')
end
load statsGenAge

%% Prepare the stats for the figures
for k=1:5
    temp = statsGenAge(statsGenAge(:,1)==k,3);
    tot(k,:) = [ sum(temp) sum(1-temp)];
end

%%
h0=figure;
h0.Position=[    204   294   843   353];

%%
h1=subplot(121);
boxplot(statsGenAge(:,2),statsGenAge(:,1))
grid on
h1.XTickLabel={'Pre-successful','Pre-unsuccessful','Post-successful','Post-unsuccessful','Control'};
h1.XTickLabelRotation   = 40;
h1.YLabel.String        = 'Age ';

 h1.FontSize=12;
%
h2= subplot(122);
h2B = bar(tot,'stacked');
grid on
legend('Female','Male')
h2.XTickLabel={'Pre-successful','Pre-unsuccessful','Post-successful','Post-unsuccessful','Control'};
h2.XTickLabelRotation=40;
h2.FontSize=12;
% pre-successful (n=50), pre-unsuccessful (n=31), post-successful50(n=40), post-unsuccessful (n=18). Control
% n(22)


h2.YLabel.String        = 'Num Participants';
h2.YLabel.FontSize      = 16;
h1.YLabel.FontSize      = 16;
%%
h2B(1).FaceColor=[0    0.247    0.541]; %[1 0.61 0.4];
h2B(2).FaceColor=[0.95    0.425    0.298] ;%[0.1 0.2 0.61];
h2B(2).FaceAlpha=0.7;


%%
h1.Position=[ 0.08    0.32    0.41    0.66];
h2.Position=[ 0.57    0.32    0.41    0.66];


%%
filename = 'Fig_statsGenAge.tif';
print ('-dtiff','-r400',filename);
%%
filename = 'Fig_statsGenAge.png';
print ('-dpng','-r400',filename);


