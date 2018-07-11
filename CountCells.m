function [bw3] = CountCells(inputImage) 

if inputImage == "StackNinja1.bmp"
    variable = "StackNinja1.bmp";
end
if inputImage == "StackNinja2.bmp"
    variable = "StackNinja2.bmp";
end
if inputImage == "StackNinja3.bmp"
    variable = "StackNinja3.bmp";
end
   

ImageUsed = imread(inputImage);

% ------ Pre-processing ------------
GreenChannel = ImageUsed(:,:,2);
% make image brighter
GreenChannel = immultiply(GreenChannel, 1.4);

% remove noises in the image 
GreenChannel = medfilt2(GreenChannel, [5 5]);
GreenChannel = imgaussfilt(GreenChannel);

% get edges using laplacian 
GreenChannel_edge = imfilter(GreenChannel, fspecial('laplacian'));


SE = strel('disk', 1);


% subtract the edge from original image
GreenChannel3 = GreenChannel - GreenChannel_edge;

% remove remaining impulse noise 
finalGreen = medfilt2(GreenChannel3, [5 5]);



% ----------- Segmentation --------------
cannyEdge = edge(finalGreen, 'canny');  % get the edge of the image

final4 = imdilate(cannyEdge, SE);  % connect the edges together 


final5 = imfill(final4, 'holes');   % fill remaining holes


SS = strel('disk', 2);

final6 = imerode(final5, SS);  % To avoid nuclei from connecting

final7 = bwareaopen(final6 , 10);  % remove some small objects in the image  


final8 = imdilate(final7, SS);

% watershed part | seperating connected objects 
D = -bwdist(~final8);   

mask = imextendedmin(D,2);

D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = final8;
bw3(Ld2 == 0) = 0;  
%---------------------


% count the number of cells found in image
CC = bwconncomp(bw3);

% --------- Representation -----------
% show changes in the images for the user 

figure, imshow(ImageUsed)
title("Your input image: " + variable)


figure, imshow(finalGreen)
title("Your image after pre-processing")


figure, imshow(cannyEdge)
title("Canny edge of your image")


figure, imshow(bw3)
title({"Your final processed image", "Total number of cells found: " + num2str(CC.NumObjects)})


figure, imshow(imoverlay(ImageUsed, bwperim(bw3)))
title("Amount of cells detected compared to the original input image")

end

