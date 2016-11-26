function W = segment(C)

typ = 1;

if typ==1
    sigma_edge = 20; sigma_blur = 20;
    BW = edge(C, 'log', 0, sigma_edge);
    W = imgaussfilt(0.5*BW, sigma_blur);
end














end