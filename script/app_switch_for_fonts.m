function [record,font_list] = app_switch_for_fonts(app,expandedBBoxes,present_char,font,record,ii,font_list)
    start = 0;
    switch app.DropDown.Value
        case 'Number'
            endding = 9;
        case 'Both'
            switch font
                case 'Yu_Gothic'
                    endding = 35;
                case 'Dubai'
                    endding = 35;
                otherwise
                    endding = 9;
            end
        case 'Letter'
            start = 10;
            endding = 35;
    end

    for iii = start:endding
        file_name = [font '\tem_' num2str(iii) '.png'];
        if exist(file_name,"file")
            Image = imread(file_name);
        else
            continue;
        end
        Image = imresize(Image,[expandedBBoxes(ii,4)-1 NaN]);
        templateWidth = size(Image,2);
        templateHeight = size(Image,1);        
        if templateWidth > size(present_char,2)
            Image = imresize(Image,[expandedBBoxes(ii,4)-1 expandedBBoxes(ii,3)-1]);
        end
        correlationOutput = normxcorr2(Image,present_char);
        
        [max_v, maxIndex] = max(abs(correlationOutput(:)));
        max_v = max_v * min(1,templateWidth / size(present_char,2)) * psnr(im2uint8(imresize(Image,size(present_char))),im2uint8(present_char));
        [yPeak, xPeak] = ind2sub(size(correlationOutput),maxIndex(1));
        record = [record;[max_v,yPeak,xPeak,templateWidth,templateHeight,iii,templateWidth / size(present_char,2)]];
        font_list = [font_list;{font}];
    end
end
