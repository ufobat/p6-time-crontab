#!/usr/bin/env perl6
use v6;
use lib 'lib';
use Test;
use Time::Crontab::Set;

plan 5;

sub run-test-for(Time::Crontab::Set::Type $type, Int $min, Int $max) {
    subtest {
        plan 9;
        diag $type;
        my $set = Time::Crontab::Set.new(type => $type);
        nok($set.will-ever-execute(), "a new set for $type, with initial values, will-never-execute()");
        my $list;
        $list{$_} = False for ($min..$max);
        is-deeply($set.hash, $list, 'everything is false');
        $set.enable(5);
        ok($set.contains(5), 'element 5 is enabled');
        ok($set.will-ever-execute(), "but it will execute after 5 is enabled");

        $list{5} = True;
        is-deeply($set.hash, $list, '5th element of the list is true');
        
        dies-ok(sub {$set.enable($min-1) }, "enabling element smaller than possible fails");
        dies-ok(sub {$set.enable($max+1) }, "enabling element higher than possible fails");
        lives-ok(sub {$set.enable($min) }, "enabling minimal element");
        lives-ok(sub {$set.enable($max) }, "enabling maximal element");
    }
}

run-test-for(Time::Crontab::Set::Type::minute, 0, 59);
run-test-for(Time::Crontab::Set::Type::hour, 0, 23);
run-test-for(Time::Crontab::Set::Type::dom, 1, 31);
run-test-for(Time::Crontab::Set::Type::month, 1, 12);
run-test-for(Time::Crontab::Set::Type::dow, 0, 6);

