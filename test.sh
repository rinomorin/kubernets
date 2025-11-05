Initial Scan:
oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis \
  --results /tmp/`hostname -s`-scan-result.xml \
  --report /tmp/`hostname -s`-scan-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
chmod 644 /tmp/`hostname -s`-scan*
df --local -P | awk '{if (NR!=1) print $6}' \
| xargs -I '$6' find '$6' -xdev -type d \
\( -perm -0002 -a ! -perm -1000 \) 2>/dev/null \
-exec chmod a+t {} +

Skip Rules:
xccdf_org.ssgproject.content_rule_grub2_password 
  this prevent reboot and stat in pending till someone type a password (exempted)
xccdf_org.ssgproject.content_rule_package_httpd_removed 
  required by proxy for haprox and certificat monitoring
xccdf_org.ssgproject.content_rule_service_rpcbind_disabled 
  required by proxy and nfs
xccdf_org.ssgproject.content_rule_package_squid_removed 
  require for proxy
xccdf_org.ssgproject.content_rule_service_nfs_disabled 
  required for nfs service

Proxy:
oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis \
  --skip-rule xccdf_org.ssgproject.content_rule_grub2_password \
  --skip-rule xccdf_org.ssgproject.content_rule_package_httpd_removed \
  --skip-rule xccdf_org.ssgproject.content_rule_service_rpcbind_disabled \
  --skip-rule xccdf_org.ssgproject.content_rule_package_squid_removed \
  --results /tmp/`hostname -s`-scan-result.xml \
  --report /tmp/`hostname -s`-scan-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
chmod 644 /tmp/`hostname -s`-scan*

Jump Box:
oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis \
  --skip-rule xccdf_org.ssgproject.content_rule_grub2_password \
  --skip-rule xccdf_org.ssgproject.content_rule_service_rpcbind_disabled \
  --skip-rule xccdf_org.ssgproject.content_rule_service_nfs_disabled \
  --results /tmp/`hostname -s`-scan-result.xml \
  --report /tmp/`hostname -s`-scan-report.html \
  /usr/share/xml/scap/ssg/content/ssg-rhel9-ds.xml
chmod 644 /tmp/`hostname -s`-scan*

