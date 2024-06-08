
/* 在更新players資料時，u_id一定不可更新，player_name可以更新，
 * 若要更新players_level的值則更新的值必須大於當前players_level，且不可以大於60等
 */
-- 創建觸發器函數
CREATE OR REPLACE FUNCTION check_players_update() RETURNS TRIGGER AS $$
BEGIN
    -- 確保 u_id 不被更新
    IF NEW.u_id <> OLD.u_id THEN
        RAISE EXCEPTION 'u_id cannot be updated';
    END IF;
    -- 檢查 players_level 的更新值
    IF NEW.players_level IS DISTINCT FROM OLD.players_level THEN
        IF NEW.players_level <= OLD.players_level THEN
            RAISE EXCEPTION 'new players_level must be greater than the current players_level';
        ELSIF NEW.players_level > 60 THEN
            RAISE EXCEPTION 'players_level cannot be greater than 60';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 創建觸發器
CREATE TRIGGER before_players_update
BEFORE UPDATE ON players
FOR EACH ROW
EXECUTE FUNCTION check_players_update();


/* 限制player_characters中的character_hp初始化為對應characters的c_hp，
 * 且不可由使用者，用UPDATE進行更改，只能在使用者更新player_characters 等級時，
 * 讓系統以以下公式進行運算:[(character_level-1)*elements.hp_bonus + c_hp]*(1 + w_hp)，
 * 再更新character_hp值，未裝備武器時，character_weapon預設為NULL，相關數值以0進行運算
 */
-- 創建一個觸發器函數
-- 创建触发器函数
CREATE OR REPLACE FUNCTION update_character_stats()
RETURNS TRIGGER AS $$
DECLARE
    -- 声明局部变量，用于存储查询结果
    char_element RECORD;
    char_weapon RECORD;
BEGIN
    -- 获取 character 对应的元素的 bonus 值
    SELECT hp_bonus, atk_bonus, def_bonus INTO char_element 
    FROM elements 
    WHERE element_type = (SELECT element FROM characters WHERE character_name = NEW.character_name);

    -- 获取 character 装备的武器的属性值
    SELECT base_atk, w_hp, w_atk, w_def, w_crit_damage, w_crit_rate INTO char_weapon
    FROM weapons 
    WHERE weapon_name = NEW.character_weapon;

    -- 计算 character_hp
    NEW.character_hp := ((NEW.character_level - 1) * char_element.hp_bonus + (SELECT c_hp FROM characters WHERE character_name = NEW.character_name)) * (1 + COALESCE(char_weapon.w_hp, 0));

    -- 计算 character_atk
    NEW.character_atk := ((NEW.character_level - 1) * (char_element.atk_bonus + COALESCE(char_weapon.base_atk, 0)) + (SELECT c_atk FROM characters WHERE character_name = NEW.character_name)) * (1 + COALESCE(char_weapon.w_atk, 0));

    -- 计算 character_def
    NEW.character_def := ((NEW.character_level - 1) * char_element.def_bonus + (SELECT c_def FROM characters WHERE character_name = NEW.character_name)) * (1 + COALESCE(char_weapon.w_def, 0));

    -- 返回新记录
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 创建触发器
CREATE TRIGGER trigger_update_character_stats
BEFORE INSERT OR UPDATE ON player_characters
FOR EACH ROW
EXECUTE FUNCTION update_character_stats();



/*CREATE OR REPLACE FUNCTION update_character_hp()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.character_level IS NOT NULL THEN
        SELECT ((NEW.character_level - 1) * elements.hp_bonus + c_hp) * (1 + COALESCE(w_hp, 0))
        INTO NEW.character_hp
        FROM characters
        LEFT JOIN player_weapons ON characters.character_name = player_weapons.weapon_name
        LEFT JOIN elements ON characters.element = elements.element_type
        WHERE characters.character_name = NEW.character_name;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 創建觸發器
CREATE TRIGGER update_character_hp_trigger
BEFORE INSERT OR UPDATE ON player_characters
FOR EACH ROW
EXECUTE FUNCTION update_character_hp();
*/

