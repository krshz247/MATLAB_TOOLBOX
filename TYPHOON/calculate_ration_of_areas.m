function [ p_fit,  A_sub, B_sub] = calculate_ration_of_areas( A, B_in, varargin )
% Calculates the ration of subimage A to subimage B based on a scattered
% plot and a linear fit. 
%  - This method should be more robust to errors in bakcground corretion.
%  - It also overlays the two images to reduce shift-errores
% 
% Input:    A = channel 1 of image (or subimage)
%           B_in = channel 2 of image, must have same size as A
%           display_plot (optional) 
% Example:  calculateRation(A, B)
%           calculateRation(A, B, 'display', 'on')

    % parse input variables
    p = inputParser;
    default_display = 'off';
    expected_display = {'on', 'off'};
    
    addRequired(p,'A',@isnumeric);
    addRequired(p,'B_in',@isnumeric);
    addParameter(p,'display', default_display,  @(x) any(validatestring(x,expected_display))); % check display is 'on' or 'off'

    parse(p, A, B_in, varargin{:});
    display_bool = strcmp(p.Results.display, 'on');

    % check for sizes of images
    if ~( (size(A,1)==size(B_in,1)) && (size(A,2)==size(B_in,2)) )
        disp('Warning: A and B do not have the same size.')
    end
    % Find best overlay of images
    [cc, shift, B] = xcorr2_bounded(A, B_in, 5, 0); % find the best overlay of images with +- 5 pixel
    
    % only use subimage for further analysis (because it might have been
    % shifted)
    dy = shift(2);
    dx = shift(1);
    
    B_sub = B( max(1,1+dy):min(size(B,1), size(B,1)+dy), max(1,1+dx):min(size(B,2), size(B,2)+dx) );
    A_sub = A( max(1,1+dy):min(size(B,1), size(B,1)+dy), max(1,1+dx):min(size(B,2), size(B,2)+dx) );

       
    % Fit a line to the scattered points ot obtain slope and offset
    p_fit = polyfit(B_sub(:), A_sub(:), 1);
        % scatter plot of data (if desired
   %%
           a_tmp = A_sub(:);
        b_tmp = B_sub(:);

        t_a = mean(a_tmp);
        t_b = mean(b_tmp);
        ab = [a_tmp, b_tmp];
        ab_sort = ab(ab(:,1)>t_a & ab(:,2)>t_b, :);
        
        p_g = polyfit(ab_sort(:,2), ab_sort(:,1), 1);
        %%
   %%
    if display_bool
       figure();
        x = [min([B_sub(:); B_in(:)]) max([B_sub(:); B_in(:)])];
        p_raw = polyfit(B_in(:), A(:), 1);
        
        a_tmp = A_sub(:);
        b_tmp = B_sub(:);

        t_a = mean(a_tmp);
        t_b = mean(b_tmp);
        ab = [a_tmp, b_tmp];
        ab_sort = ab(ab(:,1)>t_a & ab(:,2)>t_b, :);
        
        p_g = polyfit(ab_sort(:,2), ab_sort(:,1), 1);

        subplot(4, 4, [1:3, 5:7, 9:11])
        plot(B_in(:), A(:), 'b+', B_sub(:), A_sub(:), 'r.', x, p_raw(1)*x+p_raw(2),  'k--',ab_sort(:,2), ab_sort(:,1), 'g.', x, p_fit(1)*x+p_fit(2), 'k-', x, p_g(1)*x+p_g(2), 'b-')   
        legend({'Data raw', 'Shifted data', 'Fit to raw data', 'Fit to shifted data'}, 'Location', 'NorthWest')
        ylim = get(gca, 'YLim');
        xlim = get(gca, 'XLim');
        set(gca, 'XLim', xlim, 'Ylim', ylim) 

        xlabel('Channel B'), ylabel('Channel A')

        subplot(4, 4, [4;8;12])
        y_hist = ylim(1):(ylim(2)-ylim(1))/100:ylim(2);
        n_y = hist(A_sub(:), y_hist);
        plot( n_y, y_hist, 'r'), hold on
        hline(mean(A_sub(:)), {'b'});
        hline(median(A_sub(:)), {'k'});
        set(gca, 'YLim', ylim)      
        
        subplot(4,4, [13:15])
        x_hist = xlim(1):(xlim(2)-xlim(1))/100:xlim(2);
        n_x = hist(B_sub(:), x_hist);
        plot( x_hist, n_x, 'r'), hold on
        vline(mean(B_sub(:)), {'b'});
        vline(median(B_sub(:)), {'k'});
        set(gca, 'XLim', xlim, 'Ydir', 'reverse') 
        
    end
   %%
    
end

