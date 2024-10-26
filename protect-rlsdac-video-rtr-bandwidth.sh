#!/bin/bash -x

# Objective: Protect at least 7 megabits/second of outbound bandwidth on the 
# 'wan' interface for the rlsdac-video-rtr.  Everything outbound via 'wan' is limited to 11 megabits/second by the upstream.

# The MAC address for the rlsdac-video-rtr as seen by 'mac'
VIDEOMAC=52:54:00:1e:0f:a9

# Clear all the queue disciplines from the 'wan' interface

/usr/sbin/tc qdisc del root dev wan

# Use Hierarchical Token Bucket (HTB)

# Set the HTB qdisc on the root of wan, specifying that the class 1:20 is used
# by default.  Set the name of the root as 1: for future reference.

/usr/sbin/tc qdisc add dev wan root handle 1: \
             htb default 20

# Create a class called 1:1, which is the direct descendant of root (1:);
# this class also gets assigned an HTB qdisc, and then sets a maximum
# rate of 11 megabits/second, with a burst of 15k

/usr/sbin/tc class add dev wan parent 1: classid 1:1 \
             htb rate 11mbit burst 15k

# Class 1:10 is the protected class for traffic up to 7 megabits/second
# with a ceiling of 9 megabits/second

/usr/sbin/tc class add dev wan parent 1:1 classid 1:10 \
             htb rate 7mbit ceil 9mbit burst 15k

# Match the source MAC address of the rlsdac-video-rtr and dropped 
# those packets into Class 1:10:

/usr/sbin/tc filter add dev wan protocol ip parent 1: prio 1 \
             u32 match ether src $VIDEOMAC flowid 1:10

# Class 1:20 has a rate of 1kbit/second but it is the default class so
# can consume everything available to the parent class 1:

/usr/sbin/tc class add dev wan parent 1:1 classid 1:20 \
             htb rate 1kbit ceil 11mbit burst 15k

# Use standard fair queueing beneath the other classes:

# /usr/sbin/tc qdisc add dev wan parent 1:10 handle 10: sfq perturb 10
# /usr/sbin/tc qdisc add dev wan parent 1:20 handle 20: sfq perturb 10

