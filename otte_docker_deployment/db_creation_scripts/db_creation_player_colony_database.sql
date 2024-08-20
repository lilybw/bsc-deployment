-- Missing tables: "PlayerPreferences" and "AvailablePreference" due to lack of references.
-- TODO: Does any attributes need to be "NOT NULL", look at database diagram and discuss.

CREATE TABLE IF NOT EXISTS GraphicalAsset (
    id SERIAL PRIMARY KEY,
    alias VARCHAR(255),
    type VARCHAR(50), -- Assuming the MIME type strings
    blob BYTEA,
    useCase VARCHAR(255),
    width INT,
    height INT
);

CREATE TABLE IF NOT EXISTS NPC (
    id SERIAL PRIMARY KEY,
    sprite INT,
    name VARCHAR(255),
    FOREIGN KEY (sprite) REFERENCES GraphicalAsset(id)
);

CREATE TABLE IF NOT EXISTS Transform (
    id SERIAL PRIMARY KEY,
    xScale FLOAT,
    yScale FLOAT,
    xOffset FLOAT,
    yOffset FLOAT,
    zIndex INT
);

CREATE TABLE IF NOT EXISTS AssetCollection (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    entries INT[]  -- Array of foreign keys pointing to CollectionEntry IDs (array for multiple references and to avoid creation conflicts, triggers will handle)
);

CREATE TABLE IF NOT EXISTS ColonyCode (
    id SERIAL PRIMARY KEY,
    lobbyId INT, -- foreign key?
    expiresAt TIMESTAMP,
    value VARCHAR(255),
    colony INT  -- Single foreign key pointing to Colony ID (Single id attribute to avoid creation conflicts, triggers will handle)
);

CREATE TABLE IF NOT EXISTS Achievement (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    icon INT,
    FOREIGN KEY (icon) REFERENCES GraphicalAsset(id)
);

CREATE TABLE IF NOT EXISTS Player (
    id SERIAL PRIMARY KEY,
    IGN VARCHAR(255) UNIQUE,
    sprite INT,  
    achievements INT[], -- Should achievements not just reference player to make a proper one to many relationship?
    FOREIGN KEY (sprite) REFERENCES GraphicalAsset(id)
);

CREATE TABLE IF NOT EXISTS Session (
    id SERIAL PRIMARY KEY,
    player INT,
    token VARCHAR(255) UNIQUE,  -- Unique session token
    validDuration INTERVAL DEFAULT '1 hour',  -- Default session duration
    lastCheckIn TIMESTAMP DEFAULT NOW(),  -- Timestamp of last activity
    FOREIGN KEY (player) REFERENCES Player(id)
);

CREATE TABLE IF NOT EXISTS Colony (
    id SERIAL PRIMARY KEY,
    colonyCode INT,
    name VARCHAR(255),
    accLevel INT,
    latestVisit TIMESTAMP,
    owner INT,
    assets INT[],  -- Array of foreign keys pointing to ColonyAsset IDs (array for multiple references and to avoid creation conflicts, triggers will handle)
    locations INT[],  -- Array of foreign keys pointing to ColonyLocation IDs (array for multiple references and to avoid creation conflicts, triggers will handle)
    FOREIGN KEY (owner) REFERENCES Player(id),
    FOREIGN KEY (colonyCode) REFERENCES ColonyCode(id)
);

CREATE TABLE IF NOT EXISTS MiniGame (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    icon INT,
    description TEXT,
    settings JSONB,  -- Assuming settings are stored in JSON format
    FOREIGN KEY (icon) REFERENCES GraphicalAsset(id)
);

CREATE TABLE IF NOT EXISTS MiniGameDifficulty (
    id SERIAL PRIMARY KEY,
    minigame INT,
    icon INT,
    name VARCHAR(255),
    description TEXT,
    overwritingSettings JSONB,  -- Overwrites default settings with these specific to the difficulty level
    FOREIGN KEY (minigame) REFERENCES MiniGame(id),
    FOREIGN KEY (icon) REFERENCES GraphicalAsset(id)
);

CREATE TABLE IF NOT EXISTS Location (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    description TEXT,
    minigame INT,
    assetCollection INT,
    FOREIGN KEY (minigame) REFERENCES MiniGame(id),
    FOREIGN KEY (assetCollection) REFERENCES AssetCollection(id)
);

