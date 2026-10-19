--DataBae Schema for Project 1, part 2 of Introduction to Databases
--Raymond Wang, Rebecca Pliskin

CREATE TABLE profile (
    uni                 VARCHAR(10),
    first_name          VARCHAR(50) NOT NULL,
    last_name           VARCHAR(50) NOT NULL,
    gender              VARCHAR(20),
    graduation_year     INTEGER,
    PRIMARY KEY (uni),
    CONSTRAINT profile_uni_format CHECK (uni ~ '^[a-z]{2,3}[0-9]{1,4}$'),
    CONSTRAINT profile_names_not_blank CHECK (first_name <> '' AND last_name <> ''),
	CONSTRAINT profile_graduation_year_range CHECK (graduation_year BETWEEN 2020 AND 2035),
	CONSTRAINT profile_names_trimmed CHECK (first_name = TRIM(first_name) AND last_name = TRIM(last_name))
);

CREATE TABLE department (
    name                VARCHAR(100),
    housed_at           VARCHAR(100),
    offered_major       BOOLEAN NOT NULL,
    offered_minor       BOOLEAN NOT NULL,
    PRIMARY KEY (name),
    CONSTRAINT department_name_not_blank CHECK (name <> ''),
    CONSTRAINT department_offers_a_program CHECK (offered_major OR offered_minor),
	CONSTRAINT department_housed_at_values CHECK (housed_at IN ('Columbia College', 'SEAS', 'Barnard College', 'School of General Studies', 'School of the Arts'))
);

CREATE TABLE classes (
    call_number         VARCHAR(10),
    course_name         VARCHAR(100) NOT NULL,
    professor           VARCHAR(100),
    department_name     VARCHAR(100) NOT NULL,
    PRIMARY KEY (call_number),
    FOREIGN KEY (department_name) REFERENCES department(name)
        ON DELETE NO ACTION,
    CONSTRAINT classes_call_number_format CHECK (call_number ~ '^[0-9]{5}$'),
    CONSTRAINT classes_course_name_not_blank CHECK (course_name <> '')
);

CREATE TABLE users (
    email               VARCHAR(100),
    verified            BOOLEAN NOT NULL,
    claimed_uni         VARCHAR(10) NOT NULL,
    PRIMARY KEY (email),
    UNIQUE (claimed_uni),
    FOREIGN KEY (claimed_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    CHECK (
        LOWER(email) LIKE '_%@columbia.edu'
        OR LOWER(email) LIKE '_%@barnard.edu'
    ),
    CONSTRAINT users_email_lowercase CHECK (email = LOWER(email)),
    CONSTRAINT users_email_matches_claimed_uni CHECK (email LIKE claimed_uni || '@%')
);

CREATE TABLE status_submission (
    sid                 INTEGER,
    status              VARCHAR(20) NOT NULL,
    created_at          TIMESTAMP NOT NULL,
    verified            BOOLEAN NOT NULL,
    submitter_email     VARCHAR(100) NOT NULL,
    profile_uni         VARCHAR(10) NOT NULL,
    PRIMARY KEY (sid),
    FOREIGN KEY (submitter_email) REFERENCES users(email)
        ON DELETE NO ACTION,
    FOREIGN KEY (profile_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
	CONSTRAINT status_submission_status_values CHECK (status IN ('single', 'taken', 'not looking')),
	CONSTRAINT status_submission_created_at_floor CHECK (created_at >= TIMESTAMP '2020-01-01 00:00:00'),
	CONSTRAINT status_submission_not_looking_unverified CHECK (NOT (status = 'not looking' AND verified)),
	CONSTRAINT status_submission_sid_positive CHECK (sid > 0)
);

CREATE TABLE friends_with (
    friend1_uni         VARCHAR(10),
    friend2_uni         VARCHAR(10),
    PRIMARY KEY (friend1_uni, friend2_uni),
    FOREIGN KEY (friend1_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    FOREIGN KEY (friend2_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    CONSTRAINT friends_with_ordered_pair CHECK (friend1_uni < friend2_uni)
);

CREATE TABLE has_program (
    profile_uni         VARCHAR(10),
    department_name     VARCHAR(100),
    program_type        VARCHAR(10) NOT NULL,
    PRIMARY KEY (profile_uni, department_name),
    FOREIGN KEY (profile_uni) REFERENCES profile(uni)
        ON DELETE NO ACTION,
    FOREIGN KEY (department_name) REFERENCES department(name)
        ON DELETE NO ACTION,
    CONSTRAINT has_program_type_values CHECK (program_type IN ('major', 'minor'))
);

CREATE TABLE enrolled_in (
    profile_uni         VARCHAR(10),
    call_number         VARCHAR(10),
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
