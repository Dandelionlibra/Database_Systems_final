/* 限制更新玩家等級時，更新等級不能小於舊等級 */
CREATE OR REPLACE FUNCTION check_player_level_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.players_level < OLD.players_level THEN
        RAISE EXCEPTION 'New level (%s) cannot be less than the old level (%s)', NEW.players_level, OLD.players_level;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER player_level_update_trigger
BEFORE UPDATE ON players
FOR EACH ROW
EXECUTE FUNCTION check_player_level_update();



/* 限制更新玩家擁有的角色等級時，更新等級不能小於舊等級 */
CREATE OR REPLACE FUNCTION check_character_update()
RETURNS TRIGGER AS $$
BEGIN
    -- 檢查玩家是否要更改角色名字
    IF NEW.character_name IS DISTINCT FROM OLD.character_name THEN
        RAISE EXCEPTION '無法更改角色名字';
    END IF;
    
    -- 檢查角色等级是否下降
    IF NEW.character_level < OLD.character_level THEN
        RAISE EXCEPTION 'New character level (%s) cannot be less than the old character level (%s)', NEW.character_level, OLD.character_level;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER character_level_update_trigger
BEFORE UPDATE ON player_characters
FOR EACH ROW
EXECUTE FUNCTION check_character_update();


/*
CREATE OR REPLACE FUNCTION check_character_level_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.character_level < OLD.character_level THEN
        RAISE EXCEPTION 'New character level (%s) cannot be less than the old character level (%s)', NEW.character_level, OLD.character_level;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER character_level_update_trigger
BEFORE UPDATE ON player_characters
FOR EACH ROW
EXECUTE FUNCTION check_character_level_update();
*/

-- 删除触发器
-- DROP TRIGGER IF EXISTS character_level_update_trigger ON player_characters;

-- 删除触发器函数
-- DROP FUNCTION IF EXISTS check_character_level_update();

