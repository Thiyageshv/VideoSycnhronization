# VideoSycnhronization

## Project Contribtuion 
Thiyagesh Viswanathan - Sycn using NTP clock (method 2)
Jerry A Barona  - Sync using rtpjitterbuffer and rtpbin (method 1 and part of method 2)
Rishikanth Chandrasekaran - Sync using Net clock  and plugin to calculate relative latency 

The proejct has various sender and receiver pipleines that we tried for various methods. 

rtspserver.sh and rtspserver2.sh for Senders and rtspreceiverC.sh served as the best pipelines for our cause. 

You can execute the program as
```
./rtspserver.sh ip address of receiver
./rtsprserver2.sh ip address of receiver
./rtspreceiverC.sh on receiver with $DEST as ip address of server 1 and $DEST2 as ip address of server 2.
```

Other pipelines are experiments with different combinations and methods. 
The final working pipeline had the following features
- ntp-time-source = ntp
- rtp-profile=avpf 
- rtcp-sync-send-time=false
- buffer-mode=synced
- ntp-sync=true
- no rtpjitterbuffer to be added
- Frame rate = 15 fps

Result:
The latency was observed to be between 0 to 40ms


