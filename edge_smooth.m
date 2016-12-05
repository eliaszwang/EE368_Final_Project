function out_img = edge_smooth(in_img, n_gap)

typ=1;

if typ==1
    [h, w, c] = size(in_img);

    mask = zeros(h, w, c);
    mask(1,:,:) = 1;
    mask(h,:,:) = 1;
    mask(:,1,:) = 1;
    mask(:,w,:) = 1;
    
    mask = imgaussfilt(mask, n_gap/3);
    mask = 1 - mask / max(mask(:));
    
    out_img = mask .* in_img;
end

end