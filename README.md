# Geometric Semi-automatic Analysis of Colles' Fractures



##### Table of Contents  

[Colles' Fractures](#fractures)  
[Citation](#citation)   
[Brief Description](#description)   
[Limitations](#limitations)   
[Running the code](#running)   

<a name="fractures"/>
<h2> Segmentation of Nuclear Envelope of HeLa Cells observed with Electron Microscope </h2>
</a>


This code contains an image-processing pipeline for the automatic segmentation of the nuclear envelope of {\it HeLa} cells
observed through Electron Microscopy. This pipeline has been tested with a 3D stack of 300 images.
The intermediate results of neighbouring slices are further combined to improve the final results.
Comparison with a hand-segmented  ground truth reported Jaccard similarity values between 94-98% on
the central slices with a decrease towards the edges of the cell where the structure was considerably more complex.
The processing is unsupervised and  each 2D Slice is processed in about 5-10 seconds running on a MacBook Pro.
No systematic attempt to make the code faster was made.


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
<h2> Brief description </h2>
</a>




Fractures of the wrist are common in Emergency Departments, where some patients are
treated with a procedure called Manipulation under Anaesthesia. In some cases this
procedure is unsuccessful and patients need to visit the hospital again where they
undergo surgery to treat the fracture. This work describes a geometric semi-automatic
image analysis algorithm to analyse and compare the x-rays of healthy controls and
patients with dorsally displaced wrist fractures (Colles' fractures) who were treated with
Manipulation under Anaesthesia.


<a name="limitations"/>
<h2>Limitations</h2>
</a>


<a name="running"/>
<h2>Running the code</h2>
</a>




<li><a href="#7">Remove lines of collimator</a></li></ul></div><h2 id="1">Reading DICOM files</h2><p>If your data is in DICOM format, you can read into Matlab using the functions dicomread and dicominfo like this</p><pre class="codeinput">dicom_header = dicominfo(<span class="string">'D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture\DICOM\Normals\N1\PAT1\STD1\SER1\IMG0'</span>);

dicom_image = dicomread(<span class="string">'D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture\DICOM\Normals\N1\PAT1\STD1\SER1\IMG0'</span>);
</pre><pre class="codeinput">dicom_header
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
</pre><img vspace="5" hspace="5" src="Figures/guideFractures_01.png" alt=""> <pre class="codeinput">clear
</pre><p>If you are going to handle numerous images, it can be convenient to read the dicom and then save in Matlab format as a .mat  file. You can save the header and the image into a single file, the image with the name "Xray" and the header with the name "Xray_info". Later on you can also add the mask (the three landmarks) as "Xray_mask". Then these can be loaded together from one file, e.g.</p><pre class="codeinput">clear
load(<span class="string">'D:\OneDrive - City, University of London\Acad\Research\Exeter_Fracture\DICOM_Karen\ANON8865_PATIENT_PA_301.mat'</span>)

whos
</pre><pre class="codeoutput">  Name              Size                 Bytes  Class     Attributes

Xray           2500x2048            40960000  double              
Xray_info         1x1                  16820  struct              
Xray_mask      2500x2048            40960000  double              

</pre><h2 id="6">Alignment of the forearm</h2><p>To rotate the Xray so that the forearm is aligned vertically, use the function alingXray. If you are already using a mask, the mask should also be b provided so that it is rotated with the same angle. The actual angle of rotation is one output parameter.</p><pre class="codeinput">[XrayR,Xray_maskR,angleRot]     = alignXray (Xray,Xray_mask);

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
</pre><img vspace="5" hspace="5" src="Figures/guideFractures_03.png" alt=""> <img vspace="5" hspace="5" src="Figures/guideFractures_04.png" alt=""> <p class="footer"><br><a href="https://www.mathworks.com/products/matlab/">Published with MATLAB&reg; R2019a</a><br></p></div><!--
