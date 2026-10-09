--DataBae Schema for Project 1, part 1 of Introduction to Databases
--Raymond Wang, Rebecca Pliskin

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

/*
 
-- Major limit: A profile may be associated with at most two departments through a has_program relationship where program_type = 'major'. There is no corresponding limit on minors. 
-- Program availability: A has_program relationship is valid only if the associated department offers the selected program type, as indicated by offered_major or offered_minor.
-- Self-reported status: A status submission with status = 'not looking' is valid only if the submitting user claims the profile referenced by that submission.
-- Verified submitter: A status submission is valid only if the submitting user has verified = TRUE.
-- Permanent claims: Once a user claims a profile, users.claimed_uni may not be changed.

Constraints:
A program type is allowed only if the department offers it
A status can be "single" or "taken" or "not looking"
"not looking" is self-report only
Each profile may have at most two majors and any number of minors. A profile may not have both a major and a minor in the same department.
"friends with" is symmetric but profile cannot be friends with itself
Each unordered pair of profiles represents only one friendship
Emails must be Columbia or Barnard addresses
Only verified users can submit a status
Claims are permanent once established
A program_type can be either "major" or "minor"


*/
