# 廖元宏 102061137

Project 3 / Seam Carving for Content-Aware Image Resizing
## Overview
> This lab will implement a well-known image processing technique: seam carving. Seam carving is an algorithm for content-aware image resizing. In a nutshell, we will eliminate where is not important.

## Implementation
- energyRGB():

1. Calculate the gradient of x, y direction
2. Define the response to be the sum of the gradient of x, y axis.

```Matlab
% for every channel
[Rgx, Rgy] = gradient(I(:,:,1));
res(:,:,1) = abs(Rgx)+abs(Rgy);
```
- findOptSeam():

1. First, we will have to calculate teh cost from each top pixel
2. After the first step, we'll get the accumulated cost from top of the image to the bottom of the image
3. Use a bottom-up method to find that shortest path

```Matlab
% pad the image for convenience
M = padarray(energy, [0 1], realmax('double'));
...
% step 1
for i = 2:sz(1)
    for j = 2:sz(2)-1
        M(i,j)=M(i,j)+min([M(i-1,j-1),M(i-1,j),M(i-1,j+1)]);
    end
end
% step 2,3
idx = idx-1;
optSeamMask(sz(1),idx) = 1;
for h = sz(1):-1:2
    [m,i] = min([M(h-1,idx-1),M(h-1,idx),M(h-1,idx+1)]);
    optSeamMask(h-1,idx+i-3) = 1;
    idx = idx+i-2;
end
```

- reduceImageByMask():   
Given the mask and the orginal image, this function is used for resizing the image

```
sz = size(image);
% allocate a resized placeholder
imageReduced = zeros(sz(1),sz(2)-1,sz(3));
% iterativey mask out the designated pixels
for c = 1:sz(3)
    for h = 1:sz(1)
        [a,b] = min(seamMask(h,:));
        imageReduced(h,:,c) = [image(h,1:b-1,c), image(h,b+1:end,c)];
    end
end
```

## Results

### Given image: 
- Original:   
<img src="https://github.com/andrewliao11/DSP_Lab_HW3/blob/master/data/sea.jpg?raw=true" width="400" align="middle"> 

- Resized:   
<img src="https://github.com/andrewliao11/DSP_Lab_HW3/blob/master/code/resize_sea.png?raw=true" width="400" align="middle"> 

- Crop:   
<img src="https://github.com/andrewliao11/DSP_Lab_HW3/blob/master/code/crop_sea.png?raw=true" width="400" align="middle"> 

- Seam carving:   
<img src="https://github.com/andrewliao11/DSP_Lab_HW3/blob/master/code/seam_carving_sea.png?raw=true" width="400" align="middle"> 

### My Image
- Original:   
<img src="https://github.com/andrewliao11/DSP_Lab_HW3/blob/master/data/lake.jpg?raw=true" width="400" align="middle"> 

- Resized:   
<img src="https://github.com/andrewliao11/DSP_Lab_HW3/blob/master/code/lake_resize.png?raw=true" width="400" align="middle"> 

- Crop:   
<img src="https://github.com/andrewliao11/DSP_Lab_HW3/blob/master/code/crop_lake.png?raw=true" width="400" align="middle"> 

- Seam carving:   
<img src="https://github.com/andrewliao11/DSP_Lab_HW3/blob/master/code/seam_carving_lake.png?raw=true" width="400" align="middle"> 

## Discussion
The seam carving assume the pixel with low gradient is not important, so we can eliminate it. This seems to make sense. However, **what if the image with high gradient is with less saliency.**   
Just like this:   
<img src="http://virginityquest.com/wp-content/uploads/2016/08/Virginity-Party-In-Ibiza.jpg" width="400" align="middle">    
The top of the image contain high energy(gradient), while it's less important than the human on the bottom for human being.    
In this case, we should take the **saliency** into consideration. We can use a saliency detectot to make sure that the seam carving path doesn't eliminate the object with high saliency.
