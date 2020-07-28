%% 1. Load Data Set
% Images and GT Labels Datapath - Local
impath = 'img-jpg';
labpath = 'gt-jpg';

% Images and GT Labels Datapath - Server
%impath = '/home/server/MATLAB/dataset/MP-IDB/Falciparum/img';
%labpath = '/home/server/MATLAB/dataset/MP-IDB/Falciparum/gt';

% Images and Labels Datastore
imds = imageDatastore(impath);
lds = imageDatastore(labpath);

malariaDataset = table;
malariaDataset.imageFilename = imds.Files(:);

csvTable = table;
%% 2. Conversion of BW ground-truths to rectangular bounding boxes to train the detector 
for i=1:numel(imds.Files) 
    
    I = imread(imds.Files{i});
    L = imread(lds.Files{i});
    [height, width] = size(L);

    % Obtain Bounding Boxes --- TODO transform to function
    L_labels = logical(L);
    L_props = regionprops(L_labels, 'BoundingBox'); % for Object Detection
    %L_props2 = regionprops(L_labels, 'PixelList'); % for Semantic Segmentation

    bboxNumber = max(size(L_props));
    %figure; imshow(I);
    
    parasites = zeros(bboxNumber, 4);
 
    for k = 1:bboxNumber
        box = L_props(k).BoundingBox;
        %rectangle('Position', [box(1), box(2), box(3), box(4)], 'EdgeColor', 'r', 'LineWidth', 2)
        if(box(3) * box(4) > 4)
            parasites(k, 1:4) = [ box(1), box(2), box(3), box(4) ];

            [filepath, name, ext] = fileparts(imds.Files{i});

            csvTable.filename{row} = strcat(name, ext);
            csvTable.width{row} = width;
            csvTable.height{row} = height;
            csvTable.class{row} = 'parasite';
            csvTable.xmin{row} = ceil(box(1));
            csvTable.ymin{row} = ceil(box(2));
            csvTable.xmax{row} = ceil(box(1)) + box(3) - 1;
            csvTable.ymax{row} = ceil(box(2)) + box(4) - 1;
            row = row + 1;
        end
    end
    
    malariaDataset.parasite{i} = parasites;
       
end

% TensorFlow Object Detection CSV format
writetable(csvTable, 'MP-IDB-ann.csv');


