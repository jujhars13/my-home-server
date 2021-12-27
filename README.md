# My Home Server

IaC for my home Ubuntu server deployed to an old Lenovo laptop.

We need

- Ubuntu server 21.10 (Impish)
- K3s
  - [pihole](https://pi-hole.net/) for network level DNS protection
  - network software

## Testing

Test in a Vagrant VM:

```bash
# Ubuntu
vagrant destroy -f && vagrant up
```