CREATE TABLE IF NOT EXISTS "GraphicalAsset" (
    id SERIAL PRIMARY KEY,
    alias VARCHAR(255) NOT NULL, -- For debugging
    type VARCHAR(255) NOT NULL, -- Assuming the MIME type strings
    blob BYTEA,
    "useCase" VARCHAR(255),
    width INT NOT NULL,
    height INT NOT NULL,
    "hasLODs" BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS "NPC" (
    id SERIAL PRIMARY KEY,
    sprite INT,
    name VARCHAR(255),
    FOREIGN KEY (sprite) REFERENCES "GraphicalAsset"(id)
);

CREATE TABLE IF NOT EXISTS "Transform" (
    id SERIAL PRIMARY KEY,
    "xScale" FLOAT DEFAULT 1,
    "yScale" FLOAT DEFAULT 1,
    "xOffset" FLOAT DEFAULT 0,
    "yOffset" FLOAT DEFAULT 0,
    "zIndex" INT DEFAULT 100
);

CREATE TABLE IF NOT EXISTS "AssetCollection" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) DEFAULT 'DATA.UNNAMED.COLLECTION',
    "useCase" VARCHAR(255) DEFAULT 'environment',
    "collectionEntries" INT[] DEFAULT '{}'  -- Array of foreign keys pointing to CollectionEntry IDs (array for multiple references and to avoid creation conflicts, triggers will handle)
);

CREATE TABLE IF NOT EXISTS "Colony" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) DEFAULT 'DATA.UNNAMED.COLONY',
    "accLevel" INT DEFAULT 0,
    "latestVisit" TIMESTAMP,
    owner INT NOT NULL,
    assets INT[] DEFAULT '{}',  -- Array of foreign keys pointing to ColonyAsset IDs (array for multiple references and to avoid creation conflicts, triggers will handle)
    locations INT[] DEFAULT '{}',  -- Array of foreign keys pointing to ColonyLocation IDs (array for multiple references and to avoid creation conflicts, triggers will handle)
    "colonyCode" INT  -- Single foreign key pointing to ColonyCode ID (Single id attribute to avoid creation conflicts, triggers will handle)
);

CREATE TABLE IF NOT EXISTS "ColonyCode" (
    id SERIAL PRIMARY KEY,
    "lobbyId" INT NOT NULL,  -- foreign key? To multiplayer backend.
    "serverAddress" VARCHAR(255) NOT NULL,
    colony INT NOT NULL,  -- Server per lobby?
    value VARCHAR(6) UNIQUE NOT NULL,
    FOREIGN KEY (colony) REFERENCES "Colony"(id)
);

CREATE TABLE IF NOT EXISTS "MiniGame" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) DEFAULT 'DATA.UNNAMED.MINIGAME',
    icon INT NOT NULL,
    description TEXT DEFAULT 'UI.DESCRIPTION_MISSING',
    settings JSON NOT NULL,  -- Assuming settings are stored in JSON format
    FOREIGN KEY (icon) REFERENCES "GraphicalAsset"(id)
);

CREATE TABLE IF NOT EXISTS "MiniGameDifficulty" (
    id SERIAL PRIMARY KEY,
    minigame INT NOT NULL,
    icon INT NOT NULL,
    name VARCHAR(2) DEFAULT '?',  -- Roman Numerals as string.
    description TEXT DEFAULT 'UI.DESCRIPTION_MISSING',
    "overwritingSettings" JSON NOT NULL,  -- Overwrites default settings with these specific to the difficulty level
    FOREIGN KEY (minigame) REFERENCES "MiniGame"(id),
    FOREIGN KEY (icon) REFERENCES "GraphicalAsset"(id)
);

CREATE TABLE IF NOT EXISTS "Location" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) DEFAULT 'DATA.UNNAMED.LOCATION',
    description TEXT DEFAULT 'UI.DESCRIPTION_MISSING',
    minigame INT,
    appearences INT[] DEFAULT '{}', -- Ids of AssetCollections.
    FOREIGN KEY (minigame) REFERENCES "MiniGame"(id)
);

CREATE TABLE IF NOT EXISTS "ColonyLocation" (
    id SERIAL PRIMARY KEY,
    colony INT NOT NULL,
    location INT NOT NULL,
    transform INT NOT NULL,
    level INT DEFAULT 1,
    FOREIGN KEY (colony) REFERENCES "Colony"(id),
    FOREIGN KEY (location) REFERENCES "Location"(id),
    FOREIGN KEY (transform) REFERENCES "Transform"(id)
);

CREATE TABLE IF NOT EXISTS "ColonyAsset" (
    id SERIAL PRIMARY KEY,
    "assetCollection" INT NOT NULL,
    transform INT NOT NULL,
    colony INT NOT NULL,
    FOREIGN KEY ("assetCollection") REFERENCES "AssetCollection"(id),
    FOREIGN KEY (transform) REFERENCES "Transform"(id),
    FOREIGN KEY (colony) REFERENCES "Colony"(id)
);

CREATE TABLE IF NOT EXISTS "CollectionEntry" (
    id SERIAL PRIMARY KEY,
    transform INT NOT NULL,
    "assetCollection" INT NOT NULL, -- Foreign key to AssetCollection this CollectionEntry is a part of
    "graphicalAsset" INT NOT NULL,
    FOREIGN KEY (transform) REFERENCES "Transform"(id),
    FOREIGN KEY ("assetCollection") REFERENCES "AssetCollection"(id),
    FOREIGN KEY ("graphicalAsset") REFERENCES "GraphicalAsset"(id)
);

CREATE TABLE IF NOT EXISTS "LOD" (
    id SERIAL PRIMARY KEY,
    "detailLevel" INT DEFAULT 1,
    blob BYTEA NOT NULL,
    "graphicalAsset" INT NOT NULL,
    FOREIGN KEY ("graphicalAsset") REFERENCES "GraphicalAsset"(id)
);
