function [W, BWs] = bg_hall(C, hall)

typ = 3;

if typ==1
    % sharp edge transition from hallucination in bg to content in fg
    sigma_edge = 1*1; sigma_blur = 1*3;
    E = edge(rgb2gray(C), 'log', 0.03, sigma_edge);
    B = imgaussfilt(0.5*E, sigma_blur);
    mask = B > mean2(B);
    BW = activecontour(rgb2gray(C),mask);
    W = repmat(BW,[1 1 3]).*C + repmat(1-BW,[1 1 3]).*hall;
elseif typ==2
    % just hallucination in background, ones in foreground
    sigma_edge = 1*1; sigma_blur = 1*3;
    E = edge(rgb2gray(C), 'log', 0.03, sigma_edge);
    B = imgaussfilt(0.5*E, sigma_blur);
    mask = B > mean2(B);
    BW = activecontour(rgb2gray(C),mask);
    W = repmat(1-BW,[1 1 3]).*imgaussfilt(C,12) + repmat(BW,[1 1 3]).*hall;
elseif typ==3
    % smooth transition from hallucination to content/foreground
    sigma_edge = 1*1; sigma_blur = 1*3;
    E = edge(rgb2gray(C), 'log', 0.03, sigma_edge);
    B = imgaussfilt(0.5*E, sigma_blur);
    mask = B > mean2(B);
    BW = activecontour(rgb2gray(C),mask);
    BWs = imgaussfilt(double(BW),3);
    BWs = BWs / max(BWs(:));
    W = repmat(BWs,[1 1 3]).*C + repmat(1-BWs,[1 1 3]).*hall;
end




end