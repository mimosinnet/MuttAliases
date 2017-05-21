#!/usr/bin/env perl6
use v6;

# Description of MuttAliases {{{

=IMPORTANT This script is work in progress. Please, backup your alias file before using it.

=NAME MuttAliases: Manipulate Mutt Aliases File

=SYNOPSIS MuttAliases 'command' 'optional email substring'

=para Where command is one of the following:
=item list:	list aliases
=item dups: find duplicate aliases
=item sort: sort aliases and save them to file
=item add: add alias in alias file
=item find 'string':	find 'string' in alias or email
=item del 'email': delete alias from alias file

=para Examples:
=item MuttAliases list
=item MuttAliases del  gmail  <- Deletes e-mail with the string 'gmail'

sub USAGE() {
	say("
	Usage: 
		{$*PROGRAM-NAME} list
		{$*PROGRAM-NAME} dups
		{$*PROGRAM-NAME} sort
		{$*PROGRAM-NAME} add
		{$*PROGRAM-NAME} find 'string'
		{$*PROGRAM-NAME} del 'email'
	");
}

=CONFIGURATION
MuttAliases looks if the files B<~/mutt/aliases> or B<~/mutt/data/aliases> exist. If MuttAliases does not find one of these files, it reads the configuratin file B<~/.config/muttalias/muttaliasrc> or B<~/.muttaliasrc>. The format of this file is in the format:
B<option = value>
The only option defined at this moment is 'alias_file'.

=para Example of B<~/.config/muttalias/muttaliasrc>:
=para alias_file = /home/mimosinnet/.mutt/data/aliases 

=TODO
- The aliases file has three fields: alias, name, email. The command 'find' does a search on the field 'alias' and 'email', but not in the field 'name'. 

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
	has Str		$!filename;

	# Reads alias file and BUILDs object {{{
	submethod BUILD {
		{
			when "$*HOME/.mutt/aliases".IO ~~ :e & :rw 			{ $!filename = "$*HOME/.mutt/aliases" }
			when "$*HOME/.mutt/data/aliases".IO ~~ :e & :rw { $!filename = "$*HOME/.mutt/data/aliases" }
			when "$*HOME/.config/muttalias/muttaliasrc".IO ~~ :e & :r { 
				$!filename = read-config("$*HOME/.config/muttalias/muttaliasrc", "alias_file");
			}
			when "$*HOME/..muttaliasrc".IO ~~ :e & :r {
				$!filename = read-config("$*HOME/.muttaliasrc", "alias_file");
			}
		}

		for $!filename.IO.lines -> $line {
			next unless $line ~~ /^alias/; # next if we do not define any alias
			my @elements = $line.split(/\s+/);
			@elements.shift;
			my $alias = @elements.shift;
			my $email = @elements.pop;
			my $name  = @elements.join(' ');
			my $register = Alias.new( alias => $alias, email => $email, name  => $name);
			self.registers.push: ($alias, $email, $register).Array;
		}
	} # }}}
	
	# sub reading config file with format 'option = value' {{{
	sub read-config ( Str $path, Str $config_option ) {
		my %options;
		my $fh = open($path, :r);
		while $fh.lines -> $line {
			$line ~~ /
				$<option> = (\S+)
				\s* \= \s*
				$<value>	= (\S+)
			/;
			%options{$<option>.Str} = $<value>.Str;
		}
		$fh.close;
		die "Sorry! Unable to find option '$config_option' in '$path' configuration filei \n\n\n" unless %options{$config_option}.defined;
		return %options{$config_option};
	} # }}}

	# Methods definitions of Class File {{{
	=head3 METHODS
	=para All methods belong to class File

	# Method list {{{
	=head4 list
	=para Sorts and prints registers

	method list { 
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

		# Write registers to file unless e-mail contains @@@@@. In other words, write all regisers.
		self!write_file(@sorted,"@@@@@");
	}
	# }}}

	# Method add {{{
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

	# Method Find {{{
	=head4 find
	=para Find string in alias or email

	method find (Str $find) { 
		for self.registers -> @line {
			if @line[0].contains($find) || @line[1].contains($find) {
				my $register = @line[2];
				say ("alias",$register.alias,$register.name,$register.email).join(' ') 
			}
		}
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
		when "list" {File.new.list;}
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
