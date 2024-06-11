PGDMP                      |            Genshin    16.3    16.3 L    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    17489    Genshin    DATABASE     �   CREATE DATABASE "Genshin" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Chinese (Traditional)_Taiwan.950';
    DROP DATABASE "Genshin";
                postgres    false            �            1255    18970    check_character_insert()    FUNCTION       CREATE FUNCTION public.check_character_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
	-- 檢查u_id是否存在於players表中
    IF NOT EXISTS (
        SELECT 1
        FROM players
        WHERE u_id = NEW.u_id
    ) THEN
        RAISE EXCEPTION '# 新增失敗 # 玩家UID: % 不存在資料庫中', NEW.u_id;
    END IF;

    -- 檢查角色是否存在 characters 表中
    IF NOT EXISTS (
        SELECT 1
        FROM characters
        WHERE character_name = NEW.character_name
    ) THEN
        RAISE EXCEPTION '# 新增失敗 # 角色 % 不存在資料庫中', NEW.character_name;
    END IF;

    -- 檢查該角色玩家是否已擁有
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
            RAISE NOTICE '# 新增失敗 # 武器類型並不匹配當前角色，自動卸下當前武器';
		    NEW.character_weapon = NULL;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;
 /   DROP FUNCTION public.check_character_insert();
       public          postgres    false            �            1255    18930    check_character_update()    FUNCTION     �  CREATE FUNCTION public.check_character_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
    errorr BOOLEAN default FALSE;
    player_exists BOOLEAN default FALSE;
BEGIN
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
$$;
 /   DROP FUNCTION public.check_character_update();
       public          postgres    false            �            1255    18976    check_player_insert()    FUNCTION       CREATE FUNCTION public.check_player_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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

