#!/bin/bash
set -e

cat > /usr/local/bin/gitlab_runner_setup.sh <<'EOF'
#!/bin/bash
set -e

apt-get update -y
apt-get install -y docker.io unzip curl gnupg ca-certificates
systemctl enable --now docker

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

curl -L --output /tmp/gitlab-runner.deb "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb"
dpkg -i /tmp/gitlab-runner.deb || true
apt-get install -f -y
systemctl enable --now gitlab-runner

%{ if token != "" }
gitlab-runner register --non-interactive \
  --url https://gitlab.com \
  --registration-token ${token} \
  --executor shell \
  --description "gitlab-runner" \
  --tag-list "docker" \
  --run-untagged="true" \
  --locked="false"
%{ endif }
EOF

chmod +x /usr/local/bin/gitlab_runner_setup.sh

cat > /etc/systemd/system/gitlab_runner_setup.service <<'EOF'
[Unit]
Description=GitLab Runner provisioning
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/gitlab_runner_setup.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now gitlab_runner_setup.service
