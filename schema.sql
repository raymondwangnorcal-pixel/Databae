CREATE TABLE Profile (
    uni                 CHAR(10),
    first_name          CHAR(50) NOT NULL,
    last_name           CHAR(50) NOT NULL,
    gender              CHAR(20),
    graduation_year     INTEGER,
    PRIMARY KEY (uni)
);

CREATE TABLE Department (
    name                CHAR(100),
    housed_at           CHAR(100),
    offered_major       BOOLEAN NOT NULL,
    offered_minor       BOOLEAN NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE Classes (
    call_number         CHAR(10),
    course_name         CHAR(100) NOT NULL,
    professor           CHAR(100),
    dept_name           CHAR(100) NOT NULL,
    PRIMARY KEY (call_number),
    FOREIGN KEY (dept_name) REFERENCES Department
        ON DELETE NO ACTION
);

CREATE TABLE Users (
    email               CHAR(100),
    verified            BOOLEAN NOT NULL,
    claimed_uni         CHAR(10) NOT NULL,
    PRIMARY KEY (email),
    UNIQUE (claimed_uni),
    FOREIGN KEY (claimed_uni) REFERENCES Profile
        ON DELETE NO ACTION
);

CREATE TABLE Status_Submission (
    sid                 INTEGER,
    status              CHAR(20) NOT NULL,
    created_at          DATE NOT NULL,
    verified            BOOLEAN NOT NULL,
    submitter_email     CHAR(100) NOT NULL,
    profile_uni         CHAR(10) NOT NULL,
    PRIMARY KEY (sid),
    FOREIGN KEY (submitter_email) REFERENCES Users
        ON DELETE NO ACTION,
    FOREIGN KEY (profile_uni) REFERENCES Profile
        ON DELETE NO ACTION
);

CREATE TABLE Friends_With (
    friend1             CHAR(10),
    friend2             CHAR(10),
    PRIMARY KEY (friend1, friend2),
    FOREIGN KEY (friend1) REFERENCES Profile,
    FOREIGN KEY (friend2) REFERENCES Profile
);

CREATE TABLE Has_Program (
    uni                 CHAR(10),
    dept_name           CHAR(100),
    program_type        CHAR(10) NOT NULL,
    PRIMARY KEY (uni, dept_name),
    FOREIGN KEY (uni) REFERENCES Profile,
    FOREIGN KEY (dept_name) REFERENCES Department
);

CREATE TABLE Enrolled_In (
    uni                 CHAR(10),
    call_number         CHAR(10),
    PRIMARY KEY (uni, call_number),
    FOREIGN KEY (uni) REFERENCES Profile,
    FOREIGN KEY (call_number) REFERENCES Classes
);

/*
This is an additional notation section for our mapping notes and general
constraints we couldn't capture in the SQL schema

The User entity set is mapped to the table Users because USER is a reserved word
in PostgreSQL. We folded relationship sets with a key constraint into the table
of the constrained entity set: Claims into Users (claimed_uni, NOT NULL because
every User claims a Profile and UNIQUE because each Profile is claimed by at
most one User), Submits and About into Status_Submission (submitter_email and
profile_uni, NOT NULL because participation is total), and Belongs_To into
Classes (dept_name, NOT NULL because participation is total). Friends_With,
Has_Program, and Enrolled_In are many-to-many and get their own tables.

The following real-world constraints are not directly captured in the schema:
  1.  Status_Submission.status must be single, taken, or not looking.
  2.  Not looking may only be self-reported: the claimed_uni of the
      Status_Submission's submitter must equal Status_Submission.profile_uni.
  3.  Users.email must be a Columbia or Barnard email address.
  4.  Friends_With is symmetric, so each pair is stored once, and friend1 and
      friend2 must be different Profiles.
  5.  Has_Program.program_type must be major or minor, and it is allowed only
      if the Department offers that program (offered_major or offered_minor is
      TRUE).
  6.  A Profile may have at most two Has_Program rows with program_type major,
      and any number with program_type minor.
  7.  Every Department must have at least one Class (total participation of
      Department in Belongs_To); the foreign key in Classes cannot force this.
  8.  Status_Submission.verified may only be set to TRUE by the User who claims
      the Profile the Status_Submission is about, and only for a
      Status_Submission someone else submitted.

A profile's current displayed status is computed from its Status_Submissions and
is not stored.
*/
