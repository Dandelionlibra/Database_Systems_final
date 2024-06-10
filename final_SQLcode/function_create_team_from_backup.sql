CREATE OR REPLACE FUNCTION create_team_from_backup(backup_team_id INTEGER, new_u_id INTEGER) RETURNS TABLE (
    new_uid INTEGER,
    new_team_name VARCHAR(25),
    new_member1 VARCHAR(25),
    member1_level INTEGER,
    member1_weapon VARCHAR(25),
    new_member2 VARCHAR(25),
    member2_level INTEGER,
    member2_weapon VARCHAR(25),
    new_member3 VARCHAR(25),
    member3_level INTEGER,
    member3_weapon VARCHAR(25),
    new_member4 VARCHAR(25),
    member4_level INTEGER,
    member4_weapon VARCHAR(25)
) AS $$
DECLARE
    backup_team RECORD;
    member_names TEXT[];
    member_weapons TEXT[];
    i INTEGER;
    tmp_weapon VARCHAR(25); 
    current_team_avg_damage NUMERIC;
    backup_team_expected_damage NUMERIC;
    tmp_character_level INTEGER;
BEGIN
    -- 取得備份隊伍的資料
    SELECT * INTO backup_team
    FROM ( 
        SELECT team_id, u_id, create_time, team_name, 
        member1, weapon1, member2, weapon2,
        member3, weapon3, member4, weapon4, expected_damage
        FROM team_backup )
    WHERE team_id = backup_team_id;

    IF NOT FOUND THEN
        RAISE NOTICE '備份隊伍ID: % 不存在', backup_team_id;
        RETURN;
    END IF;

    member_names := ARRAY[backup_team.member1, backup_team.member2, backup_team.member3, backup_team.member4];
    member_weapons := ARRAY[backup_team.weapon1, backup_team.weapon2, backup_team.weapon3, backup_team.weapon4];

    -- 檢查每個角色是否都存在玩家擁有的角色中，並更新武器
    FOR i IN 1..4 LOOP
        IF member_names[i] IS NOT NULL THEN
            IF NOT EXISTS (SELECT 1 FROM player_characters WHERE u_id = new_u_id AND character_name = member_names[i]) THEN
                RAISE NOTICE '# 新增失敗 # 玩家UID: % 缺少角色: %', new_u_id, member_names[i];
                member_names[i] := NULL;
                member_weapons[i] := NULL;
            ELSE
                -- 更新角色武器
                IF member_weapons[i] IS NOT NULL THEN
				    SELECT character_weapon into tmp_weapon
				    FROM player_characters
				    WHERE u_id = new_u_id AND character_name = member_names[i];

                    -- RAISE NOTICE 'tmp_weapon: % 裝備武器: %',  tmp_weapon, member_weapons[i];

				    IF tmp_weapon is null or member_weapons[i] != tmp_weapon THEN
                        
                        UPDATE player_characters
                        SET character_weapon = member_weapons[i]
                        WHERE u_id = new_u_id AND character_name = member_names[i];
                        RAISE NOTICE '角色: % 卸下武器: % 裝備武器: %', member_names[i], tmp_weapon, member_weapons[i];
				    
                    END IF;
                END IF;
            END IF;
        END IF;
    END LOOP;

    -- 插入新隊伍資料
    INSERT INTO team (u_id, create_time, team_name, member1, member2, member3, member4)
    VALUES (new_u_id, NOW(), 'team_from_backup', member_names[1], member_names[2], member_names[3], member_names[4]);
    
    -- 計算當前隊伍的傷害
	backup_team_expected_damage := backup_team.expected_damage;
    SELECT SUM(character_expected_atk) INTO current_team_avg_damage
    FROM view_character_expected_atk
    WHERE u_id = new_u_id AND character_name = ANY(member_names);
    
    -- RAISE NOTICE '1.current_team_avg_damage:%  backup_team_expected_damage:%', current_team_avg_damage, backup_team_expected_damage;

    -- 檢查當前隊伍的强度
    IF current_team_avg_damage < backup_team_expected_damage THEN
    	-- RAISE NOTICE '2.current_team_avg_damage:%  backup_team_expected_damage:%', current_team_avg_damage, backup_team_expected_damage;
        RAISE NOTICE '# 隊伍強度過低 # 您的隊伍目前總傷害為 % ，低於選擇的隊伍傷害(%)', current_team_avg_damage, backup_team_expected_damage;
		
        -- 檢查隊伍成員數量
        IF array_length(member_names, 1) - array_length(array_remove(member_names, NULL), 1) < 4 THEN
            RAISE NOTICE '目前隊伍未滿，還可以加入 % 名成員進入隊伍', 4 - array_length(array_remove(member_names, NULL), 1);
        END IF;

        -- 檢查成員等級
        FOR i IN 1..4 LOOP
            IF member_names[i] IS NOT NULL THEN
                SELECT tmp_characters.character_level INTO tmp_character_level
                FROM player_characters as tmp_characters
                WHERE tmp_characters.u_id = new_u_id AND tmp_characters.character_name = member_names[i];
                
                IF tmp_character_level < 90 THEN
                    RAISE NOTICE '% 目前等級為 % 等，建議提升到 90 等', member_names[i], tmp_character_level;
                END IF;
            END IF;
        END LOOP;
    END IF;

    RETURN QUERY
		SELECT
        new_u_id,
        'team_from_backup'::VARCHAR(25),
        member_names[1]::VARCHAR(25),
        (SELECT character_level FROM player_characters WHERE u_id = new_u_id AND character_name = member_names[1]),
        member_weapons[1]::VARCHAR(25),
        member_names[2]::VARCHAR(25),
        (SELECT character_level FROM player_characters WHERE u_id = new_u_id AND character_name = member_names[2]),
        member_weapons[2]::VARCHAR(25),
        member_names[3]::VARCHAR(25),
        (SELECT character_level FROM player_characters WHERE u_id = new_u_id AND character_name = member_names[3]),
        member_weapons[3]::VARCHAR(25),
        member_names[4]::VARCHAR(25),
        (SELECT character_level FROM player_characters WHERE u_id = new_u_id AND character_name = member_names[4]),
        member_weapons[4]::VARCHAR(25);
END;
$$ LANGUAGE plpgsql;