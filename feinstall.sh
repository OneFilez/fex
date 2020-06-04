#!/bin/bash

apt-get update
apt-get install -y curl nginx git unzip p7zip-full
curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
apt-get install -y nodejs
npm install pm2 -g
cat > /etc/nginx/sites-available/your-domain.com <<EOF
server {
    listen 80;
    listen [::]:80;
    index index.html;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:6500;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
sudo rm /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/your-domain.com /etc/nginx/sites-enabled/your-domain.com
sudo nginx -t
sudo systemctl restart nginx
sudo mkdir -p /home/dist
cd /home/dist
wget https://github.com/OneFilez/fex/raw/master/fembed.zip
unzip fembed.zip
npm install
sudo apt install -y mongodb && mongo --eval 'db.runCommand({ connectionStatus: 1 })' && sudo systemctl restart mongodb && sudo systemctl enable mongodb
pm2 start --name Fembed node -- index
cd /root
#etc.