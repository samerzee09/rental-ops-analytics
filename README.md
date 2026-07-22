# Property Rental Operations & Revenue Analytics

**Author:** Samer Zeeshan | [LinkedIn](https://linkedin.com/in/samer-zeeshan-759417212) | [GitHub](https://github.com/samerzee09)
**Tools:** SQL (MySQL 8.0) · Microsoft Excel (Advanced) · Power BI-style Dashboard
**Source Data:** DePaul University — Exp25 Excel Ch09 HOE Rentals

---

## Project Overview

An end-to-end rental portfolio analytics project tracking occupancy, revenue, delinquency, and operational performance across 8 properties in the Chicagoland area. Built to demonstrate production-level SQL schema design, Advanced Excel analysis, and interactive dashboard reporting for data and business analyst roles.

---

## Skills Demonstrated

**SQL:** 5-table relational schema, JOINs, CTEs, GROUP BY, CASE, window functions (RANK, LEAD, AVG OVER), DATEDIFF, COALESCE, DATE_FORMAT

**Advanced Excel:** Power Query, XLOOKUP, SUMIFS, SUMPRODUCT, pivot tables with calculated NOI margin fields, conditional formatting for occupancy thresholds

**Dashboard / Power BI-style:** KPI cards, bar+line combo chart, occupancy trend with target line, NOI horizontal bar, payment status donut, maintenance by category, property performance table

---

## Key SQL Queries

| Query | Technique |
|-------|-----------|
| Occupancy rate by property & quarter | LEFT JOIN, GROUP BY, ROUND |
| Net Operating Income (NOI) by property | CTEs, multiple JOINs, COALESCE |
| Late payment trend by month | DATE_FORMAT, CASE, GROUP BY |
| Vacancy duration between leases | LEAD() window function, DATEDIFF |
| Maintenance cost by category | RANK() window function, GROUP BY |
| Revenue per unit ranking | RANK() + portfolio % window function |
| Rolling 3-month revenue | AVG() OVER ROWS BETWEEN |
| Tenant retention by property | CASE stratification, GROUP BY |

---

## Key Findings

- Portfolio occupancy improved from 87.2% to 91.4% YoY (+4.2 pts), exceeding the 90% target in Q2-Q4 2024
- - Single-family and townhouse units generated 20%+ higher revenue per unit ($16,800-$18,000) vs. apartment buildings ($6,120-$8,900)
  - - Prairie View Condos showed 70% occupancy — the largest gap below target — requiring immediate leasing action
    - - NOI margin held at 71.9% despite maintenance spend rising 14% YoY; HVAC accounted for 32% of all maintenance costs
      - - Average vacancy duration dropped from 24 days to 18 days YoY, reducing lost rent exposure
       
        - ---

        ## Files in This Repo

        | File | Description |
        |------|-------------|
        | `schema.sql` | 5-table relational schema: properties, tenants, payments, maintenance_requests, operating_expenses |
        | `queries.sql` | 8 analytical SQL queries with inline comments |
        | `dashboard.html` | Interactive dashboard — open in any browser (no server required) |

        ---

        ## How to Run

        1. Import `schema.sql` into MySQL Workbench or any MySQL 8.0+ instance
        2. 2. Load your data (or generate sample data matching the schema)
           3. 3. Run queries from `queries.sql` — each query is independently executable
              4. 4. Open `dashboard.html` in Chrome or Edge for the full interactive dashboard
                
                 5. ---
                
                 6. ## Dashboard Preview
                
                 7. - 6 KPI cards: Occupancy (91.4%), Gross Revenue ($1.24M), NOI ($892K), Delinquency Rate (6.8%), Maintenance Spend ($87.4K), Avg Vacancy (18 days)
                    - - Monthly revenue vs. expenses bar+line combo chart
                      - - Quarterly occupancy trend with 90% target benchmark line
                        - - NOI by property ranked horizontally
                          - - Payment status donut (Paid / Late / Partial / Unpaid)
                            - - Maintenance cost by category (HVAC, Plumbing, Electrical, etc.)
                              - - Property performance summary table with revenue-per-unit window ranking
