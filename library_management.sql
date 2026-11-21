-- 1. CREATE DATABASE
CREATE DATABASE library_management;
USE library_management;
-- 2. AUTHORS TABLE
CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    author_name VARCHAR(100) NOT NULL
);
-- 3. CATEGORIES TABLE
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE
);
-- 4. USERS TABLE
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) UNIQUE,
    address VARCHAR(200),
    registered_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active'
);
-- 5. BOOKS TABLE
CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    publication_year YEAR,
    publisher VARCHAR(100),
    category_id INT NOT NULL,
    author_id INT NOT NULL,

    FOREIGN KEY (category_id)
        REFERENCES categories(category_id),

    FOREIGN KEY (author_id)
        REFERENCES authors(author_id)
);
-- 6. BOOK COPIES TABLE
CREATE TABLE book_copies (
    copy_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    shelf_location VARCHAR(50),
    copy_status ENUM(
        'Available',
        'Issued',
        'Lost',
        'Damaged'
    ) NOT NULL DEFAULT 'Available',

    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE
);
-- 7. LOANS / TRANSACTIONS TABLE
CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    copy_id INT NOT NULL,
    issue_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status ENUM(
        'Issued',
        'Returned',
        'Overdue'
    ) NOT NULL DEFAULT 'Issued',

    FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    FOREIGN KEY (copy_id)
        REFERENCES book_copies(copy_id)
);
-- 8. INSERT AUTHORS
INSERT INTO authors (author_name)
VALUES
('James Gosling'),
('Robert C. Martin'),
('Raghu Ramakrishnan'),
('Jon Duckett'),
('Mark Lutz');
-- 9. INSERT CATEGORIES
INSERT INTO categories (category_name)
VALUES
('Programming'),
('Database'),
('Web Development'),
('Software Engineering');
-- 10. INSERT USERS
INSERT INTO users
(full_name, email, phone, address)
VALUES
('Rahul Kumar', 'rahul@gmail.com', '9876543210', 'Chennai'),
('Priya Sharma', 'priya@gmail.com', '9876543211', 'Trichy'),
('Arun Kumar', 'arun@gmail.com', '9876543212', 'Madurai'),
('Karthik Raj', 'karthik@gmail.com', '9876543213', 'Coimbatore'),
('Divya S', 'divya@gmail.com', '9876543214', 'Salem');
-- 11. INSERT BOOKS
INSERT INTO books
(title, isbn, publication_year, publisher, category_id, author_id)
VALUES
('Java Programming', 'ISBN001', 2023, 'Oracle Press', 1, 1),

('Clean Code', 'ISBN002', 2008, 'Prentice Hall', 4, 2),

('Database Management System', 'ISBN003', 2019, 'McGraw Hill', 2, 3),

('HTML and CSS', 'ISBN004', 2022, 'Wiley', 3, 4),

('Python Programming', 'ISBN005', 2021, 'OReilly', 1, 5);
-- 12. INSERT BOOK COPIES
INSERT INTO book_copies
(book_id, shelf_location, copy_status)
VALUES
(1, 'A-101', 'Available'),
(1, 'A-102', 'Available'),
(1, 'A-103', 'Available'),

(2, 'A-104', 'Available'),
(2, 'A-105', 'Available'),

(3, 'B-101', 'Available'),
(3, 'B-102', 'Available'),

(4, 'C-101', 'Available'),
(4, 'C-102', 'Available'),

(5, 'D-101', 'Available'),
(5, 'D-102', 'Available');
-- 13. ISSUE A BOOK
-- Rahul borrows Java Programming
INSERT INTO loans
(user_id, copy_id, issue_date, due_date, status)
VALUES
(1, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Issued');

UPDATE book_copies
SET copy_status = 'Issued'
WHERE copy_id = 1;
-- 14. ISSUE ANOTHER BOOK
-- Priya borrows Clean Code
INSERT INTO loans
(user_id, copy_id, issue_date, due_date, status)
VALUES
(2, 4, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 'Issued');

UPDATE book_copies
SET copy_status = 'Issued'
WHERE copy_id = 4;
-- 15. VIEW ALL BOOKS
SELECT
    b.book_id,
    b.title,
    a.author_name,
    c.category_name,
    b.isbn,
    b.publication_year,
    b.publisher
FROM books b
JOIN authors a
    ON b.author_id = a.author_id
JOIN categories c
    ON b.category_id = c.category_id
ORDER BY b.title;
-- 16. VIEW AVAILABLE BOOK COPIES
SELECT
    bc.copy_id,
    b.title,
    a.author_name,
    bc.shelf_location
FROM book_copies bc
JOIN books b
    ON bc.book_id = b.book_id
JOIN authors a
    ON b.author_id = a.author_id
WHERE bc.copy_status = 'Available';
-- 17. VIEW CURRENTLY ISSUED BOOKS
SELECT
    l.loan_id,
    u.full_name AS user_name,
    b.title AS book_title,
    l.issue_date,
    l.due_date,
    l.status
FROM loans l
JOIN users u
    ON l.user_id = u.user_id
JOIN book_copies bc
    ON l.copy_id = bc.copy_id
JOIN books b
    ON bc.book_id = b.book_id
WHERE l.status = 'Issued';
-- 18. VIEW OVERDUE BOOKS
SELECT
    l.loan_id,
    u.full_name AS user_name,
    b.title AS book_title,
    l.issue_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) AS overdue_days
