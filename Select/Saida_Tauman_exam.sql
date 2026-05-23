-- Task 1
SELECT
    cu.first_name         AS first_name,
    cu.last_name          AS last_name,
    ci.city               AS city_name
FROM public.customer cu
JOIN public.address a  ON cu.address_id = a.address_id
JOIN public.city    ci ON a.city_id    = ci.city_id
WHERE ci.city = 'Aurora'
ORDER BY cu.last_name ASC;

-- Task 2
SELECT
    l.name                AS language_name,
    COUNT(f.film_id)      AS film_count
FROM public.film f
JOIN public.language l ON f.language_id = l.language_id
GROUP BY l.name
ORDER BY film_count DESC;

-- Task 3
SELECT
    f.title               AS film_title,
    f.length              AS length_minutes,
    cat.name              AS category_name
FROM public.film f
JOIN public.film_category fc ON f.film_id = fc.film_id
JOIN public.category cat     ON fc.category_id = cat.category_id
ORDER BY f.length DESC, f.title ASC
LIMIT 10;

-- Task 4
SELECT
    cu.store_id           AS store_id,
    COUNT(cu.customer_id) AS active_customer_count
FROM public.customer cu
WHERE cu.activebool = true
GROUP BY cu.store_id
ORDER BY cu.store_id ASC;

-- Task 5
SELECT
    cat.name              AS category,
    SUM(p.amount)         AS total_revenue
FROM public.payment p
JOIN public.rental r         ON p.rental_id = r.rental_id
JOIN public.inventory i      ON r.inventory_id = i.inventory_id
JOIN public.film f           ON i.film_id = f.film_id
JOIN public.film_category fc ON f.film_id = fc.film_id
JOIN public.category cat     ON fc.category_id = cat.category_id
GROUP BY cat.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Task 6
SELECT
    f.title               AS film_title
FROM public.film f
LEFT JOIN public.inventory i  ON f.film_id = i.film_id
LEFT JOIN public.rental r     ON i.inventory_id = r.inventory_id
LEFT JOIN public.customer cu  ON r.customer_id = cu.customer_id
LEFT JOIN public.address a    ON cu.address_id = a.address_id
LEFT JOIN public.city ci      ON a.city_id = ci.city_id AND ci.city = 'London'
WHERE r.rental_id IS NULL
ORDER BY f.title ASC;

-- Task 7
SELECT
    co.country            AS country_name,
    COUNT(cu.customer_id) AS active_customer_count
FROM public.customer cu
JOIN public.address a        ON cu.address_id = a.address_id
JOIN public.city ci          ON a.city_id = ci.city_id
JOIN public.country co       ON ci.country_id = co.country_id
WHERE cu.activebool = true
GROUP BY co.country
HAVING COUNT(cu.customer_id) >= 2
ORDER BY active_customer_count DESC, co.country ASC;

-- Task 8
SELECT
    st.first_name || ' ' || st.last_name AS staff_full_name,
    st.store_id                          AS store_id,
    COUNT(DISTINCT r.rental_id)          AS rental_count,
    SUM(p.amount)                        AS total_revenue
FROM public.staff st
JOIN public.rental r  ON st.staff_id = r.staff_id
JOIN public.payment p ON r.rental_id = p.rental_id
GROUP BY st.staff_id, st.first_name, st.last_name, st.store_id
ORDER BY total_revenue DESC;
