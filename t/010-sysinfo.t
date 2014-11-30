use strict;
use warnings;
use Test::More tests => 5;
use Sys::Statistics::Linux::SysInfo;

my @pf = qw(
  /proc/sys/kernel/hostname
  /proc/sys/kernel/domainname
  /proc/sys/kernel/ostype
  /proc/sys/kernel/osrelease
  /proc/sys/kernel/version
  /proc/cpuinfo
  /proc/meminfo
  /proc/uptime
  /bin/uname
);

foreach my $f (@pf) {
    if ( !-r $f ) {
        plan skip_all => "$f is not readable";
        exit(0);
    }
}

my $sys = Sys::Statistics::Linux::SysInfo->new();
is( $sys->get_proc_arch, undef,
    'get_proc_arch will return undef unless get is invoked first' );
my $stat = $sys->get;

can_ok( $sys,
    qw(new get_proc_arch get_cpu_flags get _get_common _get_meminfo _get_cpuinfo _get_interfaces _get_uptime _calsec)
);

my $cpu_type = $sys->get_proc_arch;

if ( ( $cpu_type == 32 ) or ( $cpu_type == 64 ) ) {

    pass('get_proc_arch returns 32 or 64');

}
else {

    fail('get_proc_arch returns 32 or 64');

}

SKIP: {

    eval { require List::BinarySearch };

    skip "List::BinarySearch not installed", 2 if $@;

    my $flags = $sys->get_cpu_flags;

    is( ref($flags), 'ARRAY', 'get_cpu_flags returns an array reference' );

    my @sorted = sort( @{$flags} );
    my $index =
      &List::BinarySearch::binsearch( sub { $a eq $b }, 'lm', \@sorted );

    if ( defined($index) ) {

        is( $cpu_type, 64, 'the lm flags denotes a 64 processor on Linux' );

    }
    else {

        is( $cpu_type, 32,
            'lm flag was not found so this must be a 32 processor' );

    }

}
