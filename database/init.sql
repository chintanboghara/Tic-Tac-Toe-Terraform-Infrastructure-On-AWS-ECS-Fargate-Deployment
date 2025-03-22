CREATE TABLE sample_table (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50)
);

INSERT INTO sample_table (name) VALUES ('Sample Data 1'), ('Sample Data 2');