#!/bin/sh

cat <<EOF >/var/lib/boot2docker/bootlocal.sh
#!/bin/sh

echo "cd /docker/machine" >> /home/docker/.profile

if [ -f /usr/local/bin/docker-compose ]; then
    exit
fi

echo 'Installing docker-compose'
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo sh /docker/machine/resources/watcher.sh daemon > /dev/null 2>&1 &
EOF

sudo chmod +x /var/lib/boot2docker/bootlocal.sh
sudo /var/lib/boot2docker/bootlocal.sh &

