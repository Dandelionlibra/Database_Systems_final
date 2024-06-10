/* 建立或更新player_characters 的character_weapon時檢查對應到的
   characters表格中的weapon_type是否等於要裝備的武器的weapon_type，
   若不等於則回報錯誤訊息，並不可新增 */
CREATE OR REPLACE FUNCTION check_character_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- 檢查角色是否存在 characters 表中
    IF NOT EXISTS (
        SELECT 1
        FROM characters
        WHERE character_name = NEW.character_name
    ) THEN
        RAISE EXCEPTION '# 新增失敗 # 角色 % 不存在資料庫中', NEW.character_name;
    END IF;

    -- 檢查角色是否已存在
    IF EXISTS (
        SELECT 1
        FROM player_characters
        WHERE u_id = NEW.u_id AND character_name = NEW.character_name
    ) THEN
        RAISE EXCEPTION '# 新增失敗 # 玩家UID: % 已擁有角色 %', NEW.u_id, NEW.character_name;
    END IF;

    -- 檢查角色等級範圍
    IF NEW.character_level < 1 OR NEW.character_level > 90 THEN
        RAISE EXCEPTION '# 新增失敗 # 角色等級 % 超出範圍 (1-90)', NEW.character_level;
    END IF;

    -- 檢查武器是否存在 weapons 表中
    IF NEW.character_weapon IS NOT NULL and NOT EXISTS (
        SELECT 1
        FROM weapons
        WHERE weapon_name = NEW.character_weapon
    ) THEN
        RAISE EXCEPTION '# 新增失敗 # 武器 % 不存在資料庫中', NEW.character_weapon;
    END IF;

	-- 確認武器與角色是否匹配
    IF NEW.character_weapon IS NOT NULL THEN
        IF (SELECT weapon_type FROM characters WHERE character_name = NEW.character_name) != 
            (SELECT weapon_type FROM weapons WHERE weapon_name = NEW.character_weapon) THEN
            RAISE NOTICE '# 新增失敗 # 武器類型並不匹配當前角色';
		    NEW.character_weapon = NULL;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER character_insert_trigger
BEFORE INSERT ON player_characters
FOR EACH ROW
EXECUTE FUNCTION check_character_insert();