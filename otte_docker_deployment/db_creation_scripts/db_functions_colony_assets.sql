
-- Triggers:

---------------------------------- Update AssetCollection Entries ----------------------------------
-- Step 1: Create or replace the trigger function to handle both insertion, update, and removal
CREATE OR REPLACE FUNCTION update_assetcollection_entries()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.assetCollection IS NOT NULL THEN
        -- Case 1: If the assetCollection is not null, append the new id to the entries array
        UPDATE "AssetCollection"
        SET collectionEntries = array_append(collectionEntries, NEW.id)
        WHERE id = NEW.assetCollection;
    END IF;
    
    IF OLD.assetCollection IS NOT NULL AND NEW.assetCollection IS DISTINCT FROM OLD.assetCollection THEN
        -- Case 2: If the old assetCollection is not null and differs from the new one, remove the id from the old collection
        UPDATE "AssetCollection"
        SET collectionEntries = array_remove(collectionEntries, OLD.id)
        WHERE id = OLD.assetCollection;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 2: Create or replace the trigger to invoke this function after insert, update, or delete
CREATE TRIGGER collectionentry_insert_update_trigger
AFTER INSERT OR UPDATE ON "CollectionEntry"
FOR EACH ROW
EXECUTE FUNCTION update_assetcollection_entries();

-- Step 3: Create a trigger to handle the deletion of a CollectionEntry and update the entries array accordingly
CREATE OR REPLACE FUNCTION delete_collectionentry_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.assetCollection IS NOT NULL THEN
        -- Remove the entry from the array when the entry is deleted
        UPDATE "AssetCollection"
        SET collectionEntries = array_remove(collectionEntries, OLD.id)
        WHERE id = OLD.assetCollection;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER collectionentry_delete_trigger
AFTER DELETE ON "CollectionEntry"
FOR EACH ROW
EXECUTE FUNCTION delete_collectionentry_trigger();
---------------------------------- Update AssetCollection Entries ----------------------------------

---------------------------------- Update CollectionEntry Entries ----------------------------------
CREATE OR REPLACE FUNCTION sync_collectionentry_addition()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the CollectionEntry to point to the AssetCollection
    UPDATE "CollectionEntry"
    SET assetCollection = NEW.id
    WHERE id = ANY(NEW.collectionEntries);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_assetcollection_update_addition
AFTER UPDATE OF collectionEntries ON "AssetCollection"
FOR EACH ROW
WHEN (NEW.collectionEntries IS DISTINCT FROM OLD.collectionEntries)
EXECUTE FUNCTION sync_collectionentry_addition();

CREATE OR REPLACE FUNCTION sync_collectionentry_removal()
RETURNS TRIGGER AS $$
BEGIN
    -- Set the CollectionEntry assetCollection field to NULL if the ID is removed
    DELETE FROM "CollectionEntry" 
    WHERE id = ANY(OLD.collectionEntries)
      AND id != ALL(NEW.collectionEntries);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_assetcollection_update_removal
AFTER UPDATE OF collectionEntries ON "AssetCollection"
FOR EACH ROW
WHEN (NEW.collectionEntries IS DISTINCT FROM OLD.collectionEntries)
EXECUTE FUNCTION sync_collectionentry_removal();
---------------------------------- Update CollectionEntry Entries ----------------------------------

---------------------------------- Update Colony (Locations) ----------------------------------
CREATE OR REPLACE FUNCTION update_colony_locations()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.colony IS NOT NULL THEN
        -- Case 1: Add the `ColonyLocation` ID to the `locations` array in `Colony`
        UPDATE "Colony"
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
AFTER INSERT OR UPDATE ON "ColonyLocation"
FOR EACH ROW
EXECUTE FUNCTION update_colony_locations();

CREATE OR REPLACE FUNCTION delete_colonylocation_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.colony IS NOT NULL THEN
        -- Remove the `ColonyLocation` ID from the `locations` array in `Colony`
        UPDATE "Colony"
        SET locations = array_remove(locations, OLD.id)
        WHERE id = OLD.colony;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonylocation_delete_trigger
AFTER DELETE ON "ColonyLocation"
FOR EACH ROW
EXECUTE FUNCTION delete_colonylocation_trigger();
---------------------------------- Update Colony (Locations) ----------------------------------

---------------------------------- Update ColonyLocations ----------------------------------
CREATE OR REPLACE FUNCTION sync_colonylocation_addition()
RETURNS TRIGGER AS $$
BEGIN
    -- Update `ColonyLocation` to point to the `Colony`
    UPDATE "ColonyLocation"
    SET colony = NEW.id
    WHERE id = ANY(NEW.locations);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_addition_locations
AFTER UPDATE OF locations ON "Colony"
FOR EACH ROW
WHEN (NEW.locations IS DISTINCT FROM OLD.locations)
EXECUTE FUNCTION sync_colonylocation_addition();

