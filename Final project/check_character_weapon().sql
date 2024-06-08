/* 建立或更新player_characters 的character_weapon時檢查對應到的
   characters表格中的weapon_type是否等於要裝備的武器的weapon_type，
   若不等於則回報錯誤訊息，並不可新增或不可更新  */
CREATE OR REPLACE FUNCTION check_character_weapon()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.character_weapon IS NOT NULL THEN
        IF (SELECT weapon_type FROM characters WHERE character_name = NEW.character_name) != 
            (SELECT weapon_type FROM weapons WHERE weapon_name = NEW.character_weapon) THEN
            RAISE EXCEPTION 'The weapon type does not match the character''s weapon type';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER character_weapon_check_trigger
BEFORE INSERT OR UPDATE ON player_characters
FOR EACH ROW
EXECUTE FUNCTION check_character_weapon();