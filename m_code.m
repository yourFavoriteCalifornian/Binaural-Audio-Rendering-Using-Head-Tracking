% Arduino object
uno = arduino;

% Sensor object
imu = mpu9250(uno);

% Create and set the sample rate of the Kalman filter.
Fs = imu.SampleRate;
imufilt = imufilter('SampleRate',Fs);

%% ARI HRTF Dataset

% load the HRTF dataset
ARIDataset = load('ReferenceHRTF.mat');

% get the relevant HRTF data from the ...
% dataset and put it in a useful format for ...
% our processing.
hrtfData = double(ARIDataset.hrtfData);
hrtfData = permute(hrtfData,[2,3,1]);

% Get the associated source positions
sourcePosition = ARIDataset.sourcePosition(:,[1,2]);
sourcePosition(:,1) = sourcePosition(:,1) - 180;

%% Load Monaural Recording

% Load an ambisonic recording of a helicopter
% * Remember to comment out files not in use:

% [heli,originalSampleRate] = audioread('sony_demo.wav');
[heli,originalSampleRate] = audioread('sony_demo_enhanced.wav');

heli = 12*heli(:,1); % keep only one channel

sampleRate = 48e3;
heli = resample(heli,sampleRate,originalSampleRate);

%Load the audio data into a SignalSource object.
sigsrc = dsp.SignalSource(heli, ...
    'SamplesPerFrame',sampleRate/10, ...
    'SignalEndAction','Cyclic repetition');

%% Set Up the Audio Device
deviceWriter = audioDeviceWriter('SampleRate',sampleRate);

%% Create FIR Filters for the HRTF coefficients
FIR = cell(1,2);
FIR{1} = dsp.FIRFilter('NumeratorSource','Input port');
FIR{2} = dsp.FIRFilter('NumeratorSource','Input port');

%% Initialize the Orientation Viewer
orientationScope = HelperOrientationViewer;
data = read(imu);

qimu = imufilt(data.Acceleration,data.AngularVelocity);
orientationScope(qimu);

%% Audio Processing Loop
imuOverruns = 0;
audioUnderruns = 0;
audioFiltered = zeros(sigsrc.SamplesPerFrame,2);
tic
while toc < 300

    % Read from the IMU sensor.
    [data,overrun] = read(imu);
    if overrun > 0
        imuOverruns = imuOverruns + overrun;
    end
    
    % Fuse IMU sensor data to estimate the orientation of the sensor.
    qimu = imufilt(data.Acceleration,data.AngularVelocity); 
    orientationScope(qimu);
    
    % Convert the orientation from a quaternion representation to pitch and yaw in Euler angles.
    ypr = eulerd(qimu,'zyx','frame');
    yaw = ypr(end,1);
    pitch = ypr(end,2);
    desiredPosition = [yaw,pitch];
    
    % Obtain a pair of HRTFs at the desired position.
    interpolatedIR = squeeze(interpolateHRTF(hrtfData,sourcePosition,desiredPosition));
    
    % Read audio from file   
    audioIn = sigsrc();
             
    % Apply HRTFs
    audioFiltered(:,1) = FIR{1}(audioIn, interpolatedIR(1,:)); % Left
    audioFiltered(:,2) = FIR{2}(audioIn, interpolatedIR(2,:)); % Right    
    audioUnderruns = audioUnderruns + deviceWriter(squeeze(audioFiltered)); 
end

%% Clean up
release(sigsrc)
release(deviceWriter)
clear imu uno