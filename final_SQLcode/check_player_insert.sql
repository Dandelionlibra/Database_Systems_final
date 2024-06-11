CREATE OR REPLACE FUNCTION check_player_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- 檢查UID是否存在
    IF EXISTS (
        SELECT 1
        FROM players
        WHERE u_id = NEW.u_id
    ) THEN
        RAISE EXCEPTION '# 新增失敗 # UID: % 已存在', NEW.u_id;
    END IF;

    -- 檢查玩家等級範圍
    IF NEW.players_level < 1 OR NEW.players_level > 60 THEN
        RAISE EXCEPTION '# 新增失敗 # 角色等級 % 超出範圍 (1-60)', NEW.players_level;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER player_insert_trigger
BEFORE INSERT ON players
FOR EACH ROW
EXECUTE FUNCTION check_player_insert();