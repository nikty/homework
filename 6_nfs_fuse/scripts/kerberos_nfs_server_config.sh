#!/bin/sh

set -e

PATH=/usr/lib/mit/bin:$PATH
export PATH

realm=OTUS_LAB
admin_princ=admin/admin
admin_pass=admin

# Create static host entries
cat >> /etc/hosts <<'END'
192.168.56.10 nfs-server 
192.168.56.20 nfs-client
192.168.56.30 kdc
END

# Install Kerberos client utils
zypper in -y krb5-client

# Edit Kerberos config
cat > /etc/krb5.conf <<END
includedir  /etc/krb5.conf.d

[libdefaults]
# "dns_canonicalize_hostname" and "rdns" are better set to false for improved security.
# If set to true, the canonicalization mechanism performed by Kerberos client may
# allow service impersonification, the consequence is similar to conducting TLS certificate
# verification without checking host name.
# If left unspecified, the two parameters will have default value true, which is less secure.
dns_canonicalize_hostname = false
rdns = false
default_realm = $realm

[realms]
$realm = {
    kdc = 192.168.56.30
    admin_server = 192.168.56.30
}

[logging]
kdc = FILE:/var/log/krb5/krb5kdc.log
admin_server = FILE:/var/log/krb5/kadmind.log
default = SYSLOG:NOTICE:DAEMON
END

# Create parent dir for credential cache (ccache)
mkdir -pv /run/user/0

# Add server principal to keytab
kadmin -p "$admin_princ" -w "$admin_pass" ktadd nfs/nfs-server

# Export kerberized NFS
mkdir -pv /srv/nfs_krb/upload
chmod 777 /srv/nfs_krb/upload
echo '/srv/nfs_krb *(rw,sec=krb5p) ' >> /etc/exports

# Re-export shares
systemctl restart nfsserver

