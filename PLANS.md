# Harmony City Zoo — Build Plan

## Completed

- [x] Azure SQL — DDL + seed data (11 exhibits, 17 animals) in `data/azure_sql.sql`
- [x] Service Cloud — Contacts (10 records, V-1001–V-1010) and Zoo_Ticket__c (10 records)
- [x] GCP — Cloud Storage (zoo documents), Vertex AI Vector Search, Cloud Run concierge agent
- [x] Data Cloud — Contact Data Stream → Individual DMO + Contact Point Email + Contact Point Phone DMOs
- [x] Data Cloud — Zoo_Ticket Data Stream → Zoo_Ticket custom DMO
- [x] Data Cloud — Exhibit_Status Data Stream (Azure SQL batch connector)
- [x] Data Cloud — Animal_Roster Data Stream (Azure SQL batch connector)
- [x] Data Cloud — Park_Alert Streaming Ingestion API (Connected App created, `zoo_alerts_schema.yaml`)
- [x] Identity Resolution — `Zoo_Visitor_Identity_Resolution` ruleset → 154 Unified Individuals
- [x] Data Graph — `Zoo_Visitor_360_Graph` created, root (Unified Individual) + Zoo_Ticket node added

---

## Phase 3 — Complete the Data Graph

### 3.1 Resolve Exhibit_Status / Animal_Roster permissions blocker

**Blocker:** Data Graph editor throws:
> "You can't view or create this Data Graph because you don't have access to all objects and fields"

when searching for Exhibit_Status (and by extension Animal_Roster). DMOs show Success in Data Streams; fields are mapped in Data Lake Objects.

**Investigation checklist:**
- [ ] Confirm the running user's Data Cloud permission set includes read access to Exhibit_Status and Animal_Roster DLOs
- [ ] Check whether the DMOs are marked as "Discoverable" in Data Cloud setup
- [ ] Verify Data Lake Object field-level security — all fields must be accessible to the Data Graph editor user
- [ ] Try cloning the permission set and re-assigning
- [ ] Check for any missing `Data Model Object` vs `Data Lake Object` linkage in Data Cloud setup

### 3.2 Add remaining nodes to Zoo_Visitor_360_Graph

- [ ] Add Exhibit_Status node (joined to root via… contextual — no direct Individual join; add as related node)
- [ ] Add Animal_Roster node (joined to Exhibit_Status via `Exhibit_ID`)
- [ ] Add Park_Alert node (top-level contextual node; no join to Individual; query by `Exhibit_Name`)

### 3.3 Activate the Data Graph

- [ ] Review all node field selections (include only fields needed for agent grounding)
- [ ] Activate `Zoo_Visitor_360_Graph`
- [ ] Verify activation in Data Cloud — check for errors in Data Graph run logs

---

## Phase 4 — Agentforce Zoo Support Agent

### 4.1 Agent setup

- [ ] Create agent in Agentforce Studio: `Zoo Support Agent`
- [ ] Set Data Cloud grounding to `Zoo_Visitor_360_Graph`
- [ ] Configure agent persona and instructions

### 4.2 Topics

| Topic | Description |
|---|---|
| Visitor Lookup | Retrieve visitor profile and ticket history by name or ID |
| Exhibit Status | Check current status and maintenance info for a specific exhibit |
| Animal Info | Look up animal name, species, diet, and home exhibit |
| Park Alerts | Surface active alerts for a given exhibit or zone |
| General Zoo Info | Answer questions about events, menus, hours (GCP Concierge Agent) |

### 4.3 Actions

- [ ] `GetVisitorProfile` — query Individual + Zoo_Ticket from Data Graph
- [ ] `GetExhibitStatus` — query Exhibit_Status node
- [ ] `GetAnimalRoster` — query Animal_Roster node filtered by Exhibit_ID
- [ ] `GetParkAlerts` — query Park_Alert node filtered by Exhibit_Name
- [ ] `AskConcierge` — call GCP Cloud Run Zoo Concierge Agent for document-grounded answers

### 4.4 Testing

- [ ] Test each topic with sample visitor IDs (V-1001 through V-1010)
- [ ] Test exhibit status lookup for all 11 exhibits
- [ ] Test park alert retrieval (requires streaming pipeline — see Phase 5)

