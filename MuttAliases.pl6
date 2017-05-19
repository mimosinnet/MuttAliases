#!/usr/bin/env perl6
use v6;

# Description of MuttAliases {{{

=head1 IMPORTANT
=para This script is in working progress. Please, backup your alias file before using this script.

=head1 DESCRIPTION

=NAME MuttAliases: Manipulate Mutt Aliases File

=SYNOPSIS MuttAliases print|dups|sort|del|insert|find

=item print:			list aliases
=item dups: 			find duplicate aliases
=item sort: 			sort aliasses file
=item del 'email': delete alias from alias file
=item insert: 		insert alias in alias file
=item find:			find alias in alias file

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
	=para Finds registers

	method find (Str $find) { 
		for self.registers -> @line {
			if @line[0].contains($find) || @line[1].contains($find) {
				my $register = @line[2];
				say ("alias",$register.alias,$register.name,$register.email).join(' ') 
			}
		}
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

multi MAIN('print') {
	my $file = File.new();
	$file.print;
}

multi MAIN('dups') {
	my $file = File.new();
	$file.dups;
}

multi MAIN('sort') {
	my $file = File.new();
	$file.sort;
}

multi MAIN('del', Str $email) {
	my $file = File.new();
	$file.del: $email;
}

multi MAIN('insert') {
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

multi MAIN('find', Str $find) {
	my $file = File.new();
	$file.find: $find;
}

# End of multi MAIN definition}}}

# vim: tabstop=2 
