function    [stats,displayResultsRadial]=analyseLandmarkRadial(Xray,Xray_mask,Xray_info,currentFile,displayData)
%
% Regular dimensions check
[rows,cols,levs]    = size(Xray);

% Locate the mask, and the centroids of the landmarks
Xray_maskP          = regionprops(Xray_mask,Xray,'Area','Centroid','meanIntensity');

if ~isfield(Xray_info,'PixelSpacing')
    Xray_info.PixelSpacing=[    0.1440;     0.1440];
end

% Trace a line between the lunate and the radial styloid and then one at 20,40 degrees down
% Determine the x,y (or rows,cols) location of lunate and radial styloid
r_lunate                = Xray_maskP(1).Centroid(2); % (1),(2)
c_lunate                = Xray_maskP(1).Centroid(1); % (1),(1)
r_radial                = Xray_maskP(2).Centroid(2); % (2),(2)
c_radial                = Xray_maskP(2).Centroid(1); % (2),(1)
r_finger                = Xray_maskP(3).Centroid(2); % (3),(2)
c_finger                = Xray_maskP(3).Centroid(1); % (3),(1)


% Find the slope between landmarks
slope_radial_lunate     = (r_radial-r_lunate)/...
    (c_radial-c_lunate);
slope_finger_lunate     = (r_finger-r_lunate)/...
    (c_finger-c_lunate);

% Calculate the new slopes, 30 and 60 degrees down the sign is used to
% compensate if the radial is to the right or the left of the lunate
dist_radial_lunate_cols  = c_radial-c_lunate;
sign_radial_lunate       = sign(dist_radial_lunate_cols);
slope_radial_new1        = slope_radial_lunate-(sign_radial_lunate)*(30*pi/180);
slope_radial_new2        = slope_radial_lunate-(sign_radial_lunate)*(45*pi/180);

% Determine the new locations along the lines
% When the column is the same as the lunate, sometimes lands inside the bone
% sometimes in between bones, better to extend further and then cut at the edge of
% the bone.
c_new1                   = c_lunate-0.35*dist_radial_lunate_cols;
c_new2                   = c_lunate-0.35*dist_radial_lunate_cols;

% Calculate the new row
r_new1                   = r_radial-(c_radial-c_new1)*tan (slope_radial_new1);
r_new2                   = r_radial-(c_radial-c_new2)*tan(slope_radial_new2);


%                                                                 c1  c2    r1  r2
%[rows_radial_lunate,cols_radial_lunate,c]   =   improfile(Xray,[100 500],[300 500]);plot(c)

[rows_radial_lunate,cols_radial_lunate,prof_radial_lunate]   =   improfile(Xray, ...
    [c_radial,c_lunate],...
    [r_radial,r_lunate]);

[rows_radial_new1,cols_radial_new1,prof_radial_new1]   =   improfile(Xray, ...
    [c_radial,c_new1],...
    [r_radial,r_new1]);

[rows_radial_new2,cols_radial_new2,prof_radial_new2]   =   improfile(Xray, ...
    [c_radial,c_new2],...
    [r_radial,r_new2]);

%
% Find the peaks of the derivatives to determine where the bone ends
% The highest drop corresponds to the edge of the bone, recalculate profiles The
% highest drop of new1 should be at a distance further than the distance to the
% lunate and the drop of new2 should be further than new1