FROM loans l
JOIN users u
    ON l.user_id = u.user_id
JOIN book_copies bc
    ON l.copy_id = bc.copy_id
JOIN books b
    ON bc.book_id = b.book_id
WHERE l.status = 'Issued'
AND l.due_date < CURDATE();
-- 19. RETURN A BOOK
-- Rahul returns Java Programming
UPDATE loans
SET
    return_date = CURDATE(),
    status = 'Returned'
WHERE loan_id = 1
AND status = 'Issued';


UPDATE book_copies
SET copy_status = 'Available'
WHERE copy_id = 1;
-- 20. VIEW RETURNED BOOKS
SELECT
    l.loan_id,
    u.full_name AS user_name,
    b.title AS book_title,
    l.issue_date,
    l.return_date,
    l.status
FROM loans l
JOIN users u
    ON l.user_id = u.user_id
JOIN book_copies bc
    ON l.copy_id = bc.copy_id
JOIN books b
    ON bc.book_id = b.book_id
WHERE l.status = 'Returned';
-- 21. USER BORROWING HISTORY
SELECT
    u.user_id,
    u.full_name,
    b.title AS book_title,
    l.issue_date,
    l.due_date,
    l.return_date,
    l.status
FROM loans l
JOIN users u
    ON l.user_id = u.user_id
JOIN book_copies bc
    ON l.copy_id = bc.copy_id
JOIN books b
    ON bc.book_id = b.book_id
ORDER BY l.issue_date DESC;
-- 22. BOOK SEARCH
SELECT
    b.book_id,
    b.title,
    a.author_name,
    c.category_name,
    b.isbn
FROM books b
JOIN authors a
    ON b.author_id = a.author_id
JOIN categories c
    ON b.category_id = c.category_id
WHERE b.title LIKE '%Java%';
-- 23. BOOKS BY CATEGORY
SELECT
    c.category_name,
    COUNT(b.book_id) AS total_books
FROM categories c
LEFT JOIN books b
    ON c.category_id = b.category_id
GROUP BY c.category_id, c.category_name
ORDER BY total_books DESC;
-- 24. MOST BORROWED BOOKS
SELECT
    b.title,
    COUNT(l.loan_id) AS times_borrowed
FROM books b
JOIN book_copies bc
    ON b.book_id = bc.book_id
JOIN loans l
    ON bc.copy_id = l.copy_id
GROUP BY b.book_id, b.title
ORDER BY times_borrowed DESC;
-- 25. USERS WITH ACTIVE LOANS
SELECT
    u.user_id,
    u.full_name,
    u.email,
    COUNT(l.loan_id) AS active_loans
FROM users u
JOIN loans l
    ON u.user_id = l.user_id
WHERE l.status = 'Issued'
GROUP BY u.user_id, u.full_name, u.email;
-- 26. TOTAL BOOK COPIES
SELECT
    COUNT(*) AS total_book_copies
FROM book_copies;
-- 27. AVAILABLE BOOK COPIES COUNT
SELECT
    COUNT(*) AS available_copies
FROM book_copies
WHERE copy_status = 'Available';
-- 28. ISSUED BOOK COPIES COUNT
SELECT
    COUNT(*) AS issued_copies
FROM book_copies
WHERE copy_status = 'Issued';
-- 29. LIBRARY SUMMARY
SELECT
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM books) AS total_book_titles,
    (SELECT COUNT(*) FROM book_copies) AS total_copies,
    (SELECT COUNT(*) FROM book_copies
     WHERE copy_status = 'Available') AS available_copies,
    (SELECT COUNT(*) FROM book_copies
     WHERE copy_status = 'Issued') AS issued_copies;