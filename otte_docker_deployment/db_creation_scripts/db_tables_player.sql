CREATE TABLE IF NOT EXISTS "Player" (
    id SERIAL PRIMARY KEY,
    IGN VARCHAR(255) UNIQUE NOT NULL,
    sprite INT NOT NULL,  
    achievements INT[] DEFAULT '{}', -- Should achievements not just reference player to make a proper one to many relationship?
);

CREATE TABLE IF NOT EXISTS "Session" (
    id SERIAL PRIMARY KEY,
    player INT NOT NULL,
    createdAt TIMESTAMP DEFAULT NOW(), -- Perform check in backend against maxValidDuration.
    token VARCHAR(255) UNIQUE NOT NULL,  -- Unique session token
    validDuration INTERVAL DEFAULT '1 hour',  -- Default session duration
    lastCheckIn TIMESTAMP DEFAULT NOW(),  -- Timestamp of last activity
    FOREIGN KEY (player) REFERENCES "Player"(id)
);


CREATE TABLE IF NOT EXISTS "Achievement" (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    icon INT NOT NULL,
);
