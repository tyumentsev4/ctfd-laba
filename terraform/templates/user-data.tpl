#cloud-config
users:
  - name: ${ssh_user}
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ${ssh_public_key}
ssh_pwauth: no
