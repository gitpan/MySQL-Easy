# vi:fdm=marker fdl=0 syntax=perl:
# $Id: main.t,v 1.9 2002/08/28 21:04:59 jettero Exp $

use Test;

# plan tests => 4;
 plan tests => 1;

use MySQL::Easy; ok 1;

# these tests only work on the devel machine

# no good without the tables set up...
__END__
 my $dbo = new MySQL::Easy("stocks"); $dbo->set_user("jettero");
 ok $dbo; # 2
 my $show = $dbo->ready("show tables");
 ok $show; # 3

 my $h = $dbo->selectall_hashref( $show, "Tables_in_stocks" );
 ok ref($h) eq "HASH";

 print STDERR " ", join(", ", keys %$h), "\n";
