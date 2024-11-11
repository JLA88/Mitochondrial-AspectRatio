function [BW, labelimage, DataTable] = MitoMeasurements(name, image1, image2)

    %Calculate original point spread function
    PSF = fspecial('gaussian',7,10);
    INITPSF = ones(size(PSF));

    [Decon, ~] = deconvblind(image1, INITPSF, 10);
    
    %Image Segmentation Filter out Image background, Saturate Images signal
    background = imopen(Decon,strel('disk',15));
    TI3 = Decon - background;
    
%     net = denoisingNetwork('DnCNN');
%     TI3 = denoiseImage(TI3,net);
    
    BW = imbinarize(TI3, 'adaptive', 'sensitivity', 0.050);

    BW = bwareaopen(BW, 50, 4);
    
    seD = strel('diamond',1);
    BW = imerode(BW,seD);

    BW = bwareaopen(BW, 10, 4);
    
    [lbl, ~] = bwlabel(BW, 8);
    nLabels = max(lbl(:));
    [~, Labels] = bwboundaries(lbl,'noholes');
    stats = regionprops(Labels, image2, 'Area', 'Centroid', 'Circularity', 'MajorAxisLength', 'MinorAxisLength', 'MeanIntensity');

    labelimage = label2rgb(lbl, jet(nLabels), 'w', 'shuffle');


    [m, ~] = size(stats);

    for k = 1:m
        aspect(k, 1) = stats(k,1).MajorAxisLength/stats(k,1).MinorAxisLength;
    end

    lable = repmat(name, [m 1]);

    DataTable = table(lable, aspect);
    stats = struct2table(stats);
    DataTable = [DataTable stats];
    
end
