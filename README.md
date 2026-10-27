# Mini-SOC Déployable & Automatisé (SIEM + SOAR + Incident Response)

Solution complète de Security Operations Center (SOC) conteneurisée réunissant **Wazuh**, **Shuffle (SOAR)**, **TheHive 4** et **Cortex**. Le projet est conçu pour être portable et déployable en une seule commande via Docker.

---

## Architecture Globale

```text
[ Sources / Cibles ]
         │ (Logs / Syslog / Agent)
         ▼
    [ Wazuh SIEM ] ──(Alertes JSON / Webhook)──► [ Shuffle SOAR ]
                                                       │
                                      ┌────────────────┴────────────────┐
                                      ▼                                 ▼
                             [ TheHive 4 ] ◄──(Enrichissement)── [ Cortex Engine ]
                             (Case Management)                   (Analyzers / VT)