$$;
 ,   DROP FUNCTION public.check_player_insert();
       public          postgres    false            �            1255    18974    check_player_update()    FUNCTION     �  CREATE FUNCTION public.check_player_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 ,   DROP FUNCTION public.check_player_update();
       public          postgres    false            �            1255    18981    check_team_members_exist()    FUNCTION     :  CREATE FUNCTION public.check_team_members_exist() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;
 1   DROP FUNCTION public.check_team_members_exist();
       public          postgres    false            �            1255    19025 )   create_team_from_backup(integer, integer)    FUNCTION       CREATE FUNCTION public.create_team_from_backup(backup_team_id integer, new_u_id integer) RETURNS TABLE(new_uid integer, new_team_name character varying, new_member1 character varying, member1_level integer, member1_weapon character varying, new_member2 character varying, member2_level integer, member2_weapon character varying, new_member3 character varying, member3_level integer, member3_weapon character varying, new_member4 character varying, member4_level integer, member4_weapon character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    backup_team RECORD;
    member_names TEXT[];
    member_weapons TEXT[];
    i INTEGER;
    tmp_weapon VARCHAR(25); 
    missing_members TEXT := '';
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
$$;
 X   DROP FUNCTION public.create_team_from_backup(backup_team_id integer, new_u_id integer);
       public          postgres    false            �            1255    19042 !   get_used_characters_rank(integer)    FUNCTION     �  CREATE FUNCTION public.get_used_characters_rank(rank_n integer) RETURNS TABLE(u_id integer, character_name text, usage_count integer, rank integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY EXECUTE format(
        'WITH combined_teams AS (
            SELECT u_id, member1::text AS character_name FROM team_backup WHERE member1 IS NOT NULL
            UNION ALL
            SELECT u_id, member2::text AS character_name FROM team_backup WHERE member2 IS NOT NULL
            UNION ALL
            SELECT u_id, member3::text AS character_name FROM team_backup WHERE member3 IS NOT NULL
            UNION ALL
            SELECT u_id, member4::text AS character_name FROM team_backup WHERE member4 IS NOT NULL
            UNION ALL
            SELECT u_id, member1::text AS character_name FROM team WHERE member1 IS NOT NULL
            UNION ALL
            SELECT u_id, member2::text AS character_name FROM team WHERE member2 IS NOT NULL
            UNION ALL
            SELECT u_id, member3::text AS character_name FROM team WHERE member3 IS NOT NULL
            UNION ALL
            SELECT u_id, member4::text AS character_name FROM team WHERE member4 IS NOT NULL
        ),
        character_usage_by_user AS (
            SELECT 
                u_id, 
                character_name,
                COUNT(*)::INTEGER AS usage_count
            FROM combined_teams
            WHERE character_name IS NOT NULL
            GROUP BY u_id, character_name
        )
        SELECT 
            u_id,
            character_name,
            usage_count,
            rank::INTEGER
        FROM (
            SELECT 
                u_id,
                character_name,
                usage_count,
                ROW_NUMBER() OVER (PARTITION BY u_id ORDER BY usage_count DESC) AS rank
            FROM character_usage_by_user
        ) AS ranked_usage
        WHERE rank <= %L
        ORDER BY u_id, rank;',
        rank_n
    );
END;
$$;
 ?   DROP FUNCTION public.get_used_characters_rank(rank_n integer);
       public          postgres    false            �            1255    18843    handle_team_insertion()    FUNCTION     �  CREATE FUNCTION public.handle_team_insertion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    team_count INTEGER;
    oldest_team RECORD;
    member_count INTEGER;
    backup_weapon1 VARCHAR(25);
    backup_weapon2 VARCHAR(25);
    backup_weapon3 VARCHAR(25);
    backup_weapon4 VARCHAR(25);
BEGIN
    -- 確保至少有一個成員存在
    IF NEW.member1 IS NULL AND NEW.member2 IS NULL AND NEW.member3 IS NULL AND NEW.member4 IS NULL THEN
        RAISE EXCEPTION '# 新增失敗 # 隊伍需要至少有一人才能成立';
    END IF;

    -- 確保隊伍中沒有相同的角色
    SELECT COUNT(*) INTO member_count
    FROM (VALUES (NEW.member1), (NEW.member2), (NEW.member3), (NEW.member4)) AS members
    WHERE members.column1 IS NOT NULL
    GROUP BY members.column1
    HAVING COUNT(*) > 1;

    IF member_count > 0 THEN
        RAISE EXCEPTION '# 新增失敗 # 隊伍中不能有相同的角色';
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

    	-- 找到舊紀錄中角色的武器資料
    	SELECT character_weapon INTO backup_weapon1 FROM player_characters WHERE u_id = oldest_team.u_id AND character_name = oldest_team.member1;
    	SELECT character_weapon INTO backup_weapon2 FROM player_characters WHERE u_id = oldest_team.u_id AND character_name = oldest_team.member2;
    	SELECT character_weapon INTO backup_weapon3 FROM player_characters WHERE u_id = oldest_team.u_id AND character_name = oldest_team.member3;
    	SELECT character_weapon INTO backup_weapon4 FROM player_characters WHERE u_id = oldest_team.u_id AND character_name = oldest_team.member4;

        -- 備份最早的隊伍記錄
        INSERT INTO team_backup (u_id, create_time, team_name,
			                     member1, weapon1, member2, weapon2,
			                     member3, weapon3, member4, weapon4,
			                     expected_damage, highest_damage, lowest_damage)
        VALUES (oldest_team.u_id, oldest_team.create_time, oldest_team.team_name,
			    oldest_team.member1, backup_weapon1, oldest_team.member2, backup_weapon2,
			    oldest_team.member3, backup_weapon3, oldest_team.member4, backup_weapon4,
                (SELECT COALESCE(SUM(character_expected_atk), 0)
					FROM view_character_expected_atk
					WHERE u_id = oldest_team.u_id AND character_name IN (oldest_team.member1, oldest_team.member2, oldest_team.member3, oldest_team.member4)),
                (SELECT COALESCE(SUM(character_highest_atk), 0)
					FROM view_character_highest_atk
					WHERE u_id = oldest_team.u_id AND character_name IN (oldest_team.member1, oldest_team.member2, oldest_team.member3, oldest_team.member4)),
                (SELECT COALESCE(SUM(character_atk), 0)
					FROM view_character_atk
					WHERE u_id = oldest_team.u_id AND character_name IN (oldest_team.member1, oldest_team.member2, oldest_team.member3, oldest_team.member4)));
		
		-- 輸出備份記錄
        RAISE NOTICE E'# 自動備份，並刪除最早的隊伍資料 # \n備份記錄: \nUID = %, \nTeam Name = %, \nMember1 = %, Weapon1 = %, \nMember2 = %, Weapon2 = %, \nMember3 = %, Weapon3 = %, \nMember4 = %, Weapon4 = %',
            oldest_team.u_id, oldest_team.team_name, oldest_team.member1, backup_weapon1, oldest_team.member2, backup_weapon2,
            oldest_team.member3, backup_weapon3, oldest_team.member4, backup_weapon4;

        -- 刪除最早的隊伍記錄
        DELETE FROM team WHERE u_id = oldest_team.u_id AND team_id = oldest_team.team_id;
    END IF;

    RETURN NEW;
END;
$$;
 .   DROP FUNCTION public.handle_team_insertion();
       public          postgres    false            �            1259    18718 
   characters    TABLE     �  CREATE TABLE public.characters (
    character_name character varying(25) NOT NULL,
    element character varying(25) NOT NULL,
    weapon_type character varying(25) NOT NULL,
    c_hp integer DEFAULT 0 NOT NULL,
    c_atk integer DEFAULT 0 NOT NULL,
    c_def integer DEFAULT 0 NOT NULL,
    c_crit_damage double precision DEFAULT 0 NOT NULL,
    c_crit_rate double precision DEFAULT 0 NOT NULL
);
    DROP TABLE public.characters;
       public         heap    postgres    false            �            1259    18687    elements    TABLE     �   CREATE TABLE public.elements (
    element_type character varying(25) NOT NULL,
    hp_bonus integer DEFAULT 1 NOT NULL,
    atk_bonus integer DEFAULT 1 NOT NULL,
    def_bonus integer DEFAULT 1 NOT NULL
);
    DROP TABLE public.elements;
       public         heap    postgres    false            �            1259    18738    player_characters    TABLE     N  CREATE TABLE public.player_characters (
    u_id integer NOT NULL,
    character_name character varying(25) NOT NULL,
    character_level integer DEFAULT 1,
    character_weapon character varying(25) DEFAULT NULL::character varying,
    CONSTRAINT character_level_range CHECK (((character_level >= 1) AND (character_level <= 90)))
);
 %   DROP TABLE public.player_characters;
       public         heap    postgres    false            �            1259    18678    players    TABLE     �   CREATE TABLE public.players (
    u_id integer NOT NULL,
    player_name character varying(25) NOT NULL,
    players_level integer DEFAULT 1,
    CONSTRAINT player_level_range CHECK (((players_level >= 1) AND (players_level <= 60)))
);
    DROP TABLE public.players;
       public         heap    postgres    false            �            1259    18677    players_u_id_seq    SEQUENCE     �   CREATE SEQUENCE public.players_u_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.players_u_id_seq;
       public          postgres    false    216            �           0    0    players_u_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.players_u_id_seq OWNED BY public.players.u_id;
          public          postgres    false    215            �            1259    18762    team    TABLE     �  CREATE TABLE public.team (
    team_id integer NOT NULL,
    u_id integer NOT NULL,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    team_name character varying(25) DEFAULT 'default teamname'::character varying,
    member1 character varying(25) DEFAULT NULL::character varying,
    member2 character varying(25) DEFAULT NULL::character varying,
    member3 character varying(25) DEFAULT NULL::character varying,
    member4 character varying(25) DEFAULT NULL::character varying
);
    DROP TABLE public.team;
       public         heap    postgres    false            �            1259    18857    team_backup    TABLE     }  CREATE TABLE public.team_backup (
    team_id integer NOT NULL,
    u_id integer NOT NULL,
    create_time timestamp without time zone,
    backup_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    team_name character varying(25),
    member1 character varying(25) DEFAULT NULL::character varying,
    member2 character varying(25) DEFAULT NULL::character varying,
    member3 character varying(25) DEFAULT NULL::character varying,
    member4 character varying(25) DEFAULT NULL::character varying,
    expected_damage double precision,
    highest_damage double precision,
    lowest_damage double precision,
    weapon1 character varying(25) DEFAULT NULL::character varying,
    weapon2 character varying(25) DEFAULT NULL::character varying,
    weapon3 character varying(25) DEFAULT NULL::character varying,
    weapon4 character varying(25) DEFAULT NULL::character varying
);
    DROP TABLE public.team_backup;
       public         heap    postgres    false            �            1259    18856    team_backup_team_id_seq    SEQUENCE     �   CREATE SEQUENCE public.team_backup_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.team_backup_team_id_seq;
       public          postgres    false    228            �           0    0    team_backup_team_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.team_backup_team_id_seq OWNED BY public.team_backup.team_id;
          public          postgres    false    227            �            1259    18761    team_team_id_seq    SEQUENCE     �   CREATE SEQUENCE public.team_team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.team_team_id_seq;
       public          postgres    false    223            �           0    0    team_team_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.team_team_id_seq OWNED BY public.team.team_id;
          public          postgres    false    222            �            1259    18696    weapon_types    TABLE     �   CREATE TABLE public.weapon_types (
    weapon_type_name character varying(25) NOT NULL,
    atk_bonus integer DEFAULT 1 NOT NULL
);
     DROP TABLE public.weapon_types;
       public         heap    postgres    false            �            1259    18702    weapons    TABLE     �  CREATE TABLE public.weapons (
    weapon_name character varying(25) NOT NULL,
    weapon_type character varying(25) NOT NULL,
    base_atk integer DEFAULT 0 NOT NULL,
    w_hp double precision DEFAULT 0 NOT NULL,
    w_atk double precision DEFAULT 0 NOT NULL,
    w_def double precision DEFAULT 0 NOT NULL,
    w_crit_damage double precision DEFAULT 0 NOT NULL,
    w_crit_rate double precision DEFAULT 0 NOT NULL
);
    DROP TABLE public.weapons;
       public         heap    postgres    false            �            1259    18818    view_character_atk    VIEW     �  CREATE VIEW public.view_character_atk AS
 SELECT pc.u_id,
    pc.character_name,
    ((((((pc.character_level - 1) * (e.atk_bonus + w_types.atk_bonus)) + c.c_atk) + COALESCE(w.base_atk, 0)))::double precision * ((1)::double precision + COALESCE(w.w_atk, (0)::double precision))) AS character_atk
   FROM ((((public.player_characters pc
     JOIN public.characters c ON (((pc.character_name)::text = (c.character_name)::text)))
     JOIN public.elements e ON (((c.element)::text = (e.element_type)::text)))
     LEFT JOIN public.weapons w ON (((pc.character_weapon)::text = (w.weapon_name)::text)))
     LEFT JOIN public.weapon_types w_types ON (((c.weapon_type)::text = (w_types.weapon_type_name)::text)))
  ORDER BY pc.u_id, pc.character_name;
 %   DROP VIEW public.view_character_atk;
       public          postgres    false    217    218    221    221    220    221    220    221    220    220    219    219    219    217    218            �            1259    18823    view_character_def    VIEW     J  CREATE VIEW public.view_character_def AS
 SELECT pc.u_id,
    pc.character_name,
    (((((pc.character_level - 1) * e.def_bonus) + c.c_def))::double precision * ((1)::double precision + COALESCE(w.w_def, (0)::double precision))) AS character_def
   FROM (((public.player_characters pc
     JOIN public.characters c ON (((pc.character_name)::text = (c.character_name)::text)))
     JOIN public.elements e ON (((c.element)::text = (e.element_type)::text)))
     LEFT JOIN public.weapons w ON (((pc.character_weapon)::text = (w.weapon_name)::text)))
  ORDER BY pc.u_id, pc.character_name;
 %   DROP VIEW public.view_character_def;
       public          postgres    false    220    219    221    221    217    221    220    220    221    217    219            �            1259    18868    view_character_expected_atk    VIEW     �  CREATE VIEW public.view_character_expected_atk AS
 SELECT vca.character_name,
    vca.u_id,
    ((((1)::double precision - c.c_crit_rate) * vca.character_atk) + (c.c_crit_rate * (vca.character_atk * (c.c_crit_damage + (1)::double precision)))) AS character_expected_atk
   FROM (public.view_character_atk vca
     JOIN public.characters c ON (((vca.character_name)::text = (c.character_name)::text)))
  ORDER BY vca.u_id, vca.character_name;
 .   DROP VIEW public.view_character_expected_atk;
       public          postgres    false    220    225    225    220    225    220            �            1259    18872    view_character_highest_atk    VIEW     d  CREATE VIEW public.view_character_highest_atk AS
 SELECT vca.character_name,
    vca.u_id,
    (vca.character_atk * (c.c_crit_damage + (1)::double precision)) AS character_highest_atk
   FROM (public.view_character_atk vca
     JOIN public.characters c ON (((vca.character_name)::text = (c.character_name)::text)))
  ORDER BY vca.u_id, vca.character_name;
 -   DROP VIEW public.view_character_highest_atk;
       public          postgres    false    225    225    225    220    220            �            1259    18813    view_character_hp    VIEW     E  CREATE VIEW public.view_character_hp AS
 SELECT pc.u_id,
    pc.character_name,
    (((((pc.character_level - 1) * e.hp_bonus) + c.c_hp))::double precision * ((1)::double precision + COALESCE(w.w_hp, (0)::double precision))) AS character_hp
   FROM (((public.player_characters pc
     JOIN public.characters c ON (((pc.character_name)::text = (c.character_name)::text)))
     JOIN public.elements e ON (((c.element)::text = (e.element_type)::text)))
     LEFT JOIN public.weapons w ON (((pc.character_weapon)::text = (w.weapon_name)::text)))
  ORDER BY pc.u_id, pc.character_name;
 $   DROP VIEW public.view_character_hp;
       public          postgres    false    221    217    217    219    219    220    220    220    221    221    221            �            1259    19008    view_character_owner_rate    VIEW     �  CREATE VIEW public.view_character_owner_rate AS
 SELECT c.character_name,
    COALESCE(character_amount.ownership_count, (0)::bigint) AS ownership_count,
    player_amount.total_player_count,
    (((COALESCE(character_amount.ownership_count, (0)::bigint))::double precision / (player_amount.total_player_count)::double precision) * (100)::double precision) AS ownership_rate
   FROM (public.characters c
     LEFT JOIN ( SELECT pc.character_name,
            count(DISTINCT pc.u_id) AS ownership_count
           FROM public.player_characters pc
          GROUP BY pc.character_name) character_amount ON (((c.character_name)::text = (character_amount.character_name)::text))),
    ( SELECT count(DISTINCT players.u_id) AS total_player_count
           FROM public.players) player_amount
  ORDER BY (((COALESCE(character_amount.ownership_count, (0)::bigint))::double precision / (player_amount.total_player_count)::double precision) * (100)::double precision) DESC, c.character_name;
 ,   DROP VIEW public.view_character_owner_rate;
       public          postgres    false    221    220    216    221            �            1259    19070    view_character_usage_counts    VIEW     �  CREATE VIEW public.view_character_usage_counts AS
 SELECT character_name,
    count(*) AS usage_count
   FROM ( SELECT team.member1 AS character_name
           FROM public.team
        UNION ALL
         SELECT team.member2 AS character_name
           FROM public.team
        UNION ALL
         SELECT team.member3 AS character_name
           FROM public.team
        UNION ALL
         SELECT team.member4 AS character_name
           FROM public.team
        UNION ALL
         SELECT team_backup.member1 AS character_name
           FROM public.team_backup
        UNION ALL
         SELECT team_backup.member2 AS character_name
           FROM public.team_backup
        UNION ALL
         SELECT team_backup.member3 AS character_name
           FROM public.team_backup
        UNION ALL
         SELECT team_backup.member4 AS character_name
           FROM public.team_backup) all_characters
  WHERE (character_name IS NOT NULL)
  GROUP BY character_name;
 .   DROP VIEW public.view_character_usage_counts;
       public          postgres    false    223    223    228    228    223    223    228    228            �            1259    19035     view_most_used_character_by_user    VIEW     �  CREATE VIEW public.view_most_used_character_by_user AS
 WITH combined_teams AS (
         SELECT team_backup.u_id,
            team_backup.member1 AS character_name
           FROM public.team_backup
          WHERE (team_backup.member1 IS NOT NULL)
        UNION ALL
         SELECT team_backup.u_id,
            team_backup.member2 AS character_name
           FROM public.team_backup
          WHERE (team_backup.member2 IS NOT NULL)
        UNION ALL
         SELECT team_backup.u_id,
            team_backup.member3 AS character_name
           FROM public.team_backup
          WHERE (team_backup.member3 IS NOT NULL)
        UNION ALL
         SELECT team_backup.u_id,
            team_backup.member4 AS character_name
           FROM public.team_backup
          WHERE (team_backup.member4 IS NOT NULL)
        UNION ALL
         SELECT team.u_id,
            team.member1 AS character_name
           FROM public.team
          WHERE (team.member1 IS NOT NULL)
        UNION ALL
         SELECT team.u_id,
            team.member2 AS character_name
           FROM public.team
          WHERE (team.member2 IS NOT NULL)
        UNION ALL
         SELECT team.u_id,
            team.member3 AS character_name
           FROM public.team
          WHERE (team.member3 IS NOT NULL)
        UNION ALL
         SELECT team.u_id,
            team.member4 AS character_name
           FROM public.team
          WHERE (team.member4 IS NOT NULL)
        ), character_usage_by_user AS (
         SELECT combined_teams.u_id,
            combined_teams.character_name,
            count(*) AS usage_count
           FROM combined_teams
          WHERE (combined_teams.character_name IS NOT NULL)
          GROUP BY combined_teams.u_id, combined_teams.character_name
        )
 SELECT u_id,
    character_name,
    usage_count
   FROM ( SELECT character_usage_by_user.u_id,
            character_usage_by_user.character_name,
            character_usage_by_user.usage_count,
            row_number() OVER (PARTITION BY character_usage_by_user.u_id ORDER BY character_usage_by_user.usage_count DESC) AS rn
           FROM character_usage_by_user) ranked_usage
  WHERE (rn = 1)
  ORDER BY u_id, usage_count DESC;
 3   DROP VIEW public.view_most_used_character_by_user;
       public          postgres    false    228    228    228    228    223    223    223    223    223    228            �            1259    19075    view_player_team_counts    VIEW     �  CREATE VIEW public.view_player_team_counts AS
 SELECT character_name,
    count(DISTINCT u_id) AS player_count,
    sum(team_count) AS total_teams
   FROM ( SELECT all_characters.u_id,
            all_characters.character_name,
            count(*) AS team_count
           FROM ( SELECT team.u_id,
                    team.member1 AS character_name
                   FROM public.team
                UNION ALL
                 SELECT team.u_id,
                    team.member2 AS character_name
                   FROM public.team
                UNION ALL
                 SELECT team.u_id,
                    team.member3 AS character_name
                   FROM public.team
                UNION ALL
                 SELECT team.u_id,
                    team.member4 AS character_name
                   FROM public.team
                UNION ALL
                 SELECT team_backup.u_id,
                    team_backup.member1 AS character_name
                   FROM public.team_backup
                UNION ALL
                 SELECT team_backup.u_id,
                    team_backup.member2 AS character_name
                   FROM public.team_backup
                UNION ALL
                 SELECT team_backup.u_id,
                    team_backup.member3 AS character_name
                   FROM public.team_backup
                UNION ALL
                 SELECT team_backup.u_id,
                    team_backup.member4 AS character_name
                   FROM public.team_backup) all_characters
          WHERE (all_characters.character_name IS NOT NULL)
          GROUP BY all_characters.u_id, all_characters.character_name) pc
  GROUP BY character_name;
 *   DROP VIEW public.view_player_team_counts;
       public          postgres    false    223    223    223    223    223    228    228    228    228    228            �            1259    19080    view_show_player_character_data    VIEW       CREATE VIEW public.view_show_player_character_data AS
 SELECT v_hp.u_id,
    v_hp.character_name,
    pc.character_weapon,
    pc.character_level,
    v_hp.character_hp,
    v_def.character_def,
    v_atk.character_atk,
    v_highest_atk.character_highest_atk,
    v_expected_atk.character_expected_atk
   FROM (((((public.view_character_hp v_hp
     JOIN public.view_character_def v_def USING (u_id, character_name))
     JOIN public.view_character_atk v_atk USING (u_id, character_name))
     JOIN public.view_character_highest_atk v_highest_atk USING (u_id, character_name))
     JOIN public.view_character_expected_atk v_expected_atk USING (u_id, character_name))
     JOIN public.player_characters pc ON (((v_hp.u_id = pc.u_id) AND ((v_hp.character_name)::text = (pc.character_name)::text))));
 2   DROP VIEW public.view_show_player_character_data;
       public          postgres    false    221    230    230    229    230    229    229    226    226    226    225    225    225    221    221    221    224    224    224            �            1259    19044    view_team_damage_summary    VIEW     �  CREATE VIEW public.view_team_damage_summary AS
 SELECT team_id,
    u_id,
    team_name,
    member1,
    member2,
    member3,
    member4,
    COALESCE(( SELECT sum(vce.character_expected_atk) AS sum
           FROM public.view_character_expected_atk vce
          WHERE ((vce.u_id = t.u_id) AND ((vce.character_name)::text = ANY (ARRAY[(t.member1)::text, (t.member2)::text, (t.member3)::text, (t.member4)::text])))), (0)::double precision) AS expected_damage,
    COALESCE(( SELECT sum(vch.character_highest_atk) AS sum
           FROM public.view_character_highest_atk vch
          WHERE ((vch.u_id = t.u_id) AND ((vch.character_name)::text = ANY (ARRAY[(t.member1)::text, (t.member2)::text, (t.member3)::text, (t.member4)::text])))), (0)::double precision) AS highest_damage,
    COALESCE(( SELECT sum(vca.character_atk) AS sum
           FROM public.view_character_atk vca
          WHERE ((vca.u_id = t.u_id) AND ((vca.character_name)::text = ANY (ARRAY[(t.member1)::text, (t.member2)::text, (t.member3)::text, (t.member4)::text])))), (0)::double precision) AS total_damage
   FROM public.team t
  GROUP BY u_id, team_id, team_name, member1, member2, member3, member4
  ORDER BY u_id, team_id;
 +   DROP VIEW public.view_team_damage_summary;
       public          postgres    false    223    223    223    223    223    225    225    225    229    229    229    230    230    230    223    223            �           2604    18681    players u_id    DEFAULT     l   ALTER TABLE ONLY public.players ALTER COLUMN u_id SET DEFAULT nextval('public.players_u_id_seq'::regclass);
 ;   ALTER TABLE public.players ALTER COLUMN u_id DROP DEFAULT;
       public          postgres    false    216    215    216            �           2604    18765    team team_id    DEFAULT     l   ALTER TABLE ONLY public.team ALTER COLUMN team_id SET DEFAULT nextval('public.team_team_id_seq'::regclass);
 ;   ALTER TABLE public.team ALTER COLUMN team_id DROP DEFAULT;
       public          postgres    false    222    223    223            �           2604    18860    team_backup team_id    DEFAULT     z   ALTER TABLE ONLY public.team_backup ALTER COLUMN team_id SET DEFAULT nextval('public.team_backup_team_id_seq'::regclass);
 B   ALTER TABLE public.team_backup ALTER COLUMN team_id DROP DEFAULT;
       public          postgres    false    227    228    228            �          0    18718 
   characters 
   TABLE DATA           z   COPY public.characters (character_name, element, weapon_type, c_hp, c_atk, c_def, c_crit_damage, c_crit_rate) FROM stdin;
    public          postgres    false    220   *�       �          0    18687    elements 
   TABLE DATA           P   COPY public.elements (element_type, hp_bonus, atk_bonus, def_bonus) FROM stdin;
    public          postgres    false    217   ��       �          0    18738    player_characters 
   TABLE DATA           d   COPY public.player_characters (u_id, character_name, character_level, character_weapon) FROM stdin;
    public          postgres    false    221   $�       �          0    18678    players 
   TABLE DATA           C   COPY public.players (u_id, player_name, players_level) FROM stdin;
    public          postgres    false    216   5�       �          0    18762    team 
   TABLE DATA           i   COPY public.team (team_id, u_id, create_time, team_name, member1, member2, member3, member4) FROM stdin;
    public          postgres    false    223   ��       �          0    18857    team_backup 
   TABLE DATA           �   COPY public.team_backup (team_id, u_id, create_time, backup_time, team_name, member1, member2, member3, member4, expected_damage, highest_damage, lowest_damage, weapon1, weapon2, weapon3, weapon4) FROM stdin;
    public          postgres    false    228   �       �          0    18696    weapon_types 
   TABLE DATA           C   COPY public.weapon_types (weapon_type_name, atk_bonus) FROM stdin;
    public          postgres    false    218   C�       �          0    18702    weapons 
   TABLE DATA           u   COPY public.weapons (weapon_name, weapon_type, base_atk, w_hp, w_atk, w_def, w_crit_damage, w_crit_rate) FROM stdin;
    public          postgres    false    219   ��       �           0    0    players_u_id_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.players_u_id_seq', 100009, true);
          public          postgres    false    215            �           0    0    team_backup_team_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.team_backup_team_id_seq', 22, true);
          public          postgres    false    227            �           0    0    team_team_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.team_team_id_seq', 121, true);
          public          postgres    false    222            �           2606    18727    characters characters_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (character_name);
 D   ALTER TABLE ONLY public.characters DROP CONSTRAINT characters_pkey;
       public            postgres    false    220            �           2606    18694    elements elements_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.elements
    ADD CONSTRAINT elements_pkey PRIMARY KEY (element_type);
 @   ALTER TABLE ONLY public.elements DROP CONSTRAINT elements_pkey;
       public            postgres    false    217            �           2606    18745 (   player_characters player_characters_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.player_characters
    ADD CONSTRAINT player_characters_pkey PRIMARY KEY (u_id, character_name);
 R   ALTER TABLE ONLY public.player_characters DROP CONSTRAINT player_characters_pkey;
       public            postgres    false    221    221            �           2606    18685    players players_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (u_id);
 >   ALTER TABLE ONLY public.players DROP CONSTRAINT players_pkey;
       public            postgres    false    216            �           2606    18867    team_backup team_backup_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.team_backup
    ADD CONSTRAINT team_backup_pkey PRIMARY KEY (team_id);
 F   ALTER TABLE ONLY public.team_backup DROP CONSTRAINT team_backup_pkey;
       public            postgres    false    228            �           2606    18773    team team_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (u_id, team_id);
 8   ALTER TABLE ONLY public.team DROP CONSTRAINT team_pkey;
       public            postgres    false    223    223            �           2606    18701    weapon_types weapon_types_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.weapon_types
    ADD CONSTRAINT weapon_types_pkey PRIMARY KEY (weapon_type_name);
 H   ALTER TABLE ONLY public.weapon_types DROP CONSTRAINT weapon_types_pkey;
       public            postgres    false    218            �           2606    18712    weapons weapons_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.weapons
    ADD CONSTRAINT weapons_pkey PRIMARY KEY (weapon_name);
 >   ALTER TABLE ONLY public.weapons DROP CONSTRAINT weapons_pkey;
       public            postgres    false    219            �           2620    18982    team before_insert_team    TRIGGER     �   CREATE TRIGGER before_insert_team BEFORE INSERT ON public.team FOR EACH ROW EXECUTE FUNCTION public.check_team_members_exist();
 0   DROP TRIGGER before_insert_team ON public.team;
       public          postgres    false    223    248            �           2620    18971 *   player_characters character_insert_trigger    TRIGGER     �   CREATE TRIGGER character_insert_trigger BEFORE INSERT ON public.player_characters FOR EACH ROW EXECUTE FUNCTION public.check_character_insert();
 C   DROP TRIGGER character_insert_trigger ON public.player_characters;
       public          postgres    false    254    221            �           2620    18931 *   player_characters character_update_trigger    TRIGGER     �   CREATE TRIGGER character_update_trigger BEFORE UPDATE ON public.player_characters FOR EACH ROW EXECUTE FUNCTION public.check_character_update();
 C   DROP TRIGGER character_update_trigger ON public.player_characters;
       public          postgres    false    221    250            �           2620    18977    players player_insert_trigger    TRIGGER     �   CREATE TRIGGER player_insert_trigger BEFORE INSERT ON public.players FOR EACH ROW EXECUTE FUNCTION public.check_player_insert();
 6   DROP TRIGGER player_insert_trigger ON public.players;
       public          postgres    false    249    216            �           2620    18975    players player_update_trigger    TRIGGER     �   CREATE TRIGGER player_update_trigger BEFORE UPDATE ON public.players FOR EACH ROW EXECUTE FUNCTION public.check_player_update();
 6   DROP TRIGGER player_update_trigger ON public.players;
       public          postgres    false    216    252            �           2620    18844 "   team trigger_handle_team_insertion    TRIGGER     �   CREATE TRIGGER trigger_handle_team_insertion BEFORE INSERT ON public.team FOR EACH ROW EXECUTE FUNCTION public.handle_team_insertion();
 ;   DROP TRIGGER trigger_handle_team_insertion ON public.team;
       public          postgres    false    223    255            �           2606    18881 "   characters characters_element_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_element_fkey FOREIGN KEY (element) REFERENCES public.elements(element_type) ON UPDATE CASCADE;
 L   ALTER TABLE ONLY public.characters DROP CONSTRAINT characters_element_fkey;
       public          postgres    false    220    217    4811            �           2606    18733 &   characters characters_weapon_type_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_weapon_type_fkey FOREIGN KEY (weapon_type) REFERENCES public.weapon_types(weapon_type_name);
 P   ALTER TABLE ONLY public.characters DROP CONSTRAINT characters_weapon_type_fkey;
       public          postgres    false    220    218    4813            �           2606    18751 7   player_characters player_characters_character_name_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.player_characters
    ADD CONSTRAINT player_characters_character_name_fkey FOREIGN KEY (character_name) REFERENCES public.characters(character_name) ON DELETE CASCADE;
 a   ALTER TABLE ONLY public.player_characters DROP CONSTRAINT player_characters_character_name_fkey;
       public          postgres    false    221    220    4817            �           2606    18756 9   player_characters player_characters_character_weapon_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.player_characters
    ADD CONSTRAINT player_characters_character_weapon_fkey FOREIGN KEY (character_weapon) REFERENCES public.weapons(weapon_name) ON DELETE SET NULL;
 c   ALTER TABLE ONLY public.player_characters DROP CONSTRAINT player_characters_character_weapon_fkey;
       public          postgres    false    4815    221    219            �           2606    18746 -   player_characters player_characters_u_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.player_characters
    ADD CONSTRAINT player_characters_u_id_fkey FOREIGN KEY (u_id) REFERENCES public.players(u_id);
 W   ALTER TABLE ONLY public.player_characters DROP CONSTRAINT player_characters_u_id_fkey;
       public          postgres    false    4809    216    221            �           2606    18774    team team_u_id_fkey    FK CONSTRAINT     s   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_u_id_fkey FOREIGN KEY (u_id) REFERENCES public.players(u_id);
 =   ALTER TABLE ONLY public.team DROP CONSTRAINT team_u_id_fkey;
       public          postgres    false    4809    216    223            �           2606    18905    team team_u_id_member1_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_u_id_member1_fkey FOREIGN KEY (u_id, member1) REFERENCES public.player_characters(u_id, character_name) ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.team DROP CONSTRAINT team_u_id_member1_fkey;
       public          postgres    false    223    221    221    4819    223            �           2606    18910    team team_u_id_member2_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_u_id_member2_fkey FOREIGN KEY (u_id, member2) REFERENCES public.player_characters(u_id, character_name) ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.team DROP CONSTRAINT team_u_id_member2_fkey;
       public          postgres    false    223    4819    221    221    223            �           2606    18915    team team_u_id_member3_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_u_id_member3_fkey FOREIGN KEY (u_id, member3) REFERENCES public.player_characters(u_id, character_name) ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.team DROP CONSTRAINT team_u_id_member3_fkey;
       public          postgres    false    221    221    4819    223    223            �           2606    18920    team team_u_id_member4_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_u_id_member4_fkey FOREIGN KEY (u_id, member4) REFERENCES public.player_characters(u_id, character_name) ON DELETE CASCADE;
 E   ALTER TABLE ONLY public.team DROP CONSTRAINT team_u_id_member4_fkey;
       public          postgres    false    4819    221    221    223    223            �           2606    18893     weapons weapons_weapon_type_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.weapons
    ADD CONSTRAINT weapons_weapon_type_fkey FOREIGN KEY (weapon_type) REFERENCES public.weapon_types(weapon_type_name) ON UPDATE CASCADE;
 J   ALTER TABLE ONLY public.weapons DROP CONSTRAINT weapons_weapon_type_fkey;
       public          postgres    false    4813    218    219            �   �  x�}VMkG=�~��3=;�Gi��ʂxEl�\Z����f��hG0���	>���CH0I���m���ni�zF� !��WU�^U������ͯl�竛7�Xq',)X� ��x�Ԩ������˘�)E<lG'�X��W6?~���g��1�`�G�;��7���|���Pq�2�a��H`q�����:-�m^EZؼ���ݦ��y��}�EH��,��ՙlH�c�K���'�Y�!S�e���+&�WRQU�"a��'��������q�"��)�	��h��&��Vz9L�䱭$ۂ'��jd{)��%c��ơXmy}i�j����F�y���I�)щh��t0�uaLśAF��hj��J�#А�u
