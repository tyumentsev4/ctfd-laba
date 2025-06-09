---
all:
  children:
    nfs_servers:
      hosts:
        nfs01:
          ansible_host: ${nfs01_ip}
          ansible_user: ${nfs01_user}
          ansible_private_key_file: ../ctfd-key
