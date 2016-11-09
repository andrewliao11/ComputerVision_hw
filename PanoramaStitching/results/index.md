# 廖元宏 <span style="color:red">(102061137)</span>

# Project 2 / Panorama Stitching

## Overview
> In this lab, we use SIFT feature to match the point between multiple images, and then stitch them together. To error caused by the outliers, we use RANSAC to eliminate the outliers. After eliminating the outliers, we can find the affine matrix. Iteratively use this techniques can generate a better transform matrix.


## Implementation
1. Compute SIFT feature and match them
	* Calculate the SIFT feature via vlfeat
	* Find the closest SIFT feature points between images   
2. Compute Affine matrix
	* Solve the transforming matrix that can transform the coordinates system of A image to one of B image
3. RANSAC
	* Iteratively pick out the outliers and solve the affine matrix

SIFT Matcher:   
We use the vlfeat package to extract the SIFT feature and this function is used to match the corresponding points across images. If the smallest gap is smaller than 0.7*second smallest gap, we consider it as valid matched point.

```Matlab
repeat from 1 to N1
	% calculate the difference
	rep = repmat(descriptor1(i,:),N2,1);  % N2,128
	diff = sqrt(sum((rep-descriptor2).^2,2));
	[y,j] = min(diff);
	diff(j) = realmax('double');
	y2 = min(diff);
	if(y<thresh*y2)
       match = [match;[i, j]];
   end
end
```

RANSAC   
Random sample consensus is an iterative method to estimate parameters of a mathematical model from a set of observed data that contains outliers, when outliers are to be accorded no influence on the values of the estimates. Therefore, it also can be interpreted as an outlier detection method. It is a non-deterministic algorithm in the sense that it produces a reasonable result only with a certain probability, with this probability increasing as more iterations are allowed.


```Matlab
repeat 1 to max iteration
	eta = ComputeAffineMatrix()
	delta = ComputeError(eta)
	epsilon = (delta <= maxInlierError);
	if epsilon > goodThreshold:
		# remove the point that "delta > maxInlierError"
		zeta = [beta; gamma(epsilon, :)];
		... do it again
end
```

## Installation
* VLfeat   
create ```startup.m``` script in MATLAB root:    

```Matlab
run('VLFEATROOT/toolbox/vl_setup')
```

### Results
The Panorama given by TAs   

- uttower_pano   
<p align="center"><img src="https://github.com/andrewliao11/homework2-1/blob/master/code/uttower_pano.jpg?raw=true" width="400"> </p> 
- yosemite  
<p align="center"><img src="https://github.com/andrewliao11/homework2-1/blob/master/code/yosemite.jpg?raw=true" width="400"> </p> 
- Rainier   
<p align="center"><img src="https://github.com/andrewliao11/homework2-1/blob/master/code/Rainier.jpg?raw=true" width="400"> </p> 
- MelakwaLake   
<p align="center"><img src="https://github.com/andrewliao11/homework2-1/blob/master/code/MelakwaLake.jpg?raw=true" width="400"> </p> 
- Hanging   
<p align="center"><img src="https://github.com/andrewliao11/homework2-1/blob/master/code/Hanging.jpg?raw=true" width="400"> </p> 
 


