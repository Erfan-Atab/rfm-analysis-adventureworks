# RFM Analysis on AdventureWorks

Customer segmentation using the RFM (Recency, Frequency, Monetary) model
on the AdventureWorks2022 OLTP database, implemented entirely in T-SQL.

> **Status:** Work in progress.

---

## Business Problem

AdventureWorks sells bicycles and accessories through two channels: wholesale
to resellers and direct online sales to individual consumers. The marketing
team has a limited budget for retention and reactivation campaigns but no
systematic way to prioritise customers.

This project turns raw transactional data into an actionable behavioural
segmentation, answering: which customers are most valuable, which are at risk
of churning, and where should marketing spend be focused.

---

## Dataset

* **Database:** AdventureWorks2022 (OLTP version)
* **Core tables:** `Sales.SalesOrderHeader`, `Sales.SalesOrderDetail`, `Sales.Customer`
* **Source:** Microsoft sample databases

The `.bak` file is not included in this repository. See Microsoft's
documentation for download and restore instructions.

---

## Repository Structure

```text
docs/     Methodology notes, assumptions, and final report
sql/      Numbered SQL scripts, one per analysis stage
results/  Exported query outputs
assets/   Data model diagram and charts
```

---

## Methodology

*To be completed.*

---

## Key Findings

*To be completed.*

---

## Limitations

*To be completed.*
