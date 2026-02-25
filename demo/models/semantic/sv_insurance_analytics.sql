{{
    config(
        materialized='semantic_view'
    )
}}

TABLES(
    customers AS {{ ref('dim_customer') }}
        PRIMARY KEY (customer_id)
        UNIQUE (customer_key)
        WITH SYNONYMS = ('client', 'policyholder', 'insured')
        COMMENT = 'Customer dimension with demographics and risk profiles',

    policies AS {{ ref('fct_policy') }}
        PRIMARY KEY (policy_id)
        WITH SYNONYMS = ('insurance policy', 'contract', 'coverage')
        COMMENT = 'Policy transactions with premiums and coverage details',

    claims AS {{ ref('fct_claim') }}
        PRIMARY KEY (claim_id)
        WITH SYNONYMS = ('insurance claim', 'loss', 'incident')
        COMMENT = 'Claims filed against policies',

    agents AS {{ ref('dim_agent') }}
        PRIMARY KEY (agent_id)
        UNIQUE (agent_key)
        WITH SYNONYMS = ('sales agent', 'broker', 'representative')
        COMMENT = 'Insurance agents who sell policies',

    agencies AS {{ ref('dim_agency') }}
        PRIMARY KEY (agency_id)
        UNIQUE (agency_key)
        WITH SYNONYMS = ('insurance agency', 'broker firm', 'office')
        COMMENT = 'Insurance agencies that employ agents'
)

RELATIONSHIPS(
    policy_customer AS policies(customer_key) REFERENCES customers(customer_key),
    policy_agent AS policies(agent_key) REFERENCES agents(agent_key),
    policy_agency AS policies(agency_key) REFERENCES agencies(agency_key),
    claim_customer AS claims(customer_key) REFERENCES customers(customer_key),
    agent_agency AS agents(agency_id) REFERENCES agencies(agency_id)
)

FACTS(
    policies.premium AS premium_amount
        WITH SYNONYMS = ('premium', 'policy premium', 'insurance cost')
        COMMENT = 'The premium amount charged for the policy',

    policies.annual_premium AS annualized_premium
        WITH SYNONYMS = ('annual premium', 'yearly premium')
        COMMENT = 'Premium normalized to annual basis',

    policies.coverage AS coverage_amount
        WITH SYNONYMS = ('coverage', 'policy limit', 'insured amount')
        COMMENT = 'Maximum coverage amount for the policy',

    policies.deductible AS deductible_amount
        WITH SYNONYMS = ('deductible', 'out of pocket')
        COMMENT = 'Amount customer pays before coverage kicks in',

    claims.claimed AS claim_amount
        WITH SYNONYMS = ('claimed amount', 'loss amount', 'claim value')
        COMMENT = 'Total amount claimed',

    claims.approved AS approved_amount
        WITH SYNONYMS = ('approved claim', 'settlement amount')
        COMMENT = 'Amount approved for the claim',

    claims.paid AS paid_amount
        WITH SYNONYMS = ('paid claim', 'disbursed amount')
        COMMENT = 'Amount actually paid out',

    customers.credit AS credit_score
        WITH SYNONYMS = ('credit rating', 'FICO score')
        COMMENT = 'Customer credit score',

    customers.cust_age AS age
        WITH SYNONYMS = ('age', 'policyholder age')
        COMMENT = 'Age of the customer',

    agents.tenure AS tenure_days
        WITH SYNONYMS = ('experience', 'time employed')
        COMMENT = 'Number of days agent has been employed',

    agencies.commission AS commission_rate
        WITH SYNONYMS = ('commission', 'commission percentage')
        COMMENT = 'Agency commission rate'
)

