-- ADD EACH WORD OF INSERTED TRANSLATED STRING TO RESPECTIVE WORDLIST

CREATE OR REPLACE FUNCTION add_words_to_da_wordlist() RETURNS trigger AS $$
DECLARE
    word TEXT;
BEGIN
    FOR word IN SELECT unnest(string_to_array(NEW."DA", ' ')) LOOP
        INSERT INTO "DA_Wordlist"(word)
        VALUES (word)
        ON CONFLICT DO NOTHING; -- Conflict will rise if word already exists (unique constraint), which is okay and expected
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_words_to_en_wordlist() RETURNS trigger AS $$
DECLARE
    word TEXT;
BEGIN
    FOR word IN SELECT unnest(string_to_array(NEW."EN", ' ')) LOOP
        INSERT INTO "EN_Wordlist"(word)
        VALUES (word)
        ON CONFLICT DO NOTHING; -- Conflict will rise if word already exists (unique constraint), which is okay and expected
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_words_to_no_wordlist() RETURNS trigger AS $$
DECLARE
    word TEXT;
BEGIN
    FOR word IN SELECT unnest(string_to_array(NEW."NO", ' ')) LOOP
        INSERT INTO "NO_Wordlist"(word)
        VALUES (word)
        ON CONFLICT DO NOTHING; -- Conflict will rise if word already exists (unique constraint), which is okay and expected
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_add_da_words
AFTER INSERT ON "Catalogue"
FOR EACH ROW
WHEN (NEW."DA" IS NOT NULL)
EXECUTE FUNCTION add_words_to_da_wordlist();

CREATE TRIGGER trigger_add_en_words
AFTER INSERT ON "Catalogue"
FOR EACH ROW
 -- EN has the "not null" constraint so no need to check like the others as translations to some languages might not exist initially
EXECUTE FUNCTION add_words_to_en_wordlist();

CREATE TRIGGER trigger_add_no_words
AFTER INSERT ON "Catalogue"
FOR EACH ROW
WHEN (NEW."NO" IS NOT NULL)
EXECUTE FUNCTION add_words_to_no_wordlist();