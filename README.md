# Ansible Role: Backup Server
[![Gitlab pipeline status (self-hosted)](https://git.dubzland.net/dubzland/ansible-role-backup-server/badges/master/pipeline.svg)](https://git.dubzland.net/dubzland/ansible-role-backup-server)

Sets up an rsyncd-based backup target.  This role is highly opinionated, and
therefore probably not fit for mass consumption.

## Requirements

Ansible version 2.0 or higher.

## Role Variables

Available variables are listed below, along with their default values (see
    `defaults/main.yml` for more info):

### dubzland_backup_server_root

```yaml
dubzland_backup_server_root: "/backups"
```

Location where all backups will be stored on the server.

### dubzland_backup_server_clients

```yaml
dubzland_backup_server_clients: []
```

List of clients this server will handle backups for.  See `defaults/main.yml`
for an example.

## Dependencies

None

## Example Playbook

```yaml
- hosts: backup-servers
  become: yes
  roles:
    - role: dubzland-backup_server
      vars:
        dubzland_backup_server_root: "/backups"
        dubzland_backup_server_clients:
          - client1.dubzland.net
```

## License
-------

MIT

## Author

* [Josh Williams](https://codingprime.com)
