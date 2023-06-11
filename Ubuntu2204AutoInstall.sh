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
          {{if (eq .IpVersion "V4")}}{{if (eq .IpConfigType "dhcp")}}dhcp4: yes{{end}}{{end}}
          {{if (eq .IpVersion "V6")}}{{if (eq .IpConfigType "dhcp")}}dhcp6: yes{{end}}{{end}}
          {{if (eq .IpConfigType "static")}}
          addresses: [{{if (eq .IpVersion "V4")}}{{IpToCidr .IpAddress .Netmask}}{{else}}'{{.IpAddress}}/{{ .Prefix}}'{{end}}]
          nameservers:
            addresses: [{{ .NameServer }}]
          routes:
            - to: default
              via: {{ .Gateway }}{{end}}
          match:
            macaddress: {{.NetworkDevice}}
          set-name: eth0

  identity:
    hostname: {{ .Hostname }}
    password: "{{ .secure.Password }}"
    username: llm
  user-data:
    disable_root: false
    chpasswd:
      list: |
        root: "{{ .secure.Password }}"
      expire: false
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
    install-server: yes
  storage:
    config:
      {{if (eq (.BootMode | LowerCase) "uefi")}}- {ptable: gpt, DISKID_PLACEHOLDER, wipe: superblock-recursive, preserve: false, name: '', grub_device: false, type: disk, id: disk0}
      - {device: disk0, size: 512M, wipe: superblock, flag: boot, number: 1, preserve: false, grub_device: true, type: partition, id: partition-0}
      - {fstype: fat32, volume: partition-0, preserve: false, type: format, id: format-0 }
      - {device: disk0, size: -1, wipe: superblock, flag: '', number: 2, preserve: false, type: partition, id: partition-1}
      - {fstype: ext4, volume: partition-1, preserve: false, type: format, id: format-1 }
      - {device: format-1, path: /, type: mount, id: mount-1 }
      - {device: format-0, path: /boot/efi, type: mount, id: mount-0 }{{else}}- {ptable: gpt, DISKID_PLACEHOLDER, wipe: superblock-recursive, preserve: false, name: '', grub_device: true, type: disk, id: disk0}
      - {device: disk0, size: 1148576, flag: bios_grub, number: 1, preserve: false, grub_device: false, type: partition, id: partition-0}
      - {device: disk0, size: -1, wipe: superblock, flag: '', number: 2, preserve: false, grub_device: false, type: partition, id: partition-1}
      - {fstype: ext4, volume: partition-1, preserve: false, type: format, id: format-0 }
      - {device: format-0, path: /, type: mount, id: mount-0 }{{end}}
