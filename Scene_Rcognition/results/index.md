# 廖元宏(Andrew Liao) (102061127)
## Project 3 / Scene recognition with bag of words
I implement a hand-crafted feature extractor(tiny-image, SIFT BoW), and use knn and svm to classify. We do the experiment on 15 scene database. All the images are gray scale to reduce complexity.

## Implementation

- ```get_tiny_images.m```   
This file is to extract the tiny-image feature, which is quite simple. We use the built-in function to resize the image into 16*16 using bilinear interpolation and flatten it.
- ```nearest_neighbor_classify.m```   
Use ```vl_alldist2``` to calculate the l2 distance between every possible pair and choose the closest one as prediction

```matlab
dist = vl_alldist2(train_image_feats', test_image_feats');
[Y,I] = min(dist);
predicted_categories = cell(length(train_labels),1);
for i=1:length(I)
    predicted_categories{i} = train_labels{I(i)};
end
```
- ```build_vocabulary.m```   
Extract the sift feature of the training data and use kmeans cluster the feature and find the center of the cluster as visual words.

```matalb
sift = [];
disp('extracting SIFT...')
for i = 1:length(image_paths)
    img = im2double(imread(image_paths{i}));
    [locations, SIFT_features] = vl_dsift(single(img),'fast','step', 15);
    sift = [sift SIFT_features];
end
disp('kmeans...')
[centers, assignments] = vl_kmeans(double(sift), vocab_size);
vocab = centers';
disp('clustering done')
```

- ```get_bags_of_sifts.m```   
After the clustering, we'll have some visual words. This file is to extract the sift feature and turns it into histogram as BoW features. Here, I use kd-tree to make the process effecient, and ignore the error caused by kd-tree. 

```matlab
kd_tree = vl_kdtreebuild(vocab');
disp('comparing feature...')
for i = 1:length(image_paths)
    img = im2double(imread(image_paths{i}));
    [locations, SIFT_features] = vl_dsift(single(img),'fast','step', 3);
    [I,~] = vl_kdtreequery(kd_tree, vocab', double(SIFT_features));
    tem = histogram(I, vocab_size);
    norm_feat = tem.Values/norm(tem.Values);
    image_feats(i,:) = norm_feat;
end
```
- ```svm_classify.m```   
I create a svm binary classifier, which predict the similarity of the testing image and corresponding label. e.g the probability that the testing image is 'Bedroom'. So I create 15 svm classifier to do the binary classification and pick one that with the higher score as prediction.

```matlab
for c = 1:num_categories
    labels = double(strcmp(train_labels, categories(c))); % N
    labels(labels==0) = -1;
    [W B] = vl_svmtrain(train_image_feats',labels, lambda);
    score = test_image_feats*W+B;
    scores(c,:) = score;
end
```

## Result 

Confusion matrix:   

- tiny-image + knn
<p align="center"><img src="TI_KNN.png" width="350"> </p>
<br>
Accuracy (mean of diagonal of confusion matrix) is **0.198**
<p>

- BoW of SIFT+ knn
<p align="center"><img src="sift_knn.png" width="350"> </p>
<br>
Accuracy (mean of diagonal of confusion matrix) is **0.522**
<p>

- BoW of SIFT+ svm
<p align="center"><img src="sift_svm.png" width="350"> </p>
<br>
Accuracy (mean of diagonal of confusion matrix) is **0.652**
<p>

- BoW of SIFT representation + linear SVM classifier, I have tune lambda from 0.1 ~ 1e-06:
	- lambda = 0.1, acc = **0.469**
	- lambda = 0.01, acc = **0.512**
	- lambda = 0.001, acc = **0.626**
	- lambda = 0.0001, acc = **0.669**
	- lambda = 0.00001, acc = **0.652**
	- lambda = 0.000001, acc = **0.654**

