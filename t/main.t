# vi:fdm=marker fdl=0 syntax=perl:
# $Id: main.t,v 1.4 2002/01/17 16:46:18 jettero Exp $

use Test;

plan tests => 3;

use MySQL::Easy; ok 1;


my $dbo = new MySQL::Easy("stocks");
ok $dbo; # 2

my $show = $dbo->ready("show tables");
ok $show; # 3
