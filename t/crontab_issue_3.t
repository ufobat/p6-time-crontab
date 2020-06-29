use lib 'lib';
use Test;
use Time::Crontab;

plan 2;

my $somewhen = DateTime.new('2020-06-29T09:04:00Z');

subtest {
    my $tc = Time::Crontab.new(crontab => '* * * * 0');
    my $dt = $tc.next-datetime($somewhen);
    my $expectation = DateTime.new('2020-07-05T00:00:00Z');
    is $dt, $expectation;

}, "* * * * 0";


subtest {
    my $tc = Time::Crontab.new(crontab => '0 * * * 0');
    my $dt = $tc.next-datetime($somewhen);
    my $expectation = DateTime.new('2020-07-05T00:00:00Z');
    is $dt, $expectation;
}, "0 * * * 0";

done-testing;
