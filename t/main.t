# vi:fdm=marker fdl=0 syntax=perl:
# $Id: main.t,v 1.5 2002/02/26 15:14:05 jettero Exp $

use Test;

plan tests => 3;

use MySQL::Easy; ok 1;

# no good without the tables set up...
#my $dbo = new MySQL::Easy("stocks");
#ok $dbo; # 2
#my $show = $dbo->ready("show tables");
#ok $show; # 3
