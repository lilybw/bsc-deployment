-- AssetCollection and CollectionEntry Triggers

CREATE OR REPLACE FUNCTION update_assetcollection_entries()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        IF NEW."assetCollection" IS NOT NULL THEN
            UPDATE "AssetCollection"
            SET "collectionEntries" = array_append("collectionEntries", NEW.id)
            WHERE id = NEW."assetCollection";
        END IF;
        
        IF OLD."assetCollection" IS NOT NULL AND NEW."assetCollection" IS DISTINCT FROM OLD."assetCollection" THEN
            UPDATE "AssetCollection"
            SET "collectionEntries" = array_remove("collectionEntries", OLD.id)
            WHERE id = OLD."assetCollection";
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER collectionentry_insert_update_trigger
AFTER INSERT OR UPDATE ON "CollectionEntry"
FOR EACH ROW
EXECUTE FUNCTION update_assetcollection_entries();

CREATE OR REPLACE FUNCTION delete_collectionentry_function()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        IF OLD."assetCollection" IS NOT NULL THEN
            UPDATE "AssetCollection"
            SET "collectionEntries" = array_remove("collectionEntries", OLD.id)
            WHERE id = OLD."assetCollection";
        END IF;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER collectionentry_delete_trigger
AFTER DELETE ON "CollectionEntry"
FOR EACH ROW
EXECUTE FUNCTION delete_collectionentry_function();

-- Colony and ColonyLocation Triggers
CREATE OR REPLACE FUNCTION update_colony_locations()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        IF NEW.colony IS NOT NULL THEN
            UPDATE "Colony"
            SET locations = array_append(locations, NEW.id)
            WHERE id = NEW.colony;
        END IF;
        
        IF OLD.colony IS NOT NULL AND NEW.colony IS DISTINCT FROM OLD.colony THEN
            UPDATE Colony
            SET locations = array_remove(locations, OLD.id)
            WHERE id = OLD.colony;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonylocation_insert_update_trigger
AFTER INSERT ON "ColonyLocation"
FOR EACH ROW
EXECUTE FUNCTION update_colony_locations();

CREATE OR REPLACE FUNCTION delete_colonylocation_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        IF OLD.colony IS NOT NULL THEN
            UPDATE "Colony"
            SET locations = array_remove(locations, OLD.id)
            WHERE id = OLD.colony;
        END IF;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonylocation_delete_trigger
AFTER DELETE ON "ColonyLocation"
FOR EACH ROW
EXECUTE FUNCTION delete_colonylocation_trigger();

CREATE OR REPLACE FUNCTION sync_colonylocation_removal()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        -- Set the ColonyLocation colony field to NULL if the ID is removed
        DELETE FROM "ColonyLocation"
        WHERE id = ANY(OLD.locations);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_removal_locations
AFTER UPDATE OF locations ON "Colony"
FOR EACH ROW
WHEN (NEW.locations IS DISTINCT FROM OLD.locations)
EXECUTE FUNCTION sync_colonylocation_removal();

-- Colony and ColonyAsset Triggers

CREATE OR REPLACE FUNCTION update_colony_assets()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        IF NEW.colony IS NOT NULL THEN
            UPDATE "Colony"
            SET assets = array_append(assets, NEW.id)
            WHERE id = NEW.colony;
        END IF;
        
        IF OLD.colony IS NOT NULL AND NEW.colony IS DISTINCT FROM OLD.colony THEN
            UPDATE "Colony"
            SET assets = array_remove(assets, OLD.id)
            WHERE id = OLD.colony;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonyasset_insert_update_trigger
AFTER INSERT ON "ColonyAsset"
FOR EACH ROW
EXECUTE FUNCTION update_colony_assets();

CREATE OR REPLACE FUNCTION delete_colonyasset_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        IF OLD.colony IS NOT NULL THEN
            UPDATE "Colony"
            SET assets = array_remove(assets, OLD.id)
            WHERE id = OLD.colony;
        END IF;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER colonyasset_delete_trigger
AFTER DELETE ON "ColonyAsset"
FOR EACH ROW
EXECUTE FUNCTION delete_colonyasset_trigger();

CREATE OR REPLACE FUNCTION sync_colonyasset_removal()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        -- Set the ColonyAsset colony field to NULL if the ID is removed
        DELETE FROM "ColonyAsset"
        WHERE id = ANY(OLD.assets);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_update_removal_assets
AFTER UPDATE OF assets ON "Colony"
FOR EACH ROW
WHEN (NEW.assets IS DISTINCT FROM OLD.assets)
EXECUTE FUNCTION sync_colonyasset_removal();

CREATE OR REPLACE FUNCTION handle_colony_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        UPDATE "ColonyCode"
        SET colony = NULL
        WHERE colony = OLD.id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colony_delete
AFTER DELETE ON "Colony"
FOR EACH ROW
EXECUTE FUNCTION handle_colony_deletion();

CREATE OR REPLACE FUNCTION handle_colonycode_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF pg_trigger_depth() = 0 THEN
        UPDATE "Colony"
        SET "colonyCode" = NULL
        WHERE "colonyCode" = OLD.id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_colonycode_delete
AFTER DELETE ON "ColonyCode"
FOR EACH ROW
EXECUTE FUNCTION handle_colonycode_deletion();

-- New Insert Handlers
CREATE OR REPLACE FUNCTION handle_collectionentry_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW."assetCollection" IS NOT NULL THEN
        UPDATE "AssetCollection"
        SET "collectionEntries" = array_append("collectionEntries", NEW.id)
        WHERE id = NEW."assetCollection";
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER collectionentry_insert_trigger
AFTER INSERT ON "CollectionEntry"
FOR EACH ROW
EXECUTE FUNCTION handle_collectionentry_insert();