# vi:set syntax=perl:

use ExtUtils::MakeMaker;

print STDERR "  **** Do not use this unless you need it for legacy purposes. ****\n";
print STDERR "  **** Use DBIx::Easy::MySQL instead -- iff you need it at all. ****\n";
sleep 5;

WriteMakefile(
    'NAME'		=> 'MySQL::Easy',
    'VERSION_FROM'	=> 'Easy.pm',
    'PREREQ_PM'         => { DBI => 0, 'DBD::mysql' => 0, 'DBIx::Easy' => 0 },
);
