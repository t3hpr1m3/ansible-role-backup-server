
# Ansible Role: Backup Server
[![Gitlab pipeline status (self-hosted)](https://git.dubzland.net/dubzland/ansible-role-backup-server/badges/main/pipeline.svg)](https://git.dubzland.net/dubzland/ansible-role-backup-server/pipelines)
[![Ansible role](https://img.shields.io/ansible/role/50086)](https://galaxy.ansible.com/dubzland/backup_server)
[![Ansible role downloads](https://img.shields.io/ansible/role/d/50086)](https://galaxy.ansible.com/dubzland/backup_server)
[![Ansible Quality Score](https://img.shields.io/ansible/quality/50086)](https://galaxy.ansible.com/dubzland/backup_server)
[![Liberapay patrons](https://img.shields.io/liberapay/patrons/jdubz)](https://liberapay.com/jdubz/donate)
[![Liberapay receiving](https://img.shields.io/liberapay/receives/jdubz)](https://liberapay.com/jdubz/donate)

## Description

Sets up an rsync/ssh based backup server.  This role is highly opinionated, and
therefore probably not fit for mass consumption.

## Requirements

Ansible version 2.8 or higher (might work with earlier versions).

## Role Variables

Available variables are listed below, along with their default values (see [defaults/main.yml](defaults/main.yml) for more info):

```yaml
dubzland_backup_server_data: "/srv/backups"
```
(_**absolute**_) Directory where backups will be stored.
```yaml
dubzland_backup_server_bin: "/usr/local/bin"
dubzland_backup_server_etc: "/etc/backups"
dubzland_backup_server_lib: "/usr/local/lib/backups"
dubzland_backup_server_log: "/var/log/backups"
dubzland_backup_server_run: "/var/run/backups"
dubzland_backup_server_tmp: "/var/tmp/backups"
dubzland_backup_server_var: "/var/lib/backups"
```
(_**absolute**_) Location to store backup scripts, configuration data, function libraries, logs, backup status, and pids (respectively).
```yaml
dubzland_backup_server_user: "backup-user"
dubzland_backup_server_group: "backup_group"
```
Local user/group under which backups will run.  This user and group will be created, with the following parameters:
- the user's home directory will be `{{ dubzland_backup_server_var }}`
- the user's shell will be set to `/usr/sbin/nologin`
- the system will configure sudo to allow the user to execute the rsync command (`/usr/bin/rsync`) without a password
- the above directories will be owned by the user/group specified above
- if logrotate functionality is enabled, the user will own the logrotate configuration file
```yaml
dubzland_backup_server_private_key: ""
```
SSH private key used to authenticate with target machines.  A public/private keypair can be generated with the following command: `$ ssh-keygen -t ed25519 -f <keypair_name>`.  This will create two files in the current directory:
- `<keypair_name>` - contains the private key
- `<keypair_name>.pub` - contains the public key

The private key file should be treated with the same level of respect as any other private key.  If obtained, anyone with physical access to your network would be able to log into any client machine as the backup user.  Keep it secret.  Keep it safe.

The public key file should be supplied to the [corresponding client role](https://git.dubzland.net/dubzland/ansible-role-backup-client).
```yaml
dubzland_backup_server_job_name: "network backups"
```
Name used for the cron job and logrotate directives.
```yaml
dubzland_backup_server_frequency: "5m"
```
Frequency to trigger the backup job.  If the job detects that a previous backup job is still active, it will exit with success without performing any actions.  For this reason, it is recommended to keep the frequency short, to ensure backups run as close to their scheduled time as possible.
```yaml
dubzland_backup_server_logrotate_enabled: true
```
Whether to install and configure logrotate.
```yaml
dubzland_backup_server_logrotate_config: |
  weekly
  rotate 7
  size 10M
  compress
  delaycompress
```
Configuration for logrotate

## Dependencies

None

## Example Playbook

```yaml
- hosts: backup-servers
  become: yes
  roles:
    - role: dubzland.backup_server
      vars:
        dubzland_backup_server_user: "backups"
        dubzland_backup_server_root: "/srv/backups"
        dubzland_backup_server_private_key: |
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACAKeioH5qr9ZsWayFLG9rH7HESOU2PUOHq+0xsibNlpnAAAAJBB7f9+Qe3/
fgAAAAtzc2gtZWQyNTUxOQAAACAKeioH5qr9ZsWayFLG9rH7HESOU2PUOHq+0xsibNlpnA
AAAEATcOS3zXcCiymUVchUFlOEfIpSHwVcAz+3uuGonOOxigp6Kgfmqv1mxZrIUsb2sfsc
RI5TY9Q4er7TGyJs2WmcAAAADGpkdWJ6QGFwb2xsbwE=
-----END OPENSSH PRIVATE KEY-----
        dubzland_backup_server_targets:
          - name: client1
            host: client1.local.dubzland.net
```

## License
-------

MIT

## Author

* [Josh Williams](https://codingprime.com)

