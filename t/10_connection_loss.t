# vi:fdm=marker fdl=0 syntax=perl:
# $Id: 10_connection_loss.t,v 1.2 2005/05/25 15:09:51 jettero Exp $

if( -d "/home/jettero/code/perl/easy" ) {
    use strict;
    use Test;
    use MySQL::Easy;

    plan tests => 5;

    my $dbo1 = new MySQL::Easy("scratch"); my $dies = $dbo1->ready("select count(*) from aga");
    my $dbo2 = new MySQL::Easy("scratch");

    execute $dies or die $dbo1->errstr;
    if( my ($c) = fetchrow_array $dies ) {
        ok( $c > 0 );
    }
    finish $dies;

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

    # but more importantly, ... 
    execute $dies or die $dbo1->errstr;
    if( my ($c) = fetchrow_array $dies ) {
        ok( $c > 0 );
    }
    finish $dies;
}


sub is_in {
    my ($val, @a) = @_;

    for my $v (@a) {
        return 1 if $val == $v;
    }

    return 0;
}
