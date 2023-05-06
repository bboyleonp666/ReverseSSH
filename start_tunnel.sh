#!/bin/bash

HOST=reverseTunnel
[[ $(ps -aux | grep "ssh -Nf $HOST" | grep -v grep) ]] || ssh -Nf $HOST
