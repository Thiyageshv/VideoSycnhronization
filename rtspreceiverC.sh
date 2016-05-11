export GST_PLUGIN_PATH=/usr/lib/gstreamer-1.0 
export LD_LIBRARY_PATH=/usr/lib

#!/bin/sh
#
# A simple RTP receiver
#
#  receives H264 encoded RTP video on port 5000, RTCP is received on  port 5001.
#  the receiver RTCP reports are sent to port 5005
#  receives alaw encoded RTP audio on port 5002, RTCP is received on  port 5003.
#  the receiver RTCP reports are sent to port 5007
#
#             .-------.      .----------.     .---------.   .-------.   .-----------.
#  RTP        |udpsrc |      | rtpbin   |     |h264depay|   |h264dec|   |xvimagesink|
#  port=5000  |      src->recv_rtp recv_rtp->sink     src->sink   src->sink         |
#             '-------'      |          |     '---------'   '-------'   '-----------'
#                            |          |
#                            |          |     .-------.
#                            |          |     |udpsink|  RTCP
#                            |    send_rtcp->sink     | port=5005
#             .-------.      |          |     '-------' sync=false
#  RTCP       |udpsrc |      |          |               async=false
#  port=5001  |     src->recv_rtcp      |
#             '-------'      |          |
#                            |          |
#             .-------.      |          |     .---------.   .-------.   .-------------.
#  RTP        |udpsrc |      | rtpbin   |     |pcmadepay|   |alawdec|   |autoaudiosink|
#  port=5002  |      src->recv_rtp recv_rtp->sink     src->sink   src->sink           |
#             '-------'      |          |     '---------'   '-------'   '-------------'
#                            |          |
#                            |          |     .-------.
#                            |          |     |udpsink|  RTCP
#                            |    send_rtcp->sink     | port=5007
#             .-------.      |          |     '-------' sync=false
#  RTCP       |udpsrc |      |          |               async=false
#  port=5003  |     src->recv_rtcp      |
#             '-------'      '----------'

# the destination machine to send RTCP to. This is the address of the sender and
# is used to send back the RTCP reports of this receiver. If the data is sent
# from another machine, change this address.
#DEST=127.0.0.1
# Jerry's
DEST=209.2.218.156
DEST2=209.2.218.156
# Wired
#DEST=128.59.19.228
#DEST2=128.59.19.228
# Calculon's
#DEST2=127.0.0.1
#DEST2=128.59.23.199
# this adjusts the latency in the receiver
LATENCY=200

# the caps of the sender RTP stream. This is usually negotiated out of band with
# SDP or RTSP. normally these caps will also include SPS and PPS but we don't
# have a mechanism to get this from the sender with a -launch line.
VIDEO_CAPS="application/x-rtp,media=(string)video,clock-rate=(int)90000,encoding-name=(string)VP8"
AUDIO_CAPS="application/x-rtp,media=(string)video,clock-rate=(int)90000,encoding-name=(string)VP8"

VIDEO_DEC="rtpvp8depay ! vp8dec"
AUDIO_DEC="rtpvp8depay ! vp8dec"

VIDEO_SINK="videoconvert ! autovideosink"
AUDIO_SINK="videoconvert ! autovideosink"

gst-launch-1.0 -v rtpbin name=rtpbin ntp-time-source=clock-time buffer-mode=synced ntp-sync=true rtcp-sync-send-time=false \
     udpsrc caps=$VIDEO_CAPS port=5000 ! rtpjitterbuffer ! rtpbin.recv_rtp_sink_0                       \
       rtpbin.  ! $VIDEO_DEC ! $VIDEO_SINK                                             \
     udpsrc port=5001 ! rtpbin.recv_rtcp_sink_0                                       \
         rtpbin.send_rtcp_src_0 ! udpsink port=5005 host=$DEST sync=false \
     udpsrc caps=$AUDIO_CAPS port=6000 ! rtpjitterbuffer ! rtpbin.recv_rtp_sink_1                       \
       rtpbin. ! $AUDIO_DEC ! $AUDIO_SINK                                             \
     udpsrc port=6001  ! rtpbin.recv_rtcp_sink_1                                       \
         rtpbin.send_rtcp_src_1 ! udpsink port=6005 host=$DEST2 sync=false
