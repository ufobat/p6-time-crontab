#!/usr/bin/env perl6
use v6;
use lib 'lib';
use Test;
use Time::Crontab;

plan 19;

my $with-sec    = get-datetime();
my $without-sec = $with-sec.truncated-to('minute');
my $crontab     = "* * * * *";
my $tc          = Time::Crontab.new(:$crontab);

ok(  $tc.match($without-sec),       "$crontab matches $without-sec");
nok( $tc.match($with-sec),          "$crontab matches $with-sec");
ok(  $tc.match($without-sec.posix), "$crontab matches $without-sec as posix timestamp");
nok( $tc.match($with-sec.posix),    "$crontab matches $with-sec as posix timestamp");

# tests from perl5 Time::Crontab
cron-ok(   '*/5 * * * *', 0, 0, 26, 12, 2013);
cron-ok(   '*/5 * * * *', 0, 0, 26, 12, 2013);
cron-notok('0 0 13 * 5',  0, 1,  6, 12, 2013);
cron-notok('0 0 * * 0',   0, 0, 13,  8, 2013); # 0==sun, but day is Tuesday 13th Aug 2013
cron-notok('0 0 * * 1',   0, 0, 13,  8, 2013); # 1==mon, but day is Tuesday 13th Aug 2013
cron-ok(   '0 0 * * 2',   0, 0, 13,  8, 2013); # 2==tue, but day is Tuesday 13th Aug 2013
cron-notok('0 0 * * 3',   0, 0, 13,  8, 2013); # 3==wed, but day is Tuesday 13th Aug 2013
cron-notok('0 0 * * 4',   0, 0, 13,  8, 2013); # 4==thu, but day is Tuesday 13th Aug 2013
cron-notok('0 0 * * 5',   0, 0, 13,  8, 2013); # 5==fri, but day is Tuesday 13th Aug 2013
cron-notok('0 0 * * 6',   0, 0, 13,  8, 2013); # 6==sat, but day is Tuesday 13th Aug 2013
cron-notok('0 0 * * 7',   0, 0, 13,  8, 2013); # 7==sun, but day is Tuesday 13th Aug 2013
cron-notok('0 0 13 8 7',  0, 0, 13,  8, 2013); # 7==sun, but day is Tuesday 13th Aug 2013 - special check!
cron-ok(   '0 0 13 8 2',  0, 0, 13,  8, 2013); # 2==tue, and day is Tuesday 13th Aug 2013 - special check!
cron-notok('0 0 13 * 5',  0, 0, 13,  1, 2013); # defined day and dow => day or dow
cron-notok('0 0 13 * 5',  0, 0,  6, 12, 2013); # defined day and dow => day or dow

sub cron-ok(Str $crontab, $minute, $hour, $day, $month, $year) {
    my $datetime = DateTime.new(:$year, :$month, :$hour, :$minute, :$day);
    my $tc = Time::Crontab.new(:$crontab);
    ok($tc.match($datetime), "$crontab matches $datetime");
}

sub cron-notok(Str $crontab, $minute, $hour, $day, $month, $year) {
    my $datetime = DateTime.new(:$year, :$month, :$hour, :$minute, :$day);
    my $tc = Time::Crontab.new(:$crontab);
    nok($tc.match($datetime), "$crontab matches $datetime");
}

sub get-datetime {
    my $dt = DateTime.now;
    while $dt.whole-second == 0 {
        sleep 1;
        $dt = DateTime.now;
    }
    return $dt;
}
