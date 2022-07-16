CREATE USER 'test'@'localhost'
        IDENTIFIED WITH mysql_native_password BY 'test-pass'
        WITH MAX_QUERIES_PER_HOUR 100
        PASSWORD EXPIRE INTERVAL 180 DAY
        FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 1
        ATTRIBUTE '{"surname": "Pretty", "name": "James"}';
GRANT SELECT ON test_db.* TO 'test'@'localhost';
