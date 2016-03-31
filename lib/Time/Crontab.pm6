use v6;

unit module Time::Crontab;
use Time::Crontab::Grammar;
use Time::Crontab::Actions;
use Time::Crontab::Set;

class Time::Crontab {
    has Int $.timezone;
    has Str $.crontab;
    has Time::Crontab::Set $!minute;
    has Time::Crontab::Set $!hour;
    has Time::Crontab::Set $!dom;
    has Time::Crontab::Set $!month;
    has Time::Crontab::Set $!dow;
    
    submethod BUILD(:$!crontab!, :$!timezone = 0)  {
        my $actions = Time::Crontab::Actions.new();
        my $bean = Time::Crontab::Grammar.parse($!crontab, :$actions).made;
        die "$!crontab is syntactically wrong" unless $bean;
        ($!minute, $!hour, $!dom, $!month, $!dow) = $bean;
    }
    
    multi method match(Int $posix) {
        return self.match(DateTime.new($posix, :$.timezone));
    }
    
    multi method match(DateTime $datetime, Bool :$truncate = False) {
        my $dt = $datetime.in-timezone($.timezone);
        unless $!minute.contains($datetime.minute) {
            #say "minutes missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
            return False;
        }
        unless $!hour.contains($datetime.hour) {
            #say "hours missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
            return False;
        }
        unless $!month.contains($datetime.month) {
            #say "month missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
            return False;
        }

        # if dow (or dom) has a 'any' == '*' react as if there if no dow (or dom) at all.
        if $!dow.all-enabled && $!dom.all-enabled {
            # just continue, no need to check anything
        }elsif $!dow.all-enabled && ! $!dom.all-enabled {
            # just check dom
            unless $!dom.contains($datetime.day-of-month) {
                #say "dom missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
                return False;
            }
        }elsif ! $!dow.all-enabled && $!dom.all-enabled {
            # just check dow
            unless $!dow.contains($datetime.day-of-week % 7) { # %7 to make sunday (7th day) to the 0th day ;)
                #say "dow missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
                return False;
            }
        }else {
            # check both
            unless $!dom.contains($datetime.day-of-month) ||  $!dow.contains($datetime.day-of-week % 7) {
                #say "dom/dow missmatch: date = {$datetime.minute} vs parsed crontab = { $!minute.hash{$datetime.minute}:kv }";
                return False;
            }
        }

        if $truncate {
            # don't care for seconds or even smaller fractions of seconds
            return True;
        }else{
            if $datetime.truncated-to('minute') == $datetime {
                #say "$datetime matches the exact minute";
                return True;
            }
            return False;
        }
    }
}

