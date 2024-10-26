#!/bin/sh
sudo watch 'tc -s -d class show dev wan ; tc -s -d qdisc show dev wan'
