create table 'CommiCleoExcludedTraits'(
    'TraitType' TEXT NOT NULL,
    'ModifierId' TEXT NOT NULL,
    PRIMARY KEY(TraitType, ModifierId)
    -- FOREIGN KEY(TraitType) REFERENCES Traits (TraitType) ON DELETE CASCADE ON UPDATE CASCADE
    -- FOREIGN KEY(ModifierId) REFERENCES Modifiers (ModifierId) ON DELETE CASCADE ON UPDATE CASCADE
);

insert or replace into CommiCleoExcludedTraits
    (TraitType,                                 ModifierId)
values
	('TRAIT_LEADER_NZINGA_MBANDE',				'TRAIT_FOREIGN_CONTINENT_YIELD'),
	('TRAIT_CIVILIZATION_GAUL',					'TRAIT_CIVILIZATION_GAUL_CITY_NO_ADJACENT_DISTRICT'),
    ('TRAIT_CIVILIZATION_MALI_GOLD_DESERT',     'TRAIT_LESS_BUILDING_PRODUCTION'),
    ('TRAIT_CIVILIZATION_MALI_GOLD_DESERT',     'TRAIT_LESS_UNIT_PRODUCTION'),
    ('TRAIT_CIVILIZATION_MAYAB',                'TRAIT_NO_FRESH_WATER_HOUSING'),
    ('TRAIT_LEADER_MUTAL',                      'TRAIT_LEADER_NEARBY_CITIES_LOSE_YIELDS'),
    ('TRAIT_CIVILIZATION_PORTUGAL',             'TRAIT_FORBID_INTERNATIONAL_LAND_ROUTES'),
    ('TRAIT_CIVILIZATION_BABYLON',              'TRAIT_SCIENCE_DECREASE'),
    ('TRAIT_CIVILIZATION_FACES_OF_PEACE',       'TRAIT_NO_SUPRISE_WAR_FOR_CANADA'),
    ('TRAIT_CIVILIZATION_VIETNAM',              'TRAIT_DISTRICTS_FOREST_ONLY'),
    ('TRAIT_CIVILIZATION_VIETNAM',              'TRAIT_DISTRICTS_MARSH_ONLY'),
    ('TRAIT_CIVILIZATION_VIETNAM',              'TRAIT_DISTRICTS_JUNGLE_ONLY'),
    ('TRAIT_CIVILIZATION_DISTRICT_THANH',       'DO_NOTHING'),
    ('TRAIT_CIVILIZATION_DISTRICT_OBSERVATORY', 'DO_NOTHING'),
    ('TRAIT_CIVILIZATION_DISTRICT_OPPIDUM',     'DO_NOTHING'),
    ('TRAIT_CIVILIZATION_BUILDING_PALGUM',      'DO_NOTHING'),
    ('TRAIT_LEADER_RELIGIOUS_CONVERT',          'DO_NOTHING'), -- NOTE: need add individual modifiers to avoid excluding Great Prophet.
    ('TRAIT_CIVILIZATION_MAORI_MANA',           'TRAIT_MAORI_PREVENT_HARVEST'), -- NOTE: need add individual modifiers to avoid excluding Great Writer.
    ('TRAIT_CIVILIZATION_BABYLON',              'TRAIT_EUREKA_INCREASE'), -- too strong to have.
    -- Debuff in MOD
    ('TRAIT_LEADER_HWARANG',                    'HWARANG_LOYALTY_DEBUFF'),
    ('TRAIT_LEADER_HWARANG',                    'HWARANG_AMENITY_DEBUFF'),
    ('TRAIT_LEADER_HWARANG',                    'HWARANG_ALLDEBUFF');

insert or replace into LeaderTraits
    (LeaderType,    TraitType)
select
    'LEADER_CLEOPATRA',   TraitType
