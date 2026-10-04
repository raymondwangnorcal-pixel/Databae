-- DataBae schema (PostgreSQL)
-- entity sets only for now, relationships come later

CREATE TABLE users (
    email       VARCHAR(255) PRIMARY KEY,
    verified    BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE profile (
    uni          VARCHAR(10) PRIMARY KEY,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    gender       VARCHAR(30),
    school_year  VARCHAR(20)
);
