
%% a simple single level block matcher
clear; clear global; close all;

%%%%%%%%%%%%%%% parameters etc %%%%%%%%%%%%%%%%%%%%%%%%

filename    = './qonly.360x288.y';
hres        = 360;  % horizontal size
vres        = 288;  % versical size
B           = 16;   % block size
w           = 4;    % window search range is +/-w 
mae_t       = 2;    % motion threshold MAE per block
start_frame = 1;    
nframes     = 30;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%open the file for reading
fin = fopen(filename,'rb');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize error parameters & for-loop for plots
mc_error = (nframes); non_mc_error = (nframes);
figure;
for mae_t = [1 2 4 8]
    tic
    for frame = start_frame:start_frame+nframes-1
        fseek(fin,hres*vres*(frame-1),'bof');
        past_frame = double(fread(fin,[hres vres],'uint8')');
        
        fseek(fin,hres*vres*frame,'bof');
        curr_frame = double(fread(fin,[hres vres],'uint8')');
        
        % calc motion & non-motion compensated DFD
        [~,~,mc_dfd] = blockmatching(curr_frame, past_frame, B, w, mae_t);
        non_mc_dfd = abs(curr_frame-past_frame);
        
        mc_error(frame) = sum(mean(abs(mc_dfd(:))))/numel(mc_dfd);
        non_mc_error(frame) = sum(mean(non_mc_dfd(:)))/numel(non_mc_dfd);
    end
    plot((start_frame:nframes),mc_error, '-x'); hold on;
    toc
end
plot((start_frame:nframes),non_mc_error, '-x');

legend('MAE_t = 1','MAE_t = 2','MAE_t = 4','MAE_t = 8','Non-Motion Compensated',"Location",'best');

ylabel('Mean Absolute DFD'); xlabel('Frame Number');  title('Motion Estimation v/s No Motion Estimation');