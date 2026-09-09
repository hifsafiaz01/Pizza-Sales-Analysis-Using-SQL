-- Pizza Hut Analysis --


CREATE DATABASE PizzaHut;

CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);


-- 1. Basic:
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id)
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    SUM(p.price * od.quantity) AS TotalRevenue
FROM
    pizzas AS p
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.

SELECT 
    PT.name, p.price
FROM
    pizza_types AS PT
        JOIN
    pizzas AS p ON PT.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(OD.order_details_id) AS OrderCount
FROM
    pizzas AS p
        JOIN
    order_details AS OD ON p.pizza_id = OD.pizza_id
GROUP BY 1
ORDER BY OrderCount DESC;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    PT.name, SUM(OD.quantity) AS TotalQuantity
FROM
    pizza_types AS PT
        JOIN
    pizzas AS p ON PT.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS OD ON p.pizza_id = OD.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 2. Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
select PT.category, SUM(OD.quantity) AS TotalQuantity
FROM
    pizza_types AS PT
        JOIN
    pizzas AS p ON PT.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS OD ON p.pizza_id = OD.pizza_id
    GROUP BY 1
    ORDER BY 2 DESC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) as hour, COUNT(order_id) AS TotalOrders
FROM
    orders
GROUP BY 1;

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS name
FROM
    pizza_types
GROUP BY 1;


-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(TotalQuantity)
FROM
    (SELECT 
        o.order_date, SUM(OD.quantity) AS TotalQuantity
    FROM
        orders AS o
    JOIN order_details AS OD ON o.order_id = OD.order_id
    GROUP BY 1) AS OrderQuantity;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    PT.name, SUM(p.price * OD.quantity) AS Revenue
FROM
    pizza_types AS PT
        JOIN
    pizzas AS p ON PT.pizza_type_id = P.pizza_type_id
        JOIN
    order_details AS OD ON p.pizza_id = OD.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;


-- 3. Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    PT.category,
    SUM(p.price * OD.quantity) / (SELECT 
            SUM(p.price * OD.quantity) asTotalSales
        FROM
            order_details AS OD
                JOIN
            pizzas AS p ON OD.pizza_id = p.pizza_id) * 100 AS TotalRevenue
FROM
    pizza_types AS PT
        JOIN
    pizzas AS p ON PT.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS OD ON p.pizza_id = OD.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- Analyze the cumulative revenue generated over time.

SELECT order_date, 
sum(TotalRevenue) over (ORDER BY order_date) AS cum_revenue 
FROM
(SELECT 
        o.order_date, SUM(p.price * OD.quantity) AS TotalRevenue
    FROM
        order_details AS OD
    JOIN pizzas AS p ON OD.pizza_id = p.pizza_id
    join orders as o on o.order_id = OD.order_id
    group by 1) as Sales;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, Revenue
FROM 
(SELECT category, name, Revenue,
rank() over (partition by category order by Revenue DESC) AS T2
FROM
(SELECT 
    PT.category, PT.name, SUM(OD.quantity * p.price) AS Revenue
FROM
    pizza_types AS PT
        JOIN
    pizzas AS p ON PT.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS OD ON OD.pizza_id = p.pizza_id
GROUP BY 1 , 2) AS T1) AS T3
WHERE T2 <=3;

