- To open Matlab demo sample, type following in Matlab Terminal:
	openExample('shared_audio_nav_fusion/BinauralAudioRenderingUsingHeadTrackingExample')

- Run the 'm_code.m' in conjunction with 'sony_demo_enhanced.wav' file, and Mathlab library files 'HelperBox.m' and 'HelperOrientationViewer.m'

- Please note mentioned steps require an Arduino Uno and a gyroscpe, preferably MPU9250.
- Additionally, 'HelperBox.m' and 'HelperOrientationViewer.m' are standard Matlab libraries and aren't needed ideally; however, we had issues loading this libraries on Matlab R2023b version and we reverted to placing mentioned libraries inside the local path as 'm_code.m'

Please note,
This project is a modified form of Binaural Audio Rendering Using Head Tracking offered by MatWorks as documentation for utilizing following toolboxes:
- MATLAB Support Package for Arduino Hardware
- Audio Toolbox
- Navigation Toolbox
- Sensor Fusion and Tracking Toolbox

https://www.mathworks.com/help/audio/ug/binaural-audio-rendering-using-head-tracking.html

Thanks.