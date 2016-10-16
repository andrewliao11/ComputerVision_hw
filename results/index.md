# Yuan-Hong Liao(廖元宏) <span style="color:red">(102061137)</span>

# Project 1 / Image Filtering and Hybrid Images

## Overview
The project is related to 
> Use a simple Gaussian filter to filter out the low/high frequencies component, and simple sum them together. We have to implement a ```con2d``` equivalent function with reseaonable computation.


## Implementation
- Implement ```my_imfilter.m```
	* Get the image and filter size
	* Create a placeholder for image with padding
	* Tile the filter into a 3D filter, for optimization
	* Run the convolution pixel by pixel, with complexity **O(W*H)**
Code Highlight   

```
pseudocode:
create image_with_padding
tile the filter into filter_3D
repeat i = 1:width
	repeat j = 1:height
		output = filter_3D * image_with_padding(i:i+filter_width, j:j+filter_height)
	end
end
```
The convolution we do here is arbitrary padding no strides, like this:   
<p align="center"><img src="https://github.com/vdumoulin/conv_arithmetic/blob/master/gif/arbitrary_padding_no_strides.gif?raw=true" width="250"></p>

- Utilize ```my_imfilter.m``` for hybrid image
	* Use simple Gaussian filter as low pass filter
	* Use 1 - Gaussian filter a  high pass filter
	* Combine the two images

## Installation
* Use simple package of Matlab 

## Results
Here, we'll show result hybrid images and compare the timing	

### Hybrid Images
|Low-frequency|High-frequency|Hybrid Image|With different scales|
|---|---|---|---|
|<img src="https://github.com/andrewliao11/homework1-1/blob/master/code/dog_low_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/cat_high_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/dog_cat_hybrid_image.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/dog_cat_hybrid_image_scales.jpg?raw=true" width="250">|
| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/marilyn_low_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/einstein_high_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/marilyn_einstein_hybrid_image.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/marilyn_einstein_hybrid_image_scales.jpg?raw=true" width="250">|
| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/bicycle_low_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/motorcycle_high_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/bicycle_motorcycle_hybrid_image.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/bicycle_motorcycle_hybrid_image_scales.jpg?raw=true" width="250">|
| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/plane_low_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/bird_high_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/plane_bird_hybrid_image.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/plane_bird_hybrid_image_scales.jpg?raw=true" width="250">|
| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/submarine_low_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/fish_high_frequencies.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/submarine_fish_hybrid_image.jpg?raw=true" width="250">| <img src="https://github.com/andrewliao11/homework1-1/blob/master/code/submarine_fish_hybrid_image_scales.jpg?raw=true" width="250">|

### Timing
|Image name|Time elapse(my_imfilter)|Total Pixel|
|---|---|---|
|dog|1.86|148010|
|cat|1.73|148010|
|marilyn|0.71|67575|
|einstein|0.66|67575|
|bicycle|1.58|135900|
|motorcycle|1.49|135900|
|plane|1.48|124125|
|bird|1.48|124125|
|submarine|1.34|96705|
|fish|1.28|96705|

This experiment result show that the complexity of my_imfilter is nearly O(W*H), where W * H equal to total pixel.
## Reference
- [conv_arithmetic](https://github.com/vdumoulin/conv_arithmetic)
