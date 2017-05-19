IMPORTANT
=========

This script is in working progress. Please, backup your alias file before using this script.

DESCRIPTION
===========

NAME
====

MuttAliases: Manipulate Mutt Aliases File

SYNOPSIS
========

MuttAliases print|dups|sort|del|insert|find

  * print: list aliases

  * dups: find duplicate aliases

  * sort: sort aliasses file

  * del 'email': delete alias from alias file

  * insert: insert alias in alias file

  * find: find alias in alias file

DESCRIPTION
===========

MuttAliases manipulates Mutt Aliases files

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

Finds registers
