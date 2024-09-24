-- ADD EACH WORD OF INSERTED TRANSLATED STRING TO RESPECTIVE WORDLIST

CREATE OR REPLACE FUNCTION add_words_to_da_wordlist() 
RETURNS trigger AS $$
DECLARE
    word TEXT;
BEGIN
    -- Check the trigger depth
    IF pg_trigger_depth() = 0 THEN
        FOR word IN SELECT unnest(string_to_array(NEW."dk-DA", ' ')) LOOP
            INSERT INTO "DA_Wordlist"(word)
            VALUES (word)
            ON CONFLICT DO NOTHING; -- Conflict will rise if word already exists (unique constraint), which is okay and expected
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_words_to_en_wordlist() 
RETURNS trigger AS $$
DECLARE
    word TEXT;
BEGIN
    -- Check the trigger depth
    IF pg_trigger_depth() = 0 THEN
        FOR word IN SELECT unnest(string_to_array(NEW."en-GB", ' ')) LOOP
            INSERT INTO "EN_Wordlist"(word)
            VALUES (word)
            ON CONFLICT DO NOTHING; -- Conflict will rise if word already exists (unique constraint), which is okay and expected
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_words_to_no_wordlist() 
RETURNS trigger AS $$
DECLARE
    word TEXT;
BEGIN
    -- Check the trigger depth
    IF pg_trigger_depth() = 0 THEN
        FOR word IN SELECT unnest(string_to_array(NEW."nn-NO", ' ')) LOOP
            INSERT INTO "NO_Wordlist"(word)
            VALUES (word)
            ON CONFLICT DO NOTHING; -- Conflict will rise if word already exists (unique constraint), which is okay and expected
        END LOOP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_add_da_words
AFTER INSERT ON "Catalogue"
FOR EACH ROW
WHEN (NEW."da-DK" IS NOT NULL)
EXECUTE FUNCTION add_words_to_da_wordlist();

CREATE TRIGGER trigger_add_en_words
AFTER INSERT ON "Catalogue"
FOR EACH ROW
WHEN (NEW."en-GB" IS NOT NULL)
-- EN has the "not null" constraint so no need to check like the others as translations to some languages might not exist initially
EXECUTE FUNCTION add_words_to_en_wordlist();

CREATE TRIGGER trigger_add_no_words
AFTER INSERT ON "Catalogue"
FOR EACH ROW
WHEN (NEW."nb-NO" IS NOT NULL)
EXECUTE FUNCTION add_words_to_no_wordlist();
