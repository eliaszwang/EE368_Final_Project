function W = segment(C, scale)

typ = 2;

if typ==1
    sigma_edge = scale*10; sigma_blur = scale*20;
    BW = edge(C, 'log', 0, sigma_edge);
    imagesc(BW)
    W = imgaussfilt(0.5*BW, sigma_blur);
elseif typ==2
    sigma_edge = scale*10; sigma_blur = scale*20;
    BW = edge(C, 'log', 0, sigma_edge);
    imagesc(BW)
    W = imgaussfilt(0.5*BW, sigma_blur);
end














end