CREATE TABLE IF NOT EXISTS ColonyLocation (
    id SERIAL PRIMARY KEY,
    colony INT,
    location INT,
    transform INT,
    level INT,
    FOREIGN KEY (colony) REFERENCES Colony(id),
    FOREIGN KEY (location) REFERENCES Location(id),
    FOREIGN KEY (transform) REFERENCES Transform(id)
);

CREATE TABLE IF NOT EXISTS ColonyAsset (
    id SERIAL PRIMARY KEY,
    assetCollection INT,
    transform INT,
    colony INT,
    FOREIGN KEY (assetCollection) REFERENCES AssetCollection(id),
    FOREIGN KEY (transform) REFERENCES Transform(id),
    FOREIGN KEY (colony) REFERENCES Colony(id)
);

CREATE TABLE IF NOT EXISTS CollectionEntry (
    id SERIAL PRIMARY KEY,
    transform INT,
    assetCollection INT,
    graphicalAsset INT,
    FOREIGN KEY (transform) REFERENCES Transform(id),
    FOREIGN KEY (assetCollection) REFERENCES AssetCollection(id),
    FOREIGN KEY (graphicalAsset) REFERENCES GraphicalAsset(id)
);

CREATE TABLE IF NOT EXISTS LOD (
    id SERIAL PRIMARY KEY,
    detailLevel INT,
    blob BYTEA,
    graphicalAsset INT,
    FOREIGN KEY (graphicalAsset) REFERENCES GraphicalAsset(id)
);

-- Triggers:

---------------------------------- Update AssetCollection Entries ----------------------------------
-- Step 1: Create or replace the trigger function to handle both insertion, update, and removal
CREATE OR REPLACE FUNCTION update_assetcollection_entries()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.assetCollection IS NOT NULL THEN
        -- Case 1: If the assetCollection is not null, append the new id to the entries array
        UPDATE AssetCollection
        SET entries = array_append(entries, NEW.id)
        WHERE id = NEW.assetCollection;
    END IF;
    
    IF OLD.assetCollection IS NOT NULL AND NEW.assetCollection IS DISTINCT FROM OLD.assetCollection THEN
        -- Case 2: If the old assetCollection is not null and differs from the new one, remove the id from the old collection
        UPDATE AssetCollection
        SET entries = array_remove(entries, OLD.id)
        WHERE id = OLD.assetCollection;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 2: Create or replace the trigger to invoke this function after insert, update, or delete
CREATE TRIGGER collectionentry_insert_update_trigger
AFTER INSERT OR UPDATE ON CollectionEntry
FOR EACH ROW
EXECUTE FUNCTION update_assetcollection_entries();

-- Step 3: Create a trigger to handle the deletion of a CollectionEntry and update the entries array accordingly
CREATE OR REPLACE FUNCTION delete_collectionentry_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.assetCollection IS NOT NULL THEN
        -- Remove the entry from the array when the entry is deleted
        UPDATE AssetCollection
        SET entries = array_remove(entries, OLD.id)
        WHERE id = OLD.assetCollection;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER collectionentry_delete_trigger
AFTER DELETE ON CollectionEntry
FOR EACH ROW
EXECUTE FUNCTION delete_collectionentry_trigger();
---------------------------------- Update AssetCollection Entries ----------------------------------

---------------------------------- Update CollectionEntry Entries ----------------------------------
CREATE OR REPLACE FUNCTION sync_collectionentry_addition()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the CollectionEntry to point to the AssetCollection
    UPDATE CollectionEntry
    SET assetCollection = NEW.id
    WHERE id = ANY(NEW.entries);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_assetcollection_update_addition
AFTER UPDATE OF entries ON AssetCollection
FOR EACH ROW
WHEN (NEW.entries IS DISTINCT FROM OLD.entries)
EXECUTE FUNCTION sync_collectionentry_addition();

CREATE OR REPLACE FUNCTION sync_collectionentry_removal()
RETURNS TRIGGER AS $$
BEGIN
    -- Set the CollectionEntry assetCollection field to NULL if the ID is removed
    UPDATE CollectionEntry
    SET assetCollection = NULL
    WHERE id = ANY(OLD.entries)
      AND id != ALL(NEW.entries);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_assetcollection_update_removal
