USE demo;
CREATE TABLE feedback (
  id integer NOT NULL auto_increment,
  name varchar(128) NOT NULL,
  ip int unsigned NOT NULL,
  created datetime DEFAULT now(),
  comments text NOT NULL,
  PRIMARY KEY (id)
);
