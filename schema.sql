-- COMP3311
-- 23T1
-- Assignment 2
-- Pokemon Database
 
-- Schema By: Dylan Brotherston <d.brotherston@unsw.edu.au>
-- Version 1.3
-- 2023-04-07
 
CREATE DOMAIN Byte AS
    SMALLINT
    CHECK (
        VALUE >= 0
        AND
        VALUE <= 255
    )
;
 
CREATE DOMAIN Statistic AS
    Byte
    CHECK (
        VALUE >= 1
    )
;
 
CREATE DOMAIN Percentage AS
    INTEGER
    DEFAULT 100
    CHECK (
        VALUE >= 0
    )
;
 
CREATE DOMAIN Ratio AS
    Percentage
    DEFAULT 50
    CHECK (
        VALUE <= 100
    )
;
 
CREATE DOMAIN Probability AS
    Percentage
    DEFAULT 0
    CHECK (
        VALUE <= 100
    )
;
 
CREATE DOMAIN Meters AS
    REAL
    CHECK (
        VALUE >= 0
    )
;
 
CREATE DOMAIN Kilograms AS
    REAL
    CHECK (
        VALUE >= 0
    )
;
 
CREATE TYPE _Pokemon_ID AS (
    Pokedex_Number   INTEGER,
    Variation_Number INTEGER
);
 
CREATE DOMAIN Pokemon_ID AS
    _Pokemon_ID
    CHECK (
        (VALUE).Pokedex_Number   IS NOT NULL
        AND
        (VALUE).Variation_Number IS NOT NULL
    )
;
 
CREATE TYPE _Stats AS (
    Hit_Points      Statistic,
    Attack          Statistic,
    Defense         Statistic,
    Special_Attack  Statistic,
    Special_Defense Statistic,
    Speed           Statistic
);
 
CREATE DOMAIN Stats AS
    _Stats
    CHECK (
        (VALUE).Hit_Points      IS NOT NULL
        AND
        (VALUE).Attack          IS NOT NULL
        AND
        (VALUE).Defense         IS NOT NULL
        AND
        (VALUE).Special_Attack  IS NOT NULL
        AND
        (VALUE).Special_Defense IS NOT NULL
        AND
        (VALUE).Speed           IS NOT NULL
    )
;
 
CREATE TYPE _Range AS (
    MIN INTEGER,
    MAX INTEGER
);
 
CREATE DOMAIN Open_Range AS
    _Range
    CHECK (
        (VALUE).Min <= (VALUE).Max
        AND
        (
            (VALUE).Min IS NOT NULL
            OR
            (VALUE).Max IS NOT NULL
        )
    )
;
 
CREATE DOMAIN Closed_Range AS
    Open_Range
    CHECK (
        (VALUE).Min IS NOT NULL
        AND
        (VALUE).Max IS NOT NULL
    )
;
 
CREATE TYPE Growth_Rates AS ENUM (
    'Erratic',
    'Fast',
    'Medium Fast',
    'Medium Slow',
    'Slow',
    'Fluctuating'
);
 
CREATE TYPE Move_Categories AS ENUM (
    'Physical',
    'Special',
    'Status'
);
 
CREATE TYPE Regions AS ENUM (
    'Kanto',
    'Johto',
    'Hoenn',
    'Sinnoh',
    'Unova',
    'Kalos',
    'Alola',
    'Galar',
    'Hisui',
    'Paldea'
);
 
CREATE TABLE Types (
    ID   SERIAL          PRIMARY KEY,
    Name Text   NOT NULL UNIQUE
);
 
CREATE TABLE Type_Effectiveness (
    Attacking  INTEGER             REFERENCES Types (ID),
    Defending  INTEGER             REFERENCES Types (ID),
    Multiplier Percentage NOT NULL,
    PRIMARY KEY (Attacking, Defending)
);
 
CREATE TABLE Requirements (
    ID        SERIAL          PRIMARY KEY,
    Assertion Text   NOT NULL UNIQUE
);
 
