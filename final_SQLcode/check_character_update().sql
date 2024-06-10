
CREATE OR REPLACE FUNCTION check_character_update()
RETURNS TRIGGER AS $$
DECLARE
    errorr BOOLEAN default FALSE;
    player_exists BOOLEAN default FALSE;
BEGIN
	/*-- 檢查玩家UID是否存在players
    RAISE NOTICE '1.檢查玩家UID是否存在players %', player_exists;
    SELECT EXISTS (SELECT 1 FROM players WHERE u_id = NEW.u_id) INTO player_exists;
    IF NOT player_exists THEN
        RAISE EXCEPTION '玩家UID: % 不存在', NEW.u_id;
    END IF;
    RAISE NOTICE '2.檢查玩家UID是否存在players %', player_exists;*/
	
    -- 檢查玩家是否要更改角色名字
    IF NEW.character_name IS DISTINCT FROM OLD.character_name THEN
	    errorr := TRUE;
        RAISE EXCEPTION '# 更新失敗 # 無法更改角色名字';
    END IF;
    
    -- 檢查角色等級是否下降
    IF NEW.character_level < OLD.character_level THEN
		errorr := TRUE;
        RAISE NOTICE '# 更新失敗 # 更新角色等級 (%) 無法低於原本角色等級 (%)', NEW.character_level, OLD.character_level;
    END IF;

	-- 確認武器與角色是否匹配
    IF NEW.character_weapon IS NOT NULL THEN
        IF (SELECT weapon_type FROM characters WHERE character_name = NEW.character_name) != 
            (SELECT weapon_type FROM weapons WHERE weapon_name = NEW.character_weapon) THEN
            errorr := TRUE;
		    RAISE NOTICE '# 更新失敗 # 武器類型並不匹配當前角色';
        END IF;
    END IF;

    IF errorr IS TRUE THEN
		RAISE EXCEPTION '';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_character_update_trigger
BEFORE UPDATE ON player_characters
FOR EACH ROW
EXECUTE FUNCTION check_character_update();
