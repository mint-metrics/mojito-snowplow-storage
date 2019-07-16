-- AUTO-GENERATED BY schema-ddl DO NOT EDIT
-- Generator: schema-ddl 0.3.0
-- Generated: 2019-04-11 15:46

CREATE SCHEMA IF NOT EXISTS atomic;

CREATE TABLE IF NOT EXISTS atomic.io_mintmetrics_mojito_mojito_failure_1 (
    "schema_vendor"  VARCHAR(128)  ENCODE ZSTD NOT NULL,
    "schema_name"    VARCHAR(128)  ENCODE ZSTD NOT NULL,
    "schema_format"  VARCHAR(128)  ENCODE ZSTD NOT NULL,
    "schema_version" VARCHAR(128)  ENCODE ZSTD NOT NULL,
    "root_id"        CHAR(36)      ENCODE RAW  NOT NULL,
    "root_tstamp"    TIMESTAMP     ENCODE ZSTD NOT NULL,
    "ref_root"       VARCHAR(255)  ENCODE ZSTD NOT NULL,
    "ref_tree"       VARCHAR(1500) ENCODE ZSTD NOT NULL,
    "ref_parent"     VARCHAR(255)  ENCODE ZSTD NOT NULL,
    "component"      VARCHAR(255)  ENCODE ZSTD,
    "error"          VARCHAR(1000) ENCODE ZSTD,
    "wave_id"        VARCHAR(255)  ENCODE ZSTD,
    "wave_name"      VARCHAR(255)  ENCODE ZSTD,
    FOREIGN KEY (root_id) REFERENCES atomic.events(event_id)
)
DISTSTYLE KEY
DISTKEY (root_id)
SORTKEY (root_tstamp);

COMMENT ON TABLE atomic.io_mintmetrics_mojito_mojito_failure_1 IS 'iglu:io.mintmetrics.mojito/mojito_failure/jsonschema/1-0-0';