DIMENSIONS(
    customers.customer_name AS full_name
        WITH SYNONYMS = ('name', 'client name', 'policyholder name')
        COMMENT = 'Full name of the customer',

    customers.cust_city AS city
        WITH SYNONYMS = ('city', 'location')
        COMMENT = 'City where customer resides',

    customers.cust_state AS state_code
        WITH SYNONYMS = ('state', 'region')
        COMMENT = 'State where customer resides',

    customers.cust_type AS customer_type
        WITH SYNONYMS = ('client type', 'segment')
        COMMENT = 'Type of customer: Individual, Family, Business',

    customers.cust_credit_tier AS credit_tier
        WITH SYNONYMS = ('credit category', 'credit rating tier')
        COMMENT = 'Credit score tier: Excellent, Good, Fair, Poor, Very Poor',

    customers.cust_risk AS risk_category
        WITH SYNONYMS = ('risk level', 'risk tier')
        COMMENT = 'Customer risk classification',

    customers.is_active_customer AS is_active
        WITH SYNONYMS = ('active customer', 'current customer')
        COMMENT = 'Whether customer is currently active',

    policies.pol_number AS policy_number
        WITH SYNONYMS = ('policy id', 'contract number')
        COMMENT = 'Unique policy identifier',

    policies.pol_type AS policy_type
        WITH SYNONYMS = ('insurance type', 'coverage type', 'product type')
        COMMENT = 'Type of insurance: Auto, Home, Life, Health, etc.',

    policies.prod_code AS product_code
        WITH SYNONYMS = ('product', 'insurance product')
        COMMENT = 'Product code for the policy',

    policies.pol_status AS policy_status
        WITH SYNONYMS = ('status', 'policy state')
        COMMENT = 'Current status of the policy',

    policies.period_status AS policy_period_status
        WITH SYNONYMS = ('period status', 'term status')
        COMMENT = 'Whether policy is Active, Expired, Expiring Soon, or Future',

    policies.pay_frequency AS payment_frequency
        WITH SYNONYMS = ('billing frequency', 'payment schedule')
        COMMENT = 'How often premiums are paid: Monthly, Quarterly, Annual',

    policies.pay_method AS payment_method
        WITH SYNONYMS = ('billing method', 'payment type')
        COMMENT = 'Method of premium payment',

    policies.is_renewal_policy AS is_renewal
        WITH SYNONYMS = ('renewed policy', 'renewal')
        COMMENT = 'Whether this policy is a renewal',

    policies.pol_effective_date AS effective_date
        WITH SYNONYMS = ('start date', 'policy start')
        COMMENT = 'Date when policy coverage begins',

    policies.pol_expiration_date AS expiration_date
        WITH SYNONYMS = ('end date', 'policy end')
        COMMENT = 'Date when policy coverage ends',

    claims.clm_number AS claim_number
        WITH SYNONYMS = ('claim id', 'case number')
        COMMENT = 'Unique claim identifier',

    claims.clm_type AS claim_type
        WITH SYNONYMS = ('type of claim', 'loss type')
        COMMENT = 'Type of claim filed',

    claims.clm_status AS claim_status
        WITH SYNONYMS = ('status', 'claim state')
        COMMENT = 'Current status of the claim',

    claims.resolution_status AS claim_resolution_status
        WITH SYNONYMS = ('resolution', 'outcome')
        COMMENT = 'Whether claim is Open or Resolved',

    claims.clm_date AS claim_date
        WITH SYNONYMS = ('date filed', 'filing date')
        COMMENT = 'Date when claim was filed',

    claims.inc_date AS incident_date
        WITH SYNONYMS = ('loss date', 'event date')
        COMMENT = 'Date when the incident occurred',

    claims.settle_date AS settlement_date
        WITH SYNONYMS = ('paid date', 'resolution date')
        COMMENT = 'Date when claim was settled',

    agents.agent_name AS full_name
        WITH SYNONYMS = ('agent', 'sales rep', 'broker name')
        COMMENT = 'Full name of the insurance agent',

    agents.agt_license_state AS license_state
        WITH SYNONYMS = ('licensed state', 'agent state')
        COMMENT = 'State where agent is licensed',

    agents.agt_license_status AS license_status
        WITH SYNONYMS = ('license validity')
        COMMENT = 'Status of agent license: Valid, Expired, Expiring Soon',

    agents.agt_employment_status AS employment_status
        WITH SYNONYMS = ('employment', 'job status')
        COMMENT = 'Current employment status of agent',

    agents.is_active_agent AS is_active
        WITH SYNONYMS = ('active agent', 'current agent')
        COMMENT = 'Whether agent is currently active',

    agencies.agy_name AS agency_name
        WITH SYNONYMS = ('agency', 'firm name', 'office name')
        COMMENT = 'Name of the insurance agency',

    agencies.agy_type AS agency_type
        WITH SYNONYMS = ('type of agency', 'agency category')
        COMMENT = 'Type of agency',

    agencies.agy_city AS city
        WITH SYNONYMS = ('agency location', 'office city')
        COMMENT = 'City where agency is located',

    agencies.agy_state AS state_code
        WITH SYNONYMS = ('agency state', 'office state')
        COMMENT = 'State where agency is located',

    agencies.agy_license_status AS license_status
        WITH SYNONYMS = ('agency license validity')
        COMMENT = 'Status of agency license',

    agencies.is_active_agency AS is_active
        WITH SYNONYMS = ('active agency', 'operating agency')
        COMMENT = 'Whether agency is currently active'
)

