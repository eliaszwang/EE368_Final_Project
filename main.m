addpath('DomainTransformFilters-Source-v1.0/');

% import images
house=im2double(imread('images/house - small.jpg'));
imsize=400;
house=house(1:imsize,1:imsize,:);
night=im2double(imread('images/starry-night - small.jpg'));
night=night(1:imsize,1:imsize,:);

% Initialize variables

% R = zeros(size(house));
% R(270:290,170:190,:) = 1;
% R = R(:);
mask = segment(rgb2gray(house));
C = house(:);
S = night(:);
sigma_s = 10;
sigma_r = 0.2;
h=imsize; w=imsize; c=3;
patch_sizes=[33 21 13 9].^2 ;
gap_sizes=[28 18  8 5];
X=C+0.2*randn(size(C)); %initialize estimate to content image plus noise 


% Loop over scales L=Lmax, ... ,1
for L=1
    % Loop over patch sizes n=n1, ... ,nm
    for n=patch_sizes(2) %n=Q_size^2
        Q_size=sqrt(n);
        % precompute P
        Pstride=8;
        S = reshape(S, [h w c]);
        P = zeros(c*Q_size*Q_size, (floor( ((h-Q_size+1)-1)/Pstride ) + 1 )*(floor( ((w-Q_size+1)-1)/Pstride ) + 1) );
        for k=1:Pstride:(h-Q_size+1)
            for j=1:Pstride:(w-Q_size+1)
                patch = S(k:k+Q_size-1,j:j+Q_size-1,:);
                P(:,(ceil(k/Pstride)-1)*(floor( ((w-Q_size+1)-1)/Pstride )+ 1) + ceil(j/Pstride) ) = patch(:);
            end
        end
        S=S(:);
        
        % compute PCA of P
        %P = P - repmat(mean(P,2),[1 size(P,2)]);
        [V, D] = eig(P*P');
        [D,I] = sort(diag(D),'descend');
        V = V(:, I);
        
        % find top eig vals
        eig_idx = 1; %size(D,1)
        energy = 0; energy_tot = sum(D);
        for i=1:size(D,1)
            energy = energy + D(i);

            if energy >= 0.95*energy_tot
                eig_idx = i;
                break;
            end
        end
        
        % reduce dimensionality
        Vp = V(:,1:eig_idx);
        Pp = Vp' * P;
        
        % Iterate: for k=1, ... ,Ialg
        for k=1
            
            % 1. Patch Matching
            disp('patch matching')
            z = [];
            Rall=[];
            gap=gap_sizes(patch_sizes==n); %should correspond to current n
            for i=1:gap:h-Q_size+1
                i
                for j=1:gap:w-Q_size+1
                    R = zeros(size(house));
                    R(i:i+Q_size-1,j:j+Q_size-1,:) = 1;
                    R = R(:);
                    Rall=[Rall R];
                    [ks, ls, zij] = nearest_n(R, X, Q_size, S, h, w, c, Pp,Vp,Pstride);
                    z = [z zij];                   
                end
            end
            
            % 2. Robust Aggregation
            disp('robust aggregation')
            [Xtilde]=irls(Rall,X,z);

            
            % 3. Content Fusion
            disp('content fusion')
            W = repmat(mask(:),c,1);
            Nc=(imsize/L)^2;
            %W=0.5*ones(3*Nc,1);
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








