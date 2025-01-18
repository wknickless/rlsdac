#!/bin/bash -x
ssh -L 8000:127.0.0.1:8000 -L 9330:127.0.0.1:9330 rlsdac@192.168.4.8 journalctl --follow --unit=speedify-remote.service
