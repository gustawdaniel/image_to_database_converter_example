DROP DATABASE   IF     EXISTS electronic_store;
CREATE DATABASE IF NOT EXISTS electronic_store;
use electronic_store;

CREATE TABLE product (
  maker    CHAR(1),
  model    DECIMAL(4,0),
  type     VARCHAR(255)
);

CREATE TABLE pc (
  model DECIMAL(4,0),
  speed DECIMAL(3,2),
  ram   SMALLINT,
  hd  SMALLINT,
  price SMALLINT
);

CREATE TABLE laptop (
  model DECIMAL(4,0),
  speed DECIMAL(3,2),
  ram   SMALLINT,
  hd  SMALLINT,
  screen DECIMAL(3,1),
  price SMALLINT
);

CREATE TABLE printer (
  model DECIMAL(4,0),
  color BOOLEAN,
  type  VARCHAR(255),
  price SMALLINT
);