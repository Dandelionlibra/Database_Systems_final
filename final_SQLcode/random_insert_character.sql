DO $$
DECLARE
    player RECORD;
    character RECORD;
BEGIN
    FOR player IN SELECT * FROM players ORDER BY u_id LOOP
        FOR character IN (
            SELECT 
                c.character_name, 
                FLOOR(RANDOM() * 90) + 1 AS character_level,
                w.weapon_name
            FROM characters c
            LEFT JOIN weapons w ON c.weapon_type = w.weapon_type
            ORDER BY RANDOM()
            LIMIT 5
        ) LOOP
            BEGIN
                INSERT INTO player_characters (u_id, character_name, character_level, character_weapon)
                VALUES (player.u_id, character.character_name, character.character_level, character.weapon_name);
            EXCEPTION WHEN OTHERS THEN
                RAISE NOTICE 'Skipping character % for player % due to: %', character.character_name, player.player_name, SQLERRM;
            END;
        END LOOP;
    END LOOP;
END $$;