CREATE OR REPLACE FUNCTION sync_colonylocation_removal()
RETURNS TRIGGER AS $$
BEGIN
    -- Set the `ColonyLocation` `colony` field to NULL if the ID is removed
    UPDATE "ColonyLocation"
    SET colony = NULL
    WHERE id = ANY(OLD.locations)
      AND id != ALL(NEW.locations);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_removal_locations
AFTER UPDATE OF locations ON "Colony"
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
        UPDATE "Colony"
        SET assets = array_append(assets, NEW.id)
        WHERE id = NEW.colony;
    END IF;
    
    IF OLD.colony IS NOT NULL AND NEW.colony IS DISTINCT FROM OLD.colony THEN
        -- Case 2: Remove the `ColonyAsset` ID from the old `Colony`
        UPDATE "Colony"
        SET assets = array_remove(assets, OLD.id)
        WHERE id = OLD.colony;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonyasset_insert_update_trigger
AFTER INSERT OR UPDATE ON "ColonyAsset"
FOR EACH ROW
EXECUTE FUNCTION update_colony_assets();

CREATE OR REPLACE FUNCTION delete_colonyasset_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.colony IS NOT NULL THEN
        -- Remove the `ColonyAsset` ID from the `assets` array in `Colony`
        UPDATE "Colony"
        SET assets = array_remove(assets, OLD.id)
        WHERE id = OLD.colony;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonyasset_delete_trigger
AFTER DELETE ON "ColonyAsset"
FOR EACH ROW
EXECUTE FUNCTION delete_colonyasset_trigger();
---------------------------------- Update Colony (Assets) ----------------------------------

---------------------------------- Update ColonyAssets ----------------------------------
CREATE OR REPLACE FUNCTION sync_colonyasset_addition()
RETURNS TRIGGER AS $$
BEGIN
    -- Update `ColonyAsset` to point to the `Colony`
    UPDATE "ColonyAsset"
    SET colony = NEW.id
    WHERE id = ANY(NEW.assets);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_addition_assets
AFTER UPDATE OF assets ON "Colony"
FOR EACH ROW
WHEN (NEW.assets IS DISTINCT FROM OLD.assets)
EXECUTE FUNCTION sync_colonyasset_addition();

CREATE OR REPLACE FUNCTION sync_colonyasset_removal()
RETURNS TRIGGER AS $$
BEGIN
    -- Set the `ColonyAsset` `colony` field to NULL if the ID is removed
    UPDATE "ColonyAsset"
    SET colony = NULL
    WHERE id = ANY(OLD.assets)
      AND id != ALL(NEW.assets);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_removal_assets
AFTER UPDATE OF assets ON "Colony"
FOR EACH ROW
WHEN (NEW.assets IS DISTINCT FROM OLD.assets)
EXECUTE FUNCTION sync_colonyasset_removal();
---------------------------------- Update ColonyAssets ----------------------------------

---------------------------------- Update ColonyCode ----------------------------------
CREATE OR REPLACE FUNCTION sync_colony_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Sync ColonyCode's colony when Colony is updated
    UPDATE "ColonyCode"
    SET colony = NEW.id
    WHERE id = NEW.colonyCode;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update
AFTER INSERT OR UPDATE ON "Colony"
FOR EACH ROW
EXECUTE FUNCTION sync_colony_update();

CREATE OR REPLACE FUNCTION handle_colony_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- Set ColonyCode's colony to NULL when corresponding Colony is deleted
    UPDATE "ColonyCode"
    SET colony = NULL
    WHERE colony = OLD.id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_delete
AFTER DELETE ON "Colony"
FOR EACH ROW
EXECUTE FUNCTION handle_colony_deletion();
---------------------------------- Update ColonyCode ----------------------------------

---------------------------------- Update Colony ----------------------------------
CREATE OR REPLACE FUNCTION sync_colonycode_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Sync Colony's colonyCode when ColonyCode is updated
    UPDATE "Colony"
    SET colonyCode = NEW.id
    WHERE id = NEW.colony;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colonycode_update
AFTER INSERT OR UPDATE ON "ColonyCode"
FOR EACH ROW
EXECUTE FUNCTION sync_colonycode_update();

CREATE OR REPLACE FUNCTION handle_colonycode_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- Set Colony's colonyCode to NULL when corresponding ColonyCode is deleted
    UPDATE "Colony"
    SET colonyCode = NULL
    WHERE colonyCode = OLD.id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colonycode_delete
AFTER DELETE ON "ColonyCode"
FOR EACH ROW
EXECUTE FUNCTION handle_colonycode_deletion();
---------------------------------- Update Colony ----------------------------------



-- Functions:

---------------------------------- getLocationApperances ----------------------------------
CREATE OR REPLACE FUNCTION getLocationApperances(location_id INT)
RETURNS TABLE(asset_collection_id INT, asset_collection_name VARCHAR(255)) AS $$
BEGIN
    RETURN QUERY
    SELECT ac.id, ac.name
    FROM "AssetCollection" ac
    WHERE ac.id = ANY(
        SELECT unnest(l.appearances)
        FROM Location l
        WHERE l.id = location_id
    );
END;
$$ LANGUAGE plpgsql;
---------------------------------- getLocationApperances ----------------------------------


