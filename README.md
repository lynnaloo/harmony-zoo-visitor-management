# Harmony City Zoo — Visitor Management System

A capstone architecture project demonstrating a **Data-First, AI-Second** multicloud visitor management platform. Data from Salesforce Service Cloud, Azure SQL, and GCP is unified in Salesforce Data Cloud (Data 360) and surfaced through an Agentforce Zoo Support Agent.

## Architecture Overview

```
Azure SQL ──────────────────────────────────────────────────────┐
  (Exhibit_Status, Animal_Roster)                               │  Azure SQL Connector (batch)
                                                                 ▼
Admin Web App → API Gateway → Management Service → Event Broker → Streaming Ingestion API
                                      │                                   │
                               Azure SQL (SoR)                    Park_Alert DMO
                                                                           │
Service Cloud ─────────────────────────────────────────► Data 360 (Data Cloud)
  (Contacts, Zoo_Ticket__c)          standard connector       │
                                                               ├── Identity Resolution
GCP Cloud Storage ─► Vertex AI Vector Search ◄── Cloud Run    ├── Data Graph
  (Zoo documents)                            (Concierge Agent) └── Agentforce Zoo Support Agent
```

**Salesforce org alias:** `storm-cd9049bb96cb12`  
**Data Cloud instance:** `h1zt8mtcmq2g8mjrg8yd0zt0g4.c360a.salesforce.com`  
**Architecture slides:** [Google Slides](https://docs.google.com/presentation/d/1ExjzDD6K1eA0iFhgEC2EA8DcoMBRW1RshFE8vP-132Y/edit)

## Data Model

### DMOs in Data Cloud

| DMO | Source | Ingestion Method | PK |
|---|---|---|---|
| Individual | Service Cloud Contacts | Standard connector | Individual ID (Contact.Id) |
| Zoo_Ticket | Service Cloud Zoo_Ticket__c | Standard connector | Zoo_Ticket_ID |
| Exhibit_Status | Azure SQL | Batch connector | Exhibit_ID |
| Animal_Roster | Azure SQL | Batch connector | Animal_ID |
| Park_Alert | Azure Event Grid → Azure Function | Streaming Ingestion API | Alert_ID |

### DMO Relationships

- **Individual → Zoo_Ticket**: `Individual.External_Visitor_ID__c = Zoo_Ticket.Visitor_External_ID`
- **Exhibit_Status → Animal_Roster**: `Exhibit_Status.Exhibit_ID = Animal_Roster.Exhibit_ID`
- **Park_Alert**: top-level contextual node (no join to Individual); correlate by `Exhibit_Name`

### Key Field Notes

- `Contact.Email` routes through **Contact Point Email DMO** (not mapped directly to Individual); `Party` field links back
- `Contact.Phone` routes through **Contact Point Phone DMO** same way
- `Animal_Roster.Name` mapped to `Animal_Name` to avoid DMO system field collision
- `Park_Alert.Status` mapped to `Alert_Status` to avoid system field collision

## Repo Layout

```
data/
  azure_sql.sql         # Azure SQL DDL + seed data (11 exhibits, 17 animals)
  Contacts.csv          # 10 visitor records (V-1001 to V-1010)
  Zoo_Ticket__c.csv     # 10 ticket records
documents/              # PDF reference materials (exhibits, animals, events, menus)
zoo_alerts_schema.yaml  # OpenAPI 3.0.3 schema for Park_Alert streaming ingestion
CLAUDE.md               # AI assistant context and Salesforce doc links
PLANS.md                # Build plan and current status
README.md               # This file
```

## Build Status

| Layer | Status |
|---|---|
| Azure SQL data streams (Exhibit_Status, Animal_Roster) | Done |
| GCP (Cloud Storage + Vertex AI Vector Search) | Done |
| Service Cloud (Contacts, Zoo_Ticket__c) | Done |
| Contact Data Stream → Individual + CPE + CPP DMOs | Done |
| Zoo_Ticket Data Stream | Done |
| Exhibit_Status Data Stream | Done |
| Animal_Roster Data Stream | Done |
| Park_Alert Streaming Ingestion (Connected App created) | Done |
| Identity Resolution (154 Unified Individuals) | Done |
| Data Graph — root + Zoo_Ticket node | Done |
| Data Graph — Exhibit_Status, Animal_Roster, Park_Alert nodes | Blocked — see PLANS.md |
| Agentforce Zoo Support Agent | Not started |
| Azure Event Grid → Azure Function pipeline | Not started |

## Key Gotchas

- **Azure SQL firewall**: must allowlist CDP2 US-East-2 IPs: `52.15.242.74, 52.14.190.51, 3.147.169.136, 3.20.62.47, 13.59.240.150, 3.142.20.224`
- **HTTP 202 from Streaming Ingestion API** does not guarantee the record landed — always verify in Data Explorer
- **Identity resolution** operates on Individual DMO only; Zoo_Ticket join is a Data Graph relationship, not a match rule
- **Zero-Copy connector** requires an internal Salesforce gate (`core/sfdc/config/gater/dev/gates/cdp.gates`); standard batch connector used instead
