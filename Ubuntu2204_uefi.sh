#cloud-config
autoinstall:
  version: 1
  early-commands:
    - systemctl stop ssh
  network:
    network:
      version: 2
      renderer: networkd
      ethernets:
        eth0:
          addresses: [{{ .IpAddress }}/{{ .IpPrefix }}]
          nameservers:
            addresses: [{{ .DnsServers_comma_seperated }}]
            search: [{{ .DnsDomains_comma_seperated }}]
          routes:
            - to: default
              via: {{ .IpGateway }}
          match:
            macaddress: {{ .MacAddress }}
          set-name: eth0

  identity:
    hostname: {{ .FQDN_Hostname }}
    password: "{{ .secure.HashedPasswd }}"
    username: ubuntu
  user-data:
    disable_root: false
    users:
      - default
      - name: "{{ .Username }}"
        chpasswd: { expire: false }
        groups: [users,admin]
        lock_passwd: false
        hashed_passwd: "{{ .secure.HashedPasswd }}"
        shell: /bin/bash
        ssh_pwauth: true
        sudo: ALL=(ALL) ALL
  late-commands:
    - echo "Applied late commands" >> /tmp/log1
    - OS_INSTALL_COMPLETED_STATUS_PLACEHOLDER
    - sudo systemctl start ssh
  # packages may be supplied as a single package name or as a list
  # with the format [<package>, <version>] wherein the specifc
  # package version will be installed.
  packages:
    - build-essential
    - ntp
    - python3-pip
    - sysstat
  package_update: true
  package_upgrade: true
  ssh:
    allow-pw: true
    install-server: yes
  storage:
    config:
      - {ptable: gpt, DISKID_PLACEHOLDER, wipe: superblock-recursive, preserve: false, name: '', grub_device: false, type: disk, id: disk0}
      - {device: disk0, size: 512M, wipe: superblock, flag: boot, number: 1, preserve: false, grub_device: true, type: partition, id: partition-0}
      - {fstype: fat32, volume: partition-0, preserve: false, type: format, id: format-0 }
      - {device: disk0, size: -1, wipe: superblock, flag: '', number: 2, preserve: false, type: partition, id: partition-1}
      - {fstype: ext4, volume: partition-1, preserve: false, type: format, id: format-1 }
      - {device: format-1, path: /, type: mount, id: mount-1 }
      - {device: format-0, path: /boot/efi, type: mount, id: mount-0 }
