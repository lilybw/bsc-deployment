CREATE TABLE IF NOT EXISTS "Catalogue" (
    key TEXT primary key,
    "da-DK" TEXT,
    "en-GB" TEXT not null,
    "nb-NO" TEXT,
    "sv-SE" TEXT,
    "de-DE" TEXT,
    "nl-NL" TEXT
);

CREATE TABLE IF NOT EXISTS "AvailableLanguages" (
    id serial primary key,
    "code" VARCHAR(255) not null unique,
    "icon" Integer not null, -- Id of graphical asset in other db
    "commonName" VARCHAR(255) not null
);

CREATE TABLE IF NOT EXISTS "DA_Wordlist" (
    id serial primary key,
    word VARCHAR(255) not null unique
);

CREATE TABLE IF NOT EXISTS "EN_Wordlist" (
    id serial primary key,
    word VARCHAR(255) not null unique
);

CREATE TABLE IF NOT EXISTS "NO_Wordlist" (
    id serial primary key,
    word VARCHAR(255) not null unique
);