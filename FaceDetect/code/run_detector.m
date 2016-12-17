% Starter code prepared by James Hays
% This function returns detections on all of the images in a given path.
% You will want to use non-maximum suppression on your detections or your
% performance will be poor (the evaluation counts a duplicate detection as
% wrong). The non-maximum suppression is done on a per-image basis. The
% starter code includes a call to a provided non-max suppression function.
function [bboxes, confidences, image_ids] = .... 
    run_detector(test_scn_path, w, b, feature_params)
% 'test_scn_path' is a string. This directory contains images which may or
%    may not have faces in them. This function should work for the MIT+CMU
%    test set but also for any other images (e.g. class photos)
% 'w' and 'b' are the linear classifier parameters
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.

% 'bboxes' is Nx4. N is the number of detections. bboxes(i,:) is
%   [x_min, y_min, x_max, y_max] for detection i. 
%   Remember 'y' is dimension 1 in Matlab!
% 'confidences' is Nx1. confidences(i) is the real valued confidence of
%   detection i.
% 'image_ids' is an Nx1 cell array. image_ids{i} is the image file name
%   for detection i. (not the full path, just 'albert.jpg')

% The placeholder version of this code will return random bounding boxes in
% each test image. It will even do non-maximum suppression on the random
% bounding boxes to give you an example of how to call the function.

% Your actual code should convert each test image to HoG feature space with
% a _single_ call to vl_hog for each scale. Then step over the HoG cells,
% taking groups of cells that are the same size as your learned template,
% and classifying them. If the classification is above some confidence,
% keep the detection and then pass all the detections for an image to
% non-maximum suppression. For your initial debugging, you can operate only
% at a single scale and you can skip calling non-maximum suppression.

    test_scenes = dir( fullfile( test_scn_path, '*.jpg' ));

    %initialize these as empty and incrementally expand them.
    bboxes = zeros(0,4);
    confidences = zeros(0,1);
    image_ids = cell(0,1);
    
    %initialize parameters
    templateSize = feature_params.template_size;
    cellSize = feature_params.hog_cell_size;
    thres = 1.25;
    overlap = .9;

    overlapInPix = round( (1-overlap) * templateSize );

    for i = 1:length(test_scenes)
      
        fprintf('Detecting faces in %s\n', test_scenes(i).name)
        img = imread( fullfile( test_scn_path, test_scenes(i).name ));
        img = single(img)/255;
        if(size(img,3) > 1)
            img = rgb2gray(img);
        end
        
        bboxes_section = [];
        confidences_section = [];
        
        scale = max( [ 1 ( templateSize*(1-overlap)*19+templateSize )/min(size(img)) ] );
        ratio = ( floor(100*scale/templateSize*min(size(img)))/100 )^.2;
        while floor(min(size(img))*scale) > templateSize
            imgScaled = imresize(img, scale);
            for scanHoriz = 1:floor( (size(imgScaled, 2)-templateSize)/overlapInPix + 1 )
                for scanVert = 1:floor( (size(imgScaled, 1)-templateSize)/overlapInPix + 1 )
                    startPos = [(scanHoriz-1)*overlapInPix+1 (scanVert-1)*overlapInPix+1];
                    endPos = startPos + templateSize - 1;
                    imgWindowed = imgScaled(startPos(2):endPos(2), startPos(1):endPos(1));
                    imgHog = vl_hog(imgWindowed, cellSize);
                    conf = imgHog(:)' * w + b;
                    if conf > thres
                        curBox = [startPos' endPos'];
                        curBox = round( ( curBox(:)' )/scale );
                        bboxes_section = [bboxes_section; curBox];
                        confidences_section = [confidences_section; conf];
                    end
                end
            end
            scale = scale / ratio;
        end
        
        boxesArea = zeros(size(bboxes_section, 1), 1);
        for ii = 1:length(boxesArea)
            boxesArea(ii) = computeArea(bboxes_section(ii, :));
        end
        [~, idx] = sort(boxesArea, 'descend');
        bboxes_section = bboxes_section(idx, :);
        confidences_section = confidences_section(idx);
        [bboxes_section idx] = resultsPostProcess(bboxes_section);
        bboxes = [bboxes; bboxes_section];
        confidences = [confidences; ...
            ( confidences_section(idx(:, 1)) + confidences_section(idx(:, 2)) )/2];
        for ii = 1:size(bboxes_section, 1)
            image_ids{length(image_ids)+1} = test_scenes(i).name;
        end
    end
end

function [bboxes_post idx] = resultsPostProcess(bboxes_pre)
    idx = zeros(size(bboxes_pre, 1)-1, 2);
    bboxes_post = zeros(size(bboxes_pre));
    pattern_cnt = 0;
    for ii = 1:size(bboxes_pre, 1)-1
        if computeArea(bboxes_pre(ii, :)) == 0
            continue;
        end
        pattern_cnt = pattern_cnt + 1;
        bboxes_post(pattern_cnt, :) = bboxes_pre(ii, :);
        idx(pattern_cnt, :) = ii;
        for jj = ii+1:size(bboxes_pre, 1)
            box1 = bboxes_pre(ii, :);
            box2 = bboxes_pre(jj, :);
            [olpArea olpBox unionBox] = boxesOverlapArea(box1, box2);
            if olpArea > 0 && olpArea/min([computeArea(box1) computeArea(box2)]) > .5
                idx(pattern_cnt, 2) = jj;
                bboxes_post(pattern_cnt, :) = olpBox;
                bboxes_pre(ii, :) = olpBox;
                bboxes_pre(jj, :) = zeros(1, 4);
            elseif olpArea > 0 && olpArea/max([computeArea(box1) computeArea(box2)]) > .5
                idx(pattern_cnt, 2) = jj;
                bboxes_post(pattern_cnt, :) = olpBox;
                bboxes_pre(ii, :) = unionBox;
                bboxes_pre(jj, :) = zeros(1, 4);
            end
        end
    end
    idx = idx(1:pattern_cnt, :);
    bboxes_post = bboxes_post(1:pattern_cnt, :);
end

%   [x_min, y_min, x_max, y_max]
function [area olpBox unionBox] = boxesOverlapArea(box1, box2)
    if sum( box1(1) >= box2([1 3]) ) == 2 || sum( box2(1) >= box1([1 3]) ) == 2 ... % Not contained
            || sum( box1(2) >= box2([2 4]) ) == 2 || sum( box2(2) >= box1([2 4]) ) == 2
        area = 0;
        olpBox = [];
        unionBox = [];
    else
        olpx_min = max([box1(1) box2(1)]);
        olpy_min = max([box1(2) box2(2)]);
        olpx_max = min([box1(3) box2(3)]);
        olpy_max = min([box1(4) box2(4)]);
        unix_min = min([box1(1) box2(1)]);
        uniy_min = min([box1(2) box2(2)]);
        unix_max = max([box1(3) box2(3)]);
        uniy_max = max([box1(4) box2(4)]);
        area = ( olpx_max-olpx_min ) * ( olpy_max-olpy_min );
        olpBox = [olpx_min, olpy_min, olpx_max, olpy_max];
        unionBox = [unix_min, uniy_min, unix_max, uniy_max];
    end
end

function area = computeArea(box)
    area = (box(3)-box(1))*(box(4)-box(2));
end




