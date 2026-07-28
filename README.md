# Fraud and Scams Analytics Data Mart

A portfolio data-modelling and analytics-engineering project using Snowflake, dbt and Power BI.

## Business problem

The Fraud Operations team needs a trusted reporting model to monitor fraud and scam cases, measure financial loss, track detection effectiveness and understand operational performance.

## Current architecture

- Raw layer
- Silver staging layer
- Gold dimensional model
- Power BI reporting layer

## Gold model

### Fact table

- `fct_scam_cases`
- Grain: one row per fraud/scam investigation case

### Dimensions

- `dim_customer`
- `dim_account`
- `dim_product`
- `dim_channel`
- `dim_scam_type`
- `dim_rule`
- `dim_date`

## Project status

Phases 1–7 and Phase 8.1 are complete.

Current phase:

- Phase 8.2 — Environment setup