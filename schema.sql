-- ============================================================
--  PROJECT: Property Rental Operations & Revenue Analytics
--  Author : Samer Zeeshan  |  github.com/samerzee09
--  Tools  : MySQL 8.0 / PostgreSQL 15
-- ============================================================

CREATE TABLE properties (
      property_id     INT PRIMARY KEY AUTO_INCREMENT,
      property_name   VARCHAR(100) NOT NULL,
      address         VARCHAR(200),
      city            VARCHAR(60),
      state           CHAR(2),
      property_type   VARCHAR(30),
      total_units     INT NOT NULL,
      year_built      INT,
      monthly_rent    DECIMAL(8,2) NOT NULL,
      created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
  );

CREATE TABLE tenants (
      tenant_id       INT PRIMARY KEY AUTO_INCREMENT,
      property_id     INT NOT NULL,
      first_name      VARCHAR(50),
      last_name       VARCHAR(50),
      unit_number     VARCHAR(10),
      lease_start     DATE NOT NULL,
      lease_end       DATE NOT NULL,
      monthly_rate    DECIMAL(8,2) NOT NULL,
      security_deposit DECIMAL(8,2),
      status          VARCHAR(20) DEFAULT 'Active',
      FOREIGN KEY (property_id) REFERENCES properties(property_id)
  );

CREATE TABLE payments (
      payment_id      INT PRIMARY KEY AUTO_INCREMENT,
      tenant_id       INT NOT NULL,
      due_date        DATE NOT NULL,
      paid_date       DATE,
      amount_due      DECIMAL(8,2) NOT NULL,
      amount_paid     DECIMAL(8,2),
      late_fee        DECIMAL(6,2) DEFAULT 0.00,
      payment_method  VARCHAR(30),
      payment_status  VARCHAR(20),
      FOREIGN KEY (tenant_id) REFERENCES tenants(tenant_id)
  );

CREATE TABLE maintenance_requests (
      work_id         INT PRIMARY KEY AUTO_INCREMENT,
      property_id     INT NOT NULL,
      unit_number     VARCHAR(10),
      request_date    DATE NOT NULL,
      category        VARCHAR(50),
      priority        VARCHAR(10),
      description     TEXT,
      vendor_name     VARCHAR(100),
      cost            DECIMAL(8,2) DEFAULT 0.00,
      resolved_date   DATE,
      status          VARCHAR(20) DEFAULT 'Open',
      FOREIGN KEY (property_id) REFERENCES properties(property_id)
  );

CREATE TABLE operating_expenses (
      expense_id      INT PRIMARY KEY AUTO_INCREMENT,
      property_id     INT NOT NULL,
      expense_date    DATE NOT NULL,
      category        VARCHAR(50),
      description     VARCHAR(200),
      amount          DECIMAL(10,2) NOT NULL,
      FOREIGN KEY (property_id) REFERENCES properties(property_id)
  );

CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_payments_due    ON payments(due_date);
CREATE INDEX idx_maintenance     ON maintenance_requests(property_id);
