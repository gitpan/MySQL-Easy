# vi:fdm=marker fdl=0 syntax=perl:
# $Id: 01_load.t,v 1.1 2006/03/30 12:16:20 jettero Exp $

use Test;

plan tests => 1;

eval {use MySQL::Easy}; ok not $@;
