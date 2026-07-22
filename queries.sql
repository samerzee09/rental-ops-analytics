-- ============================================================
--  RENTAL OPS: Analytical SQL Queries
--  Author: Samer Zeeshan  |  github.com/samerzee09
-- ============================================================

-- Q1: Occupancy Rate by Property & Quarter
SELECT
    p.property_name, p.city, p.property_type,
    YEAR(t.lease_start)                                    AS yr,
    QUARTER(t.lease_start)                                 AS qtr,
    p.total_units,
    COUNT(t.tenant_id)                                     AS occupied_units,
    ROUND(COUNT(t.tenant_id) * 100.0 / p.total_units, 1)  AS occupancy_rate_pct
FROM properties p
LEFT JOIN tenants t ON p.property_id = t.property_id AND t.status = 'Active'
GROUP BY p.property_name, p.city, p.property_type, yr, qtr, p.total_units
ORDER BY yr DESC, qtr DESC, occupancy_rate_pct DESC;

-- Q2: Net Operating Income (NOI) by Property
WITH rent_collected AS (
    SELECT t.property_id, SUM(py.amount_paid) AS total_rent
    FROM payments py
    JOIN tenants t ON py.tenant_id = t.tenant_id
    WHERE py.payment_status IN ('Paid','Late')
    GROUP BY t.property_id
),
maint_expenses AS (
    SELECT property_id, SUM(cost) AS maint_cost
    FROM maintenance_requests WHERE status = 'Resolved'
    GROUP BY property_id
),
op_expenses AS (
    SELECT property_id, SUM(amount) AS op_cost
    FROM operating_expenses GROUP BY property_id
)
SELECT
    p.property_name, p.city, p.property_type,
    COALESCE(rc.total_rent, 0)                                          AS gross_revenue,
    COALESCE(me.maint_cost, 0)                                          AS maintenance_cost,
    COALESCE(oe.op_cost, 0)                                             AS operating_cost,
    COALESCE(rc.total_rent,0) - COALESCE(me.maint_cost,0)
                              - COALESCE(oe.op_cost,0)                  AS noi,
    ROUND((COALESCE(rc.total_rent,0) - COALESCE(me.maint_cost,0)
                                     - COALESCE(oe.op_cost,0))
          * 100.0 / NULLIF(COALESCE(rc.total_rent,0),0), 1)            AS noi_margin_pct
FROM properties p
LEFT JOIN rent_collected rc ON p.property_id = rc.property_id
LEFT JOIN maint_expenses  me ON p.property_id = me.property_id
LEFT JOIN op_expenses     oe ON p.property_id = oe.property_id
ORDER BY noi DESC;

-- Q3: Late Payment Rate by Month
SELECT
    DATE_FORMAT(due_date, '%Y-%m')                              AS month,
    COUNT(*)                                                    AS total_payments,
    SUM(CASE WHEN payment_status = 'Late'   THEN 1 ELSE 0 END) AS late_count,
    SUM(CASE WHEN payment_status = 'Unpaid' THEN 1 ELSE 0 END) AS unpaid_count,
    ROUND(SUM(CASE WHEN payment_status IN ('Late','Unpaid') THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)                                AS delinquency_rate_pct,
    SUM(COALESCE(late_fee, 0))                                  AS late_fees_collected
FROM payments
GROUP BY DATE_FORMAT(due_date, '%Y-%m')
ORDER BY month;

-- Q4: Vacancy Duration Between Leases (Window Function)
WITH ordered_leases AS (
    SELECT property_id, unit_number, lease_start, lease_end,
           LEAD(lease_start) OVER (PARTITION BY property_id, unit_number ORDER BY lease_start) AS next_lease_start
    FROM tenants
)
SELECT
    p.property_name, ol.unit_number, ol.lease_end, ol.next_lease_start,
    DATEDIFF(ol.next_lease_start, ol.lease_end) AS vacancy_days
FROM ordered_leases ol
JOIN properties p ON ol.property_id = p.property_id
WHERE ol.next_lease_start IS NOT NULL AND DATEDIFF(ol.next_lease_start, ol.lease_end) > 0
ORDER BY vacancy_days DESC;

-- Q5: Maintenance Cost by Category & Priority
SELECT
    category, priority,
    COUNT(*)                    AS work_orders,
    SUM(cost)                   AS total_cost,
    ROUND(AVG(cost), 2)         AS avg_cost,
    ROUND(AVG(DATEDIFF(resolved_date, request_date)), 1) AS avg_days_to_resolve,
    RANK() OVER (ORDER BY SUM(cost) DESC) AS cost_rank
FROM maintenance_requests WHERE status = 'Resolved'
GROUP BY category, priority
ORDER BY total_cost DESC;

-- Q6: Revenue Per Unit Ranking (Window Function)
SELECT
    p.property_name, p.city, p.property_type, p.total_units,
    SUM(py.amount_paid)                                   AS total_revenue,
    ROUND(SUM(py.amount_paid) / p.total_units, 2)         AS revenue_per_unit,
    RANK() OVER (ORDER BY SUM(py.amount_paid) / p.total_units DESC) AS efficiency_rank,
    ROUND(100.0 * SUM(py.amount_paid) / SUM(SUM(py.amount_paid)) OVER (), 1) AS pct_of_portfolio
FROM payments py
JOIN tenants t    ON py.tenant_id   = t.tenant_id
JOIN properties p ON t.property_id  = p.property_id
WHERE py.payment_status IN ('Paid','Late')
GROUP BY p.property_name, p.city, p.property_type, p.total_units
ORDER BY efficiency_rank;

-- Q7: Rolling 3-Month Revenue Trend (Window Function)
SELECT
    DATE_FORMAT(py.paid_date, '%Y-%m') AS month,
    SUM(py.amount_paid)                AS monthly_revenue,
    ROUND(AVG(SUM(py.amount_paid)) OVER (
        ORDER BY DATE_FORMAT(py.paid_date, '%Y-%m')
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2)                              AS rolling_3m_avg
FROM payments py
WHERE py.payment_status IN ('Paid','Late')
GROUP BY DATE_FORMAT(py.paid_date, '%Y-%m')
ORDER BY month;

-- Q8: Tenant Retention Analysis
SELECT
    p.property_name,
    COUNT(DISTINCT t.tenant_id)                                          AS total_tenants,
    SUM(CASE WHEN t.status='Active' AND t.lease_end > CURDATE() THEN 1 ELSE 0 END) AS active,
    SUM(CASE WHEN t.status='Expired'    THEN 1 ELSE 0 END)              AS expired,
    SUM(CASE WHEN t.status='Terminated' THEN 1 ELSE 0 END)              AS terminated,
    ROUND(SUM(CASE WHEN t.status='Active' AND t.lease_end > CURDATE() THEN 1 ELSE 0 END)
          * 100.0 / COUNT(DISTINCT t.tenant_id), 1)                     AS retention_rate_pct
FROM tenants t
JOIN properties p ON t.property_id = p.property_id
GROUP BY p.property_name
ORDER BY retention_rate_pct DESC;
