% import images
house=im2double(imread('images/house - small.jpg'));
imsize=400;
house=house(1:imsize,1:imsize,:);
night=im2double(imread('images/starry-night - small.jpg'));
night=night(1:imsize,1:imsize,:);

% 1. Patch Matching


% 2. Robust Aggregation
[Xtilde]=irls(R,X,z);

% 3. Content Fusion
Xhat=(diag(W)+eye(3*Nc))\(Xtilde+W.*C); % W is (3*Nc/L x 1)

% 4. Color Transfer
X=imhistmatch(reshape(Xhat,h,w,c),reshape(S,h,w,c));
X=X(:);

% 5. Denoise