AFTER UPDATE OF entries ON AssetCollection
FOR EACH ROW
WHEN (NEW.entries IS DISTINCT FROM OLD.entries)
EXECUTE FUNCTION sync_collectionentry_removal();
---------------------------------- Update CollectionEntry Entries ----------------------------------

---------------------------------- Update Colony (Locations) ----------------------------------
CREATE OR REPLACE FUNCTION update_colony_locations()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.colony IS NOT NULL THEN
        -- Case 1: Add the `ColonyLocation` ID to the `locations` array in `Colony`
        UPDATE Colony
        SET locations = array_append(locations, NEW.id)
        WHERE id = NEW.colony;
    END IF;
    
    IF OLD.colony IS NOT NULL AND NEW.colony IS DISTINCT FROM OLD.colony THEN
        -- Case 2: Remove the `ColonyLocation` ID from the old `Colony`
        UPDATE Colony
        SET locations = array_remove(locations, OLD.id)
        WHERE id = OLD.colony;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonylocation_insert_update_trigger
AFTER INSERT OR UPDATE ON ColonyLocation
FOR EACH ROW
EXECUTE FUNCTION update_colony_locations();

CREATE OR REPLACE FUNCTION delete_colonylocation_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.colony IS NOT NULL THEN
        -- Remove the `ColonyLocation` ID from the `locations` array in `Colony`
        UPDATE Colony
        SET locations = array_remove(locations, OLD.id)
        WHERE id = OLD.colony;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonylocation_delete_trigger
AFTER DELETE ON ColonyLocation
FOR EACH ROW
EXECUTE FUNCTION delete_colonylocation_trigger();
---------------------------------- Update Colony (Locations) ----------------------------------

---------------------------------- Update ColonyLocations ----------------------------------
CREATE OR REPLACE FUNCTION sync_colonylocation_addition()
RETURNS TRIGGER AS $$
BEGIN
    -- Update `ColonyLocation` to point to the `Colony`
    UPDATE ColonyLocation
    SET colony = NEW.id
    WHERE id = ANY(NEW.locations);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_addition_locations
AFTER UPDATE OF locations ON Colony
FOR EACH ROW
WHEN (NEW.locations IS DISTINCT FROM OLD.locations)
EXECUTE FUNCTION sync_colonylocation_addition();

CREATE OR REPLACE FUNCTION sync_colonylocation_removal()
RETURNS TRIGGER AS $$
BEGIN
    -- Set the `ColonyLocation` `colony` field to NULL if the ID is removed
    UPDATE ColonyLocation
    SET colony = NULL
    WHERE id = ANY(OLD.locations)
      AND id != ALL(NEW.locations);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_removal_locations
AFTER UPDATE OF locations ON Colony
FOR EACH ROW
WHEN (NEW.locations IS DISTINCT FROM OLD.locations)
EXECUTE FUNCTION sync_colonylocation_removal();
---------------------------------- Update ColonyLocations ----------------------------------

---------------------------------- Update Colony (Assets) ----------------------------------
CREATE OR REPLACE FUNCTION update_colony_assets()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.colony IS NOT NULL THEN
        -- Case 1: Add the `ColonyAsset` ID to the `assets` array in `Colony`
        UPDATE Colony
        SET assets = array_append(assets, NEW.id)
        WHERE id = NEW.colony;
    END IF;
    
    IF OLD.colony IS NOT NULL AND NEW.colony IS DISTINCT FROM OLD.colony THEN
        -- Case 2: Remove the `ColonyAsset` ID from the old `Colony`
        UPDATE Colony
        SET assets = array_remove(assets, OLD.id)
        WHERE id = OLD.colony;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonyasset_insert_update_trigger
AFTER INSERT OR UPDATE ON ColonyAsset
FOR EACH ROW
EXECUTE FUNCTION update_colony_assets();

CREATE OR REPLACE FUNCTION delete_colonyasset_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.colony IS NOT NULL THEN
        -- Remove the `ColonyAsset` ID from the `assets` array in `Colony`
        UPDATE Colony
        SET assets = array_remove(assets, OLD.id)
        WHERE id = OLD.colony;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonyasset_delete_trigger
