#!/usr/bin/perl
#
#  dirt
#   directory stack tool
#
#	the latest version is at https://github.com/BleuLlama/dirt
#
#   Scott Lawrence
#   yorgle@gmail.com


#   version 1.6, 2016-Feb-18
#	uploaded to github
#
#   version 1.5, 2012-May-05
#	added 'file' to dump out the current dirt pile filename
#	useful for dvi()
#
#   version 1.4, 2005-Aug-25
#	-listfiles dumps filenames for dirt piles
#	added some minorly better support for adding new versions later
# 	NOTE: this is the latest version of the configuration files
#
#   version 1.3, 2005-Feb-15
#	moved everything into $HOME/.dirt/
#	added automigrator for old versions
#
#   version 1.2, 2005-Feb-05
#	added support for multiple dirtpiles, and switching (via "list")
#
#   version 1.1, 2001-Aug-13
#       moved the dirtpile out to be $HOME/.dirtpile
#	added aliases.sh for borne shell users
#
#   version 1.0, 2000-Feb-09
#	initial version, dirtpile hardcoded


#  use this in conjunction with some shell aliases.  See the file
#  with this package:  aliases.sh
#  or just append them to your .profile
#

#  These are necessary, because the cwd is interhal to the process
#  running.  if this perl script were to change its cwd, then when
#  it exits, the parent shell will still be where it started at.
#
#  I made this after realizing that i'd like to have a directory stack
#  available across shells in different terminals.  It is based on my old
#  MS-DOG directory stack routines, which i made because no such thing existed
#  under MS-DOG.  (pushd/popd/swapd/topd/dirs)

$|=1;

use Cwd;

$dirtdir = $ENV{'HOME'} . "/.dirt/";
$dirtpiledir = $dirtdir . "piles/";
$dirtpileid = $dirtdir . "id";
$dirtversion = $ENV{'HOME'} . "/.dirt/version";

sub usage
{
    printf <<EOB;
Dirt  v1.4  2005-08-25  Scott Lawrence  sdlpci\@cis.rit.edu

Usage: $0 [command] 

    commands:
	help			displays this
	file                    displays the full path of the current pile
	jump    NUMBER          jumps to the [number] element in the list
	list    [id]            lists directories/switches to list [id]
	pop                     pops the top element off , and prints it out
	push    [directory]     adds cwd or <directory> into listfile
	swap                    pops the top element off, pushes cwd on
	top                     prints out the top element

EOB
}

# get the current stack name from the id file
sub dirt_currentid
{
    open CPN, "$dirtpileid";
    $currentpileid = <CPN>;
    close CPN;
    chomp $currentpileid;
    if( $currentpileid eq "" )
    {
	$currentpileid = "default";
    }
    return( $currentpileid );
}

# write out a new id
sub dirt_writeid
{
    $newid = shift;
    open CPN, ">$dirtpileid";
    print CPN "$newid";
    close CPN;
}

# read in the pile file into @dirtpile
sub dirt_read_pile
{
    $pilefile = $dirtpiledir . dirt_currentid();
    @dirtpile = (); 		# reset the ram
    open DPF, "$pilefile";
    while (<DPF>)
    {
	chomp $_;
	push @dirtpile, $_;
    }
    close DPF;
}

# write out the pile file to the current id appropriately
sub dirt_write_pile
{
    $pilefile = $dirtpiledir . dirt_currentid();
    open DPF, ">$pilefile";
    foreach (@dirtpile)
    {
	printf DPF "%s\n", $_;
    }
    close DPF;
}

# list the contents of the pile file, or list the available piles
sub dirt_list
{
    # load the current pile's name
    $cpid = dirt_currentid();

    # first, check for dirtpile switching...
    if( scalar @ARGV == 2 )
    {
	# user wants to change the list, or list lists.
	if(   ( $ARGV[1] eq "-list" ) || ( $ARGV[1] eq "list") 
	   || ( $ARGV[1] eq "-listfiles" ) || ( $ARGV[1] eq "listfiles") 
	  )
	{
	    $found_default = 0;
	    printf "Available dirt piles:\n";
	    opendir ID, $dirtpiledir;
	    foreach $de (readdir ID )
	    {
		next if ( "." eq substr $de, 0, 1 );
		if( $de eq $cpid ) {
		    $ind = "<--";
		} else {
		    $ind = "";
		}
		if( "files" eq substr $ARGV[1], -5,5 ) {
		    printf "%15s %3s %s%s\n", $de, $ind, $dirtpiledir, $de;
		} else {
		    printf "%20s %s\n", $de, $ind;
		}
	    }
	    printf "\n";

	    if( "files" eq substr $ARGV[1], -5,5 ) {
		printf "%s%s\n\n", $dirtpiledir, $cpid;
	    }

	    closedir ID;
	    return;
	}

	# otherwise, switch...
	dirt_writeid( $ARGV[1] );
	$cpid = $ARGV[1];
    }
    &dirt_read_pile;
    
    # print out the list
    printf "list[ %s ]\n", $cpid;

    for ($x=0 ; $x<scalar @dirtpile ; $x++)
    {
	printf " %5d %3d  %s\n", $x, $x-(scalar @dirtpile) , $dirtpile[$x];
    }
    printf "\n";
}


