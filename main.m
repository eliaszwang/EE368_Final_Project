addpath('DomainTransformFilters-Source-v1.0/');

% import images
house=im2double(imread('images/house - small.jpg'));
imsize=400;
house=house(1:imsize,1:imsize,:);
night=im2double(imread('images/starry-night - small.jpg'));
night=night(1:imsize,1:imsize,:);

% Initialize variables
R = zeros(size(house));
R(200:220,300:320,:) = 1;
R = R(:);
X = house(:);
S = night(:);
Q_size = 21;
gap = 18;
sigma_s = 60;
sigma_r = 0.4;
h=imsize; w=imsize;

% 1. Patch Matching
z = [];
for i=1:gap:h
    for j=1:gap:w
    [~, ~, zij] = nearest_n(R, X, Q_size, S, h, w);
    z = [z; zij];
    end
end

% 2. Robust Aggregation
[Xtilde]=irls(R,X,z);

% 3. Content Fusion
Xhat=(diag(W)+eye(3*Nc))\(Xtilde+W.*C); % W is (3*Nc/L x 1)

% 4. Color Transfer
X=imhistmatch(reshape(Xhat,h,w,c),reshape(S,h,w,c));
X=X(:);

% 5. Denoise
X = RF(X, sigma_s, sigma_r);