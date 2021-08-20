
%% a simple single level block matcher
clear; clear global; close all;

%%%%%%%%%%%%%%% parameters etc %%%%%%%%%%%%%%%%%%%%%%%%

filename    = './qonly.360x288.y';
hres        = 360;  % horizontal size
vres        = 288;  % versical size
B           = 16;    % block size
w           = 8;   % window search range is +/-w 
mae_t       = 2;    % motion threshold MAE per block
start_frame = 1;    
nframes     = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%open the file for reading
fin = fopen(filename,'rb');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% x,y coordimates of the block centres
x = (B/2):B:hres-(B/2); 
y = (B/2):B:vres-(B/2); 

fprintf('processing the sequence\n')
    
for frame = start_frame:start_frame+nframes-1

    fprintf(sprintf('frame %03d/%03d\n', frame, nframes))

    fseek(fin,hres*vres*(frame-1),'bof');
    past_frame = double(fread(fin,[hres vres],'uint8')');
    
    fseek(fin,hres*vres*frame,'bof');
    curr_frame = double(fread(fin,[hres vres],'uint8')');
    
    non_mc_dfd = abs(curr_frame-past_frame); 

    figure; image(curr_frame-past_frame+128); colormap(gray(256));
    title('Non motion compensated Frame Difference');
    drawnow;

    [bdx, bdy, dfd] = blockmatching(curr_frame, past_frame, B, w, mae_t);
    
%     figure; image((1:hres),(1:vres),curr_frame);colormap(gray(256)); axis image; 
%     hold on; title('Motion vectors for each block superimposed on current frame');
%     h = quiver(x, y, bdx, bdy, 0, 'y-');
%     set(h,'linewidth',1.5); 
%     xlabel('Columns'); ylabel('Rows'); hold off;drawnow;
     
    figure; image(dfd + 128); colormap(gray(256));
    
end %end of current frame
fclose(fin);
%figure; plot(d)