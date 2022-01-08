#!/bin/sh

set -e

PATH=/usr/lib/mit/sbin:$PATH
export PATH

realm=OTUS_LAB
master_pass=otus
admin_princ=admin/admin
admin_pass=admin


# Install Kerberos packages
zypper in -y krb5 krb5-server krb5-client

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

# Edit Kerberos KDC config
cat > /var/lib/kerberos/krb5kdc/kdc.conf <<'END'
[kdcdefaults]
kdc_listen = 88

[realms]

[logging]
kdc = FILE:/var/log/krb5/krb5kdc.log
admin_server = FILE:/var/log/krb5/kadmind.log
END

# Edit ACL
cat > /var/lib/kerberos/krb5kdc/kadm5.acl <<END
$admin_princ@$realm  *
END

# Create database
kdb5_util -r "$realm" destroy -f || true
kdb5_util -P "$master_pass" -r "$realm" create -s

# Create parent dir for credential cache (ccache)
mkdir -pv /run/user/0

# Add admin principal
kadmin.local addprinc -pw "$admin_pass" "$admin_princ"@"$realm"

# Enable and run services
systemctl enable --now kadmind krb5kdc

# Create static host entries
cat >> /etc/hosts <<'END'
192.168.56.10 nfs-server 
192.168.56.20 nfs-client
192.168.56.30 kdc
END

# Create principals for NFS service
kadmin.local addprinc -randkey nfs/nfs-client
kadmin.local addprinc -randkey nfs/nfs-server
