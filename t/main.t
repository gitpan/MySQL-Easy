# vi:fdm=marker fdl=0 syntax=perl:
# $Id: main.t,v 1.7 2002/06/05 00:01:36 jettero Exp $

use Test;

plan tests => 1;

use MySQL::Easy; ok 1;

# these tests only work on the devel machine

# no good without the tables set up...
# my $dbo = new MySQL::Easy("stocks"); $dbo->set_user("jettero");
# ok $dbo; # 2
# my $show = $dbo->ready("show tables");
# ok $show; # 3
