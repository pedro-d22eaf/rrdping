# rrdping #

simple tool to monitor the network using ICMP (ping).

# install #

*get the software*

```
sudo apt-get install -y rrdtool fping
sudo mkdir /apps
cd /apps
git clone https://github.com/pedro-d22eaf/rrdping.git
```

*edit targets list*

```
echo "1.1.1.1" >> ping-target.cfg
```

*generate rrd files*

```
make create_rrds
```

*start service at boot*

```
cp rrdping.service  /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable rrdping.service
reboot
```

