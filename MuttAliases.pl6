#!/usr/bin/env perl6
use v6;

# Description of MuttAliases {{{

=IMPORTANT This script is in working progress. Please, backup your alias file before using this script.

=NAME MuttAliases: Manipulate Mutt Aliases File

=SYNOPSIS MuttAliases <command> <email substring>

=para Where command is one of the following:

=item list:	list aliases
=item dups: find duplicate aliases
=item sort: sort aliasses file
=item add: add alias in alias file
=item del 'email': delete alias from alias file
=item find 'email:	find alias in alias file

sub USAGE() {
	say(
	"Usage: 
		{$*PROGRAM-NAME} list
		{$*PROGRAM-NAME} dups
		{$*PROGRAM-NAME} sort
		{$*PROGRAM-NAME} add
		{$*PROGRAM-NAME} del 'email'
		{$*PROGRAM-NAME} find 'email'"
	);
}

=DESCRIPTION MuttAliases manipulates Mutt Aliases files

# End Description }}}

# Definition of Classes and Methods {{{
=head1 CLASSES
=para MuttAliases defines two classes: Alias and File

# Definition of Class Alias {{{
=head2 Class Alias 
=para Defines an object with the contact information: alias, name and email.

class Alias {
	has Str $.alias;
	has Str $.name;
	has Str $.email; 
}
# }}}

# Definition of Class File {{{
=head2 Class File
=para Reads alises files and stores registers in an Alias object. 

class File { 
	has Array @.registers; # alias, email, Alias Object
	has Alias $.alias;

	# Reads alias file and BUILDs object {{{
	submethod BUILD { 
		for 'aliases'.IO.lines -> $line {
			next unless $line ~~ /^alias/; # next if we do not define any alias
			my @elements = $line.split(/\s+/);
			@elements.shift;
			my $alias = @elements.shift;
			my $email = @elements.pop;
			my $name  = @elements.join(' ');
			my $register = Alias.new( alias => $alias, email => $email, name  => $name);
			self.registers.push: ($alias, $email, $register).Array;
		}
	}
	# }}}

	# Methods definitions of Class File {{{
	=head3 METHODS
	=para All methods belong to class File

	# Method Print {{{
	=head4 print
	=para Sorts and prints registers

	method print { 

		my @sorted = self.registers.sort(*[0]);
		for @sorted -> @register {
			my $register = @register[2];
			say ("alias",$register.alias,$register.name,$register.email).join(' ');
		}
	}
	# }}}

	# Method Dups {{{
	=head4 dups
	=para Find duplicated registers based on the email

	method dups { 
		my $dups = self.registers.map(*[1]).Bag;
		for $dups.antipairs.sort -> %email {
			if %email.key > 1 { say %email;	}
		}
	}
	# }}}

	# Method Sort {{{
	=head4 sort
	=para Sorts aliases based on alises and writes files to disk

	method sort { 
		my @sorted = self.registers.sort(*[0]);

		self!write_file(@sorted,"@@@@@");
	}
	# }}}

	# Method Del {{{
	=head4 del
	=para Asks for email address to delete and deletes alias record. 

	method del (Str $email) { 
		say "Do you want to delete theses email addresses \n" ~ "-" x 20;
		for self.registers -> @line {
			if @line[1].contains($email) {
				my $register = @line[2];
				say ("alias",$register.alias,$register.name,$register.email).join(' ') 
			}
		}
		say "-" x 20;

		my $continue = prompt("continue (yes/no): ");
		return unless $continue eq "yes";
		
		self!write_file(@!registers,$email);

	}
	# }}}

	# Method Find {{{
	=head4 find
	=para Find alias

	method find (Str $find) { 
		for self.registers -> @line {
			if @line[0].contains($find) || @line[1].contains($find) {
				my $register = @line[2];
				say ("alias",$register.alias,$register.name,$register.email).join(' ') 
			}
		}
	}
	# }}}

	# Method insert {{{
	=head4 add 
	=para Add alias in aliases file

	method add {
		my $register = Alias.new(
			alias => prompt("Alias: "),
			name  => prompt("name: "),
			email => prompt("email: "),
		);
		my $fh = open "aliases", :a;
		$fh.say: ("alias",$register.alias,$register.name,"<" ~ $register.email ~ ">").join(' ');
		$fh.close;
		my $changes = qx{tail aliases};
		say $changes;
	}

	
	# }}} 

	# Private Method Write {{{ 
	method !write_file (@array, $condition) { 
		"aliases".IO.move: "aliases.old";
		my $fh = open "aliases", :w;
		for @array -> @register {
			my $register = @register[2];
			unless @register[1].contains($condition) {
				$fh.say: ("alias",$register.alias,$register.name,$register.email).join(' ') 
			}
		}
		$fh.close;
	}
	# }}}

	# End definition of Methods of Class File }}}

}


# End definition of class File }}}

# End File Class and Methods Definition }}}

# multi MAIN definition {{{

multi MAIN( Str $command where { $command eq <list dups sort add >.any } ) {
	given $command {
		when "list" {File.new.print;}
		when "dups" {File.new.dups;}
		when "sort" {File.new.sort;}
		when "add"  {File.new.add;}
	}
}

multi MAIN( Str $command where { $command eq <del find>.any }, 
						Str $email ) {
	given $command {
		when "del"  { File.new.del:  $email }
		when "find" { File.new.find: $email }
	}
}

# End of multi MAIN definition}}}

# vim: tabstop=2 
