CREATE TABLE IF NOT EXISTS "Catalogue" (
    key TEXT primary key,
    "DA" TEXT,
    "NO" TEXT,
    "EN" TEXT not null
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