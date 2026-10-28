# Mini-SOC: Portable & Automated SIEM / SOAR / Incident Response Lab

[![Docker](https://img.shields.io/badge/Docker-Enabled-blue?style=for-the-badge&logo=docker)](https://www.docker.com/)
[![Wazuh](https://img.shields.io/badge/SIEM-Wazuh-orange?style=for-the-badge)](https://wazuh.com/)
[![Shuffle](https://img.shields.io/badge/SOAR-Shuffle-green?style=for-the-badge)](https://shuffler.io/)
[![TheHive](https://img.shields.io/badge/Case_Management-TheHive-purple?style=for-the-badge)](https://thehive-project.org/)
[![Cortex](https://img.shields.io/badge/Threat_Analysis-Cortex-yellow?style=for-the-badge)](https://thehive-project.org/)
[![Suricata](https://img.shields.io/badge/NIDS-Suricata-red?style=for-the-badge)](https://suricata.io/)


# 🛡️ Mini-SOC Lab

A complete, lightweight, and containerized **Security Operations Center (SOC)** lab designed for portability and rapid deployment. This project integrates threat detection, automated incident response, and case management into a single orchestrated environment.

---

## 🏗️ Global Architecture

```text
[ Sources / Targets ]
       │  (Logs / Syslog / Agent / NIDS)
       ▼
[ Wazuh SIEM ] ──(JSON Alerts / Webhook)──► [ Shuffle SOAR ]
                                                   │
                        ┌──────────────────────────┴──────────────────────────┐
                        ▼                                                     ▼
                  [ TheHive 4 ] ◄──(Enrichment)──────────────────────── [ Cortex Engine ]
               (Case Management)                                      (Analyzers / VT)
```

---

## 🛠️ Tech Stack

- **SIEM & Log Management:** Wazuh (Manager & Agent)
- **NIDS (Network Intrusion Detection):** Suricata
- **SOAR (Security Orchestration, Automation, and Response):** Shuffle
- **Case Management & IR:** TheHive 4 & Cortex
- **Orchestration:** Docker & Docker Compose, Shell Scripts

---

## 📂 Project Structure

```text
mini-soc/
├── 📁 assets/                 # Screenshots & visual documentation
│   ├── 00_deploiement_soc/
│   ├── 01_bruteforce_ssh/
│   ├── 02_suricata_nids/
│   └── 03_fim_integrite/
├── 📁 lab-simulation/         # Attack & victim simulation containers
├── 📁 wazuh-docker/           # Wazuh SIEM configurations & custom rules
├── 📁 shuffle/                # SOAR workflows configurations
├── 📁 thehive/                # Case management setup
├── 📜 start.sh                # Automated startup script
├── 📜 stop.sh                 # Graceful shutdown script
└── 📜 README.md
```

---

## ⚡ Quick Start (Cloning & Deployment)

Follow these simple steps to clone and run the Mini-SOC lab on your local machine or server.

### 1. Clone the repository

```bash
git clone https://github.com/elasri-ayoub/mini-soc.git
cd mini-soc
```

### 2. Check Prerequisites

Ensure you have the following installed on your host system:

- Docker (v20.10+)
- Docker Compose (v2.0+)
- At least 4 GB to 6 GB of RAM allocated to Docker for smooth execution

### 3. Start the Infrastructure

Launch the entire stack using the automated startup script:

```bash
chmod +x start.sh
./start.sh
```

### 4. Access the Interfaces

Once all containers are up and running, you can access each component via your browser:

| Component | URL |
|-----------|-----|
| Wazuh Dashboard | `https://localhost:443` (or configured port) |
| Shuffle SOAR | `http://localhost:3001` |
| TheHive | `http://localhost:9000` |
| Cortex Engine | `http://localhost:9001` |

---

## 📸 Lab Screenshots & Proof of Concept

### 00. SOC Deployment & Architecture

Overview of running containers and network topology.

![SOC Architecture](assets/00_deploiement_soc/00_01_docker_soc_containers_running)

### 01. SSH Brute-Force Detection

Wazuh detecting brute-force attacks and triggering automated alerts.

> Add your screenshots in `assets/01_bruteforce_ssh/`

![SSH Brute-Force](assets/01_bruteforce_ssh/01_04_thehive_case_observable)

### 02. Suricata NIDS Integration

Network intrusion detection alerts captured and centralized.

> Add your screenshots in `assets/02_suricata_nids/`

![Suricata NIDS](assets/02_suricata_nids/02_04_thehive_suricata_case)

### 03. File Integrity Monitoring (FIM)

Real-time tracking of critical file modifications.

> Add your screenshots in `assets/03_fim_integrite/`

![File Integrity Monitoring](assets/03_fim_integrite/03_03_shuffle_fim_execution)

---

## 🛑 Stopping the Lab

To stop all containers cleanly without losing data, run:

```bash
./stop.sh
```

---

## 👨‍💻 Author

**Ayoub El Asri**

- Engineering Student in Computer Engineering (Cybersecurity & Cloud Computing)
- [LinkedIn Profile](https://www.linkedin.com/in/ayoub-elasri-cs)
               
