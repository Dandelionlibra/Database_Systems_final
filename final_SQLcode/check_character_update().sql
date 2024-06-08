
CREATE OR REPLACE FUNCTION check_character_update()
RETURNS TRIGGER AS $$
BEGIN
    -- 檢查玩家是否要更改角色名字
    IF NEW.character_name IS DISTINCT FROM OLD.character_name THEN
        RAISE EXCEPTION '# 更新失敗 # 無法更改角色名字';
    END IF;
    
    -- 檢查角色等級是否下降
    IF NEW.character_level <= OLD.character_level THEN
        RAISE EXCEPTION '# 更新失敗 # 更新角色等級 (%) 無法低於或等於原本角色等級 (%)', NEW.character_level, OLD.character_level;
    END IF;

	-- 確認武器與角色是否匹配
    IF NEW.character_weapon IS NOT NULL THEN
        IF (SELECT weapon_type FROM characters WHERE character_name = NEW.character_name) != 
            (SELECT weapon_type FROM weapons WHERE weapon_name = NEW.character_weapon) THEN
            RAISE EXCEPTION '# 更新失敗 # 武器類型並不匹配當前角色';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_character_update_trigger
BEFORE UPDATE ON player_characters
FOR EACH ROW
EXECUTE FUNCTION check_character_update();
