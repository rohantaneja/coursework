function testBlockMatching()
% test the DFD script

fprintf('\nreading video file: \t');

filename = 'qonly.360x288.y';
hres = 360; % horizontal size
vres = 288; % versical size
B = 16;     % block size
w = 4;      % window search range is +/-w 
mae_t = 2;  % motion threshold MAE per block
fin = fopen(filename,'rb');

frame = 1;
fseek(fin,hres*vres*(frame-1),'bof');
past_frame = double(fread(fin,[hres vres],'uint8')');

fseek(fin,hres*vres*frame,'bof');
curr_frame = double(fread(fin,[hres vres],'uint8')');

fprintf(' OK\n');

fprintf('running blockmatching: \t');
[bdx1, bdy1, dfd1] = blockmatching(curr_frame, past_frame, B, w, mae_t);
fprintf(' OK\n');

if (exist('DFD_test.mat','file'))
    load('DFD_test.mat')
else
    fprintf('DFD test file is missing\n');
end

e = sum(sum(abs(dfd1_test - dfd1)));
if (e < 1e-7)
  fprintf('DFD: \t\t\t OK\n');
else 
  fprintf('DFD: \t\t\t FAILED (err=%f)\n', e);
end

e = sum(sum(abs(bdx1_test - bdx1)));
if (e < 1e-7)
  fprintf('vectors x: \t\t OK\n');
else 
  fprintf('vectors x: \t\t FAILED (err=%f)\n', e);
end

e = sum(sum(abs(bdy1_test - bdy1)));
if (e < 1e-7)
  fprintf('vectors y: \t\t OK\n');
else 
  fprintf('vectors y: \t\t FAILED (err=%f)\n', e);
end
fprintf('\n');
