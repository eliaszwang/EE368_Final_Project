function W = segment(C, scale)

typ = 1;

if typ==1
    sigma_edge = scale*20; sigma_blur = scale*20;
    BW = edge(C, 'log', 0, sigma_edge);
    W = imgaussfilt(0.5*BW, sigma_blur);
end














end