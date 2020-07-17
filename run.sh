#!/bin/bash

sudo ./1-calculate-checksums.sh /Volumes/Taerar\ Timemachine\ Bigi/ --output t2-checksums-source --skip 1541000
sudo ./1-calculate-checksums.sh /Volumes/bigi1/CCC-TimeMachine-Taerar2 --output t2-checksums-destination --skip 1068000

sudo ./1-calculate-checksums.sh /Volumes/Taerar3-TimeMachine --output t3-checksums-source --skip 1372000
sudo ./1-calculate-checksums.sh /Volumes/bigi1/CCC-TimeMachine-Taerar3 --output t3-checksums-destination --skip 938000

sudo ./1-calculate-checksums.sh /Volumes/Archive/Taerar4 --output t4-checksums-source --skip 721000
sudo ./1-calculate-checksums.sh /Volumes/bigi1/CCC-TimeMachine-Taerar4 --output t4-checksums-destination --skip 1127000

./2-verify-checksums.sh -v -s finished1/t2-checksums-destination -d finished1/t2-checksums-destination -p finished1/t2-checksums-verification

