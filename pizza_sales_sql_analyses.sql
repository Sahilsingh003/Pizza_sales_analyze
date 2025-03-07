-- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS Total_order
FROM
    orders;
    
-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id;
    
-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price desc
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size, SUM(order_details.quantity) AS total_quantity
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY SUM(order_details.quantity) DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS quanitity_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY SUM(order_details.quantity) DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Determine the distribution of orders by hour of the day

SELECT 
    HOUR(orders.order_time) AS order_hour,
    SUM(order_details.quantity) AS quanity
FROM
    orders
        JOIN
    order_details ON orders.order_id = order_details.order_id
GROUP BY HOUR(orders.order_time)
ORDER BY SUM(order_details.quantity) DESC;

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS quantity,
    SUM(quantity * pizzas.price) AS Sales
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY Sales DESC
LIMIT 3;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Total_orders), 0) AS Avg_orders_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS Total_orders
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;


-- Calculate the percentage contribution of each pizza type to total revenue.


SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS Total_sales
                FROM
                    pizzas
                        JOIN
                    order_details ON pizzas.pizza_id = order_details.pizza_id)) * 100,
            2) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY Revenue DESC;

-- Analyze the cumulative revenue generated over time.

SELECT
	order_date,
	SUM(revenue) OVER (
		ORDER BY
			order_date
	) AS cum_revenue
FROM
	(
		SELECT
			orders.order_date,
			SUM(order_details.quantity * pizzas.price) AS revenue
		FROM
			orders
			JOIN order_details ON orders.order_id = order_details.order_id
			JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
		GROUP BY
			orders.order_date
	) AS sales;
    
    
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with ranks as (with revenue as (select pizza_types.name as pizza_name,
pizza_types.category as category, 
sum(order_details.quantity*pizzas.price) as sells
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by 1,2
order by 3 desc
)
select pizza_name,category,sells,
rank() over(partition by category order by sells desc) as rn
from revenue 
group by 1,2
)
select pizza_name,category,sells,rn 
from ranks 
where rn <= 3;
