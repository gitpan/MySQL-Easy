# vi:fdm=marker fdl=0 syntax=perl:
# $Id: 10_connection_loss.t,v 1.1 2004/12/03 16:14:02 jettero Exp $

if( -d "/home/jettero/code/perl/easy" ) {
    use strict;
    use Test;
    use MySQL::Easy;

    plan tests => 3;

    my $dbo1 = new MySQL::Easy("scratch");
    my $dbo2 = new MySQL::Easy("scratch");

    my $thread  = $dbo1->thread_id;
    my $threads = $dbo2->firstcol("show processlist");

    # dbo1 should be running here...
    ok( &is_in($thread, @$threads) );

    $dbo2->do("kill $thread");
    $threads = $dbo2->firstcol("show processlist");

    # dbo1 should NOT be running here
    ok( not &is_in($thread, @$threads) );

    my $sth  = $dbo1->ready("show tables");  execute $sth;  finish $sth;
    $thread  = $dbo1->thread_id;
    $threads = $dbo2->firstcol("show processlist");

    # $dbo1 should be running again!
    ok( &is_in($thread, @$threads) );
}


sub is_in {
    my ($val, @a) = @_;

    for my $v (@a) {
        return 1 if $val == $v;
    }

    return 0;
}
