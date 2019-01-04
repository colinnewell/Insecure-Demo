USE demo;
CREATE TABLE office_numberss (
  id integer NOT NULL auto_increment,
  name varchar(128) NULL,
  number_prefix varchar(128) NULL,
  main_number varchar(128) NULL,
  PRIMARY KEY (id)
);

INSERT INTO office_numberss (name, number_prefix, main_number)
VALUES ('Head Office (Fleet)', '01252', '01252 365456'),
       ('London', '020', '020 3797 2074'),
       ('Birmingham', '0121', '0121 365456');
