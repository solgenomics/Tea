CREATE TABLE organism (
    organism_id bigserial PRIMARY KEY,
    species varchar(80) NOT NULL,
    variety varchar(80),
    description text
);

CREATE TABLE project (
    project_id bigserial PRIMARY KEY,
    name varchar(80) NOT NULL,
    description text,
    contact varchar(80),
    expr_unit varchar(80),
    indexed_dir varchar(80),
    organism_id bigserial references organism(organism_id) NOT NULL
);

CREATE TABLE figure (
    figure_id bigserial PRIMARY KEY,
    figure_name varchar(80),
    cube_stage_name varchar(80),
    project_id bigserial references project(project_id) NOT NULL
);

CREATE TABLE condition (
    condition_id bigserial PRIMARY KEY,
    name varchar(80),
    figure_id bigserial references figure(figure_id) NOT NULL
);

CREATE TABLE layer_info (
    layer_info_id bigserial PRIMARY KEY,
    name varchar(80),
    description text,
    bg_color varchar(80),
    organ varchar(80)
);

CREATE TABLE layer_type (
    layer_type_id bigserial PRIMARY KEY,
    layer_type varchar(80) NOT NULL
);

CREATE TABLE layer (
    layer_id bigserial PRIMARY KEY,
    image_file_name varchar(80),
    image_width integer,
    image_height integer,
    cube_ordinal integer,
    img_ordinal integer,
    layer_type_id bigserial REFERENCES layer_type(layer_type_id),
    layer_info_id bigserial REFERENCES layer_info(layer_info_id)
);

CREATE TABLE figure_layer (
    figure_layer_id bigserial PRIMARY KEY,
    figure_id bigserial REFERENCES figure(figure_id),
    layer_id bigserial REFERENCES layer(layer_id)
);


GRANT ALL PRIVILEGES ON DATABASE tea_metadata TO web_usr;

GRANT ALL PRIVILEGES ON organism TO web_usr;
GRANT ALL PRIVILEGES ON project TO web_usr;
GRANT ALL PRIVILEGES ON figure TO web_usr;
GRANT ALL PRIVILEGES ON condition TO web_usr;
GRANT ALL PRIVILEGES ON layer TO web_usr;
GRANT ALL PRIVILEGES ON layer_info TO web_usr;
GRANT ALL PRIVILEGES ON layer_type TO web_usr;
GRANT ALL PRIVILEGES ON figure_layer TO web_usr;

