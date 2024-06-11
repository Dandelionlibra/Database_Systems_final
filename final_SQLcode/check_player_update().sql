
CREATE OR REPLACE FUNCTION check_player_update()
RETURNS TRIGGER AS $$
BEGIN
	-- 確保 u_id 不被更新
    IF NEW.u_id <> OLD.u_id THEN
        RAISE EXCEPTION '# 無法更新 # u_id 不可被更新';
    END IF;

    -- 限制更新玩家等級時，更新等級不能小於舊等級
    IF NEW.players_level < OLD.players_level THEN
        RAISE EXCEPTION '# 無法更新 # 欲更新的新等級必須大於舊等級，新等級為%，舊等級為%', NEW.players_level, OLD.players_level;
    END IF;

    -- 檢查玩家等級範圍
    IF NEW.players_level < 1 OR NEW.players_level > 60 THEN
        RAISE EXCEPTION '# 無法更新 # 角色等級 % 超出範圍 (1-60)', NEW.players_level;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER player_update_trigger
BEFORE UPDATE ON players
FOR EACH ROW
EXECUTE FUNCTION check_player_update();



