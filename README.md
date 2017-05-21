IMPORTANT
=========

This script is work in progress. Please, backup your alias file before using it.

NAME
====

MuttAliases: Manipulate Mutt Aliases File

SYNOPSIS
========

MuttAliases 'command' 'optional email substring'

Where command is one of the following:

  * list: list aliases

  * dups: find duplicate aliases

  * sort: sort aliases and save them to file

  * add: add alias in alias file

  * find 'string': find 'string' in alias or email

  * del 'email': delete alias from alias file

Examples:

  * MuttAliases list

  * MuttAliases del gmail <- Deletes e-mail with the string 'gmail'

CONFIGURATION
=============

MuttAliases looks if the files **~/mutt/aliases** or **~/mutt/data/aliases** exist. If MuttAliases does not find one of these files, it reads the configuratin file **~/.config/muttalias/muttaliasrc** or **~/.muttaliasrc**. The format of this file is in the format: **option = value** The only option defined at this moment is 'alias_file'.

Example of **~/.config/muttalias/muttaliasrc**:

alias_file = /home/mimosinnet/.mutt/data/aliases 

TODO
====

- The aliases file has three fields: alias, name, email. The command 'find' does a search on the field 'alias' and 'email', but not in the field 'name'. 

CLASSES
=======

MuttAliases defines two classes: Alias and File

Class Alias 
------------

Defines an object with the contact information: alias, name and email.

Class File
----------

Reads alises files and stores registers in an Alias object. 

### METHODS

All methods belong to class File

#### list

Sorts and prints registers

#### dups

Find duplicated registers based on the email

#### sort

Sorts aliases based on alises and writes files to disk

#### add 

Add alias in aliases file

#### find

Find string in alias or email

#### del

Asks for email address to delete and deletes alias record. 
