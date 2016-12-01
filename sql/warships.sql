DROP DATABASE   IF     EXISTS warships;
CREATE DATABASE IF NOT EXISTS warships;
use warships;

CREATE TABLE classes (
  class VARCHAR(255),
  type CHAR(2),
  country VARCHAR(255),
  numGuns SMALLINT,
  bore SMALLINT,
  displacement INTEGER
);

CREATE TABLE ships (
  name VARCHAR(255),
  class VARCHAR(255),
  launched SMALLINT
);

CREATE TABLE battles (
  name VARCHAR(255),
  date VARCHAR(255)
);

CREATE TABLE outcomes (
  ship VARCHAR(255),
  battle VARCHAR(255),
  result VARCHAR(255)
)