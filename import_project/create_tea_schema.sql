CREATE TABLE organism (
    organism_id bigserial PRIMARY KEY,
    species varchar(80) NOT NULL,
    variety varchar(80),
    description text
);

CREATE TABLE project (
    project_id bigserial PRIMARY KEY,
    name varchar(80) NOT NULL,
    contact varchar(80),
    description text,
    indexed_dir varchar(80),
    organism_id bigserial references organism(organism_id) NOT NULL
);

CREATE TABLE experiment (
    experiment_id bigserial PRIMARY KEY,
    name varchar(80),
    description text,
    project_id bigserial references project(project_id) NOT NULL
);

CREATE TABLE layer_info (
    layer_info_id bigserial PRIMARY KEY,
    name varchar(80),
    description text
);

CREATE TABLE layer_type (
    layer_type_id bigserial PRIMARY KEY,
    layer_type varchar(80) NOT NULL
);

CREATE TABLE layer (
    layer_id bigserial PRIMARY KEY,
    image_file_name varchar(80) NOT NULL,
    layer_type_id bigserial REFERENCES layer_type(layer_type_id),
    layer_info_id bigserial REFERENCES layer_info(layer_info_id),
    parent_id bigserial REFERENCES layer(layer_id),
    image_width integer,
    image_height integer,
    ordinal integer
);

CREATE TABLE experiment_layer (
    experiment_layer_id bigserial PRIMARY KEY,
    experiment_id bigserial REFERENCES experiment(experiment_id),
    layer_id bigserial REFERENCES layer(layer_id)
);


GRANT ALL PRIVILEGES ON DATABASE tea_metadata TO web_usr;

GRANT ALL PRIVILEGES ON organism TO web_usr;
GRANT ALL PRIVILEGES ON project TO web_usr;
GRANT ALL PRIVILEGES ON experiment TO web_usr;
GRANT ALL PRIVILEGES ON layer TO web_usr;
GRANT ALL PRIVILEGES ON layer_info TO web_usr;
GRANT ALL PRIVILEGES ON layer_type TO web_usr;
GRANT ALL PRIVILEGES ON experiment_layer TO web_usr;
