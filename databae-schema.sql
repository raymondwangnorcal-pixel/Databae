-- PostgreSQL schema derived from the DataBae E/R diagram.

CREATE TABLE profile (
    uni                 CHAR(10),
    first_name          CHAR(50) NOT NULL,
    last_name           CHAR(50) NOT NULL,
    gender              CHAR(20),
    graduation_year     INTEGER,
    PRIMARY KEY (uni)
);

CREATE TABLE department (
    name                CHAR(100),
    housed_at           CHAR(100),
    offered_major       BOOLEAN NOT NULL,
    offered_minor       BOOLEAN NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE classes (
    call_number         CHAR(10),
    course_name         CHAR(100) NOT NULL,
    professor           CHAR(100),
    department_name     CHAR(100) NOT NULL,
    PRIMARY KEY (call_number),
    FOREIGN KEY (department_name) REFERENCES department(name)
        ON DELETE NO ACTION
);

CREATE TABLE users (
    email               CHAR(100),
    verified            BOOLEAN NOT NULL,
    claimed_uni         CHAR(10) NOT NULL,
    PRIMARY KEY (email),
    UNIQUE (claimed_uni),
    FOREIGN KEY (claimed_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    CHECK (
        LOWER(email) LIKE '_%@columbia.edu'
        OR LOWER(email) LIKE '_%@barnard.edu'
    )
);

CREATE TABLE status_submission (
    sid                 INTEGER,
    status              CHAR(20) NOT NULL,
    created_at          TIMESTAMP NOT NULL,
    verified            BOOLEAN NOT NULL,
    submitter_email     CHAR(100) NOT NULL,
    profile_uni         CHAR(10) NOT NULL,
    PRIMARY KEY (sid),
    FOREIGN KEY (submitter_email) REFERENCES users(email)
        ON DELETE NO ACTION,
    FOREIGN KEY (profile_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    CHECK (status IN ('single', 'taken', 'not looking'))
);

CREATE TABLE friends_with (
    friend1_uni         CHAR(10),
    friend2_uni         CHAR(10),
    PRIMARY KEY (friend1_uni, friend2_uni),
    FOREIGN KEY (friend1_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    FOREIGN KEY (friend2_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    CHECK (friend1_uni < friend2_uni)
);

CREATE TABLE has_program (
    profile_uni         CHAR(10),
    department_name     CHAR(100),
    program_type        CHAR(10) NOT NULL,
    PRIMARY KEY (profile_uni, department_name),
    FOREIGN KEY (profile_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    FOREIGN KEY (department_name) REFERENCES department(name)
        ON DELETE NO ACTION,
    CHECK (program_type IN ('major', 'minor'))
);

CREATE TABLE enrolled_in (
    profile_uni         CHAR(10),
    call_number         CHAR(10),
    PRIMARY KEY (profile_uni, call_number),
    FOREIGN KEY (profile_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    FOREIGN KEY (call_number) REFERENCES classes(call_number)
        ON DELETE NO ACTION
);
