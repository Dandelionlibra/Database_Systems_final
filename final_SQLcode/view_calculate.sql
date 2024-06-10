CREATE VIEW view_character_hp AS
	SELECT pc.u_id,
	  pc.character_name,
      ((pc.character_level - 1) * e.hp_bonus + c.c_hp) * (1 + COALESCE(w.w_hp, 0)) AS character_hp
	FROM player_characters pc
	  JOIN characters c ON pc.character_name = c.character_name
	  JOIN elements e ON c.element = e.element_type
	  LEFT JOIN weapons w ON pc.character_weapon = w.weapon_name;



CREATE VIEW view_character_atk AS
	SELECT pc.u_id, pc.character_name,
      ((pc.character_level - 1) * (e.atk_bonus + COALESCE(w.base_atk, 0)) + c.c_atk ) * (1 + COALESCE(w.w_atk, 0)) AS character_atk
	FROM  player_characters pc
	  JOIN characters c ON pc.character_name = c.character_name
	  JOIN elements e ON c.element = e.element_type
	  LEFT JOIN weapons w ON pc.character_weapon = w.weapon_name;



CREATE VIEW view_character_def AS
	SELECT pc.u_id, pc.character_name,
      ((pc.character_level - 1) * e.def_bonus + c.c_def ) * (1 + COALESCE(w.w_def, 0)) AS character_def
	FROM player_characters pc
	  JOIN characters c ON pc.character_name = c.character_name
	  JOIN elements e ON c.element = e.element_type
	  LEFT JOIN weapons w ON pc.character_weapon = w.weapon_name;



CREATE VIEW view_character_highest_atk AS
	SELECT vca.character_name, vca.u_id,
      vca.character_atk * (c.c_crit_damage + 1) AS character_highest_atk
    FROM view_character_atk vca
      JOIN characters c ON vca.character_name = c.character_name;



CREATE VIEW view_character_expected_atk AS
	SELECT vca.character_name, vca.u_id,
      (1 - c.c_crit_rate) * vca.character_atk + c.c_crit_rate * (vca.character_atk * (c.c_crit_damage + 1)) AS character_expected_atk
	FROM view_character_atk vca
	  JOIN characters c ON vca.character_name = c.character_name;



CREATE VIEW view_show_player_character_data AS
	SELECT v_hp.u_id,
      v_hp.character_name,
      pc.character_level,
      v_hp.character_hp,
      v_def.character_def,
      v_atk.character_atk,
      v_highest_atk.character_highest_atk,
      v_expected_atk.character_expected_atk
    FROM view_character_hp v_hp
      JOIN view_character_def v_def USING (u_id, character_name)
      JOIN view_character_atk v_atk USING (u_id, character_name)
      JOIN view_character_highest_atk v_highest_atk USING (u_id, character_name)
      JOIN view_character_expected_atk v_expected_atk USING (u_id, character_name)
      JOIN player_characters pc ON v_hp.u_id = pc.u_id AND v_hp.character_name::text = pc.character_name::text;
