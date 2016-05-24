BEGIN;

DROP SCHEMA IF EXISTS migrated CASCADE;

CREATE SCHEMA migrated;

SET search_path TO migrated;

-- run the CREATE TABLE statements which were generated by generate_create_tables.py using SQLAlchemy
-- and stored in a separate file
\i create_tables.sql

-- Note: in the following data-copying statements, I am being explicit about all column names since I don't think
-- it's safe to assume the columns are in the same order in the new and old schemas, even in simple cases.
-- If you are adding to this list of tables, it may be helpful to know that you can get a comma-separated list of
-- column names for a table (e.g. DemandDrivers) by executing:
-- SELECT string_agg(column_name, ', ') AS cols FROM information_schema.columns WHERE table_schema='public' AND table_name='DemandDrivers';

-- copy system table data

INSERT INTO migrated."AgeGrowthOrDecayType" (id, name)
SELECT id, name FROM public."AgeGrowthOrDecayType";

INSERT INTO migrated."CleaningMethods" (id, name)
SELECT id, name FROM public."CleaningMethods";

INSERT INTO migrated."Currencies" (id, name)
SELECT id, name FROM public."Currencies";

INSERT INTO migrated."DayTypes" (id, name)
SELECT id, name FROM public."DayType";

INSERT INTO migrated."Definitions" (id, name)
SELECT id, name FROM public."Definitions";

INSERT INTO migrated."DemandStockUnitTypes" (id, name)
SELECT id, name FROM public."DemandStockUnitTypes";

INSERT INTO migrated."DemandTechUnitTypes" (id, name)
SELECT id, name FROM public."DemandTechUnitTypes";

INSERT INTO migrated."DispatchConstraintTypes" (id, name)
SELECT id, name FROM public."DispatchConstraintTypes";

INSERT INTO migrated."EfficiencyTypes" (id, name)
SELECT id, name FROM public."EfficiencyTypes";

INSERT INTO migrated."FlexibleLoadShiftTypes" (id, name)
SELECT id, name FROM public."FlexibleLoadShiftTypes";

INSERT INTO migrated."GreenhouseGasEmissionsType" (id, name)
SELECT id, name FROM public."GreenhouseGasEmissionsType";

INSERT INTO migrated."GreenhouseGases" (id, name)
SELECT id, name FROM public."GreenhouseGases";

INSERT INTO migrated."InflationConversion" (id, currency_id, currency_year, value)
SELECT id, currency_id, currency_year_id, value FROM public."InflationConversion";
SELECT setval(pg_get_serial_sequence('migrated."InflationConversion"', 'id'), coalesce(max(id),0) + 1, false) FROM migrated."InflationConversion";

-- TODO: this is a shim to fill in for a missing InflationConversion value
-- just copying the 2014 value into 2015 for now, per Ben
INSERT INTO migrated."InflationConversion" (currency_id, currency_year, value)
SELECT currency_id, 2015, value FROM public."InflationConversion" WHERE currency_year_id = 2014;

INSERT INTO migrated."CurrenciesConversion" (id, currency_id, currency_year, value)
SELECT id, currency_id, currency_year_id, value FROM public."CurrenciesConversion";

INSERT INTO migrated."InputTypes" (id, name)
SELECT id, name FROM public."InputTypes";

INSERT INTO migrated."OptPeriods" (id, hours)
SELECT id, hours FROM public."OptPeriods";

INSERT INTO migrated."ShapesTypes" (id, name)
SELECT id, name FROM public."ShapesTypes";

INSERT INTO migrated."ShapesUnits" (id, name)
SELECT id, name FROM public."ShapesUnits";

INSERT INTO migrated."StockDecayFunctions" (id, name)
SELECT id, name FROM public."StockDecayFunctions";

INSERT INTO migrated."SupplyCostTypes" (id, name)
SELECT id, name FROM public."SupplyCostTypes";

INSERT INTO migrated."SupplyTypes" (id, name)
SELECT id, name FROM public."SupplyTypes";

INSERT INTO migrated."TimeZones" (id, name, utc_shift)
SELECT id, name, utc_shift FROM public."TimeZones";

