#!/bin/bash
set -e

cat > /usr/local/bin/app_server_setup.sh <<'EOF'
#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io unzip curl
systemctl enable --now docker

usermod -aG docker ubuntu
useradd -m gitlab || true
usermod -aG docker gitlab

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
EOF

chmod +x /usr/local/bin/app_server_setup.sh

cat > /etc/systemd/system/app_server_setup.service <<'EOF'
[Unit]
Description=App server provisioning
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/app_server_setup.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now app_server_setup.service
