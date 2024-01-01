function processing_img(app, colorImage)
    clc
    warning off;
    if(~(app.CheckBox.Value || app.DubaiCheckBox.Value || app.CalibriCheckBox.Value || app.YuGothicCheckBox.Value))
        errordlg('Please select at least one font.')
        return
    end

    if (app.L_ExtentSpinner_2.Value > app.H_ExtentSpinner_2.Value) || (app.L_ExtentSpinner.Value > app.H_ExtentSpinner.Value)
        errordlg('L_Extent must be lower than H_Extent.')
        return
    end

    if app.isopen
        delete(app.DialogApp);
        app.isopen = 0;
    end

    app.PushTool2.Enable = 'off';
    app.PushTool.Enable = 'off';
    app.PushTool3.Enable = 'off';
    pause(0.1);
    processing_bar = waitbar(0,'Processing...');


    img_type = class(colorImage);
    tag_color = app.TagDropDown.Value;
    app.celltexts = {};
    app.celltexts_2 = {};
    gray_scale = im2gray(colorImage);
    I = imbinarize(gray_scale,app.EccentricitySpinner_3.Value);
    
    waitbar(0,processing_bar,'Get bounding boxes 1')
    
    [expandedBBoxes,xmin,ymin,xmax,ymax] = app_get_boundingbox(I,0.05,app.WHSpinner_2.Value,app.EccentricitySpinner.Value,app.L_ExtentSpinner_2.Value,app.H_ExtentSpinner_2.Value,app.EulerNumberSpinner.Value);
    
    switch app.OutputDropDown.Value
        case 'Gray'
            IExpandedBBoxes = insertShape(gray_scale,"FilledRectangle",expandedBBoxes,"LineWidth",3,"Color",tag_color);
            img_for_subwindow = gray_scale;
            img_for_subwindow = cat(3, img_for_subwindow, img_for_subwindow, img_for_subwindow);
        case 'B/W'
            IExpandedBBoxes = insertShape(im2uint8(I),"FilledRectangle",expandedBBoxes,"LineWidth",3,"Color",tag_color);
            img_for_subwindow = im2uint8(I);
            img_for_subwindow = cat(3, img_for_subwindow, img_for_subwindow, img_for_subwindow);
        case 'RGB'
            IExpandedBBoxes = insertShape(colorImage,"FilledRectangle",expandedBBoxes,"LineWidth",3,"Color",tag_color);
            img_for_subwindow = colorImage;
    end
    
    if size(expandedBBoxes,1) <=0
        errordlg('There are no recognizable numbers in the image.')
        app.PushTool.Enable = 'on';
        app.PushTool2.Enable = 'on';
        app.PushTool3.Enable = 'on';
        delete(processing_bar);
        return
    end

    imshow(IExpandedBBoxes,'Parent',app.UIAxes_1);
    
    overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);
    n = size(overlapRatio,1); 
    overlapRatio(1:n+1:n^2) = 0;
    g = graph(overlapRatio);
    componentIndices = conncomp(g);
    
    xmin = accumarray(componentIndices', xmin, [], @min);
    ymin = accumarray(componentIndices', ymin, [], @min);
    xmax = accumarray(componentIndices', xmax, [], @max);
    ymax = accumarray(componentIndices', ymax, [], @max);
    textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
    numRegionsInGroup = histcounts(componentIndices);

    if app.OFFButton.Value
        textBBoxes(numRegionsInGroup == 1, :) = [];
    end 
    
    switch app.OutputDropDown.Value
        case 'Gray'
            bi_TextRegion = insertShape(gray_scale, "FilledRectangle", textBBoxes,"LineWidth",3,"Color",tag_color);
        case 'B/W'
            bi_TextRegion = insertShape(im2uint8(I), "FilledRectangle", textBBoxes,"LineWidth",3,"Color",tag_color);
        case 'RGB'
            bi_TextRegion = insertShape(colorImage, "FilledRectangle", textBBoxes,"LineWidth",3,"Color",tag_color);
    end
    
    imshow(bi_TextRegion,'Parent',app.UIAxes_2);

    waitbar(0.2,processing_bar,'Get bounding boxes 2')

    valid = [];
    valid_boxes = [];
    for i=1:size(textBBoxes,1)
        minx = textBBoxes(i,1)-2;
        minx = max(3,minx);
        maxx = textBBoxes(i,1) + textBBoxes(i,3)+2;
        maxx = min(maxx,size(I,2)-2);
        miny = textBBoxes(i,2)-2;
        miny = max(3,miny);
        maxy = textBBoxes(i,2) + textBBoxes(i,4)+2;
        maxy = min(maxy,size(I,1)-2);
        j = I(miny:maxy,minx:maxx);
        if std(sum(j,1)) < 30
            valid = [valid,i];
            valid_boxes = [valid_boxes;[minx,maxx,miny,maxy]];
        end
    end

    if numel(valid) == 0
        errordlg('There are no recognizable numbers in the image.')
        app.PushTool.Enable = 'on';
        app.PushTool2.Enable = 'on';
        app.PushTool3.Enable = 'on';
        delete(processing_bar);
        return
    end

    waitbar(0.3,processing_bar,'Processing boxes')
    
    for i=1:numel(valid)

        waitbar(0.3 + 0.6 * i / numel(valid),processing_bar,['Boxes ' num2str(i) ' / ' num2str(numel(valid)) '.'])

        string = sprintf('Line %s :', num2str(i));
        app.celltexts=horzcat(app.celltexts,string);

        ax1 = subplot(numel(valid), 2, i * 2 - 1,'Parent',app.Panel);
        present_img = I(valid_boxes(i,3):valid_boxes(i,4),valid_boxes(i,1):valid_boxes(i,2));
        ocrtxt = ocr(colorImage(valid_boxes(i,3):valid_boxes(i,4),valid_boxes(i,1):valid_boxes(i,2)));
        
        app.celltexts_2 = horzcat(app.celltexts_2,string);

        if isempty(ocrtxt.Text)
            app.celltexts_2 = horzcat(app.celltexts_2,'_________',' ');
        else
            app.celltexts_2 = horzcat(app.celltexts_2,ocrtxt.Text,' ');
        end
        
        switch app.OutputDropDown.Value
            case 'Gray'
                not01 = gray_scale(valid_boxes(i,3):valid_boxes(i,4),valid_boxes(i,1):valid_boxes(i,2));
                imshow(not01,'Parent',ax1);
            case 'B/W'
                imshow(~present_img,'Parent',ax1);
            case 'RGB'
                not01 = colorImage(valid_boxes(i,3):valid_boxes(i,4),valid_boxes(i,1):valid_boxes(i,2));
                imshow(not01,'Parent',ax1);
        end
        
        [expandedBBoxes,xmin,ymin,xmax,ymax] = app_get_boundingbox(present_img,0,app.WHSpinner.Value,app.EccentricitySpinner_2.Value,app.L_ExtentSpinner.Value,app.H_ExtentSpinner.Value,app.EulerNumberSpinner_2.Value);
        del = [];
        for ii = 1:size(expandedBBoxes,1)
            x1 = expandedBBoxes(ii,1);
            x2 = expandedBBoxes(ii,1) + expandedBBoxes(ii,3);
            y1 = expandedBBoxes(ii,2);
            y2 = expandedBBoxes(ii,2) + expandedBBoxes(ii,4);
            for j = 1:size(expandedBBoxes,1)
                if(j==ii)
                    continue
                end
                xi = x1 >= expandedBBoxes(j,1);
                xa = x2 <= (expandedBBoxes(j,1) + expandedBBoxes(j,3));
                yi = y1 >= expandedBBoxes(j,2);
                ya = y2 <= (expandedBBoxes(j,2) + expandedBBoxes(j,4));
                if(xi && xa && yi && ya)
                    del = [del,ii];
                end
            end
   
            skeleton = bwmorph(~present_img,'thin');
            if app.ONButton.Value && (sum(skeleton(:,max(1,floor(x1-0))))~=0 || sum(skeleton(:,min(size(present_img,2),round(x2+0))))~=0)
                del = [del,ii];
            end
    
            if expandedBBoxes(ii,4) < size(present_img,1) * 0.4
                del = [del,ii];
            end
        end
    
        deleted_box = expandedBBoxes(del,:);
        expandedBBoxes(del,:) = [];
        xmin(del,:) = [];
        ymin(del,:) = [];
        xmax(del,:) = [];
        ymax(del,:) = [];
        
        ax2 = subplot(numel(valid), 2, i * 2,'Parent',app.Panel);
        switch app.OutputDropDown.Value
            case 'B/W'
                IExpandedBBoxes = insertShape(im2uint8(~present_img),"rectangle",expandedBBoxes,"LineWidth",3,"Color",tag_color);
            otherwise
                IExpandedBBoxes = insertShape(not01,"rectangle",expandedBBoxes,"LineWidth",3,"Color",tag_color);
        end
        
        IExpandedBBoxes = insertShape(IExpandedBBoxes,"rectangle",deleted_box,"LineWidth",3,"Color","g");
        imshow(IExpandedBBoxes,'Parent',ax2);
    
        if(size(expandedBBoxes,1) == 0 || size(expandedBBoxes,2) == 0)
            string = sprintf('_________');
            app.celltexts=horzcat(app.celltexts,string,' ');
            continue
        end
    
        expandedBBoxes = sortrows(expandedBBoxes,1);
        recBoxes = [];
        recBoxes(:,1) = expandedBBoxes(:,1);
        recBoxes(:,2) = expandedBBoxes(:,1) + expandedBBoxes(:,3);
        recBoxes(:,3) = expandedBBoxes(:,2);
        recBoxes(:,4) = expandedBBoxes(:,2) + expandedBBoxes(:,4);
    
        output = [];
        for ii = 1:size(expandedBBoxes,1)
    
            record = [];
            font_list = {};
            present_char = present_img(recBoxes(ii,3):recBoxes(ii,4),recBoxes(ii,1):recBoxes(ii,2));
            
            if(app.CheckBox.Value)
                [record,font_list] = app_switch_for_fonts(app,expandedBBoxes,present_char,'ht',record,ii,font_list);
            end

            if(app.DubaiCheckBox.Value)
                [record,font_list] = app_switch_for_fonts(app,expandedBBoxes,present_char,'dubai',record,ii,font_list);
            end

            if(app.CalibriCheckBox.Value)
                [record,font_list] = app_switch_for_fonts(app,expandedBBoxes,present_char,'Calibri',record,ii,font_list);
            end

            if(app.YuGothicCheckBox.Value)
                [record,font_list] = app_switch_for_fonts(app,expandedBBoxes,present_char,'Yu_Gothic',record,ii,font_list);
            end

            findm = find(record(:,1) == max(record(:,1)));
            yPeak = record(findm,2);
            xPeak = record(findm,3);
            templateWidth = record(findm,4);
            templateHeight = record(findm,5);
            textString = letters(record(findm,6));

            if ii >= 2
                if recBoxes(ii,1) - recBoxes(ii - 1,2) > mean(record(:,4)) / 2
                    output = [output,' '];
                end
            end

            output = [output,textString];
            corr_offset = [(xPeak-templateWidth) (yPeak-templateHeight)];
            boxRect = [corr_offset(1) corr_offset(2) templateWidth, templateHeight];
            
            dx1 = corr_offset(1) + recBoxes(ii,1) + valid_boxes(i,1);
            dx2 = dx1 + templateWidth;
            dy1 = corr_offset(2) + recBoxes(ii,3) + valid_boxes(i,3);
            dy2 = dy1 + templateHeight;
            xp = imread([cell2mat(font_list(findm)) '\tem_' num2str(record(findm,6)) '.png']);
            
            if strcmp(img_type,'uint8')
                xp = im2uint8(xp);
            elseif strcmp(img_type,'uint16')
                xp = im2uint16(xp);
            elseif strcmp(img_type,'uint32')
                xp = im2uint32(xp);
            elseif strcmp(img_type,'uint64')
                xp = im2uint64(xp);
            else
                fprintf("Wrong image type input.\n")
            end

            xp = min(xp,1);
            img_for_subwindow = final_output(tag_color, dx1, dx2, dy1, dy2, img_for_subwindow, xp);
        end
        if isempty(output)
            string = sprintf('_________');
            app.celltexts=horzcat(app.celltexts,string,' ');
        else
            string = sprintf('%s',output);
            app.celltexts=horzcat(app.celltexts,string,' ');
        end
    end
    waitbar(1,processing_bar,'Done')
    app.DialogApp = sub_window(app,app.celltexts,app.celltexts_2,img_for_subwindow);
    app.isopen = 1;
    app.PushTool.Enable = 'on';
    app.PushTool2.Enable = 'on';
    app.PushTool3.Enable = 'on';
    delete(processing_bar);
end