-- copy geography table data

INSERT INTO migrated."Geographies" (id, name)
SELECT id, name FROM public."Geographies";

INSERT INTO migrated."GeographiesData" (id, name, geography_id)
SELECT id, name, geography_id FROM public."GeographiesData";

INSERT INTO migrated."GeographyMapKeys" (id, name)
SELECT id, name FROM public."GeographyMapKeys";

INSERT INTO migrated."GeographyIntersection" (id)
SELECT id FROM public."GeographyIntersection";

INSERT INTO migrated."GeographyIntersectionData" (id, intersection_id, gau_id)
SELECT id, intersection_id, gau_id FROM public."GeographyIntersectionData";

INSERT INTO migrated."GeographyMap" (id, intersection_id, geography_map_key_id, value)
SELECT id, intersection_id, geography_map_key_id, value FROM public."GeographyMap";

-- copy dispatch table data

INSERT INTO migrated."DispatchFeeders" (id, name)
SELECT id, name FROM public."DispatchFeeders";

-- copy misc table data

INSERT INTO migrated."OtherIndexes" (id, name)
SELECT id, name FROM public."OtherIndexes";

INSERT INTO migrated."OtherIndexesData" (id, other_index_id, name)
SELECT id, other_index_id, name FROM public."OtherIndexesData";

INSERT INTO migrated."Shapes" (
  id, name, shape_type_id, shape_unit_type_id, time_zone_id, geography_id, other_index_1_id, other_index_2_id,
  geography_map_key_id, interpolation_method_id, extrapolation_method_id
)
SELECT id, name, shape_type_id, shape_unit_type_id, time_zone_id, geography_id, other_index_1_id, other_index_2_id,
  geography_map_key_id, interpolation_method_id, extrapolation_method_id
FROM public."Shapes";

INSERT INTO migrated."ShapesData" (
  id, parent_id, gau_id, dispatch_feeder_id, timeshift_type_id, resource_bin, dispatch_constraint_type_id, year, month,
  week, hour, day_type_id, weather_datetime, value
)
SELECT id, parent_id, gau_id, dispatch_feeder, timeshift_type, resource_bin, dispatch_constraint_id, year, month, week,
  hour, day_type_id, weather_datetime::timestamp as weather_datetime, value
FROM public."ShapesData";

INSERT INTO migrated."FinalEnergy" (id, name, shape_id)
SELECT id, name, shape_id FROM public."FinalEnergy";

-- copy demand table data

INSERT INTO migrated."DemandSectors" (id, name, shape_id, max_lead_hours, max_lag_hours)
SELECT id, name, shape_id, max_lead_hours, max_lag_hours FROM public."DemandSectors";

INSERT INTO migrated."DemandDrivers" (
  id, name, base_driver_id, input_type_id, unit_prefix, unit_base, geography_id, other_index_1_id, other_index_2_id,
  geography_map_key_id, interpolation_method_id, extrapolation_method_id, extrapolation_growth
)
SELECT id, name, base_driver_id, input_type_id, unit_prefix, unit_base, geography_id, other_index_1_id,
  other_index_2_id, geography_map_key_id, interpolation_method_id, extrapolation_method_id, extrapolation_growth
FROM public."DemandDrivers";

INSERT INTO migrated."DemandDriversData" (parent_id, gau_id, oth_1_id, oth_2_id, year, value, id)
SELECT parent_id, gau_id, oth_1_id, oth_2_id, year, value, id FROM public."DemandDriversData";

CREATE TABLE IF NOT EXISTS migrated."ModelConfig" (
       id SERIAL NOT NULL,
       "group" TEXT,
       key TEXT,
       value TEXT,
       PRIMARY KEY (id),
       UNIQUE (key)
);

-- Reset all sequences in migrated, which have now become out of sync due to inserts with fixed primary key values
-- Very important! If you skip this part, the migration will appear to work but you won't be able to insert
-- any rows after.
\i reset_sequences.sql


-- TODO: rename so "migrated" is the new "public", and either delete old "public" or call it something like "legacy"

COMMIT;