<center>
<p>
<table border=0 cellpadding=4 cellspacing=1>
<tr>
<th>Category name</th>
<th>Accuracy</th>
<th colspan=2>Sample training images</th>
<th colspan=2>Sample true positives</th>
<th colspan=2>False positives with true label</th>
<th colspan=2>False negatives with wrong predicted label</th>
</tr>
<tr>
<td>Kitchen</td>
<td>0.610</td>
<td bgcolor=LightBlue><img src="thumbnails/Kitchen_image_0020.jpg" width=100 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Kitchen_image_0100.jpg" width=100 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Kitchen_image_0093.jpg" width=99 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Kitchen_image_0129.jpg" width=100 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/LivingRoom_image_0078.jpg" width=113 height=75><br><small>LivingRoom</small></td>
<td bgcolor=LightCoral><img src="thumbnails/InsideCity_image_0041.jpg" width=75 height=75><br><small>InsideCity</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Kitchen_image_0183.jpg" width=100 height=75><br><small>LivingRoom</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Kitchen_image_0095.jpg" width=102 height=75><br><small>Store</small></td>
</tr>
<tr>
<td>Store</td>
<td>0.540</td>
<td bgcolor=LightBlue><img src="thumbnails/Store_image_0255.jpg" width=102 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Store_image_0119.jpg" width=100 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Store_image_0111.jpg" width=100 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Store_image_0138.jpg" width=100 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/LivingRoom_image_0079.jpg" width=103 height=75><br><small>LivingRoom</small></td>
<td bgcolor=LightCoral><img src="thumbnails/InsideCity_image_0118.jpg" width=75 height=75><br><small>InsideCity</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Store_image_0147.jpg" width=101 height=75><br><small>Industrial</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Store_image_0074.jpg" width=54 height=75><br><small>InsideCity</small></td>
</tr>
<tr>
<td>Bedroom</td>
<td>0.530</td>
<td bgcolor=LightBlue><img src="thumbnails/Bedroom_image_0045.jpg" width=57 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Bedroom_image_0149.jpg" width=77 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Bedroom_image_0148.jpg" width=102 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Bedroom_image_0163.jpg" width=100 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/LivingRoom_image_0092.jpg" width=101 height=75><br><small>LivingRoom</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Store_image_0102.jpg" width=100 height=75><br><small>Store</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Bedroom_image_0130.jpg" width=132 height=75><br><small>Industrial</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Bedroom_image_0156.jpg" width=99 height=75><br><small>OpenCountry</small></td>
</tr>
<tr>
<td>LivingRoom</td>
<td>0.370</td>
<td bgcolor=LightBlue><img src="thumbnails/LivingRoom_image_0243.jpg" width=100 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/LivingRoom_image_0130.jpg" width=101 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/LivingRoom_image_0024.jpg" width=100 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/LivingRoom_image_0114.jpg" width=98 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/Kitchen_image_0182.jpg" width=100 height=75><br><small>Kitchen</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Office_image_0140.jpg" width=103 height=75><br><small>Office</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/LivingRoom_image_0063.jpg" width=115 height=75><br><small>Store</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/LivingRoom_image_0078.jpg" width=113 height=75><br><small>Kitchen</small></td>
</tr>
<tr>
<td>Office</td>
<td>0.840</td>
<td bgcolor=LightBlue><img src="thumbnails/Office_image_0095.jpg" width=107 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Office_image_0109.jpg" width=115 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Office_image_0037.jpg" width=108 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Office_image_0067.jpg" width=117 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/LivingRoom_image_0015.jpg" width=100 height=75><br><small>LivingRoom</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Kitchen_image_0029.jpg" width=57 height=75><br><small>Kitchen</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Office_image_0127.jpg" width=119 height=75><br><small>Kitchen</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Office_image_0140.jpg" width=103 height=75><br><small>LivingRoom</small></td>
</tr>
<tr>
<td>Industrial</td>
<td>0.450</td>
<td bgcolor=LightBlue><img src="thumbnails/Industrial_image_0103.jpg" width=112 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Industrial_image_0195.jpg" width=50 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Industrial_image_0021.jpg" width=100 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Industrial_image_0045.jpg" width=61 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/Bedroom_image_0117.jpg" width=52 height=75><br><small>Bedroom</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Store_image_0030.jpg" width=100 height=75><br><small>Store</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Industrial_image_0035.jpg" width=77 height=75><br><small>Kitchen</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Industrial_image_0087.jpg" width=112 height=75><br><small>Store</small></td>
</tr>
<tr>
<td>Suburb</td>
<td>0.940</td>
<td bgcolor=LightBlue><img src="thumbnails/Suburb_image_0007.jpg" width=113 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Suburb_image_0038.jpg" width=113 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Suburb_image_0168.jpg" width=113 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Suburb_image_0101.jpg" width=113 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/OpenCountry_image_0114.jpg" width=75 height=75><br><small>OpenCountry</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Industrial_image_0115.jpg" width=94 height=75><br><small>Industrial</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Suburb_image_0164.jpg" width=113 height=75><br><small>OpenCountry</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Suburb_image_0013.jpg" width=113 height=75><br><small>InsideCity</small></td>
</tr>
<tr>
<td>InsideCity</td>
<td>0.580</td>
<td bgcolor=LightBlue><img src="thumbnails/InsideCity_image_0108.jpg" width=75 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/InsideCity_image_0148.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/InsideCity_image_0061.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/InsideCity_image_0040.jpg" width=75 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/Street_image_0055.jpg" width=75 height=75><br><small>Street</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Highway_image_0029.jpg" width=75 height=75><br><small>Highway</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/InsideCity_image_0124.jpg" width=75 height=75><br><small>Store</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/InsideCity_image_0049.jpg" width=75 height=75><br><small>TallBuilding</small></td>
</tr>
<tr>
<td>TallBuilding</td>
<td>0.660</td>
<td bgcolor=LightBlue><img src="thumbnails/TallBuilding_image_0275.jpg" width=75 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/TallBuilding_image_0110.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/TallBuilding_image_0059.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/TallBuilding_image_0013.jpg" width=75 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/Store_image_0116.jpg" width=71 height=75><br><small>Store</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Kitchen_image_0071.jpg" width=100 height=75><br><small>Kitchen</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/TallBuilding_image_0084.jpg" width=75 height=75><br><small>Coast</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/TallBuilding_image_0035.jpg" width=75 height=75><br><small>Industrial</small></td>
</tr>
<tr>
<td>Street</td>
<td>0.620</td>
<td bgcolor=LightBlue><img src="thumbnails/Street_image_0139.jpg" width=75 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Street_image_0257.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Street_image_0026.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Street_image_0138.jpg" width=75 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/LivingRoom_image_0045.jpg" width=115 height=75><br><small>LivingRoom</small></td>
<td bgcolor=LightCoral><img src="thumbnails/TallBuilding_image_0022.jpg" width=75 height=75><br><small>TallBuilding</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Street_image_0013.jpg" width=75 height=75><br><small>LivingRoom</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Street_image_0145.jpg" width=75 height=75><br><small>Store</small></td>
</tr>
<tr>
<td>Highway</td>
<td>0.730</td>
<td bgcolor=LightBlue><img src="thumbnails/Highway_image_0166.jpg" width=75 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Highway_image_0248.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Highway_image_0044.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Highway_image_0116.jpg" width=75 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/Industrial_image_0116.jpg" width=126 height=75><br><small>Industrial</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Industrial_image_0106.jpg" width=100 height=75><br><small>Industrial</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Highway_image_0041.jpg" width=75 height=75><br><small>TallBuilding</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Highway_image_0029.jpg" width=75 height=75><br><small>InsideCity</small></td>
</tr>
<tr>
<td>OpenCountry</td>
<td>0.510</td>
<td bgcolor=LightBlue><img src="thumbnails/OpenCountry_image_0247.jpg" width=75 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/OpenCountry_image_0168.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/OpenCountry_image_0035.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/OpenCountry_image_0112.jpg" width=75 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/Highway_image_0003.jpg" width=75 height=75><br><small>Highway</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Forest_image_0126.jpg" width=75 height=75><br><small>Forest</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/OpenCountry_image_0114.jpg" width=75 height=75><br><small>Suburb</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/OpenCountry_image_0119.jpg" width=75 height=75><br><small>Coast</small></td>
</tr>
<tr>
<td>Coast</td>
<td>0.740</td>
<td bgcolor=LightBlue><img src="thumbnails/Coast_image_0267.jpg" width=75 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Coast_image_0355.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Coast_image_0072.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Coast_image_0044.jpg" width=75 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/Bedroom_image_0050.jpg" width=113 height=75><br><small>Bedroom</small></td>
<td bgcolor=LightCoral><img src="thumbnails/InsideCity_image_0015.jpg" width=75 height=75><br><small>InsideCity</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Coast_image_0002.jpg" width=75 height=75><br><small>Street</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Coast_image_0107.jpg" width=75 height=75><br><small>Bedroom</small></td>
</tr>
<tr>
<td>Mountain</td>
<td>0.770</td>
<td bgcolor=LightBlue><img src="thumbnails/Mountain_image_0340.jpg" width=75 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Mountain_image_0334.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Mountain_image_0086.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Mountain_image_0091.jpg" width=75 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/Coast_image_0011.jpg" width=75 height=75><br><small>Coast</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Store_image_0141.jpg" width=125 height=75><br><small>Store</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Mountain_image_0017.jpg" width=75 height=75><br><small>Forest</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Mountain_image_0118.jpg" width=75 height=75><br><small>Forest</small></td>
</tr>
<tr>
<td>Forest</td>
<td>0.880</td>
<td bgcolor=LightBlue><img src="thumbnails/Forest_image_0092.jpg" width=75 height=75></td>
<td bgcolor=LightBlue><img src="thumbnails/Forest_image_0254.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Forest_image_0023.jpg" width=75 height=75></td>
<td bgcolor=LightGreen><img src="thumbnails/Forest_image_0127.jpg" width=75 height=75></td>
<td bgcolor=LightCoral><img src="thumbnails/Mountain_image_0118.jpg" width=75 height=75><br><small>Mountain</small></td>
<td bgcolor=LightCoral><img src="thumbnails/Mountain_image_0008.jpg" width=75 height=75><br><small>Mountain</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Forest_image_0124.jpg" width=75 height=75><br><small>Mountain</small></td>
<td bgcolor=#FFBB55><img src="thumbnails/Forest_image_0128.jpg" width=75 height=75><br><small>Coast</small></td>
</tr>
<tr>
<th>Category name</th>
<th>Accuracy</th>
<th colspan=2>Sample training images</th>
<th colspan=2>Sample true positives</th>
<th colspan=2>False positives with true label</th>
<th colspan=2>False negatives with wrong predicted label</th>
</tr>
</table>
</center>

