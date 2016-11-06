# 廖元宏 <span style="color:red">(102061137)</span>

# Project 2 / Image Filtering and Corner Detection

## Overview
The project is related to 
> Calculate the gradient w.r.t x axis, and y axis. And analyze the gradient response to find the most interest point. The concept of corner detection comes from calculating the SSD for moving a little bit in x and y axis. Harris matrix, composed with the gradient w.r.t to x and y, helps us to find the approxiamate SSD.


## Implementation
1. Corner detection
	* Convert into intensity map
	* Calculate the gradient w.r.t x and y axis
	* Calculate the Harris Matrix
	* Calculate the corner response


- Calculate the gradient

```matlab
Ix = imfilter(gray, dx);
Iy = imfilter(gray, dy);
```
-  calculate the Ix2, Iy2, Ixy then do Gaussian

```
Ix2 = imfilter(Ix.^2, g);
Iy2 = imfilter(Iy.^2, g);
Ixy = imfilter(Ix.*Iy, g);
```

- Calculate the corner response

```
for i = 1:xmax
    for j = 1:ymax
        temp = [Ix2(i,j) Ixy(i,j);Ixy(i,j) Iy2(i,j)];
        R(i,j) = det(temp)-alpha*trace(temp)^2;
    end
end
```

## Installation
* No special package required

## Results

|Original Image|Ixy response|Corner response|
|---|---|---|
|![](https://github.com/andrewliao11/DSP_Lab_HW2/blob/master/data/Im.jpg?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW2/blob/master/ex1_Ixy.png?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW2/blob/master/ex1.png?raw=true)|
|![](https://github.com/andrewliao11/DSP_Lab_HW2/blob/master/data/test2.jpg?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW2/blob/master/ex2_Ixy.png?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW2/blob/master/ex2.png?raw=true)|

## Discussion
It's easy to guess that the corner happens where the gradient responses are high in x direction and y direction. This lab we use a simple difference filter to do the gradient calculation since the pixels in image is discrete. After using the first-order gradient to find the Harris Matrix:    
<img src="https://wikimedia.org/api/rest_v1/media/math/render/svg/4a687673feb298a1ac1410e298a4494cfb0e6100" width="400" align="middle">   
This matrix is a Harris matrix, and angle brackets denote averaging (i.e. summation over (u,v)).   

A corner (or in general an interest point) is characterized by a large variation of ```S``` in all directions of the vector (x,y). By analyzing the eigenvalues of ```A```, this characterization can be expressed in the following way: ```A``` should have two "large" **eigenvalues** for an **interest point**. Based on the magnitudes of the eigenvalues, the following inferences can be made based on this argument:   
1. If λ1≈0, λ2≈0 and (x,y) has no features of interest.    
2. If λ1≈0, λ2 have some positive large response :point_right: edge is found    
3. If λ1 and λ2 have some positive large response :point_right: corner is found   
Let's observe the R response of the example images:

|example1|example2|
|---|---|
|![](https://github.com/andrewliao11/DSP_Lab_HW2/blob/master/ex1_R_response.png?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW2/blob/master/ex2_R_response.png?raw=true)|

## Refernece
- [The Harris & Stephens / Plessey / Shi–Tomasi corner detection algorithms](https://en.wikipedia.org/wiki/Corner_detection#The_Harris_.26_Stephens_.2F_Plessey_.2F_Shi.E2.80.93Tomasi_corner_detection_algorithms)
