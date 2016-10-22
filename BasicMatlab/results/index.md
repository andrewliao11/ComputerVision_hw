# 廖元宏 <span style="color:red">(102061137)</span>

# Project 1 / Image Filtering and Hybrid Images

## Overview
The project is related to 
> In this lab, we do some basic operations on the 2D image with matlab. The aims of this lab is to let us familiar with the matlab operation on image.


## Implementation
1. Flip.m
	* 3 types of flipping
	* horizontal + vertical flipping

		```
		R_flip(h, w) = R(height-h+1, width-w+1);
       G_flip(h, w) = G(height-h+1, width-w+1);
       B_flip(h, w) = B(height-h+1, width-w+1);
		```
2. Rotation.m
	* do the rotation by ratational matrix
	
		```
		matrix = [cos(-radius) -sin(-radius) ; sin(-radius) cos(-radius)];
   		temp = matrix*[x_new-x_shift y_new-y_shift]';
   		x_old = temp(1);
   		y_old = temp(2);
		```
	* Shift the rotated image to poistive axis
	* There will be zig-zags between the rotated image and the axis, so we need interpolation (here we use bilinear interpolation)
	
		``` Python
		wa = (x_old-x1)/(x2-x1);
       wb = (y_old-y1)/(y2-y1);
		w1 = (1-wa)*(1-wb);
       w2 = (wa)*(1-wb);
       w3 = (wa)*(wb);
       w4 = (1-wa)*(wb);
       % do the interpolation
		r = R(y1,x1)*w1+R(y2,x1)*w2+R(y2,x2)*w3+R(y2,x1)*w4;
       g = G(y1,x1)*w1+G(y2,x1)*w2+G(y2,x2)*w3+G(y2,x1)*w4;
       b = B(y1,x1)*w1+B(y2,x1)*w2+B(y2,x2)*w3+B(y2,x1)*w4;
		```

## Installation
* None

### Results

|Original Image|Gray Image|Flipped Image|Rotated Image(pi/3)|
|---|---|---|---|
|![](https://github.com/andrewliao11/DSP_Lab_HW0/blob/master/image.jpg?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW0/blob/master/gray_image.jpg?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW0/blob/master/flip_image.jpg?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW0/blob/master/rotate_image.jpg?raw=true)|
|![](https://github.com/andrewliao11/DSP_Lab_HW0/blob/master/test2.jpg?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW0/blob/master/gray_image2.jpg?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW0/blob/master/flip_image2.jpg?raw=true)|![](https://github.com/andrewliao11/DSP_Lab_HW0/blob/master/rotate_image2.jpg?raw=true)|





