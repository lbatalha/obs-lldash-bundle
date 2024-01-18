#!/bin/env sh

#LISTEN_ADDR=rtmp://localhost:1935/live/app
#UTC_ADDR=http://localhost:61935/utc_timestamp

SRC_DIR=/opt/dashstream
HTTP_DIR=/tmp/dashstream

mkdir -p "$HTTP_DIR"

cp -u "$SRC_DIR"/*.html "$HTTP_DIR"/
cp -u "$SRC_DIR"/*.js "$HTTP_DIR"/
cp -u "$SRC_DIR"/*.css "$HTTP_DIR"/
cp -u "$SRC_DIR"/*.ttf "$HTTP_DIR"/

if $(which podman > /dev/null); then
	alias docker=podman
fi

docker run --name nginx \
--mount type=bind,src="$HTTP_DIR",dst=/usr/share/nginx/html,readonly \
--mount type=bind,src="$SRC_DIR"/nginx.conf,dst=/etc/nginx/nginx.conf,readonly \
--mount type=bind,src="$SRC_DIR"/default.conf,dst=/etc/nginx/conf.d/default.conf,readonly \
-p 0.0.0.0:61935:443 --rm -d \
nginxinc/nginx-unprivileged

#add -rtmp_enhanced_codecs "hvc1,av01,vp09" when released
ffmpeg -f live_flv -listen 1 -i "$LISTEN_ADDR" \
-c:v copy -c:a copy \
-ldash 1 -streaming 1 -use_template 1 -use_timeline 0 \
-adaptation_sets "id=0,streams=v id=1,streams=a" \
-seg_duration 1 -frag_duration 0.1 -frag_type duration \
-index_correction 1 -write_prft 1 -target_latency 1 \
-utc_timing_url "$UTC_ADDR" \
-window_size 300 -extra_window_size 15 -remove_at_exit 1 \
-fflags +nobuffer+flush_packets \
-f dash \
"$HTTP_DIR"/manifest.mpd

docker stop nginx
