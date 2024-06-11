CREATE OR REPLACE VIEW view_show_player_character_data AS
 SELECT v_hp.u_id,
    v_hp.character_name,
    pc.character_weapon,
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