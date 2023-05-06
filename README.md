# The reverse ssh installer

## Installation
To create a ssh tunnel from a private IP to a public IP using ssh.  
1. you should be holding a public IP in your hand
1. `bash creat_tunnel.sh`  

All the setting will be configure automatically with some basic information should be provided, for example, public IP address and port to use.

### Re-connecting
To make the connection stay forever, try add `start_tunnel.sh` to `crontab`
```
# in crontab
## check every minute
* * * * * bash /home/user/start_tunnel.sh
```

### Monitoring
Sometimes the Internet faces connection unstable problems. To automatically reestablish reverse tunnel, try add `monitor.sh` to crontab to solve that problem.
```
# in crontab
## restart every 6 hours
* */6 * * * /home/user/monitor.sh
```