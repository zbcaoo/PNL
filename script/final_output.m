function img_for_subwindow = final_output(tag_color, dx1, dx2, dy1, dy2, img_for_subwindow, xp)
    this_size = size(img_for_subwindow);
    dy1 = max(1,dy1);
    dx1 = max(1,dx1);
    dy2 = min(dy2,this_size(1));
    dx2 = min(dx2,this_size(2));

    width = dy2 - dy1 + 1;
    height = dx2 - dx1 + 1;

    xp = imresize(xp,[width + 1, height + 1]);
    xp = xp(1:(dy2 - dy1 + 1),1:round((dx2 - dx1 + 1)));

    switch tag_color
        case 'Red'
            img_for_subwindow(dy1:dy2,dx1:dx2,1) = 255 - xp .* (255 - img_for_subwindow(dy1:dy2,dx1:dx2,1));
            img_for_subwindow(dy1:dy2,dx1:dx2,2) = xp .* img_for_subwindow(dy1:dy2,dx1:dx2,2);
            img_for_subwindow(dy1:dy2,dx1:dx2,3) = xp .* img_for_subwindow(dy1:dy2,dx1:dx2,3);
        case 'Green'
            img_for_subwindow(dy1:dy2,dx1:dx2,1) = xp .* img_for_subwindow(dy1:dy2,dx1:dx2,1);
            img_for_subwindow(dy1:dy2,dx1:dx2,2) = 255 - xp .* (255 - img_for_subwindow(dy1:dy2,dx1:dx2,2));
            img_for_subwindow(dy1:dy2,dx1:dx2,3) = xp .* img_for_subwindow(dy1:dy2,dx1:dx2,3);
        case 'Blue'
            img_for_subwindow(dy1:dy2,dx1:dx2,1) = xp .* img_for_subwindow(dy1:dy2,dx1:dx2,1);
            img_for_subwindow(dy1:dy2,dx1:dx2,2) = xp .* img_for_subwindow(dy1:dy2,dx1:dx2,2);
            img_for_subwindow(dy1:dy2,dx1:dx2,3) = 255 - xp .* (255 - img_for_subwindow(dy1:dy2,dx1:dx2,3));
        case 'Yellow'
            img_for_subwindow(dy1:dy2,dx1:dx2,1) = 255 - xp .* (255 - img_for_subwindow(dy1:dy2,dx1:dx2,1));
            img_for_subwindow(dy1:dy2,dx1:dx2,2) = 255 - xp .* (255 - img_for_subwindow(dy1:dy2,dx1:dx2,2));
            img_for_subwindow(dy1:dy2,dx1:dx2,3) = xp .* img_for_subwindow(dy1:dy2,dx1:dx2,3);
    end
end

