IMPORTANT
=========

This script is in working progress. Please, backup your alias file before using this script.

NAME
====

MuttAliases: Manipulate Mutt Aliases File

SYNOPSIS
========

MuttAliases 'command' 'optional email substring'

Where command is one of the following:

  * list: list aliases

  * dups: find duplicate aliases

  * sort: sort aliasses and save them to file

  * add: add alias in alias file

  * find 'email: find alias in alias file

  * del 'email': delete alias from alias file

Examples:

  * MuttAliases list

  * MuttAliases del gmail <- Deletes e-mail with the string 'gmail'

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

#### print

Sorts and prints registers

#### dups

Find duplicated registers based on the email

#### sort

Sorts aliases based on alises and writes files to disk

#### del

Asks for email address to delete and deletes alias record. 

#### find

Find alias

#### add 

Add alias in aliases file