/*
CREATE OR REPLACE FUNCTION update_player_characters_stats() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- initialize character stats
        SELECT ((NEW.character_level - 1) * e.hp_bonus + c.c_hp) * (1 + COALESCE(w.w_hp, 0))
        INTO NEW.character_hp
        FROM characters c
        JOIN elements e ON c.element = e.element_type
        LEFT JOIN weapons w ON NEW.character_weapon = w.weapon_name AND c.weapon_type = w.weapon_type;

        SELECT ((NEW.character_level - 1) * (e.atk_bonus + COALESCE(w.base_atk, 0)) + c.c_atk) * (1 + COALESCE(w.w_atk, 0))
        INTO NEW.character_atk
        FROM characters c
        JOIN elements e ON c.element = e.element_type
        LEFT JOIN weapons w ON NEW.character_weapon = w.weapon_name AND c.weapon_type = w.weapon_type;

        SELECT ((NEW.character_level - 1) * e.def_bonus + c.c_def) * (1 + COALESCE(w.w_def, 0))
        INTO NEW.character_def
        FROM characters c
        JOIN elements e ON c.element = e.element_type
        LEFT JOIN weapons w ON NEW.character_weapon = w.weapon_name AND c.weapon_type = w.weapon_type;
    ELSIF TG_OP = 'UPDATE' THEN
        -- prevent direct update of character stats
        IF OLD.character_hp <> NEW.character_hp OR OLD.character_atk <> NEW.character_atk OR OLD.character_def <> NEW.character_def THEN
            RAISE EXCEPTION 'Character stats cannot be updated directly';
        END IF;

        -- update character stats based on level and equipped weapon
        SELECT ((NEW.character_level - 1) * e.hp_bonus + c.c_hp) * (1 + COALESCE(w.w_hp, 0))
        INTO NEW.character_hp
        FROM characters c
        JOIN elements e ON c.element = e.element_type
        LEFT JOIN weapons w ON NEW.character_weapon = w.weapon_name AND c.weapon_type = w.weapon_type
        WHERE c.character_name = NEW.character_name;

        SELECT ((NEW.character_level - 1) * (e.atk_bonus + COALESCE(w.base_atk, 0)) + c.c_atk) * (1 + COALESCE(w.w_atk, 0))
        INTO NEW.character_atk
        FROM characters c
        JOIN elements e ON c.element = e.element_type
        LEFT JOIN weapons w ON NEW.character_weapon = w.weapon_name AND c.weapon_type = w.weapon_type
        WHERE c.character_name = NEW.character_name;

        SELECT ((NEW.character_level - 1) * e.def_bonus + c.c_def) * (1 + COALESCE(w.w_def, 0))
        INTO NEW.character_def
        FROM characters c
        JOIN elements e ON c.element = e.element_type
        LEFT JOIN weapons w ON NEW.character_weapon = w.weapon_name AND c.weapon_type = w.weapon_type
        WHERE c.character_name = NEW.character_name;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_player_characters_stats_trigger
BEFORE INSERT OR UPDATE OF character_level, character_weapon ON player_characters
FOR EACH ROW
EXECUTE FUNCTION update_player_characters_stats();

*/


/*
 * 限制player_characters中的character_hp初始化為對應characters的c_hp，
 * 且不可由使用者，用UPDATE進行更改，只能在使用者更新player_characters 等級時，
 * 讓系統以以下公式進行運算:[(character_level-1)*elements.hp_bonus + c_hp]*(1 + w_hp)，
 * 再更新c_hp值，未裝備武器時，character_weapon預設為NULL，相關數值以0進行運算
 */
