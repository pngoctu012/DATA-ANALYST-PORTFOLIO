Case Study #1 - Danny's Dinner 🍜
----------------------------------------------------------------
![image](https://github.com/user-attachments/assets/9c273c84-cf9b-4086-b1f9-e7a1f3575503)
View the case study [here](https://8weeksqlchallenge.com/case-study-1/)

**📝 Table of contents**
-------------------------------------------------------------------
- [Introduction](https://github.com/pngoctu012/DATA-ANALYST-PORTFOLIO/blob/main/SQL%20Project/Case%20Study%20%231%20-%20Danny's%20Dinner/README.md#introduction)
- [Problem Statement](https://github.com/pngoctu012/DATA-ANALYST-PORTFOLIO/blob/main/SQL%20Project/Case%20Study%20%231%20-%20Danny's%20Dinner/README.md#problem-statement)
- [Dataset](https://github.com/pngoctu012/DATA-ANALYST-PORTFOLIO/blob/main/SQL%20Project/Case%20Study%20%231%20-%20Danny's%20Dinner/README.md#dataset)
- [Entity Relationship Diagram](https://github.com/pngoctu012/DATA-ANALYST-PORTFOLIO/blob/main/SQL%20Project/Case%20Study%20%231%20-%20Danny's%20Dinner/README.md#entity-relationship-diagram)
- [Case Study Questions](https://github.com/pngoctu012/DATA-ANALYST-PORTFOLIO/blob/main/SQL%20Project/Case%20Study%20%231%20-%20Danny's%20Dinner/README.md#case-study-questions)
- [Case Study Solutions](https://github.com/pngoctu012/DATA-ANALYST-PORTFOLIO/blob/main/SQL%20Project/Case%20Study%20%231%20-%20Danny's%20Dinner/Danny%E2%80%99s%20Diner%20Case.sql)

--------------------------------------------------------------------
# Introduction
Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

-------------------------------------------------------------------
# Problem Statement
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

-------------------------------------------------------------------
# Dataset
This dataset have three tables: 
- **Table 1 - sales:** The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.
  |customer_id|order_date|product_id|
  |-----------|----------|----------|
  |A|2021-01-01|1|
  |A|2021-01-01|2|
  |A|2021-01-07|2|
  |A|2021-01-10|3|
  |A|2021-01-11|3|
  |A|2021-01-11|3|
  |B|2021-01-01|2|
  |B|2021-01-02|2|
  |B|2021-01-04|1|
  |B|2021-01-11|1|
  |B|2021-01-16|3|
  |B|2021-02-01|3|
  |C|2021-01-01|3|
  |C|2021-01-01|3|
  |C|2021-01-07|3|

*Note: This is only sample data*
- **Table 2 - menu:** The menu table maps the product_id to the actual product_name and price of each menu item.
  |product_id|product_name|price|
  |-----------|----------|----------|
  |1|sushi|10|
  |2|curry|15|
  |3|ramen|12|

*Note: This is only sample data*
- **Table 3 - members:** The final members table captures the join_date when a customer_id joined the beta version of the Danny’s Diner loyalty program.
  |product_id|product_name|
  |-----------|----------|
  |A|2021-01-07|
  |B|2021-01-09|

*Note: This is only sample data*

-------------------------------------------------------------
# Entity Relationship Diagram
![image](https://github.com/user-attachments/assets/11d35f02-c339-43eb-9294-5a6f80467898)

--------------------------------------------------------------
# Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

Click [here](https://github.com/pngoctu012/DATA-ANALYST-PORTFOLIO/blob/main/SQL%20Project/Case%20Study%20%231%20-%20Danny's%20Dinner/Danny%E2%80%99s%20Diner%20Case.sql) to view my solutions for this case study!



