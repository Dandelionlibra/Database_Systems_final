
CREATE OR REPLACE FUNCTION check_team_members_exist() RETURNS TRIGGER AS $$
DECLARE
    missing_character VARCHAR default NULL;
BEGIN
    -- 檢查每個隊伍成員是否存在於玩家的角色列表資料中
    IF NEW.member1 IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM player_characters WHERE u_id = NEW.u_id AND character_name = NEW.member1) THEN
            missing_character := NEW.member1;
            RAISE NOTICE '玩家UID: % 没有角色 %', NEW.u_id, missing_character;
        END IF;
    END IF;
    
    IF NEW.member2 IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM player_characters WHERE u_id = NEW.u_id AND character_name = NEW.member2) THEN
            missing_character := NEW.member2;
            RAISE NOTICE '玩家UID: % 没有角色 %', NEW.u_id, missing_character;
        END IF;
    END IF;
    
    IF NEW.member3 IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM player_characters WHERE u_id = NEW.u_id AND character_name = NEW.member3) THEN
            missing_character := NEW.member3;
            RAISE NOTICE '玩家UID: % 没有角色 %', NEW.u_id, missing_character;
        END IF;
    END IF;
    
    IF NEW.member4 IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM player_characters WHERE u_id = NEW.u_id AND character_name = NEW.member4) THEN
            missing_character := NEW.member4;
            RAISE NOTICE '玩家UID: % 没有角色 %', NEW.u_id, missing_character;
        END IF;
    END IF;

    IF missing_character IS NOT NULL THEN
		RAISE EXCEPTION '';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER before_insert_team
BEFORE INSERT ON team
FOR EACH ROW EXECUTE FUNCTION check_team_members_exist();


