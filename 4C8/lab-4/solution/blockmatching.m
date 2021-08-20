function [motion_x, motion_y, dfd] = blockmatching(curr_frame, other_frame, B, w, mae_t)
% [motion_x, motion_y, dfd] = blockmatching(curr_frame, other_frame, B, w, mae_t)
%
% This function implements a simple Block Matching algorithm
% The block size is B (eg. 16), Edges of the image are
% ignored. The search width is w (eg. 4).
% The algorithm searches for a match between blocks only when the MAE for a
% block with its co-located block in the previous frame, exceeds mae_t the
% motion threshold.

[vres, hres] = size(curr_frame);

% lx, ly are the number of blocks across the picture
lx = length((B/2):B:hres-(B/2));
ly = length((B/2):B:vres-(B/2));

motion_x = zeros(ly,lx); %the horizontal component of motion
motion_y = zeros(ly,lx); %the vertical component of motion
dfd = zeros(vres, hres);

search_range_x = -w:w; % horizontal search range
search_range_y = -w:w; % vertical search range

non_mc_dfd = abs(curr_frame-other_frame);

% leave out a border of BxB pels so you don't have to bother about borders
ny = 2;
for j = B:B:vres-B+1-B+1
    nx = 2;
    for i = B:B:hres-B+1-B+1
        bx = i:i+B-1; by = j:j+B-1;
        ref_block = curr_frame(by,bx);
        non_mc_dfd_block = non_mc_dfd(by,bx);
        block_mae = mean(non_mc_dfd_block(:));
        if ( block_mae > mae_t )
            % searching for each possible block in the search window
            % in the past_frame and measure the mean abs dfd
            % for every offset block.
            
            mc_block = ref_block;
            min_error_ = +inf;
            for jj = search_range_y
                for ii = search_range_x
                    other_block = fetch_block(other_frame, by+jj, bx+ii);
                    % we use fetch_block (see implementation at end of file) 
                    % to deal with when outside of the image boundaries.

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Find the block with minimum DFD, save it to mc_block
                    % and assign its offset to 'motion_x(ny,nx)' 
                    % and 'motion_y(ny,nx)'

                    diff_block = abs(other_block - ref_block);
                    mae = mean(diff_block(:));
                    
                    if ( mae < min_error_ )
                        mc_block = other_block; min_error_ = mae;
                        motion_x(ny,nx) = ii; motion_y(ny,nx) = jj;
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end
            dfd(by,bx) = ref_block - mc_block;

        else
            motion_x(ny,nx) = 0;
            motion_y(ny,nx) = 0;
        end
        nx = nx+1;
    end % end of horizontal scan
    ny = ny+1;
end % end of vertical scan

% fetch block with index range bx, by in frame. handle boundaries by
% repeating the boundary values.
function block = fetch_block(frame, by, bx)
    block = frame(max(min(by,end),1),max(min(bx,end),1));