from LeaderTraits where not 
    ((LeaderType = 'LEADER_CLEOPATRA') or (LeaderType = 'LEADER_BARBARIAN') or (LeaderType like 'LEADER_MINOR_%')
    or (TraitType in (select TraitType from Traits where InternalOnly = 1))
    or (TraitType in (select TraitType from CommiCleoExcludedTraits)));

-- insert or replace into CivilizationTraits
--     (CivilizationType,      TraitType)
-- select
--     'CIVILIZATION_CHINA',   TraitType
insert or replace into LeaderTraits
    (LeaderType,    TraitType)
select
    'LEADER_CLEOPATRA',   TraitType
from CivilizationTraits where not 
    ((CivilizationType = 'CIVILIZATION_EGYPT') or (CivilizationType = 'CIVILIZATION_BARBARIAN') or
        (TraitType in (select TraitType from CommiCleoExcludedTraits)));

insert or replace into TraitModifiers
    (TraitType,             ModifierId)
select
    'TRAIT_LEADER_MEDITERRANEAN',  ModifierId
from TraitModifiers 
where (TraitType in (select TraitType from CommiCleoExcludedTraits))
and not (ModifierId in (select ModifierId from CommiCleoExcludedTraits));

-- Special Cases
-- For Vietnam:
insert or ignore into TraitModifiers (TraitType,   ModifierId) 
    select 'TRAIT_LEADER_MEDITERRANEAN', 'TRAIT_JUNGLE_VALID_' || DistrictType from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
insert or ignore into TraitModifiers (TraitType,   ModifierId) 
    select 'TRAIT_LEADER_MEDITERRANEAN', 'TRAIT_MARSH_VALID_' || DistrictType from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
insert or ignore into TraitModifiers (TraitType,   ModifierId) 
    select 'TRAIT_LEADER_MEDITERRANEAN', 'TRAIT_FOREST_VALID_' || DistrictType from Districts where DistrictType != 'DISTRICT_CITY_CENTER';

insert or ignore into Modifiers    (ModifierId, ModifierType)
    select 'TRAIT_JUNGLE_VALID_' || DistrictType, 'MODIFIER_PLAYER_CITIES_ADJUST_VALID_FEATURES_DISTRICTS' 
    from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
insert or ignore into Modifiers    (ModifierId, ModifierType)
    select 'TRAIT_MARSH_VALID_' || DistrictType, 'MODIFIER_PLAYER_CITIES_ADJUST_VALID_FEATURES_DISTRICTS' 
    from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
insert or ignore into Modifiers    (ModifierId, ModifierType)
    select 'TRAIT_FOREST_VALID_' || DistrictType, 'MODIFIER_PLAYER_CITIES_ADJUST_VALID_FEATURES_DISTRICTS' 
    from Districts where DistrictType != 'DISTRICT_CITY_CENTER';    

insert or ignore into ModifierArguments    (ModifierId,    Name,        Value) 
    select 'TRAIT_JUNGLE_VALID_' || DistrictType, 'DistrictType', DistrictType
    from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
insert or ignore into ModifierArguments    (ModifierId,    Name,        Value) 
    select 'TRAIT_MARSH_VALID_' || DistrictType, 'DistrictType', DistrictType
    from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
insert or ignore into ModifierArguments    (ModifierId,    Name,        Value) 
    select 'TRAIT_FOREST_VALID_' || DistrictType, 'DistrictType', DistrictType
    from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
insert or ignore into ModifierArguments    (ModifierId,    Name,        Value) 
    select 'TRAIT_JUNGLE_VALID_' || DistrictType, 'FeatureType', 'FEATURE_JUNGLE'
    from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
insert or ignore into ModifierArguments    (ModifierId,    Name,        Value) 
    select 'TRAIT_MARSH_VALID_' || DistrictType, 'FeatureType', 'FEATURE_MARSH'
    from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
insert or ignore into ModifierArguments    (ModifierId,    Name,        Value) 
    select 'TRAIT_FOREST_VALID_' || DistrictType, 'FeatureType', 'FEATURE_FOREST'
    from Districts where DistrictType != 'DISTRICT_CITY_CENTER';
