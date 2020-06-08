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




