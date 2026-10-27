#!/bin/bash

# 1. Éviter le crash de rsyslog sur /proc/kmsg dans Docker
sed -i 's/^module(load="imklog"/#module(load="imklog"/' /etc/rsyslog.conf 2>/dev/null || true
sed -i 's/^\$ModLoad imklog/#$ModLoad imklog/' /etc/rsyslog.conf 2>/dev/null || true

# 2. Créer le fichier auth.log et lui attribuer les droits
touch /var/log/auth.log
chmod 640 /var/log/auth.log
chown syslog:adm /var/log/auth.log 2>/dev/null || true

# 3. Démarrer rsyslog directement
rsyslogd

# 4. Démarrer SSH
service ssh restart

# 5. Configurer l'adresse du Wazuh Manager
sed -i "s/<address>.*<\/address>/<address>${WAZUH_MANAGER}<\/address>/" /var/ossec/etc/ossec.conf

# 6. Forcer la surveillance de /var/log/auth.log dans Wazuh si absent
if ! grep -q "/var/log/auth.log" /var/ossec/etc/ossec.conf; then
    sed -i '/<\/ossec_config>/i \  <localfile>\n    <log_format>syslog</log_format>\n    <location>/var/log/auth.log</location>\n  </localfile>' /var/ossec/etc/ossec.conf
fi

# 7. Forcer la surveillance de /var/log/suricata/fast.log dans Wazuh si absent
if ! grep -q "/var/log/suricata/fast.log" /var/ossec/etc/ossec.conf; then
    sed -i '/<\/ossec_config>/i \  <localfile>\n    <log_format>json</log_format>\n    <location>/var/log/suricata/fast.log</location>\n  </localfile>' /var/ossec/etc/ossec.conf
fi

# 8. Configuration du test FIM
echo "INTEGRITY_CHECK_INIT" > /etc/sensitive_config.conf
if ! grep -q "sensitive_config.conf" /var/ossec/etc/ossec.conf; then
    sed -i '/<\/syscheck>/i \  <directories check_all="yes" realtime="yes">/etc/sensitive_config.conf</directories>' /var/ossec/etc/ossec.conf
fi

# 9. Démarrer Suricata en arrière-plan sur eth0
suricata -D -c /etc/suricata/suricata.yaml -i eth0 2>/dev/null || true

# 10. Démarrer l'agent Wazuh
/var/ossec/bin/wazuh-control start

# Garder le conteneur en vie
tail -f /var/ossec/logs/ossec.log
# Forcer la surveillance de /var/log/suricata/fast.log dans Wazuh s'il n'y est pas déjà
if ! grep -q "/var/log/suricata/fast.log" /var/ossec/etc/ossec.conf; then
    sed -i '/<\/ossec_config>/i \  <localfile>\n    <log_format>json</log_format>\n    <location>/var/log/suricata/fast.log</location>\n  </localfile>' /var/ossec/etc/ossec.conf
fi
