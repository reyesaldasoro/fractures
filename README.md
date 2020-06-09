# Geometric Semi-automatic Analysis of Colles' Fractures



##### Table of Contents  

[Colles' Fractures](#fractures)  
[Citation](#citation)   
[Brief Description](#description)    
[Running the code](#running)   

<a name="fractures"/>
<h2> Segmentation of Nuclear Envelope of HeLa Cells observed with Electron Microscope </h2>
</a>

This repository describes a semi-automatic image processing algorithm for the geometric analysis of dorsally displaced wrist fractures (Colles’ fractures). The semi-automatic analysis require the manual location of three landmarks (finger, lunate and radial styloid) and automatic processing to generate 32 geometric and texture measurements, which may be related to conditions such as osteoporosis and swelling of the wrist. 

<a name="citation"/>
<h2> Citation </h2>
</a>

This work has been accepted for publication in PLOS ONE, if you find the work or the software interesting or useful, please cite as:<br> <br>
<b>Constantino Carlos Reyes-Aldasoro1, Kwun Ho Ngan, Ananda Ananda, Artur d'Avila Garcez1, Andy Appelboam, Karen M. Knapp, Geometric Semi-automatic Analysis of Colles' Fractures, PLOS ONE (2020), to appear
</b>
<br><br>

A previous version of this paper was submitted to MedRXiv (https://www.medrxiv.org/content/10.1101/2020.02.18.20024562v1)
<br>
<br>


<a name="description"/>
<h2> Colles' Fractures / dorsally displaced wrist fractures </h2>
</a>




Fractures of the wrist are common in Emergency Departments, where some patients are
treated with a procedure called Manipulation under Anaesthesia. In some cases this
procedure is unsuccessful and patients need to visit the hospital again where they
undergo surgery to treat the fracture. This work describes a geometric semi-automatic
image analysis algorithm to analyse and compare the x-rays of healthy controls and
patients with dorsally displaced wrist fractures (Colles' fractures) who were treated with
Manipulation under Anaesthesia.



<a name="running"/>
<h2>Running the code</h2>
</a>




<li><a href="#7">Remove lines of collimator</a></li></ul></div>


<h2 id="1">Reading DICOM files</h2><p>If your data is in DICOM format, you can read into Matlab using the functions dicomread and dicominfo like this</p>

<pre class="codeinput">
dicom_header = dicominfo(<span class="string">'D:\IMG0'</span>);
dicom_image = dicomread(<span class="string">'D:\IMG0'</span>);
</pre>
<pre class="codeinput">dicom_header
</pre><pre class="codeoutput">
dicom_header =

struct with fields:

                                Filename: 'D:\IMG0'
                             FileModDate: '27-Jun-2017 11:19:50'
                                FileSize: 1567164
                                  Format: 'DICOM'
                           FormatVersion: 3
                                   Width: 608
                                  Height: 1287
                                BitDepth: 12
                               ColorType: 'grayscale'
                               .
                               .
                               .
               PhotometricInterpretation: 'MONOCHROME2'
                                    Rows: 1287
                                 Columns: 608

</pre>

<pre class="codeinput">imagesc(dicom_image)
colormap <span class="string">gray</span>
</pre><img vspace="5" hspace="5" src="Figures/guideFractures_01.png" alt="">

<p>If you are going to handle numerous images, it can be convenient to read the dicom and then save in Matlab format as a .mat  file. You can save the header and the image into a single file, the image with the name "Xray" and the header with the name "Xray_info". Later on you can also add the mask (the three landmarks) as "Xray_mask". Then these can be loaded together from one file, e.g.</p><pre class="codeinput">clear
load(<span class="string">'D:\PATIENT_PA.mat'</span>)

whos
</pre><pre class="codeoutput">  Name              Size                 Bytes  Class     Attributes
Xray           2500x2048            40960000  double              
Xray_info         1x1                  16820  struct              
Xray_mask      2500x2048            40960000  double              
</pre>
<h2 id="6">Alignment of the forearm</h2><p>To rotate the Xray so that the forearm is aligned vertically, use the function alingXray. If you are already using a mask, the mask should also be b provided so that it is rotated with the same angle. The actual angle of rotation is one output parameter.</p><pre class="codeinput">[XrayR,Xray_maskR,angleRot]     = alignXray (Xray,Xray_mask);

disp(angleRot)

figure(1)
subplot(121)
imagesc(Xray)
subplot(122)
imagesc(XrayR)
</pre><pre class="codeoutput">   -13

</pre><img vspace="5" hspace="5" src="Figures/guideFractures_02.png" alt=""> <h2 id="7">Remove lines of collimator</h2><p>In case the image has lines due to the collimator and these should be removed, use the function removeEdgesCollimator. The function receives the Xray as input, and if desired a second parameter that controls the width of the removal, if the default does not work, try increasing it.</p><pre class="codeinput">load(<span class="string">'D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture\DICOM_Karen\ANON8949_PATIENT_PA_594.mat'</span>)


XrayR2                          = removeEdgesCollimator2(Xray);
figure(1)
subplot(121)
imagesc(Xray)
subplot(122)
imagesc(XrayR2)


XrayR2                          = removeEdgesCollimator2(Xray,70);
figure(2)
subplot(121)
imagesc(Xray)
subplot(122)
imagesc(XrayR2)
colormap <span class="string">gray</span>
</pre><img vspace="5" hspace="5" src="Figures/guideFractures_03.png" alt=""> <img vspace="5" hspace="5" src="Figures/guideFractures_04.png" alt="">


<h2 id="9">Analysis based on the landmark of the radial styloid</h2>

<p>To determine two profiles from the radial styloid to the edge of the radius at 30 and 45 degrees below the line between the radial styloid and the lunate the function analyseLandmarkRadial is used in the following way:</p>

<pre class="codeinput">[stats,displayResultsRadial]    = analyseLandmarkRadial (XrayR2,Xray_maskR,Xray_info);
</pre>

<p>The results contain values about the lines (slope, standard deviation, etc)</p><pre class="codeinput">stats
</pre><pre class="codeoutput">
stats =

  struct with fields:

          slope_1: 2.7681
          slope_2: 2.7769
    slope_short_1: 3.6995
    slope_short_2: -1.5135
            std_1: 238.4763
            std_2: 278.4577
         std_ad_1: 143.3862
         std_ad_2: 204.7399
          row_LBP: 560
          col_LBP: 869

</pre>
<p>In addition displayResultsRadial contains the actual profiles of the lines, as well as the data with the profiles and the landmarks. You can display displayResultsRadial.dataOut, or use the fourth parameter to request the display (the third parameter is the name of the file, in case you are using it)</p>

<pre class="codeinput">displayData                     = 1;
[stats,displayResultsRadial]    = analyseLandmarkRadial (XrayR2,Xray_maskR,Xray_info,[],displayData);
</pre><img vspace="5" hspace="5" src="Figures/guideFractures_05.png" alt="">

 <h2 id="12">Analysis based on the landmark of the lunate</h2><p>The landmark of the lunate is used to determine the forearm, and from there delineate the edges of the arm, and trace 8 lines that measure the width of the forearm, each at one cm if separation. The widths are displayed on the figure when you select to display.</p>

 <pre class="codeinput">[AreaInflammation,widthAtCM,displayResultsLunate,dataOutput,coordinatesArm]    = analyseLandmarkLunate (XrayR2,Xray_maskR,Xray_info,[],displayData);
</pre><img vspace="5" hspace="5" src="Figures/guideFractures_06.png" alt="">

<h2 id="13">Analysis of the texture a region of interest</h2><p>A region of interest is detected and the Local Binary Pattern is calculated, the location of the region is selected as an intermediate point of the previously located profiles, so these are necessary input parameters.</p>

<pre class="codeinput">sizeInMM                        = [5, 5];
[LBP_Features,displayResultsLBP]    = ComputeLBPInPatch(XrayR2,Xray_info,Xray_maskR,stats.row_LBP,stats.col_LBP+50,sizeInMM,displayData);
</pre><img vspace="5" hspace="5" src="Figures/guideFractures_07.png" alt="">


<h2 id="14">Determine the ratio of trabecular / cortical to total bone</h2><p>The analysis of the landmark of the central finger segments the bone according to the trabecular and cortical regions and then calculates the ratio.</p><pre class="codeinput">[TrabecularToTotal,WidthFinger,displayResultsFinger] = analyseLandmarkFinger (XrayR,Xray_maskR,Xray_info,[],displayData);
</pre><img vspace="5" hspace="5" src="Figures/guideFractures_08.png" alt="">

<p class="footer"><br><a href="https://www.mathworks.com/products/matlab/">Published with MATLAB&reg; R2019a</a><br></p></div>
