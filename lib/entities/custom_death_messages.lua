
--grab all the strings we intend to change are stored. for the reset_strings function to work, they should be ordered like this:
--[[
    hash_to_stringid
    original string
]]
-- BASIC GUIDE ON HOW TO IMPLEMENT CUSTOM DEATH MESSAGES FOR FUTURE ENTITIES:
--[[
    1: Make sure your custom entity has a user_data table that contains a value called "ent_type",
    2: This value should contain an HD_ENT_TYPE value, you can add to this in the file "hdentnew.lua"
    3: Find the hash for your base entities death messages. So if our custom entity was based on MONS_SNAKE, we would need that one
    4: Add them to this local table "strings", following the semantic laid out already.
    5: Do the same for the local table "I". Your new values should increment the same way the others are.
    6: Now that you've added all the necessary data for the sysytem, it's time to do add the if statement
    7: You need to check for your HD_ENT_TYPE, then follow the already existing semantic for changing the strings.
]]
local strings = {
    --GENERIC DEATH TITLE
    hash_to_stringid(0xfa9ebccc);
    get_string(hash_to_stringid(0xfa9ebccc));
    --GENERIC DEATH TEXT
    hash_to_stringid(0x6bcb5e95);
    get_string(hash_to_stringid(0x6bcb5e95));
    --TIKIMAN TITLE
    hash_to_stringid(0x61923355);
    get_string(hash_to_stringid(0x61923355));
    --TIKIMAN TEXT
    hash_to_stringid(0x7331200d);
    get_string(hash_to_stringid(0x7331200d));
    --ALIEN TITLE
    hash_to_stringid(0xa7543b0f);
    get_string(hash_to_stringid(0xa7543b0f));
    --ALIEN TEXT
    hash_to_stringid(0x970a96f8);
    get_string(hash_to_stringid(0x970a96f8));
    --CAVEMAN TITLE
    hash_to_stringid(0xfd1efff3);
    get_string(hash_to_stringid(0xfd1efff3));
    --CAVEMAN TEXT
    hash_to_stringid(0x43784d32);
    get_string(hash_to_stringid(0x43784d32));
    --MANTRAP TITLE
    hash_to_stringid(0x8383d140);
    get_string(hash_to_stringid(0x8383d140));
    --MANTRAP TEXT
    hash_to_stringid(0x446f1b7b);
    get_string(hash_to_stringid(0x446f1b7b));
    --FROG TITLE
    hash_to_stringid(0x5cbca2b7);
    get_string(hash_to_stringid(0x5cbca2b7));
    --FROG TEXT
    hash_to_stringid(0xb709a2e8);
    get_string(hash_to_stringid(0xb709a2e8));
    --QUILLBACK TEXT
    hash_to_stringid(0x7e625cc9);
    get_string(hash_to_stringid(0x7e625cc9));
    --QUILLBACK TITLE
    hash_to_stringid(0x38db11f3);
    get_string(hash_to_stringid(0x38db11f3));
    --TADPOLE TEXT
    hash_to_stringid(0x56121958);
    get_string(hash_to_stringid(0x56121958));
    --TADPOLE TITLE
    hash_to_stringid(0x4ad038b6);
    get_string(hash_to_stringid(0x4ad038b6));
    --LAMASSU TITLE
    hash_to_stringid(0xce9f5a04);
    get_string(hash_to_stringid(0xce9f5a04));
    --LAMASSU TEXT
    hash_to_stringid(0xa954e7a6);
    get_string(hash_to_stringid(0xa954e7a6));
    --ANUBIS TITLE
    hash_to_stringid(0xe640fd5c);
    get_string(hash_to_stringid(0xe640fd5c));
    --ANUBIS TEXT
    hash_to_stringid(0x2a8b3bd5);
    get_string(hash_to_stringid(0x2a8b3bd5));
}
local I = {
    GENERIC_DEATH_TITLE_ID = 1; 
    GENERIC_DEATH_TITLE_STRING = 2; 
    GENERIC_DEATH_TEXT_ID = 3; 
    GENERIC_DEATH_TEXT_STRING = 4;
    TIKIMAN_TITLE_ID = 5;
    TIKIMAN_TITLE_STRING = 6;
    TIKIMAN_TEXT_ID = 7;
    TIKIMAN_TEXT_STRING = 8;
    ALIEN_TITLE_ID = 9;
    ALIEN_TITLE_STRING = 10;
    ALIEN_TEXT_ID = 11;
    ALIEN_TEXT_STRING = 12;
    CAVEMAN_TITLE_ID = 13;
    CAVEMAN_TITLE_STRING = 14;
    CAVEMAN_TEXT_ID = 15;
    CAVEMAN_TEXT_STRING = 16;
    MANTRAP_TITLE_ID = 17;
    MANTRAP_TITLE_STRING = 18;
    MANTRAP_TEXT_ID = 19;
    MANTRAP_TEXT_STRING = 20;
    FROG_TITLE_ID = 21;
    FROG_TITLE_STRING = 22;
    FROG_TEXT_ID = 23;
    FROG_TEXT_STRING = 24;
    QUILLBACK_TITLE_ID = 25;
    QUILLBACK_TITLE_STRING = 26;
    QUILLBACK_TEXT_ID = 27;
    QUILLBACK_TEXT_STRING = 28;
    TADPOLE_TITLE_ID = 29;
    TADPOLE_TITLE_STRING = 30;
    TADPOLE_TEXT_ID = 31;
    TADPOLE_TEXT_STRING = 32;
    LAMASSU_TITLE_ID = 33;
    LAMASSU_TITLE_STRING = 34;
    LAMASSU_TEXT_ID = 35;
    LAMASSU_TEXT_STRING = 36;
    ANUBIS_TITLE_ID = 37;
    ANUBIS_TITLE_STRING = 38;
    ANUBIS_TEXT_ID = 39;
    ANUBIS_TEXT_STRING = 40;
}
local function reset_strings()
    for i=1, #strings do
        if math.fmod(i, 2) == 1 then --even numbered entries should be the strings which we are setting the previous entry to
            change_string(strings[i], strings[i+1])
        end
    end
