-- Player table with foreign key to GraphicalAsset for sprite and array of achievement IDs
CREATE TABLE IF NOT EXISTS "Player" (
    id SERIAL PRIMARY KEY,
    "IGN" VARCHAR(255) UNIQUE NOT NULL,
    sprite INT NOT NULL,
    achievements INT[] DEFAULT '{}'  -- Array to store completed achievement IDs
    -- FOREIGN KEY (sprite) REFERENCES "GraphicalAsset"(id)
);

-- Session table for managing user sessions (TODO: max session time?)
CREATE TABLE IF NOT EXISTS "Session" (
    id SERIAL PRIMARY KEY,
    player INT NOT NULL,
    "createdAt" TIMESTAMP DEFAULT NOW(),
    token VARCHAR(255) UNIQUE NOT NULL,
    "validDuration" INTERVAL DEFAULT '1 hour',
    "lastCheckIn" TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (player) REFERENCES "Player"(id)
);

-- Achievement table with foreign keys to Player and GraphicalAsset for icon
CREATE TABLE IF NOT EXISTS "Achievement" (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) DEFAULT 'DATA.UNNAMED.ACHIEVEMENT',
    description TEXT DEFAULT 'UI.DESCRIPTION_MISSING',
    icon INT NOT NULL,
    player INT NOT NULL,
    FOREIGN KEY (player) REFERENCES "Player"(id)
    -- FOREIGN KEY (icon) REFERENCES "GraphicalAsset"(id)
);

-- PlayerPreferences table for storing player preferences (TODO: relation between 'AvailablePreference' and 'PlayerPreference', 'key'?)
CREATE TABLE IF NOT EXISTS "PlayerPreference" (
    id SERIAL PRIMARY KEY,
    player INT NOT NULL,
    key VARCHAR(255) NOT NULL,
    chosenValue VARCHAR(255) NOT NULL,
    FOREIGN KEY (player) REFERENCES "Player"(id)
);

-- AvailablePreferences table for storing possible values for preferences
CREATE TABLE IF NOT EXISTS "AvailablePreference" (
    id SERIAL PRIMARY KEY,
    key VARCHAR(255) NOT NULL,
    availableValues VARCHAR(255)[]
);

-- InputReactionTime table to store player's reaction times
CREATE TABLE IF NOT EXISTS "InputReactionTime" (
    id SERIAL PRIMARY KEY,
    player INT NOT NULL,
    ms INT NOT NULL,
    FOREIGN KEY (player) REFERENCES "Player"(id)
);

-- WordsPerMinute table to store player's WPM
CREATE TABLE IF NOT EXISTS "WordsPerMinute" (
    id SERIAL PRIMARY KEY,
    player INT NOT NULL,
    amount INT NOT NULL,
    FOREIGN KEY (player) REFERENCES "Player"(id)
);

-- TimeBetweenInputs table to store the time between inputs
CREATE TABLE IF NOT EXISTS "TimeBetweenInputs" (
    id SERIAL PRIMARY KEY,
    player INT NOT NULL,
    ms INT NOT NULL,
    FOREIGN KEY (player) REFERENCES "Player"(id)
);
