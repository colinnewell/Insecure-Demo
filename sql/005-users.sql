USE demo;
CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255),
    password VARCHAR(255),
    u2f TINYINT UNSIGNED,
    totp TINYINT UNSIGNED
);