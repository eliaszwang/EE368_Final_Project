function fin_img = surf_transfer(img_c, img_s)

% img_c = im2double(imread('house 2-small.jpg'));
% img_s = im2double(imread('starry-night - small.jpg'));


% Load test image
imgE_c = rgb2gray(img_c);
% scale = 1;
% sigma_edge = scale*1.3;
% imgE_c = edge(img, 'log', 0.03, sigma_edge);
% figure
% imagesc(imgE_c)

% Load test image
% [h0, w0] = size(img);
imgE_s = rgb2gray(img_s);
% [h, w] = size(img);
% scale = h*w/h0/w0;
% sigma_edge = scale*1.3;
% imgE_s = edge(img, 'log', 0.03, sigma_edge);
% figure
% imagesc(imgE_s)

% Match SURF features between two images rotated and scaled with
% respect to each other.
Ic = imgE_c;
Is = imgE_s;

% Detect SURF features. Other feature detectors can be used too.
points1 = detectSURFFeatures(Ic);
points2 = detectSURFFeatures(Is);

% Extract features from images
[f1, vpts1] = extractFeatures(Ic, points1);
[f2, vpts2] = extractFeatures(Is, points2);

%     % Visualize 10 strongest SURF features, including their scale, and 
%     % orientation which was determined during the descriptor extraction
%     % process.
%     tenStrongestPoints = selectStrongest(vpts1,10);
%     figure
%     imshow(img_c)
%     hold on
%     plot(tenStrongestPoints,'showOrientation',true)
% 
%     fin_img = img_c;
%     for pt=1:size(tenStrongestPoints,1)
%         ptc = tenStrongestPoints(pt); locc = ptc.Location; sigc = ptc.Scale;
% 
%         maskc = zeros(size(Ic));
%         maskc(round(locc(2)),round(locc(1))) = 1;
% 
%         maskc = imgaussfilt(maskc, 3*sigc);
%         maskc = repmat(1 - maskc / max(max(maskc)), [1 1 3]);
% 
%         fin_img = fin_img .* maskc;
%     end
%     figure
%     imshow(fin_img)
%     
%     return
%  

% Match features between images 
indexPairs = matchFeatures(f1, f2,...
    'MatchThreshold', 20,...
    'Unique',true,...
    'MaxRatio', 0.8....
);

matchedPoints1 = vpts1(indexPairs(:, 1));
matchedPoints2 = vpts2(indexPairs(:, 2));

% Note that there are still several outliers present in the data,
% but otherwise you can clearly see the effects of rotation and
% scaling on the display of matched features.
% figure; showMatchedFeatures(Ic,Is,matchedPoints1,matchedPoints2);
% legend('matched points 1','matched points 2');

fin_img = img_c;
for pt=1:size(matchedPoints1,1)
    ptc = matchedPoints1(pt);
    locc = ptc.Location; sigc = 3*double(ptc.Scale); thetac = ptc.Orientation;
    pts = matchedPoints2(pt);
    locs = pts.Location; sigs = 3*double(pts.Scale); thetas = pts.Orientation;
    
    masks = zeros(size(Is));
    masks(round(locs(2)),round(locs(1))) = 1;
    masks = imgaussfilt(masks, sigs);
    masks = repmat(masks / max(max(masks)), [1 1 3]);
    
    extract = masks .* img_s;
    
    STATS = regionprops(max(extract,[],3) ~= 0,'BoundingBox');
    bbox = round(STATS.BoundingBox);
    y_lim = min(bbox(2)+bbox(4), size(extract,1));
    x_lim = min(bbox(1)+bbox(3), size(extract,2));
    extract_box = extract(bbox(2):y_lim,bbox(1):x_lim,:);
    
    extract_box = imrotate(extract_box, (thetac-thetas)*180/pi);
    extract_box = imresize(extract_box, sigc/sigs);
    
    maskc = zeros(size(Ic));
    maskc(round(locc(2)),round(locc(1))) = 1;
    
    tf(:,:,1) = conv2(maskc,extract_box(:,:,1),'same');
    tf(:,:,2) = conv2(maskc,extract_box(:,:,2),'same');
    tf(:,:,3) = conv2(maskc,extract_box(:,:,3),'same');
    
    H = fspecial('gaussian',2*ceil(2*sigc)+1,sigc);
    H = imrotate(H,(thetac-thetas)*180/pi);
%     maskc = imgaussfilt(maskc, sigc);
    maskc = conv2(maskc,H,'same');
    maskc = repmat(1 - maskc / max(max(maskc)), [1 1 3]);
    
    fin_img = fin_img .* maskc + tf;
end

size(matchedPoints1,1)

end