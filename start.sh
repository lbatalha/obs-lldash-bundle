#!/bin/env sh

LISTEN_ADDR=rtmp://127.0.0.1:1935/live/app
UTC_ADDR=http://127.0.0.1:61935/utc_timestamp

mkdir -p /tmp/dashstream

cp -u /opt/dashstream/*.html /tmp/dashstream/
cp -u /opt/dashstream/*.js /tmp/dashstream/
cp -u /opt/dashstream/*.css /tmp/dashstream/
cp -u /opt/dashstream/*.ttf /tmp/dashstream/

docker run --name nginx \
--mount type=bind,src=/tmp/dashstream,dst=/usr/share/nginx/html,readonly \
--mount type=bind,src=/opt/dashstream/nginx.conf,dst=/etc/nginx/nginx.conf,readonly \
--mount type=bind,src=/opt/dashstream/default.conf,dst=/etc/nginx/conf.d/default.conf,readonly \
-p 61935:80 --rm -d \
nginxinc/nginx-unprivileged

ffmpeg -f flv -listen 1 -i "$LISTEN_ADDR" \
-c:v copy -c:a copy \
-ldash 1 -streaming 1 -use_template 1 -use_timeline 0 \
-adaptation_sets "id=0,streams=v id=1,streams=a" \
-seg_duration 1 -frag_duration 0.1 -frag_type duration \
-index_correction 1 -write_prft 1 -target_latency 1 \
-utc_timing_url "$UTC_ADDR" \
-window_size 15 -extra_window_size 15 -remove_at_exit 1 \
-fflags +nobuffer+flush_packets \
-f dash \
/tmp/dashstream/manifest.mpd

docker stop nginx