CREATE TABLE Pokemon (
    ID               Pokemon_ID            PRIMARY KEY,
    Name             Text         NOT NULL UNIQUE,
    Species          Text         NOT NULL,
    First_Type       INTEGER      NOT NULL REFERENCES Types (ID),
    Second_Type      INTEGER               REFERENCES Types (ID),
    Average_Height   Meters       NOT NULL,
    Average_Weight   Kilograms    NOT NULL,
    Catch_Rate       Statistic    NOT NULL,
    Growth_Rate      Growth_Rates NOT NULL,
    Experience_Yield INTEGER      NOT NULL,
    Gender_Ratio     Ratio,
    Base_Stats       Stats        NOT NULL,
    Base_Friendship  Byte         NOT NULL,
    Base_Egg_Cycles  INTEGER      NOT NULL
);
 
CREATE TABLE Egg_Groups (
    ID   SERIAL          PRIMARY KEY,
    Name Text   NOT NULL UNIQUE
);
 
CREATE TABLE In_Group (
    Pokemon   Pokemon_ID REFERENCES Pokemon (ID),
    Egg_Group INTEGER    REFERENCES Egg_Groups (ID),
    PRIMARY KEY (Pokemon, Egg_Group)
);
 
CREATE TABLE Evolutions (
    ID             SERIAL              PRIMARY KEY,
    Pre_Evolution  Pokemon_ID NOT NULL REFERENCES Pokemon (ID),
    Post_Evolution Pokemon_ID NOT NULL REFERENCES Pokemon (ID)
);
 
CREATE TABLE Evolution_Requirements (
    Evolution   INTEGER          REFERENCES Evolutions (ID),
    Requirement INTEGER          REFERENCES Requirements (ID),
    Inverted    BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (Evolution, Requirement)
);
 
CREATE TABLE Games (
    ID     SERIAL           PRIMARY KEY,
    Name   Text    NOT NULL UNIQUE,
    Region Regions NOT NULL
);
 
CREATE TABLE Locations (
    ID         SERIAL           PRIMARY KEY,
    Name       Text    NOT NULL,
    Appears_In INTEGER NOT NULL REFERENCES Games (ID),
    UNIQUE (Name, Appears_In)
);
 
CREATE TABLE Pokedex (
    National_ID Pokemon_ID          REFERENCES Pokemon (ID),
    Game        INTEGER             REFERENCES Games (ID),
    Regional_ID INTEGER    NOT NULL,
    PRIMARY KEY (National_ID, Game)
);
 
CREATE TABLE Encounters (
    ID          SERIAL                PRIMARY KEY,
    Occurs_With Pokemon_ID   NOT NULL REFERENCES Pokemon (ID),
    Occurs_At   INTEGER      NOT NULL REFERENCES Locations (ID),
    Rarity      Probability  NOT NULL,
    Levels      Closed_Range NOT NULL
);
 
CREATE TABLE Encounter_Requirements (
    Encounter   INTEGER          REFERENCES Encounters (ID),
    Requirement INTEGER          REFERENCES Requirements (ID),
    Inverted    BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (Encounter, Requirement)
);
 
 
CREATE TABLE Moves (
    ID                SERIAL                   PRIMARY KEY,
    Name              Text            NOT NULL UNIQUE,
    Effect            Text,
    Of_Type           INTEGER         NOT NULL REFERENCES Types (ID),
    Category          Move_Categories,
    POWER             Statistic,
    Accuracy          Probability,
    Base_Power_Points INTEGER
);
 
CREATE TABLE Learnable_Moves (
    Learnt_By   Pokemon_ID NOT NULL REFERENCES Pokemon (ID),
    Learnt_In   INTEGER    NOT NULL REFERENCES Games (ID),
    Learnt_When INTEGER    NOT NULL REFERENCES Requirements (ID),
    Learns      INTEGER    NOT NULL REFERENCES Moves (ID),
    PRIMARY KEY (Learnt_By, Learnt_In, Learnt_When, Learns)
);
 
CREATE TABLE Abilities (
    ID     SERIAL          PRIMARY KEY,
    Name   Text   NOT NULL UNIQUE,
    Effect Text   NOT NULL
);
 
CREATE TABLE Knowable_Abilities (
    Known_By Pokemon_ID           REFERENCES Pokemon (ID),
    Knows    INTEGER              REFERENCES Abilities (ID),
    Hidden   BOOLEAN     NOT NULL,
    PRIMARY KEY (Known_By, Knows)
);
 