# determine the version number
#  1.3+  	version in ~/.dirtpile/version
#  1.2		~/.dirtpile__id  file exists
#  1.1		~/.dirtpile exists (or just fall through the above)
sub get_version
{
    my $vers = "1.1";
    $oldIDfile = $ENV{'HOME'} . "/.dirtpile__id";

    if( -e $dirtversion )
    {
	open IF, "$dirtversion";
	$vers = <IF>;
	close IF;
    } else {
	if( -e $oldIDfile )
	{
	    $vers = "1.2";
	} else {
	    $vers = "1.1";
	}
    }
    return $vers;
}

# migrate will move directory stack(s) from old versions of DIRT.
# this intentionally hardcodes a bunch of directories and files.
sub dirt_migrate
{
    $newIDfile = $ENV{'HOME'} . "/.dirt/id";

    my $vers = get_version();
    if( $vers eq "1.4" ) {
	printf "Dirt resources already at version 1.4\n";
	return;
    }

    printf "Migrating from version $vers\n";

    $create_newdirs = 0;
    $create_default = 0;
    $migrate_stacks = 0;

    if( $vers eq "1.1" )
    {
	$create_newdirs = 1;
	$create_default = 1;
    }

    if( $vers eq "1.2" )
    {
	$create_newdirs = 1;
	$migrate_stacks = 1;
    }

    if( $vers eq "1.3" )
    {
	# do nothing
    }
    
    if( $create_newdirs == 1 )
    {
	$d1 = $ENV{'HOME'} . "/.dirt";
	if( !-e $d1 ) {  `mkdir $d1`; }

	$d2 = $ENV{'HOME'} . "/.dirt/piles";
	if( !-e $dirtpiledir ) { `mkdir $dirtpiledir`; }
    }


    if( $create_default == 1 )
    {
	$old_default_dirtpile = $ENV{'HOME'} . "/.dirtpile";
	$default_dirtpile = $ENV{'HOME'} . "/.dirt/piles/default";
	`mv $old_default_dirtpile $default_dirtpile`;

	open OF, ">$newIDfile";
	print OF "default";
	close OF;
    }

    if( $migrate_stacks == 1 )
    {
	# first, copy over all of the old stacks...
	opendir ID, $ENV{'HOME'};
	foreach $de (readdir ID )
	{
	    next if ( ".dirtpile-" ne substr $de, 0, 10 );
	    $newshortname = $de;
	    $newshortname =~ s/^.dirtpile-//g;

	    $oldfn = $ENV{'HOME'} . "/" . $de;
	    $newfn = $ENV{'HOME'} . "/.dirt/piles/" . $newshortname;

	    `mv $oldfn $newfn`;
	}

	# next, copy over the current ID
	$oldIDfile = $ENV{'HOME'} . "/.dirtpile__id";
	`mv $oldIDfile $newIDfile`;

	# finally, copy over the base name to the new id.
	open IF, "$newIDfile";
	$newid = <IF>;
	close IF;

	$oldStack = $ENV{'HOME'} . "/.dirtpile";
	$newStack = $ENV{'HOME'} . "/.dirt/piles/" . $newid;
	`mv $oldStack $newStack`;
    }

    # set the current version number to the file
    open OF, ">$dirtversion";
    print OF "1.4";
    close OF;
    $dirtid = $dirtpiledir . "/version";
}

# go to a specific directory in the list
sub dirt_jump
{
    $dno = shift;
    &dirt_read_pile;
    $nwd = $dirtpile[$dno];
    printf "cd %s\n", $nwd;
}

# push the current directory onto the list
sub dirt_push
{
    &dirt_read_pile;
    if( $ARGV[1] eq "" )
    {
	push @dirtpile, cwd();
    } else {
	push @dirtpile, $ARGV[1];
    }
    &dirt_write_pile;
}

# pop a directory off of the list
sub dirt_pop
{
    &dirt_read_pile;
    $nwd = pop @dirtpile;
    &dirt_write_pile;
    printf "cd %s\n", $nwd;
}

# go to the top of the list
sub dirt_top
{
    &dirt_read_pile;
    $nwd = $dirtpile[-1];
    printf "cd %s\n", $nwd;
}

# swap cwd with the top of the list
sub dirt_swap
{
    &dirt_read_pile;
    $owd = cwd();
    $nwd = pop @dirtpile;
    push @dirtpile, $owd;
    &dirt_write_pile;
    printf "cd %s\n", $nwd;
}

sub main
{
    # automigrate
    if( get_version() ne "1.4" ) {
	&dirt_migrate;
    }

    if ($ARGV[0] eq "push") {
	&dirt_push;
    } elsif ($ARGV[0] eq "pop") {
	&dirt_pop;
    } elsif ($ARGV[0] eq "top") {
	&dirt_top;
    } elsif ($ARGV[0] eq "swap") {
	&dirt_swap;
    } elsif ($ARGV[0] eq "jump") {
	if ($ARGV[1] =~ m/\d+/)
	{
	    dirt_jump($ARGV[1]);
	} else {
	    printf "echo Bad directory selector: %s\n", $ARGV[1];
	}
    } elsif ($ARGV[0] eq "list") {
	&dirt_list;
    } elsif ($ARGV[0] eq "migrate") {
	&dirt_migrate;
    } elsif ($ARGV[0] eq "file" ) {
    	printf( "%s%s\n", $dirtpiledir, dirt_currentid() );
    } else {
	&usage;
    }
}

&main;
