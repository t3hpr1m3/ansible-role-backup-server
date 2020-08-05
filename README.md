# Ansible Role: Backup Server
[![Gitlab pipeline status (self-hosted)](https://img.shields.io/gitlab/pipeline/dubzland/ansible-role-backup-server/main?gitlab_url=https%3A%2F%2Fgit.dubzland.net)](https://git.dubzland.net/dubzland/ansible-role-backup-server/pipelines)
[![Ansible role](https://img.shields.io/ansible/role/50086)](https://galaxy.ansible.com/dubzland/backup_server)
[![Ansible role downloads](https://img.shields.io/ansible/role/d/50086)](https://galaxy.ansible.com/dubzland/backup_server)
[![Ansible Quality Score](https://img.shields.io/ansible/quality/50086)](https://galaxy.ansible.com/dubzland/backup_server)
[![Liberapay patrons](https://img.shields.io/liberapay/patrons/jdubz)](https://liberapay.com/jdubz/donate)
[![Liberapay receiving](https://img.shields.io/liberapay/receives/jdubz)](https://liberapay.com/jdubz/donate)

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