profile1_1                  = imfilter(prof_radial_new1',gaussF(15,1,1),'replicate');
profile1_2                   = diff(profile1_1);
profile1_3                  = profile1_2;
% remove the first part of the signal
profile1_3(1:abs(round(0.7*dist_radial_lunate_cols))) = 0;
[peaks_p1,peaks_p1_L]       = findpeaks(-profile1_3(4:end-3),'SortStr','descend','MinPeakDistance',5);
% If the second peak is strong, and much closer to the region, it may be that the second peak is due to the
% SECOND bone it leaves.
if (peaks_p1(2)>0.5*peaks_p1(1)) && (peaks_p1_L(2)<(-40+peaks_p1_L(1)))
    peaks_p1(1) =[];
    peaks_p1_L(1) = [];
    disp('--- take earlier peak ---');
end

profile2_1                  = imfilter(prof_radial_new2',gaussF(15,1,1),'replicate');
profile2_2                  = diff(profile2_1);
profile2_3                  = profile2_2;
% To find the peak with the bones, it is good to remove the first part of the signal, but not too much
profile2_3(1:abs(round(0.8*dist_radial_lunate_cols))) = 0;
% remove the last part of the signal
profile2_3(round(1.9*(peaks_p1_L(1))):end) = 0;

[peaks_p2,peaks_p2_L]       = findpeaks(-profile2_3(5:end-5),'SortStr','descend','MinPeakDistance',5);



% peaks_p1_L(1),prof_radial_new1(peaks_p1_L(1))
c_new1                      = round(rows_radial_new1(peaks_p1_L(1)));
r_new1                      = round(cols_radial_new1(peaks_p1_L(1)));

%
% figure(10)
% subplot(211)
% hold off
% plot((prof_radial_new1))
% hold on
% plot(peaks_p1_L(1),prof_radial_new1(peaks_p1_L(1)),'b*')
% plot(profile1_1,'r')
% subplot(212)
% plot(profile1_2(4:end-3))
% 
% figure(11)
% subplot(211)
% hold off
% plot((prof_radial_new2))
% hold on
% plot(peaks_p2_L(1),prof_radial_new2(peaks_p2_L(1)),'b*')
% plot(profile2_1,'r')
% subplot(212)
% plot(profile2_2(4:end-3))

%interc_radial_lunate    = r_radial - slope_radial_lunate*c_radial;
%interc_radial_new1       = r_radial - slope_radial_new1*c_radial;


%
[rows_radial_new1,cols_radial_new1,prof_radial_new1]   =   improfile(Xray, ...
    [c_radial,c_new1],...
    [r_radial,r_new1]);

% The highest drop corresponds to the edge of the bone, recalculate profiles
%
% peaks_p1_L(1),prof_radial_new1(peaks_p1_L(1))
c_new2                      = round(rows_radial_new2(peaks_p2_L(1)));
r_new2                      = round(cols_radial_new2(peaks_p2_L(1)));

%
[rows_radial_new2,cols_radial_new2,prof_radial_new2]   =   improfile(Xray, ...
    [c_radial,c_new2],...
    [r_radial,r_new2]);


first_10_1              = mean (prof_radial_new1(1:30));
last_10_1               = mean (prof_radial_new1(end-30:end));
first_10_2              = mean (prof_radial_new2(1:30));
last_10_2               = mean (prof_radial_new2(end-30:end));
mid_50_1                = mean (prof_radial_new1(40:60));
mid_50_2                = mean (prof_radial_new2(40:60));

slope_radial_new1       = (last_10_1-first_10_1)/numel(prof_radial_new1);
slope_radial_new2       = (last_10_2-first_10_2)/numel(prof_radial_new2);
slope_short_new1       = (mid_50_1-first_10_1)/(50-15);
slope_short_new2       = (mid_50_2-first_10_2)/(50-15);


fit_radial_new1         = (linspace(first_10_1,last_10_1,numel(prof_radial_new1)))';
fit_radial_new2         = (linspace(first_10_2,last_10_2,numel(prof_radial_new2)))';

prof2_radial_new1       = prof_radial_new1-fit_radial_new1;
prof2_radial_new2       = prof_radial_new2-fit_radial_new2;

std_new1                = std(prof_radial_new1);
std_new2                = std(prof_radial_new2);
std_fit1                = std(prof2_radial_new1);
std_fit2                = std(prof2_radial_new2);


stats.slope_1           = slope_radial_new1;
stats.slope_2           = slope_radial_new2;

stats.slope_short_1     = slope_short_new1;
stats.slope_short_2     = slope_short_new2;

stats.std_1             = std_new1;
stats.std_2             = std_new2;

stats.std_ad_1          = std_fit1;
stats.std_ad_2          = std_fit2;

stats.row_LBP           = round(rows_radial_new1(100));
stats.col_LBP           = round(cols_radial_new1(100));


% Display the PA Xray from the MATLAB file

% figure
    
% zoom on

if ~exist('displayData','var') displayData=0; end
if ~exist('currentFile','var') currentFile='                   '; end

linesLunate                         = zeros(rows,cols);
linesProfile1                       = zeros(rows,cols);
linesProfile2                       = zeros(rows,cols);
indexLunate                         = sub2ind([rows, cols],round(cols_radial_lunate),round(rows_radial_lunate));
indexProfile1                       = sub2ind([rows, cols],round(cols_radial_new1),round(rows_radial_new1));
indexProfile2                       = sub2ind([rows, cols],round(cols_radial_new2),round(rows_radial_new2));

linesLunate(indexLunate)            = 1;
linesProfile1(indexProfile1)        = 1;
linesProfile2(indexProfile2)        = 1;

sizeDilate                          =7;
linesLunate                         = imdilate(linesLunate,ones(sizeDilate));
linesProfile1                       = imdilate(linesProfile1,ones(sizeDilate));
linesProfile2                       = imdilate(linesProfile2,ones(sizeDilate));


maxIntensity                        = max(Xray(:));


dataOutput(:,:,2) = Xray.*(1-linesLunate)  .*(1-linesProfile1).*(1-linesProfile2)+linesLunate*maxIntensity;
dataOutput(:,:,1) = Xray.*(1-linesProfile2).*(1-linesProfile1).*(1-linesLunate)+linesProfile1*maxIntensity;
dataOutput(:,:,3) = Xray.*(1-linesProfile1).*(1-linesProfile2).*(1-linesLunate)+linesProfile2*maxIntensity;

dataOutput        = dataOutput/maxIntensity;

%imagesc(dataOutput)


if displayData==1
    
    figure
    subplot(121)
    hold off
    displayXrayWithMask
    hold on
    plot(rows_radial_lunate,cols_radial_lunate,'c')
    plot(rows_radial_new1,cols_radial_new1,'r')
    plot(rows_radial_new2,cols_radial_new2,'b')
    title(currentFile(13:end),'interpreter','none')
    
    subplot(222)
    hold off
    plot(prof_radial_new1,'r')
    hold on
    plot(prof_radial_new2,'b')
    %grid on
    %axis tight
    
%    subplot(224)
    grid on
    axis tight
    %ylabel('Intensity 45 deg','fontsize',14)
    %xlabel('Distance from Radial Styloid','fontsize',14)
    ylabel('Intensity 30 (r), 45 (b) deg','fontsize',12)
    xlabel('Distance from Radial Styloid','fontsize',14)

    subplot(224)
    hold off
    plot(prof2_radial_new1,'r')
    hold on
    plot(prof2_radial_new2,'b')
    %grid on
    %axis tight
    
%    subplot(224)
    grid on
    axis tight
    %ylabel('Intensity 45 deg','fontsize',14)
    %xlabel('Distance from Radial Styloid','fontsize',14)
    ylabel('Adj Intensity 30 (r), 45 (b) deg','fontsize',12)
    xlabel('Distance from Radial Styloid','fontsize',14)

    
    %    filename = strcat('Cortical',num2str(k),'.jpg');
    
end
%%
displayResultsRadial.prof_radial_new1       = prof_radial_new1;
displayResultsRadial.prof_radial_new2       = prof_radial_new2;
displayResultsRadial.prof2_radial_new1      = prof2_radial_new1;
displayResultsRadial.prof2_radial_new2      = prof2_radial_new2;
displayResultsRadial.dataOutput           = dataOutput;
% displayResultsRadial.       = ;
% displayResultsRadial.       = ;
% displayResultsRadial.       = ;
% displayResultsRadial.       = ;
% displayResultsRadial.       = ;