---

## Phase 5 — Azure Event Grid → Streaming Ingestion Pipeline

### 5.1 Azure Function

- [ ] Create Azure Function triggered by Event Grid topic (exhibit status change events)
- [ ] Map event payload to Park_Alert schema (`zoo_alerts_schema.yaml`)
- [ ] Authenticate to Salesforce using Connected App OAuth (client credentials flow)
- [ ] POST to Streaming Ingestion API endpoint

### 5.2 Event Grid

- [ ] Create Event Grid topic for exhibit management events
- [ ] Wire Management Service to publish `ExhibitStatusChanged` events to the topic
- [ ] Subscribe Azure Function to the topic

### 5.3 End-to-end test

- [ ] Trigger a status change from Admin Web App
- [ ] Confirm event flows: Admin Web App → Management Service → Event Grid → Azure Function → Streaming Ingestion API
- [ ] Verify Park_Alert record appears in Data Explorer (HTTP 202 ≠ landed — check Data Explorer)

---

## Phase 6 — Headless 360 Custom Visitor UI

Custom web UI for zoo visitors that talks to the Agentforce Zoo Support Agent via the Agentforce API (Headless 360 / Einstein Bots Headless API). The UI is a standalone React app — no Salesforce UI components — deployed independently and authenticated via Connected App.

### 6.1 Connected App and API setup

- [ ] Create (or reuse) a Connected App with the `chatbot_api` OAuth scope for Headless API access
- [ ] Enable the Agentforce Headless API on the Zoo Support Agent
- [ ] Document the session start endpoint and required auth headers
- [ ] Test raw API session lifecycle (start session → send message → receive response → end session) via curl

### 6.2 Project scaffold

- [ ] Initialize React app (`create-react-app` or Vite) under `ui/visitor-portal/`
- [ ] Add environment config: `REACT_APP_SF_INSTANCE_URL`, `REACT_APP_CONNECTED_APP_CLIENT_ID`, `REACT_APP_AGENT_ID`
- [ ] Create API client module (`src/api/agentforceClient.js`) wrapping:
  - `POST /einstein/ai/v1/agents/{agentId}/sessions` — start session
  - `POST /einstein/ai/v1/agents/{agentId}/sessions/{sessionId}/messages` — send message
  - `DELETE /einstein/ai/v1/agents/{agentId}/sessions/{sessionId}` — end session
- [ ] Handle OAuth token exchange (client credentials flow) in a lightweight backend proxy or Netlify/Vercel function to keep client secret off the browser

### 6.3 Core UI components

- [ ] `ChatWindow` — scrollable message thread, renders agent and visitor turns
- [ ] `MessageInput` — text input + send button, handles Enter key
- [ ] `SessionManager` — starts session on mount, ends session on unmount/tab close
- [ ] `TypingIndicator` — shown while awaiting agent response
- [ ] `AlertBanner` — displays active Park Alerts surfaced by the agent (parse structured data from agent response if available)

### 6.4 Visitor identity flow

- [ ] Visitor enters their External Visitor ID (V-1001 format) or name on a landing screen
- [ ] ID is passed as context in the first message to the agent to scope the session to that visitor's Data Graph profile
- [ ] Display visitor's name in the chat header once resolved

### 6.5 UI/UX

- [ ] Zoo-branded theme (colors, logo placeholder)
- [ ] Mobile-responsive layout
- [ ] Accessible: keyboard navigable, ARIA labels on interactive elements, sufficient color contrast

### 6.6 Testing and deployment

- [ ] Unit tests for `agentforceClient.js` (mock fetch)
- [ ] Component tests for `ChatWindow` and `MessageInput`
- [ ] End-to-end smoke test: start session → ask "What exhibits are open today?" → verify response references Exhibit_Status data
- [ ] Deploy to static host (Netlify, Vercel, or Azure Static Web Apps)
- [ ] Document CORS configuration required on the Salesforce Connected App

---

## Optional / Future

- [ ] Enable Zero-Copy connector (requires internal Salesforce gate: `core/sfdc/config/gater/dev/gates/cdp.gates`)
- [ ] Add Slack/Social Media notification handlers from Azure Event Handlers
- [ ] GCP Concierge Agent integration with Zoo Support Agent (Cloud Run endpoint)
