# B2B Courier Performance Analysis (Python)

## 1) Executive Summary
This project analyzes B2B courier operations to identify delivery bottlenecks, improve on-time performance, reduce return-to-origin (RTO), and optimize cost per shipment. Using Python (Pandas/NumPy/Matplotlib), I transform raw shipping logs into actionable KPIs and recommendations for operations and vendor management.

**Outcome (examples — replace with your numbers):**
- On-Time Delivery (OTD) improved from **86% → 92%** after route and vendor mix changes.
- RTO reduced by **3.8 pp**, saving an estimated **₹1.2L/month** in avoidable costs.
- Identified **5 hubs** causing 42% of delays; introduced SLA-by-zone targets and weekday staffing adjustments.

---

## 2) Business Problem
B2B shipments often traverse multiple legs (pickup → hub → linehaul → delivery). Small inefficiencies compound into missed SLAs, higher RTO, and increased costs. The business needs:
- Clear **visibility of delivery performance** by **courier, zone, weight band, and hub**.
- Root-cause analysis for **delays and RTO**.
- **Data-driven recommendations** on vendor allocation and SLA targets.

---

## 3) Data & Scope
**Typical inputs (anonymized/synthetic where needed):**
- `shipments.csv` — shipment_id, created_at, pickup_at, out_for_delivery_at, delivered_at, status, weight, zone, pincode, courier_partner, hub, attempts, rto_flag
- `sla_matrix.csv` — SLA hours by zone/weight/service type
- `costs.csv` — base cost, fuel surcharge, weight slab, COD/handling, courier rates

**Timeframe:** e.g., Jan–Jun 2025  
**Volume:** e.g., ~120k shipments across 4 courier partners and 8 regions

> **Privacy note:** Any sensitive fields are masked or aggregated. The analysis focuses on performance patterns, not PII.

---

## 4) KPIs (Clear Definitions)
- **OTD (On-Time Delivery)** = Delivered within SLA / Total delivered
- **Avg. Delivery Time** = `delivered_at - pickup_at` (hours)
- **First-Attempt Success (FAS)** = Deliveries on first attempt / Delivered
- **RTO %** = RTO shipments / Total shipments
- **Damage/Loss %** = Shipments marked damaged/lost / Total shipments
- **Cost per Shipment** = (Base + Surcharges + Handling) / Shipments
- **Zone SLA Adherence** = OTD by Zone (A/B/C/D) vs. target

---

## 5) Methodology (End-to-End)
**a) Ingestion & Type Safety**
- Load CSV/Excel into Pandas with explicit dtypes and date parsing.
- Normalize timezones; standardize `*_at` timestamps.

**b) Data Cleaning**
- Remove exact duplicates; impute or flag missing timestamps.
- Treat negative/zero durations; winsorize extreme outliers.
- Normalize categorical values (courier names, hubs, zones).

**c) Feature Engineering**
- **Durations:** pickup→hub, hub→OFD, OFD→delivered, total transit time.
- **Calendars:** day of week, hour of day, month, holiday/weekend flags.
- **Operational bands:** weight slabs, distance/zone tiers, attempt count.
- **SLA gap:** `actual_duration - sla_duration` (positive = delayed).

**d) Analysis**
- Groupby pivots by **courier/zone/hub/weight band**.
- Cohorts by **shipment week** to track trends.
- Pareto on **hubs/couriers** driving most delays/RTO.
- Correlations between **attempts, weight, distance** and late delivery.

**e) Visualization**
- Distribution of delivery times; OTD trendlines by courier.
- Heatmaps for hub×zone delay hotspots.
- Cost vs. OTD trade-off scatter (partner comparison).

**f) (Optional) Predictive Layer**
- Simple classification to flag **likely-late** shipments at creation time.
- Feature importance for actionable levers (e.g., hub, day, weight).

---

## 6) Key Findings (Replace with your specifics)
- **Vendor Mix:** Courier A excels in **Zone A/B** lightweight parcels; Courier B better for **heavyweight** and Zone C, despite slightly higher cost.
- **Hub Bottlenecks:** 3 hubs account for **~35% of total delays** due to late linehaul departures.
- **Timing Effects:** Shipments **created after 5 pm** show **+18%** higher late risk; **Mon/Tue pickups** perform best.
- **Weight Impact:** Parcels **> 10kg** take **~14 hours longer** on average and have **+2.3 pp** lower OTD.
- **RTO Drivers:** Incomplete address tags and **3+ attempts** predict RTO; targeted pre-delivery confirmation reduces RTO.

---

## 7) Recommendations & Business Impact
- **Reallocate vendor share** by zone/weight to maximize OTD at minimal cost.
- **Hub SLAs:** Introduce **cut-off windows** and monitor **first scan-to-dispatch** at bottleneck hubs.
- **Operational calendar:** Shift pickup cutoffs earlier in high-risk lanes; increase weekend capacity for OFD.
- **Pre-delivery checks** (SMS/IVR) for high-risk RTO pincodes; enforce address validation for B2B consignments.
- **SLA-by-zone targets** in contracts; bonus/penalty aligned to OTD & RTO.

> **Projected impact (example):** OTD +4–6 pp, RTO −2–3 pp, cost per shipment −₹6–₹12 via smarter carrier allocation.

---

## 8) How to Reproduce
```bash
# 1) Create environment
python -m venv .venv
source .venv/bin/activate   # (Windows) .venv\Scripts\activate

# 2) Install core libs
pip install -r requirements.txt
# or:
pip install pandas numpy matplotlib seaborn jupyter

# 3) Launch notebook
jupyter notebook

# 4) Open and run
notebooks/b2bcourieranalysis.ipynb