end
local function update_custom_death_messages()
    players[1]:set_pre_kill(function(self, corpse_destroyed, responsible)
        if responsible == nil or self == nil then return false end
        if type(responsible.user_data) == "table" then
            local d = responsible.user_data
            if d.ent_type == HD_ENT_TYPE.MONS_BLACK_KNIGHT then
                change_string(strings[I.TIKIMAN_TITLE_ID], "DETHRONED")
                change_string(strings[I.TIKIMAN_TEXT_ID], "The dark fiend has decided your fate.")
            end
            if d.ent_type == HD_ENT_TYPE.MONS_GREEN_KNIGHT then
                change_string(strings[I.CAVEMAN_TITLE_ID], "FELLED")
                change_string(strings[I.CAVEMAN_TEXT_ID], "Art thou slain by thy verdant knight.")                
            end
            if d.ent_type == HD_ENT_TYPE.MONS_BABY_WORM then
                change_string(strings[I.ALIEN_TITLE_ID], "BITTEN")
                change_string(strings[I.ALIEN_TEXT_ID], "I hope I taste good atleast!")                
            end
            if d.ent_type == HD_ENT_TYPE.MONS_BACTERIUM then
                change_string(strings[I.MANTRAP_TITLE_ID], "INFECTED")
                change_string(strings[I.MANTRAP_TEXT_ID], "I should've kept some distance!")   
            end
            if d.ent_type == HD_ENT_TYPE.MONS_GIANT_FROG then
                change_string(strings[I.FROG_TITLE_ID], "CROAKED")
                change_string(strings[I.FROG_TEXT_ID], "I've been hopped till I dropped.")                   
            end
            if d.ent_type == HD_ENT_TYPE.MONS_HELL_MINIBOSS then
                change_string(strings[I.QUILLBACK_TITLE_ID], "CLOBBERED")
                change_string(strings[I.QUILLBACK_TEXT_ID], "I Got butchered by an ungulate.")                   
            end
            if d.ent_type == HD_ENT_TYPE.MONS_PIRANHA then
                change_string(strings[I.TADPOLE_TITLE_ID], "MUNCHED")
                change_string(strings[I.TADPOLE_TEXT_ID], "The snack that bit me back.")                   
            end
            if d.ent_type == HD_ENT_TYPE.MONS_MAMMOTH then
                change_string(strings[I.LAMASSU_TITLE_ID], "CRUSHED")
                change_string(strings[I.LAMASSU_TEXT_ID], "The no longer extinct mammoth used me as a welcome mat.")                   
            end
            if d.ent_type == HD_ENT_TYPE.MONS_ALIENLORD then
                change_string(strings[I.ANUBIS_TITLE_ID], "BRAIN WIPED")
                change_string(strings[I.ANUBIS_TEXT_ID], "The Queen's subjugates saw me as an experiment.")                   
            end
        end
        return false
    end)
end

set_callback(reset_strings, ON.LEVEL)
set_callback(update_custom_death_messages, ON.LEVEL)