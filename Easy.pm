package MySQL::Easy;

# $Id: Easy.pm,v 1.12 2002/02/25 18:58:45 jettero Exp $
# vi:fdm=marker fdl=0:

use strict;
use warnings;
use Carp;

use DBI;

our $VERSION = "0.99.7b";

return 1;

# new {{{
sub new { 
    my $this  = shift;

    $this = bless {}, $this;

    $this->{dbase} = shift;
    $this->{trace} = shift;

    return $this;
}
# }}}

# do {{{
sub do {
    my $this = shift; return unless @_;

    my $e = $SIG{__WARN__}; $SIG{__WARN__} = sub {};
    my $r = $this->ready(shift)->execute(@_) or croak $this->errstr;

    $SIG{__WARN__} = $e;

    return $r;
}
# }}}
# lock {{{
sub lock {
    my $this   = shift; return unless @_;
    my $tolock = join(", ", map("$_ write", @_));

    $this->handle->do("lock tables $tolock");
}
# }}}
# unlock {{{
sub unlock {
    my $this = shift;

    $this->handle->do("unlock tables");
}
# }}}
# ready {{{
sub ready {
    my $this = shift;

    return $this->handle->prepare(@_);
}
# }}}
# firstcol {{{
sub firstcol {
    my $this = shift;
    my $query = shift;

    return $this->handle->selectcol_arrayref($query, undef, @_);
}
# }}}
# trace {{{
sub trace {
    my $this  = shift;

    $this->{trace} = shift;
    $this->handle->trace($this->{trace});
}
# }}}
# errstr {{{
sub errstr {
    my $this = shift;

    return $this->handle->errstr;
}
# }}}
# last_insert_id {{{
sub last_insert_id {
    my $this = shift;

    return $this->firstcol("select last_insert_id()")->[0];
}
# }}}

sub DESTROY {
    my $this = shift;

    $this->{dbh}->disconnect if $this->{dbh};
}

# handle {{{
sub handle {
    my $this = shift;

    if(not $this->{dbh}) {
        ($this->{user}, $this->{pass}) = $this->unp unless $this->{user} and $this->{pass};

        $this->{host}  = "localhost" unless $this->{host};
        $this->{dbase} =      "test" unless $this->{dbase};
        $this->{trace} =           0 unless $this->{trace};

        $this->{dbh} = DBI->connect("DBI:mysql:$this->{dbase}:$this->{host}", $this->{user}, $this->{pass});
        $this->{dbh}->trace($this->{trace}) if $this->{dbh};
    }

    return $this->{dbh};
}
# }}}
# unp {{{
sub unp {
    my $this = shift;

    my ($user, $pass);

    open PASS, "$ENV{HOME}/.my.cnf" or die "$!";

    my $l;
    while($l = <PASS>) {
        $user = $1 if $l =~ m/user\s*=\s*(.+)/;
        $pass = $1 if $l =~ m/password\s*=\s*(.+)/;

        last if($user and $pass);
    }

    close PASS;

    return ($user, $pass);
}
# }}}

# set_host set_user set_pass {{{
sub set_host { (shift)->{host} = shift }
sub set_user { (shift)->{user} = shift }
sub set_pass { (shift)->{pass} = shift }
# }}}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

MySQL::Easy - Perl extension to make your base code kinda pretty.

=head1 SYNOPSIS

  use MySQL::Easy;

  my $dbo = new MySQL::Easy("stocks");

  my $symbols = $dbo->firstcol(
      qq( select symbol from ohlcv where symbol != ?),
      "msft"
  );

  for(@$symbols) {
      my $q = $dbo->ready("select * from ohlcv where symbol=?");
      my @a;

      execute $q;
      print "@a" while @a = fetchrow_array $q;
  }

=head1 DESCRIPTION

   I don't remember how I used to live without this...
   I do like the way DBI and DBD work, but I wanted something
   _slightly_ prettier... _slightly_ handier.

   Here's the functions MySQL::Easy provides:

   $dbo = new MySQL::Easy( $db_name, $trace );
       # $db_name is the name of the database you're connecting to...
       # If you don't pick anything, it'll pick "test" for you.
       # $trace is a 1 or false, ... it's the DBI->trace() ...

   $dbo->do("sql statement bind=? bind=?", $bind1, $bind2);
       # this immediately executes the sql with the bind vars
       # given.  You can pas in a statement handle
       # instead of the string... this is faster if you're going
       # to use the sql over and over.  Returns a t/f like you'd
       # expect.  (i.e. $dbo->do("stuff") or die $dbo->errstr);

   $dbo->lock("table1", "table2", "table3");
       # MySQL::Easy uses only write locks.  Those are the ones
       # where nobody can read or write to the table except the
       # locking thread.  If you need a read lock, let Jet know.
       # Most probably though, if you're using this, it's a
       # smaller app, and it doesn't matter anyway.
   $dbo->unlock;

   $sth = $dbo->ready("Sql Sql Sql=? and Sql=?");
       # returns a DBI statement handle...
       # $sth->execute($bindvar); $sth->fetchrow_hashref; etc...

   $arr = $dbo->firstcol("select col from tab where x=? and y=?", $x, $y)
       # returns an arrayref of values for the sql.
       # You know, print "val: $_\n" for @$arr;
       # very handy...

   $id = $dbo->last_insert_id;
       # self explainatory?

   $dbo->trace(1); $dbo->do("sql"); $dbo->trace(0);
       # turns the DBI trace on and off.

   $dbo->errstr
       # returns an error string for the last error on the
       # thread...  Same as a $sth->errstr.  It's actually
       # described in DBI

   $dbo->set_host($h); $dbo->set_user($U); $dbo->set_pass($p);
       # The first time you do a do/ready/firstcol/etc,
       # MySQL::Easy connects to the database.  You may use these
       # set functions to override values found in your ~/.my.cnf
       # for user and pass.  MySQL::Easy reads _only_ the user
       # and pass from that file.  The host name will default to
       # "localhost" unless explicitly set.  Also, it will die on
       # a fatal error if the user or pass is false and the
       # ~/.my.cnf cannot be opened.

=head1 AUTHOR

Jettero Heller <japh@voltar-confed.org>

   Jet is using this software in his own projects...
   If you find bugs, please please please let him know. :)

   Actually, let him know if you find it handy at all.
   Half the fun of releasing this stuff is knowing 
   that people use it.

=head1 SEE ALSO

perl(1), DBI(3)

=cut
