CREATE TABLE users (
	user_id SERIAL PRIMARY KEY,
	user_name VARCHAR(255),
	phone_number VARCHAR(20),
	email VARCHAR(255),
	date_of_birth DATE,
	user_type VARCHAR(10) CHECK (user_type IN ('host', 'guest'))
);

CREATE TABLE rooms (
	room_id SERIAL PRIMARY KEY,
	host_id INT REFERENCES users(user_id),
	room_name VARCHAR(255),
	capacity INT,
	price_per_night DECIMAL(10, 2),
	has_AC BOOLEAN,
	has_refrigerator BOOLEAN,
	other_attributes TEXT
);

CREATE TABLE reservations (
	reservation_id SERIAL PRIMARY KEY,
	guest_id INT REFERENCES users(user_id),
	room_id INT REFERENCES rooms(room_id),
	check_in_date DATE,
	check_out_date DATE,
	total_price DECIMAL(10, 2),
	reservation_status VARCHAR(20) CHECK (reservation_status IN ('pending', 'confirmed', 'cancelled'))
);

CREATE TABLE payments (
	payment_id SERIAL PRIMARY KEY,
	reservation_id INT REFERENCES reservations(reservation_id),
	amount_paid DECIMAL(10, 2),
	payment_date DATE
);

CREATE TABLE reviews (
	review_id SERIAL PRIMARY KEY,
	guest_id INT REFERENCES users(user_id),
	host_id INT REFERENCES users(user_id),
	room_id INT REFERENCES rooms(room_id),
	rating INT,
	commentary TEXT
);

CREATE TABLE availability (
	availability_id SERIAL PRIMARY KEY,
	room_id INT REFERENCES rooms(room_id),
	date_available DATE,
	is_available BOOLEAN
);

INSERT INTO users (user_name, phone_number, email, date_of_birth, user_type) VALUES
    ('Іван Петров', '+380501234567', 'ivan@example.com', '1990-05-15', 'host'),
    ('Олена Коваленко', '+380997654321', 'olena@example.com', '1985-12-10', 'guest'),
    ('Павло Сидоренко', '+380673214567', 'pavlo@example.com', '1998-08-25', 'host');

INSERT INTO rooms (host_id, room_name, capacity, price_per_night, has_AC, has_refrigerator, other_attributes) VALUES
    (1, 'Приватна кімната в центрі', 2, 500, TRUE, TRUE, 'Wi-Fi доступно'),
    (1, 'Затишний апартамент', 4, 800, TRUE, TRUE, 'Велика ванна кімната'),
    (3, 'Студія біля моря', 2, 600, TRUE, FALSE, 'Вид на море');

INSERT INTO reservations (guest_id, room_id, check_in_date, check_out_date, total_price, reservation_status) VALUES
    (2, 1, '2024-05-10', '2024-05-15', 2500, 'confirmed'),
    (3, 3, '2024-06-20', '2024-06-25', 3000, 'pending'),
    (2, 2, '2024-07-05', '2024-07-10', 4000, 'confirmed');

INSERT INTO payments (reservation_id, amount_paid, payment_date) VALUES
    (1, 2500, '2024-03-30'),
    (3, 1500, '2024-03-22'),
    (3, 1500, '2024-03-23');

INSERT INTO reviews (guest_id, host_id, room_id, rating, commentary) VALUES
    (2, 1, 1, 4, 'Дуже зручне місце, рекомендую!'),
    (3, 1, 3, 5, 'Чудовий вид з вікна, гарна квартира'),
    (2, 3, 2, 4, 'Все було чудово, дякую!');

INSERT INTO availability (room_id, date_available, is_available) VALUES
    (1, '2024-05-16', TRUE),
    (1, '2024-05-17', TRUE),
    (1, '2024-05-18', FALSE); 

-- A user who had the biggest amount of reservations
SELECT user_name, user_id
FROM users
WHERE user_id = (
    SELECT guest_id
    FROM reservations
    GROUP BY guest_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- A host who earned the biggest amount of money for the last month
SELECT u.user_name AS host_name
	, u.user_id AS host_id
FROM users u
JOIN rooms r ON u.user_id = r.host_id
JOIN reservations res ON r.room_id = res.room_id
JOIN payments pay ON res.reservation_id = pay.reservation_id
WHERE date_trunc('month', pay.payment_date) = date_trunc('month', CURRENT_DATE) - INTERVAL '1 month'
GROUP BY u.user_id
ORDER BY SUM(pay.amount_paid) DESC
LIMIT 1;

-- A host with the best average rating
SELECT u.user_name AS host_name
	, u.user_id AS host_id
FROM users u
JOIN reviews rev ON u.user_id = rev.host_id
GROUP BY u.user_id
ORDER BY AVG(rev.rating) DESC
LIMIT 1;