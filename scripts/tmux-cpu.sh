#!/bin/bash
top -l 1 -s 0 | grep 'CPU usage' | awk -F'[:,%]' '{printf "%.0f", $2+$4}'
