function W = bg_hall(C, hall)

typ = 1;

if typ==1
    sigma_edge = 1*1; sigma_blur = 1*3;
    E = edge(rgb2gray(C), 'log', 0.03, sigma_edge);
    B = imgaussfilt(0.5*E, sigma_blur);
    mask = B > mean2(B);
    BW = activecontour(rgb2gray(C),mask);
    W = repmat(BW,[1 1 3]).*C + repmat(1-BW,[1 1 3]).*hall;
elseif typ==2
    sigma_edge = scale*1; sigma_blur = scale*7;
    E = edge(C, 'log', 0.03, sigma_edge);
    B = imgaussfilt(0.5*E, sigma_blur);
    mask = B > mean2(B);
    BW = activecontour(C,mask);
    W = imgaussfilt(double(BW+10*E),sigma_blur);
elseif typ==3
    sigma_blur = scale*20;
    BW = edge(C, 'roberts', 0.05);
    %imagesc(BW)
    W = imgaussfilt(0.5*BW, sigma_blur);
end




end