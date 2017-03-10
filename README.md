# Dirt

DIRectory stack Tool

This is a cross-instance persistent directory stack utility.  It
is meant for maintaining multiple lists of directory stacks for a
project.  You can use it like the builtin pushd/popd if you want,
or you can use it to just push directories onto the stack for a
project and just jump to specific directories from there.

This originally started out as a MS-DOS program I wrote in the late
1990s and has since been converted to perl, and fine-tuned over the
past 16 years to work just about everywhere. (NOTE: not tested on
Mars)

Since all of the files are stored as flat text files in your home
directory, they can be accessed by every shell instance on that
machine.  This means that you can "push" a directory in one shell,
and "pop" or "jump" to it in another shell... or the next time you
log in.  You can also directly edit and manipulate these files as
the dirt tool only accesses them when you run its commands.

The latest version of this should be found at 

   https://github.com/BleuLlama/dirt


## Setup

The first thing to do is to copy 'dirt.pl' into your path somwhere.
Personally, I have a "sw" directory in my home that has stuff like
this in it.  be sure that it is executable, and that the #! in the
top of the file points to your specific install of perl.

    cp dirt.pl ~/sw/bin/dirt
    chmod 755 ~/sw/bin/dirt

Next, make sure that the aliases get run in your .profile or other
bash startup script.

    cp aliases.sh ~/.aliases.dirt.sh
    echo ". \"$HOME/.aliases.dirt.sh\"" >> ~/.profile
    
Or of course, do all this stuff in whatever way you want. You're a
smart person, you know what you doing.

Start a new shell to try it out.


## Commands

The basic idea is that you have "piles" of directories.  When you
start out, you use a pile named "default".   To add a directory to
this pile, just type

    dpush 

And your current directory will be pushed to the current pile.

If you go somewhere else, and push, you can have anotehr directory
on that pile

    cd /etc
    dpush

Now, to see what's on the current pile, type 

    ddirs

Which will output something like this:

    list[ default ]
         0 -2  /home/cooluser/
         1 -1  /etc

As you'd expect, you can pop off the stack using 'dpop', which will
remove the bottom item from the stack and cd you to there.

HOWEVER, you can also just jump to a directory without popping it,
by specifying a number seen in the left columns.

    djump -2

or

    djump 0

Will cd you to the first directory as seen above.  Note that the
numbers, especially the negative ones, will change as you interact
with the pile.

To change piles, simply specify the new pile name with 'ddirs'

    ddirs games

And now, that is the current pile.  You can always switch to the
default by specifying it:

    ddirs default

There's also a directory swap which can be used:

    dswap

Which replaces your current directory with the one in the pile.
It's a kind of combined pop/push thing.

You can also use the autocomplete, by hitting 'tab' in bash. for example:

    ddirs [tab]

and you'll see the list of piles...


## Internals

The directory piles are stored in a dot-folder in your home directory:

	~/.dirt/
		id
		piles/
		version

The "id" file shows the current directory stack, and the "version"
file has the current save file version number in it, which is
necessary for migrating in case things change in the future.

The "piles" folder contains one file per pile, containing one
directory path on each individual line.  This file can be directly
edited without any problems. In fact. to make it easy, there's an
alias for editing it in vi.

	dvi

You can also save and restore these, or edit them to remove or 
prune out unnecessary directories.


## License

This is under an MIT license.  File included in the repository.
