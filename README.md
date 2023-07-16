# Fetch-Rewards-Coding-Exercise

**1. Review Existing Unstructured Data and Diagram a New Structured Relational Data Model**
   
   The following ERD shows each table’s fields and the joinable keys across tables.
![alt text](https://github.com/zwxxx121/Fetch-Rewards-Coding-Exercise/blob/main/Screenshot%202023-07-15%20at%2012.49.45%20PM.png)

**2. Write a query that directly answers a predetermined question from a business stakeholder**
   * What are the top 5 brands by receipts scanned for most recent month?
   * How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
   * When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
   * When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
   * Which brand has the most spend among users who were created within the past 6 months?
   * Which brand has the most transactions among users who were created within the past 6 months?
     
   I used MySQL to convert json files to relational database, and wrote queries to answer the above questions given the existing data.
    
**3. Evaluate Data Quality Issues in the Data Provided**
   
   I used Python to identify potential data quality issues, including data completeness, integrity, consistency and reliability. 
   
**4. Communicate with Stakeholders**
   
   The email encludes my questions about the data, my suggestions to resolve the data quality issues, other information I would need to optimize the data assets, my concerns in future production and how I plan to address them.
