
SGN Tomato Expression Atlas
==========

Code and database for the expression query, mining, analysis, and visualization tools


Tomato Expression Atlas Installation Manual (In progress)
==========

It has several components:

1. Catalyst, Perl and R dependencies
2. Code, in github https://github.com/solgenomics/Tea
3. Configuration file
4. Database
5. Lucy indexes

--------------------------------------------

1. Install Catalyst, Perl and R dependencies
--------------------------------------------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

This web tool was developed using the Perl framework Catalyst (​<http://www.catalystframework.org>), so to run the application is necessary to install Perl, Catalyst and its dependencies.

Check this link in case of doubts installing Catalyst (​<http://www.catalystframework.org/#install>).

To install Catalyst using cpanm, just execute:
`cpanm Catalyst::Devel`


Also, if you are installing it in a new machine you ma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ybe need to install cpanminus, gcc and make, and then some Perl dependencies like Catalyst, Lucy and Mason:

    sudo aptitude install cpanminus
    sudo aptitude install make
    sudo aptitude install gcc
    sudo aptitude install r-base
    sudo aptitude install r-base-dev
    sudo aptitude install postgresql
    sudo aptitude install postgresql-server-dev-11    
    cpanm -L ~/local-lib/ Catalyst::Devel
    cpanm -L ~/local-lib/ Catalyst::Runtime
    cpanm -L ~/local-lib/ Mason
    cpanm -L ~/local-lib/ Statistics::R
    cpanm -L ~/local-lib/ Catalyst::ScriptRunner
    cpanm -L ~/local-lib/ Catalyst::Controller::REST
    cpanm -L ~/local-lib/ Catalyst::View::HTML::Mason
    cpanm -L ~/local-lib/ Lucy::Simple
    cpanm -L ~/local-lib/ Array::Utils
    cpanm -L ~/local-lib/ DBIx::Class
    cpanm -L ~/local-lib/ Bio::Perl
    cpanm -L ~/local-lib/ Bio::BLAST::Database
    cpanm -L ~/local-lib/ DBD::Pg  

If you are having trouble installing cpanm, there may be an issue with your system's dependencies.
Visit (​<https://library.linode.com/linux-tools/utilities/cpanm>) for help with installing dependencies.

In case local-lib is not in the path, you have to add the following line in the .bashrc file (for a local-lib in your home)

`export PERL5LIB=/home/username/local-lib/lib/perl5:$PERL5LIB`

You might also need to add the next line to your .bashrc

`export PERL5LIB=$PERL5LIB:/home/username/path_to_tea/Tea/`

Do not forget to source .bashrc to be sure these changes take effect.

R v3 must be installed for the interactive heatmap. The R libraries 'd3heatmap', 'NOISeq' and 'htmlwidgets' should also be installed.

--------------------------------------------

2. Clone Github repository
--------------------------

Go to the TEA repository at GitHub (https://github.com/solgenomics/Tea) and copy the link to clone this repository.

Go to your terminal, to the folder where you want to clone this repository and use the next command (using the link copied from the web):

`git clone git@github.com:solgenomics/Tea.git`

or

`git clone https://github.com/solgenomics/Tea.git`

You can run the local server to check Catalyst is running fine. If you are running it on a server, you should also check that the Apache or Nginx configuration is correct and the ports are open on the firewall.

Go to the folder Tea, created when cloned the repository and run the server to check if all the dependencies are installed.
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
    cd Tea/
    script/tea_server.pl -r -d --fork


If you got an error, you will probably will need to go back to step one and install some dependencies.


--------------------------------------------

3. Configuration file
---------------------
Once you have cloned the repository you will see a configuration file called tea.conf inside the directory Tea.
You will need to edit this file to customize all the paths, so they work on your system.

    dbhost localhost
    dbname my_db
    dbuser web_usr
    dbpass password

    expression_indexes_path /home/user/index_files/expression
    correlation_indexes_path /home/user/index_files/correlation
    loci_and_description_index_path /home/user/index_files/description

    #path to mason folder to overwrite default front-end
    <View::Mason>
      add_comp_root /home/user/path_to_new_mason_dir
    </View::Mason>

    nt_blastdb_path /home/user/blastdbs/cdna_file.fasta
    prot_blastdb_path /home/user/blastdbs/prots_file.fasta
    tmp_path /home/user/tea_tmp_files

    default_gene gene_name

`web_usr` is the user name with permissions to edit and read the database, if you want to use a different user name you will need to grant permissions to the new user or edit the file `create_tea_schema.sql`

In order to enable the 'DEG' tab, `deg_tab 1` should be added as a line in the conf file.

Add the expression images to the folder `Tea/root/static/images/expr_viewer/`

You can customize the value of any of these variables.

--------------------------------------------

4. Create database
------------------
Install PostgreSQL, create a database to store your project metadata and import the schema to the database:

On postgres terminal:

    CREATE DATABASE my_db;

On Linux terminal create the database schema importing the file `create_tea_schema.sql` from `import_project` folder:

    psql –U postgres –d my_db –h localhost –a –f create_tea_schema.sql

Use `TEA_project_template.txt` and `TEA_project_template_example.txt` from `import_project` to create your project import file

    # Please use one line per field and one file per project. Do not edit or remove any line starting with #

    #organism
    organism_species: Solanum lycopersicum
    organism_variety: M82
    organism_description: Tomato M82
    # organism - end

    #project
    project_name: S. lycopersicum M82 Fruit Development
    project_contact: Jocelyn Rose
    project_description: Fruit development from anthsis to red ripe for whole fruit and for the cell types from the pericarp obtained by Laser Capture Microdissected (LCM)
    expr_unit: RPM
    index_dir_name: tomato_index
    # project - end


    # figure --- All info needed for a cluster of images (usually includes a stage and all its tissues). Copy this block as many times as you need (including as many tissue layer blocks as you need).
    figure_name: 10DPA Total Pericarp
    conditions: condition 1, condition 2
    # write figure metadata

    #stage layer
    layer_name: 10DPA
    layer_description: Ten days post anthesis
    layer_type: stage
    bg_color:
    layer_image: slm82_fruit_10dpa_bg.png
    image_width: 250
    image_height: 500
    cube_ordinal: 10
    img_ordinal: 10
    organ: fruit
    # layer - end

    #tissue layer
    layer_name: Total_Pericarp
    layer_description:
    layer_type: tissue
    bg_color:
    layer_image: cassava_leaf.png
    image_width: 250
    image_height: 500
    cube_ordinal: 100
    img_ordinal: 100
    organ: fruit
    # layer - end

    # figure - end


The `figure_name` will be displayed on the top of the expression figures. It is recommended to use the stage name followed by the conditions for that stage. For example: `10DPA drought`.

The `bg_color` defines the background color for the stages and tissues labels on the cube.

For the `layer_image` from the stage layer is recommended to have an image with the stage title, transparent background, and same dimensions as the tissue figures.

The `cube_ordinal` from the stage layer defines the order of the stage columns on the cube (from left to right).

The `img_ordinal` from the stage layer defines the order of the figure for the Expression images.

The `cube_ordinal` from the tissue layer defines the order of the tissue rows on the cube (from top to bottom).

The stage and tissue names on the cube are defined by the field `layer_name` on the tissue layer block. WHITE SPACES ARE NOT ALLOWED IN THIS FIELD. Please, replace them by underscores (_).
Try to avoid special characters like commas on `layer_name`, `organ` and `conditions`.

Run the script to import your project:

`perl TEA_import_project_metadata.pl -d my_db -H localhost -u postgres -t your_project_input_template.txt`


--------------------------------------------

5. Lucy indexes:
----------------

Three Lucy indexes are needed. One for expression, another for correlation and the last one for sgn_loci_id and the gene descriptions.
To format the expression and correlation data you will need to run the scripts `index_expression_file.pl` and `index_correlation_file.pl` respectively.

The input format for the expression should be gene name, stage `layer_name` (like the stage-layer in the TEA project template), tissue (like the tissue-layer `layer_name` from the TEA project template). WHITE SPACES ARE NOT ALLOWED IN THESE FIELDS. Then, the expression value, the standard error and the replicates separated by commas:

    Solyc00g005040	Anthesis	Columella	1.36	0.27	0.86,1.8,1.41
    Solyc00g005040	Anthesis	Locular_Material	0.09	0.09	0,0,0.28
    Solyc00g005040	Anthesis	Total_Pericarp	1.72	0.20	1.86,1.32,1.97
    Solyc00g005040	Anthesis	Placenta	1.65	1.12	1.17,3.78,0
    Solyc00g005040	Anthesis	Seeds	3.14	1.04	3.22,1.3,4.89
    Solyc00g005040	Anthesis	Septum	1.21	0.58	2.06,0.09,1.48
    Solyc00g005040	Light_Red	Columella	7.49	0.54	6.47,7.76,8.89,6.85
    Solyc00g005040	Light_Red	Locular_Material	6.81	1.05	5.79,9.5,4.65,7.32
    Solyc00g005040	Light_Red	Total_Pericarp	5.46	0.28	6,4.87,5.85,5.11
    Solyc00g005040	Light_Red	Placenta	3.96	0.19	3.77,3.54,4.15,4.39
    Solyc00g005040	Light_Red	Seeds	2.48	0.49	1.96,2.37,3.9,1.7
    Solyc00g005040	Light_Red	Septum	4.18	0.13	3.96,4.47,4.33,3.98
    Solyc00g005040	Red_Ripe	Columella	5.69	0.90	6.75,3.71,7.59,4.71
    Solyc00g005040	Red_Ripe	Locular_Material	6.48	0.20	6.43,6.36,6.1,7.04
    Solyc00g005040	Red_Ripe	Total_Pericarp	6.03	0.35	6.46,6.76,5.2,5.72
    Solyc00g005040	Red_Ripe	Placenta	4.70	0.40	3.59,5.48,4.75,4.98
    Solyc00g005040	Red_Ripe	Seeds	3.06	0.34	2.17,3.11,3.1,3.85
    Solyc00g005040	Red_Ripe	Septum	5.87	0.75	4.57,4.98,6,7.94

Correlation example:

    Solyc00g005000  Solyc02g081180  0.97
    Solyc00g005000  Solyc03g080070  0.97
    Solyc00g005000  Solyc05g010180  0.97
    Solyc00g005000  Solyc05g010190  0.97
    Solyc00g005000  Solyc05g010200  0.97
    Solyc00g005000  Solyc03g006240  0.95
    Solyc00g005000  Solyc07g009520  0.95
    Solyc00g005000  Solyc09g075970  0.95
    Solyc00g005000  Solyc10g086490  0.95
    Solyc00g005000  Solyc01g095610  0.94
    Solyc00g005000  Solyc02g080960  0.94
    Solyc00g005000  Solyc07g016050  0.94
    Solyc00g005000  Solyc03g058330  0.93

To format the gene description data you will need to run the scripts `index_description_file.pl`.

The loci ids and descriptions file is a tab delimited file including 3 columns; loci id (to link to SGN), gene name, and description:

    110976  Solyc00g005000  Aspartic proteinase nepenthesin I (A9ZMF9_NEPAL)
    8379    Solyc00g005020  Unknown Protein
    8381    Solyc00g005040  Potassium channel (D0EM91_9ROSI)
    8382    Solyc00g005050  Arabinogalactan protein (B6SST2_MAIZE)


Do not forget to place the created Lucy indexes in the folders indicated in tea.conf, inside a folder named as the value for `index_dir_name` in the project information.

Example:

    /home/user/index_files/expression/tomato_index/
    /home/user/index_files/correlation/tomato_index/
