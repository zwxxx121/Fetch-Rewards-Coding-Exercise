# Fetch-Rewards-Coding-Exercise

**1. Review Existing Unstructured Data and Diagram a New Structured Relational Data Model**
   
   The following ERD shows each table’s fields and the joinable keys across tables.
![alt text](https://github.com/zwxxx121/Fetch-Rewards-Coding-Exercise/blob/main/img/ERD.png)

**2. Write a query that directly answers predetermined questions from a business stakeholder**

   I used MySQL to convert json files to relational database, and wrote queries to answer the above questions given the existing data.
   
   [Click here to view the sql file](https://github.com/zwxxx121/Fetch-Rewards-Coding-Exercise/blob/main/Queries_Business_Questions.sql)
   
   * What are the top 5 brands by receipts scanned for most recent month?
   * How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
   * When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
   * When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
   * Which brand has the most spend among users who were created within the past 6 months?
   * Which brand has the most transactions among users who were created within the past 6 months?
     
   
**3. Evaluate Data Quality Issues in the Data Provided**
   
   I used Python to identify potential data quality issues, including data completeness, integrity, consistency and reliability. 

   [Click here to view the python file](https://github.com/zwxxx121/Fetch-Rewards-Coding-Exercise/blob/main/Fetch%20-%20Data%20Quality.ipynb)
   
**4. Communicate with Stakeholders**
   
   The email includes my questions about the data, my suggestions to resolve the data quality issues, other information I would need to optimize the data assets, my concerns in future production and how I plan to address them.
