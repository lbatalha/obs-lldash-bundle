Scripts to launch and manage a local ffmpeg rtmp server to output dash/hls/whatever

## Bundle Contents
- OBS Script to launch executables - handle reconnections
  - handle reconnection
- Local streaming server script
  - Start nginx-unprivileged docker container
  - Start ffmpeg as rtmp server, outputs low latency dash data to path shared with nginx http root
  - ffmpeg exits on connection close, container deleted on exit
- Simple `dash.js`+`controlbar` player webpage
  - Saves/Restores user volume setting
  - Basic statistics below player
  - Allows changing target latency on the fly
  - Media speed up/down configured for live edge catchup

