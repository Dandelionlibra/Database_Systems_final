CREATE OR REPLACE FUNCTION handle_team_insertion()
RETURNS TRIGGER AS $$
DECLARE
    team_count INTEGER;
    oldest_team RECORD;
    member_count INTEGER;
BEGIN
    -- 確保至少有一個成員存在
    IF NEW.member1 IS NULL AND NEW.member2 IS NULL AND NEW.member3 IS NULL AND NEW.member4 IS NULL THEN
        RAISE EXCEPTION '隊伍需要至少有一人才能成立';
    END IF;

    -- 確保隊伍中沒有相同的角色
    SELECT COUNT(*) INTO member_count
    FROM (VALUES (NEW.member1), (NEW.member2), (NEW.member3), (NEW.member4)) AS members
    WHERE members.column1 IS NOT NULL
    GROUP BY members.column1
    HAVING COUNT(*) > 1;

    IF member_count > 0 THEN
        RAISE EXCEPTION '隊伍中不能有相同的角色';
    END IF;

    -- 計算玩家的隊伍數量
    SELECT COUNT(*) INTO team_count FROM team WHERE u_id = NEW.u_id;

    IF team_count >= 4 THEN
        -- 找到最早的隊伍記錄
        SELECT * INTO oldest_team 
        FROM team 
        WHERE u_id = NEW.u_id 
        ORDER BY create_time 
        LIMIT 1;

        -- 備份最早的隊伍記錄
        INSERT INTO team_backup (u_id, create_time, team_name, member1, member2, member3, member4, expected_damage, highest_damage, lowest_damage)
        VALUES (oldest_team.u_id, oldest_team.create_time, oldest_team.team_name, oldest_team.member1, oldest_team.member2, oldest_team.member3, oldest_team.member4,
                (SELECT COALESCE(SUM(character_expected_atk), 0) FROM view_character_expected_atk WHERE u_id = oldest_team.u_id AND character_name IN (oldest_team.member1, oldest_team.member2, oldest_team.member3, oldest_team.member4)),
                (SELECT COALESCE(SUM(character_highest_atk), 0) FROM view_character_highest_atk WHERE u_id = oldest_team.u_id AND character_name IN (oldest_team.member1, oldest_team.member2, oldest_team.member3, oldest_team.member4)),
                (SELECT COALESCE(SUM(character_lowest_atk), 0) FROM view_character_lowest_atk WHERE u_id = oldest_team.u_id AND character_name IN (oldest_team.member1, oldest_team.member2, oldest_team.member3, oldest_team.member4)));

        -- 刪除最早的隊伍記錄
        DELETE FROM team WHERE u_id = oldest_team.u_id AND team_id = oldest_team.team_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_handle_team_insertion
BEFORE INSERT ON team
FOR EACH ROW
EXECUTE FUNCTION handle_team_insertion();

-- DROP TRIGGER handle_team_insertion() ON trigger_handle_team_insertion;

SELECT * FROM pg_proc WHERE proname = 'handle_team_insertion';