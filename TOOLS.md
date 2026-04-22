# TOOLS.md - Ghi Chú Cục Bộ

## Hạ tầng PPA

- **Repository:** /root/.openclaw/workspace/projects/ppa
- **Public URL:** https://ppa.diepxuan.com
- **GPG Key:** /root/.openclaw/workspace/projects/ppa/Release.gpg, /root/.openclaw/workspace/projects/ppa/key.gpg
- **Database:** /root/.openclaw/workspace/projects/ppa/db/

## Distributions Hỗ Trợ

### Debian
- buster (10)
- bullseye (11)
- bookworm (12)
- trixie (13)

### Ubuntu
- bionic (18.04)
- focal (20.04)
- jammy (22.04)
- noble (24.04)
- oracular (24.10)
- plucky (25.04)

## Packages

- **ductn** - DiepXuan super package
- **ductn-ll** - Package cung cấp lệnh 'll' (alias ls -l)
- **lar** - Package hỗ trợ Laravel
- **m2** - Package hỗ trợ Magento 2
- **php-runkit7** - PHP runkit7 extension
- **php-sqlsrv** - SQL Server driver cho PHP
- **php-pdo_sqlsrv** - PDO SQL Server driver cho PHP

## Build Tools

- reprepro 5.3.0
- dpkg-dev, debhelper
- dput (dùng để upload lên Launchpad)
- GPG signing enabled

## SSH/Remote

- Launchpad PPA: caothu91ppa
- Config: ~/.dput.cf
