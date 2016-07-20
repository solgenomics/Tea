SGN Tomato Expression Atlas
==========

code and database for the expression query, mining, analysis, and visualization tools


Tomato Expression Atlas Installation Manual (Still in progress)
=======================

It has several components:

1. Install Catalyst and Perl dependencies
2. Code, in github https://github.com/solgenomics/Tea
3. Configuration file
4. Database
5. Lucy indexes, one for expression, another for correlation and the last one for sgn_loci_id and description



1. Install Catalyst and Perl dependencies
-----------------------------------------

This web tool was developed using the Perl framework Catalyst (​<http://www.catalystframework.org>), so to run the application we need to install Perl, Catalyst and its dependencies.

Check this link in case of doubts installing Catalyst (​<http://www.catalystframework.org/#install>).

To install Catalyst using cpanm, just execute:
`cpanm Catalyst::Devel`


Also, if you are installing it in a new machine you maybe need to install cpanminus, gcc and make, and then, Catalyst and Mason:

    sudo aptitude install cpanminus
    sudo aptitude install make
    sudo aptitude install gcc
    cpanm -L ~/local-lib/ Catalyst::Devel
    cpanm -L ~/local-lib/ Catalyst::Runtime
    cpanm -L ~/local-lib/ Mason
		
If you are having trouble installing cpanm, there may be an issue with your system's dependencies. Visit (​<https://library.linode.com/linux-tools/utilities/cpanm>) for help with installing dependencies.

In case local-lib is not in the path you have to add the following line in the .bashrc file

`export PERL5LIB=/home/username/local-lib/lib/perl5:$PERL5LIB`

Do not forget to open a new terminal or source the .bashrc file to be sure this changes make effect.

Dependencies: Perl, Catalyst, Lucy, Mason

    cpanm -L ~/local-lib/ Lucy::Simple

You can check if you have them installed in your machine with 
'perl -M<module> -e 1'. It will return an error message if it isn't installed.

    perl -MBio::SeqIO -e 1

To install these modules, you can do through the CPAN or manually downloading
(http://search.cpan.org/) and compiling them. To use CPAN, you can do by 
writing:

    perl -MCPAN -e 'install <module>'



2. Clone Github repository
--------------------------

Go to the TEA repository at GitHub (https://github.com/solgenomics/Tea) and copy the link to clone this repository.

Go to your terminal, to the folder where you want to clone this repository and use the next command (using the link copied from the web):

`git clone git@github.com:solgenomics/Tea.git`

or

`git clone https://github.com/solgenomics/Tea.git`

You can run the local server to check Catalyst is running fine, and in case you are running it on a server you should check also the Apache or Ngnix configuration is right and the ports are open on the firewall.

Go to the folder Tea, created when cloned the repository and run the server to check if all the dependencies are installed.

    cd Tea/
    script/tea_server -r -d


If you got an error, you will probably will need to go back to step one and install some dependencies.


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
    description_index_path /home/user/index_files/description
    locus_index_path /home/user/index_files/locus_link

    nt_blastdb_path /home/production/blastdbs/tomato_v2.40_cdna.fasta
    prot_blastdb_path /home/production/blastdbs/tomato_v2.40_prots.fasta
    tmp_path /home/production/tea_tmp_files

`web_usr` is the user name with permissions to edit and read the database, if you want to use a different user name you will need to grant permissions to the new user or edit the file `create_tea_schema.sql`

4. Create database
------------------
Install PostgreSQL, create a database to store your project metadata and import the schema to the database:

On postgres terminal:

    CREATE DATABASE my_db;

On Linux terminal create the database schema importing the file `create_tea_schema.sql` from `import_project` folder:

    psql –U postgres –d my_db –h localhost –a –f create_tea_schema.sql

Use `TEA_project_template.txt` and `TEA_project_template_example.txt` from `import_project` to create your project import file

Run the script to import your project:

`TEA_import_project_metadata.pl -d my_db -H localhost -u postgres -p 'password' -t your_project_input_template.txt -i path_to_images`


5. Lucy indexes:
----------------

To format the expression and correlation data you will need to run the scripts `index_expression_file.pl` and `index_correlation_file.pl` respectively.

The input format for the expression should be gene name, stage, tissue and expression value:

    Solyc00g005050	10DPA	Inner_Epidermis	15.81
    Solyc00g005050	10DPA	Parenchyma	12.45
    Solyc00g005050	10DPA	Vascular_Tissue	9.61
    Solyc00g005050	10DPA	Collenchyma	20.87
    Solyc00g005050	10DPA	Outer_Epidermis	10.5
    Solyc00g005050	Mature_Green	Inner_Epidermis	35.64
    Solyc00g005050	Mature_Green	Parenchyma	13.69
    Solyc00g005050	Mature_Green	Vascular_Tissue	14.54
    Solyc00g005050	Mature_Green	Collenchyma	16.08
    Solyc00g005050	Mature_Green	Outer_Epidermis	15.41
    Solyc00g005050	Pink	Inner_Epidermis	22.98
    Solyc00g005050	Pink	Parenchyma	32.88
    Solyc00g005050	Pink	Vascular_Tissue	12.43
    Solyc00g005050	Pink	Collenchyma	23.76
    Solyc00g005050	Pink	Outer_Epidermis	16.25

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
