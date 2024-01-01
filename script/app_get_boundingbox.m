function [expandedBBoxes,xmin,ymin,xmax,ymax] = app_get_boundingbox(I, expansionAmount,rat,Ecc,lowwer_extent,upper_extent,EulerNumber)
    [~, mserConnComp] = detectMSERFeatures(I, "RegionAreaRange",[200 8000],"ThresholdDelta",4);
    mserStats = regionprops(mserConnComp, "BoundingBox", "Eccentricity", "Solidity", "Extent", "Euler", "Image");
    
    bbox = vertcat(mserStats.BoundingBox);
    w = bbox(:,3);
    h = bbox(:,4);
    aspectRatio = w./h;
    
    filterIdx = aspectRatio' > rat; 
    filterIdx = filterIdx | [mserStats.Eccentricity] > Ecc ;
    filterIdx = filterIdx | [mserStats.Solidity] < .3;
    filterIdx = filterIdx | [mserStats.Extent] < lowwer_extent | [mserStats.Extent] > upper_extent;
    filterIdx = filterIdx | [mserStats.EulerNumber] < EulerNumber;
    mserStats(filterIdx) = [];

    bboxes = vertcat(mserStats.BoundingBox);

    if size(bboxes,2) == 0
        expandedBBoxes = [];
        xmin = [];
        ymin = [];
        xmax = [];
        ymax = [];
        return
    end

    xmin = bboxes(:,1);
    ymin = bboxes(:,2);
    xmax = xmin + bboxes(:,3) - 1;
    ymax = ymin + bboxes(:,4) - 1;
    
    xmin = (1-expansionAmount) * xmin;
    xmax = (1+expansionAmount) * xmax;
    
    xmin = max(xmin, 1);
    ymin = max(ymin, 1);
    xmax = min(xmax, size(I,2));
    ymax = min(ymax, size(I,1));
    
    expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
end