AFTER DELETE ON ColonyAsset
FOR EACH ROW
EXECUTE FUNCTION delete_colonyasset_trigger();
---------------------------------- Update Colony (Assets) ----------------------------------

---------------------------------- Update ColonyAssets ----------------------------------
CREATE OR REPLACE FUNCTION sync_colonyasset_addition()
RETURNS TRIGGER AS $$
BEGIN
    -- Update `ColonyAsset` to point to the `Colony`
    UPDATE ColonyAsset
    SET colony = NEW.id
    WHERE id = ANY(NEW.assets);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_addition_assets
AFTER UPDATE OF assets ON Colony
FOR EACH ROW
WHEN (NEW.assets IS DISTINCT FROM OLD.assets)
EXECUTE FUNCTION sync_colonyasset_addition();

CREATE OR REPLACE FUNCTION sync_colonyasset_removal()
RETURNS TRIGGER AS $$
BEGIN
    -- Set the `ColonyAsset` `colony` field to NULL if the ID is removed
    UPDATE ColonyAsset
    SET colony = NULL
    WHERE id = ANY(OLD.assets)
      AND id != ALL(NEW.assets);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_removal_assets
AFTER UPDATE OF assets ON Colony
FOR EACH ROW
WHEN (NEW.assets IS DISTINCT FROM OLD.assets)
EXECUTE FUNCTION sync_colonyasset_removal();
---------------------------------- Update ColonyAssets ----------------------------------

---------------------------------- Update ColonyCode ----------------------------------
CREATE OR REPLACE FUNCTION sync_colony_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Sync ColonyCode's colony when Colony is updated
    UPDATE ColonyCode
    SET colony = NEW.id
    WHERE id = NEW.colonyCode;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update
AFTER INSERT OR UPDATE ON Colony
FOR EACH ROW
EXECUTE FUNCTION sync_colony_update();

CREATE OR REPLACE FUNCTION handle_colony_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- Set ColonyCode's colony to NULL when corresponding Colony is deleted
    UPDATE ColonyCode
    SET colony = NULL
    WHERE colony = OLD.id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_delete
AFTER DELETE ON Colony
FOR EACH ROW
EXECUTE FUNCTION handle_colony_deletion();
---------------------------------- Update ColonyCode ----------------------------------

---------------------------------- Update Colony ----------------------------------
CREATE OR REPLACE FUNCTION sync_colonycode_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Sync Colony's colonyCode when ColonyCode is updated
    UPDATE Colony
    SET colonyCode = NEW.id
    WHERE id = NEW.colony;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colonycode_update
AFTER INSERT OR UPDATE ON ColonyCode
FOR EACH ROW
EXECUTE FUNCTION sync_colonycode_update();

CREATE OR REPLACE FUNCTION handle_colonycode_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- Set Colony's colonyCode to NULL when corresponding ColonyCode is deleted
    UPDATE Colony
    SET colonyCode = NULL
    WHERE colonyCode = OLD.id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colonycode_delete
AFTER DELETE ON ColonyCode
FOR EACH ROW
EXECUTE FUNCTION handle_colonycode_deletion();
---------------------------------- Update Colony ----------------------------------

---------------------------------- Session Management ----------------------------------
-- Function to update the lastCheckIn timestamp for a specific session
CREATE OR REPLACE FUNCTION update_last_checkin_for_player()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the lastCheckIn timestamp to the current time only for the specific session
    IF NEW.token = OLD.token THEN
        NEW.lastCheckIn := NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger that ensures the lastCheckIn is only updated for the specific player's session
CREATE TRIGGER before_player_activity
BEFORE UPDATE ON Session
FOR EACH ROW
WHEN (OLD.token IS NOT DISTINCT FROM NEW.token)
EXECUTE FUNCTION update_last_checkin_for_player();

-- Function to check and expire sessions that have been inactive beyond their valid duration
CREATE OR REPLACE FUNCTION check_and_expire_sessions()
RETURNS VOID AS $$
BEGIN
    DELETE FROM Session
    WHERE lastCheckIn + validDuration < NOW();
END;
$$ LANGUAGE plpgsql;

-- Optionally, this function can be called periodically via cron jobs or other scheduling mechanisms.
---------------------------------- Session Management ----------------------------------
