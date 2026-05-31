# Harmony City Zoo — Claude Context

## Project Purpose

Capstone demo of a "Data-First, AI-Second" multicloud visitor management platform. The goal is to show identity resolution, Data Graph, and Agentforce grounding across data from three clouds (Salesforce, Azure, GCP). Architectural trade-offs (e.g., standard batch connector instead of Zero-Copy) are intentional capstone choices.

## Salesforce Org

- **Org alias:** `storm-cd9049bb96cb12`
- **Data Cloud instance:** `h1zt8mtcmq2g8mjrg8yd0zt0g4.c360a.salesforce.com`

## Key Resources

- [Architecture slides](https://docs.google.com/presentation/d/1ExjzDD6K1eA0iFhgEC2EA8DcoMBRW1RshFE8vP-132Y/edit)
- [Data Cloud Streaming Ingestion API docs](https://developer.salesforce.com/docs/atlas.en-us.c360a_api.meta/c360a_api/c360a_api_streaming_ingestion.htm)
- [Data Graph documentation](https://help.salesforce.com/s/articleView?id=sf.c360_a_data_graph.htm)
- [Agentforce grounding with Data Cloud](https://help.salesforce.com/s/articleView?id=sf.agentforce_data_cloud_grounding.htm)

## Data Model

Five DMOs in Data Cloud:

| DMO | Source | PK | Notes |
|---|---|---|---|
| Individual | Service Cloud Contacts | Individual ID | Email/Phone route through CPE/CPP DMOs |
| Zoo_Ticket | Service Cloud Zoo_Ticket__c | Zoo_Ticket_ID | Joined to Individual via Visitor_External_ID |
| Exhibit_Status | Azure SQL | Exhibit_ID | |
| Animal_Roster | Azure SQL | Animal_ID | Name → Animal_Name (system field collision) |
| Park_Alert | Streaming Ingestion API | Alert_ID | Status → Alert_Status (system field collision) |

Data Graph: `Zoo_Visitor_360_Graph` — root: Unified Individual

## Critical Gotchas

- **Email/Phone**: map through Contact Point Email / Contact Point Phone DMOs, not directly onto Individual. The `Party` field on those DMOs links back to Individual.
- **Park_Alert.Status → Alert_Status**: `Status` is a reserved system field on DMOs.
- **Animal_Roster.Name → Animal_Name**: `Name` is a reserved system field on DMOs.
- **HTTP 202 from Streaming Ingestion API** ≠ record landed — verify in Data Explorer.
- **Park_Alert.Event_Time** must be ISO 8601 format.
- **Identity resolution scope**: IR only operates on Individual. Zoo_Ticket join lives in the Data Graph, not in match rules.
- **Park_Alert has no join to Individual**: model as a top-level contextual node, queried by `Exhibit_Name`.
- **Azure SQL firewall IPs** (CDP2 US-East-2): `52.15.242.74, 52.14.190.51, 3.147.169.136, 3.20.62.47, 13.59.240.150, 3.142.20.224`
- **Zero-Copy connector** requires internal gate `core/sfdc/config/gater/dev/gates/cdp.gates` — not enabled; using standard batch connector.

## Current Blocker

Data Graph editor throws "You can't view or create this Data Graph because you don't have access to all objects and fields" when searching for Exhibit_Status (and Animal_Roster). DMOs show Success in Data Streams and fields are mapped in Data Lake Objects. Root cause as of 2026-05-04: unknown — likely a permissions or DMO registration issue.

## What's Not Started

- Data Graph: Exhibit_Status, Animal_Roster, and Park_Alert nodes (blocked by above)
- Data Graph activation
- Agentforce Zoo Support Agent (topics, actions, Data Cloud grounding)
- Azure Event Grid → Azure Function → Streaming Ingestion pipeline for Park_Alert