-- 創建觸發器函數
CREATE OR REPLACE FUNCTION check_characters_update() RETURNS TRIGGER AS $$
BEGIN
    -- 確保 character_name 不被更新
    IF NEW.character_name <> OLD.character_name THEN
        RAISE EXCEPTION 'character_name cannot be updated';
    END IF;
    
    -- -- 檢查 c_hp 的更新值
    -- IF NEW.c_hp IS DISTINCT FROM OLD.c_hp THEN
    --     IF NEW.c_hp <= OLD.c_hp THEN
    --         RAISE EXCEPTION 'new c_hp must be greater than the current c_hp';
    --     END IF;
    -- END IF;
    
    -- -- 檢查 c_atk 的更新值
    -- IF NEW.c_atk IS DISTINCT FROM OLD.c_atk THEN
    --     IF NEW.c_atk <= OLD.c_atk THEN
    --         RAISE EXCEPTION 'new c_atk must be greater than the current c_atk';
    --     END IF;
    -- END IF;
    
    -- -- 檢查 c_def 的更新值
    -- IF NEW.c_def IS DISTINCT FROM OLD.c_def THEN
    --     IF NEW.c_def <= OLD.c_def THEN
    --         RAISE EXCEPTION 'new c_def must be greater than the current c_def';
    --     END IF;
    -- END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- 創建觸發器
CREATE TRIGGER before_characters_update
BEFORE UPDATE ON characters
FOR EACH ROW
EXECUTE FUNCTION check_characters_update();




/*
 * team的expected_damage, highest_damage, lowest_damage，不可直接輸入，
 * 必須透過member1, member2, member3, member4，及其各自裝備武器的數值計算
*/
-- 創建觸發器函數
CREATE OR REPLACE FUNCTION calculate_team_damage(
    member1 VARCHAR(25), 
    member2 VARCHAR(25), 
    member3 VARCHAR(25), 
    member4 VARCHAR(25)
) RETURNS TABLE (
    expected_damage INTEGER, 
    highest_damage INTEGER, 
    lowest_damage INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        SUM(pc.c_atk + w.w_atk) AS expected_damage,
        MAX(pc.c_atk + w.w_atk) AS highest_damage,
        MIN(pc.c_atk + w.w_atk) AS lowest_damage
    FROM player_characters pc
    LEFT JOIN player_weapons pw ON pc.character_weapon = pw.weapon_name
    LEFT JOIN weapons w ON pw.weapon_name = w.weapon_name
    WHERE pc.character_name IN (member1, member2, member3, member4);
END;
$$ LANGUAGE plpgsql;
-- 創建觸發器函數
CREATE OR REPLACE FUNCTION set_team_damage() RETURNS TRIGGER AS $$
DECLARE
    damage RECORD;
BEGIN
    -- 調用計算函數
    SELECT * INTO damage FROM calculate_team_damage(NEW.member1, NEW.member2, NEW.member3, NEW.member4);

    -- 設置計算结果
    NEW.expected_damage := damage.expected_damage;
    NEW.highest_damage := damage.highest_damage;
    NEW.lowest_damage := damage.lowest_damage;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- 創建觸發器
CREATE TRIGGER before_team_insert_update
BEFORE INSERT OR UPDATE ON team
FOR EACH ROW
EXECUTE FUNCTION set_team_damage();







/*
 * 每個player的team上限為4組，若新增team時，發現已經達到team的上限了，
 * 則依照create_time、team_id、u_id作為主鍵，備份create_time最早的資料，
 * 再加入新的隊伍資料
 */
-- 創建觸發器函數
CREATE OR REPLACE FUNCTION limit_team_count() RETURNS TRIGGER AS $$
BEGIN
    -- 檢查玩家的team數量是否超過 4 個
    IF (SELECT COUNT(*) FROM team WHERE u_id = NEW.u_id) >= 4 THEN
        -- 備份最早創建的team
        INSERT INTO team_backup (team_id, u_id, create_time, team_name, member1, member2, member3, member4, expected_damage, highest_damage, lowest_damage)
        SELECT team_id, u_id, create_time, team_name, member1, member2, member3, member4, expected_damage, highest_damage, lowest_damage
        FROM team
        WHERE u_id = NEW.u_id
        ORDER BY create_time ASC
        LIMIT 1;

        -- 删除最早創建的team
        DELETE FROM team
        WHERE team_id = (SELECT team_id FROM team WHERE u_id = NEW.u_id ORDER BY create_time ASC LIMIT 1);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 創建觸發器
CREATE TRIGGER limit_team_trigger
BEFORE INSERT ON team
FOR EACH ROW
EXECUTE FUNCTION limit_team_count();