�]���v��QA�}���T֠�6U�:���Xզ���"�q��m�n+��҉�x:�^���fˠ�$(t�[�'�3ф"B�������P��
HM��N�^��9�CP�#	�|��]PfWR�>�z���4�4�s��v�b�/���9�����8�%�B)���D��D�vi$�t�� k�@�Y;o��2�`��:yV�s��ң�R]�(eiu!��D�d8J;��Ѵ�"L.��e�����A�V�
9z��A�<]nk����[�P6l\Js{"�B�Ѭ2K���������f,s{�R:��s��ANǁ��W���n�\��M�b��;
���MۯM;����q�`�wO�v�Gv�Q"\{�@�g�@�q��CB�F8o[�%�L](v��=�*�d�;�I[
��J�f��sǅ�!KFOˬ����'l$����;�E/?��ͮ��i�̺��5�]o�2��`�`ʻ>a�gV�̞�K�(q_�c�b�}��l��"8�jYi`c��|� �}e�E����$�[WB�+�r<���R5����ZJ�������$)\�9��T�6'��V��+Y9��ä2z��0�R�����4�EM�I`ӈ��I!4�r=0/��J|1��_�r���74�c���!]��Z�d��KO=<`�J�6�m�Z�d��g��*"Ǫ���L.�7�(vA<u���"��I�pM�lEiWqN�
F�[�q���b=�žl�d���P��zh�w6��Ȥ����=Rz���r-��;;;��c 6      �   Q   x�{޸��Ȉ�И�Ѐ�ن-�F����@��r�
N#NC#�����aʌ�^�v�9 ���m��1�c��t�J�2C�=... ?�      �     x��V�R�F�^��OБd�Kڤ1a�!�����#�b�\�/�m\��!4�`����2�Jz���^َ֩�<������wV�O��� ��c���q�n��}"��`�I�Sp�����T/�� �P��#`��ve�*V��.���_Ԓ�F��ޚ�<��k���Sh&��`NBb�������u��`�ڦʄ��8D���������L#��K�M��Mյh����+��n�E�I0�x��S�=x~bg�	�+k��%T8�˵@�L���y;�jo������cz"�����-q����Kf��Bk�&$zN��#�~��h�`���sy�?�q��&Z�0����7nߚ�e{�����Ƨf�j;��RW��~�޺#ǭ�M�GP�t�;$0�b��-��E���:�2Ϗ�ږu�w�(�a�MgN��M�-�HD�FZ�8��)Ԭ�q�3����^B4�h�QU�����+�dY� ^��>�hN���Z�*C̝�L����J��w8�)�R���}�u���h��E��|0S��U�靄�ט�SRR�"v�#��%|���	�	8�p�"�Q�EuM�5D�I�WABe6�3�.<j��1dHQI�y��z�pAjn=�z���کU
}�P�2��S�pʻN��>��� �@��K}��6X�g_Ge1�Ѝ�h����a�����"3�J��Թ��D8��42�bc��/h������}�:�'zĨ�� ���.?����/ό�+R����h��NBH�>��$���~N�A�0R� �aN���	wf�D�,ą{�K�)>�5<�.0�ŘE�Xk"�KEh��:�yJR��j����i�19@��ϳؖ{>㔨j8�3�MH�n��A}��u|�U��)�������#�;�dΐ������\)X-�����]�a����v��˭��T)��'=M:Є��[Ο�u���f��FU4	5i�g
�s�w��D'�܁U8`f��t�ϳ�e!��t��~N�Q� (pU�B�%, \�o�,� �n]���CO/tBZB���^M������F�\�b�_�dp�
+����`�3��&c}�v9���y�j�y���G�f�I<���M%+N�o�'A�Z��q���p��Hli�Ώa�e#)���~2����swʭ�#�ǌ��[��~J	ML�D.ܹhCm�#C�+�� ,���෯��^��'��EQ��K˭�����f��y������߸J�K����)˨%`�������1S=      �   y   x�34 #N�ļ�Ԝ��<N#.C��	gqviN�BP&��"h�钙���p����i��9� b��YYY�yy����sN�̤�DNSߘ���@�|�}���PaK��=... ct-'      �   N  x����j�@�ף��d�w�gv�Y�%�6���ԙX"�����u-�@�*��B��M�6�-:�帉�Z3`[�|:su�$��	&@�M��Z��)��~�|���G2��|��U������B����E���qUV���鰺�?����1��R	�JC���rT��prW��I�a��#FE�`�m0H�E�0/#r�U��Y���ZX���n��N U�׍���ne���)Mʘ��1A��U��d~ZT�yX�^gU9.�Ķ^佁Z���F�n�r7���ڌ��R��e/22����i59}�G��=
�`����[\�}�F�)��()���!FJ��>�+]�C���ɣVq�;<>Ϻ���Łr�����y>�=ƕYk��x���j'e�[f�'�0d���m���6e0�Jp��,��&O�/�+_��|S�m�m/�*%X��̧͊M��zQ���/��ϫ���y@l7��$R c�x<�aR:���J�Շ�?o�W߮VW?����7_6{��y9�[�j_��V��ؽS�;����q�V�����g~�ԭ�[���{�h��A�,ob��پ�A�M�b���$I~�̤s      �     x���[oGǟǟ�_�ќ�3�}��-���VBBl�UboH��
���Y�&�R����B �Lv��=k�sq)RF#kǣ��;g���L
��9'lU� | �K�4��[`�7R
eٕ(�Kv��RK�a�@l9{���)ϕ� ����J(H��;�L����(b_�S�7"z2�@2�@8bY�,�#�W��@{.ho�|  ��ށ�=��.%��T���z|+��T�υ�}�������ch�ɲ����jg�S{����'wYg�Y�0O��Ͽ���%���P��k�Ee�ac"i$�x.��%����kQ�6J7@[��5��$h��}�7�T)��$Gҵ���qv~i�v�I��H������k�sB��	Hϝ�B��a|3jT�k��l�}7&�������t�����s����,re,ko�g�E|w�f������b��Szy1{~7�]�7v�*ndb���D�/�/$٘}FՋ�dRjCZ����P��^�9��􅼹������}��|�Y����Y��$
W�T8:|�� �J.���G��
���a�8��G��p���"��5h�↜�R�|�q%�oe��|��ti0o˄�*��
�%(�ڒ�����Ϋ��N����>�'���� �X��"�JJ�uZ�W�8)��!���C��C��S�9�IB�����w�pK�B��g����lg#[���DU@�H��c���^L!�P����_�����ʶ��H�\K����˭��K��r�`1z�b�����}L���_�_|���}Xs�')J##�W��QJ1�n��f����������!N�^3c����<p�v8'*JJ�����tT��7�j���@k�0�h*���pv�R��� �)�m�wΞ!h��x�|��%p!�s�O�h�zu�d.L�a�c����&�8�dH7� �����,k��nn�ml�t���#cj]\��r��05���
g␝�_�f�-��X���Eq�R�^��X&�U^�T���#�      �   ;   x�{:mݳ��]��f\/gτ�͹��������gk�=��(�l�TÂ+F��� �q      �   �  x���[V�@�����n�^f1����4�I QA D��f���]L7hHp<�;U���w!���_�i�/%��C&�nsR<t.������_
ɠ��hp�^�=p�X}%�Lc}�'e����D"���4�b��'0`4�ʤ4Cy�ܼ��6y)��^l���l���ר���ȞE�mt�;��NPj�Q$��z�U����J<��W&�)fH�� I9?�Ucp0msI��8��$Ѣ���Ggg�O
�q�5���B� $�"���D➡P]��ZK�=)�g�uN�p�l��T�-^�}�i �ؤ]����:�WE����/����E�T�����l�pX��˙�f� ��Z�1T�⏯â�CO�\�v�"(�ZY��h<@����iP�]#�p�?n���L�-���ǀ����z���1�}J`�F�*�������'�<"�[�>�`���靀|��.��h
�B���C�ˏ�y�xs���A�jG�~h:�e�*;�����*ȰG�)/�>V���:6鄡4F��b������3a��r���O#ޤ�0�mB����Q��>s�}�Z�|��:P����S���^;�%�j��p+MR���^4r��6�yGvã��(������-�;���5���1n�Iaλ�󧕐�+S�9�,��7'���@l4q��w�:�ј�j�<��_�,�� �C[     