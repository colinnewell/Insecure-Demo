USE demo;
CREATE TABLE u2f_keys (
    user_id    INT NOT NULL,
    key_handle VARCHAR(200),
    user_key   BLOB,
    PRIMARY KEY (user_id, key_handle)
);
