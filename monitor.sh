#!/bin/bash

tunnel_pid=$(ps aux | grep 'ssh -Nf reverseTunnel' | grep -v grep | awk {'print $2'})
kill $tunnel_pid