METRICS(
    policies.total_premium AS SUM(premium_amount)
        WITH SYNONYMS = ('total premiums', 'premium revenue', 'gross written premium')
        COMMENT = 'Total premium amount across policies',

    policies.total_annual_premium AS SUM(annualized_premium)
        WITH SYNONYMS = ('total annual premium', 'annualized revenue')
        COMMENT = 'Total annualized premium',

    policies.total_coverage AS SUM(coverage_amount)
        WITH SYNONYMS = ('total insured amount', 'total coverage')
        COMMENT = 'Total coverage amount across policies',

    policies.avg_premium AS AVG(premium_amount)
        WITH SYNONYMS = ('average premium', 'mean premium')
        COMMENT = 'Average premium per policy',

    policies.avg_coverage AS AVG(coverage_amount)
        WITH SYNONYMS = ('average coverage', 'mean coverage')
        COMMENT = 'Average coverage amount per policy',

    policies.policy_count AS COUNT(policy_id)
        WITH SYNONYMS = ('number of policies', 'policy volume')
        COMMENT = 'Count of policies',

    claims.total_claims AS SUM(claim_amount)
        WITH SYNONYMS = ('total claimed', 'gross claims', 'total losses')
        COMMENT = 'Total amount claimed',

    claims.total_paid AS SUM(paid_amount)
        WITH SYNONYMS = ('total paid out', 'claims paid', 'disbursements')
        COMMENT = 'Total amount paid on claims',

    claims.total_approved AS SUM(approved_amount)
        WITH SYNONYMS = ('total approved', 'approved claims')
        COMMENT = 'Total amount approved for claims',

    claims.avg_claim AS AVG(claim_amount)
        WITH SYNONYMS = ('average claim', 'mean claim')
        COMMENT = 'Average claim amount',

    claims.claim_count AS COUNT(claim_id)
        WITH SYNONYMS = ('number of claims', 'claim volume')
        COMMENT = 'Count of claims',

    customers.customer_count AS COUNT(DISTINCT customer_id)
        WITH SYNONYMS = ('number of customers', 'customer base', 'client count')
        COMMENT = 'Count of unique customers',

    customers.avg_credit_score AS AVG(credit_score)
        WITH SYNONYMS = ('average credit', 'mean credit score')
        COMMENT = 'Average customer credit score',

    agents.agent_count AS COUNT(DISTINCT agent_id)
        WITH SYNONYMS = ('number of agents', 'agent headcount')
        COMMENT = 'Count of unique agents',

    agencies.agency_count AS COUNT(DISTINCT agency_id)
        WITH SYNONYMS = ('number of agencies', 'agency count')
        COMMENT = 'Count of unique agencies'
)

COMMENT = 'Insurance analytics semantic view for natural language queries'
