addpath('DomainTransformFilters-Source-v1.0/');

% import images
house=im2double(imread('images/house - small.jpg'));
imsize=400;
house=house(1:imsize,1:imsize,:);
night=im2double(imread('images/starry-night - small.jpg'));
night=night(1:imsize,1:imsize,:);

% Initialize variables

% R = zeros(size(house));
% R(200:220,300:320,:) = 1;
% R = R(:);
C = house(:);
S = night(:);
sigma_s = 60;
sigma_r = 0.4;
h=imsize; w=imsize; c=3;
patch_sizes=[33 21 13 9].^2 ;
gap_sizes=[28 18  8 5];
X=C+0*randn(size(C)); %initialize estimate to content image plus noise 
% Loop over scales L=Lmax, ... ,1
for L=1
    % Loop over patch sizes n=n1, ... ,nm
    for n=patch_sizes(2) %n=Q_size^2
        % Iterate: for k=1, ... ,Ialg
        for k=1
            
            % 1. Patch Matching
            disp('patch matching')
            z = [];
            Rall=[];
            Q_size=sqrt(n);
            gap=gap_sizes(patch_sizes==n); %should correspond to current n
            for i=1:gap:h-Q_size+1
                i
                for j=1:gap:w-Q_size+1
                    R = zeros(size(house));
                    R(i:i+Q_size-1,j:j+Q_size-1,:) = 1;
                    R = R(:);
                    Rall=[Rall R];
                    tic
                    [ks, ls, zij] = nearest_n(R, X, Q_size, S, h, w, c);
                    toc
                    z = [z zij];
                    return
                end
            end
            
            % 2. Robust Aggregation
            disp('robust aggregation')
            [Xtilde]=irls(Rall,X,z);

            
            % 3. Content Fusion
            disp('content fusion')
            Nc=(imsize/L)^2;
            W=ones(3*Nc,1);
            Xhat=(1./(W+ones(3*Nc,1))).*(Xtilde+W.*C); % W is (3*Nc/L x 1)

            
            % 4. Color Transfer
            disp('color transfer')
            X=imhistmatch(reshape(Xhat,h,w,c),reshape(S,h,w,c));
            X=X(:);

            
            % 5. Denoise
            disp('denoise')
            X = RF(X, sigma_s, sigma_r);
            
        end % end Iterate: for k=1, ... ,Ialg
        
    end % end patch size loop
    % Scale up
    if L>1
        X=imresize(X,L/(L-1));
    end
end % end resolution/scale loop  

% Result
X=reshape(X,imsize,imsize,3);








