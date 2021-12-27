# my-home-server

IaC for my home Ubuntu server 

We need

- Ubuntu server 21.10 (Impish)
- K3s
  - pihole
  - network software

## Testing

Test in a Vagrant VM:

```bash
# Ubuntu
vagrant destroy -f && vagrant up
```