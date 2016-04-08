use Time::Crontab::Set;

class Time::Crontab::Actions {

    method dow-value($/) { $/.make: +$/ % 7 }
    method dows($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::dow, $/);
    }

    method month-value($/) { $/.make: +$/ }
    method months($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::month, $/);
    }

    method dom-value($/) { $/.make: +$/ }
    method doms($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::dom, $/);
    }

    method hour-value($/) { $/.make: +$/ }
    method hours($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::hour, $/);
    }

    method minute-value($/) { $/.make: +$/ }
    method minutes($/) {
        $/.make: self!make_node(Time::Crontab::Set::Type::minute, $/);
    }

    method !make_node(Time::Crontab::Set::Type $type, Match $/) {
        my $prefix = $type.Str;
        my $set = Time::Crontab::Set.new(type => $type);

        for $/{$prefix}.map({ .hash.pairs[0] }) -> $p {
            given $p.key {
                when $prefix ~ '-value'    { $set.enable($p.value.made) }
                when $prefix ~ '-any'      { $set.enable-any() }
                when $prefix ~ '-any-step' {
                    my $step = $p.value{$prefix ~ '-value'}.made;
                    $set.enable-any($step)
                }
                when $prefix ~ '-range'    {
                    my ($from, $to) = $p.value{$prefix ~ '-value'}».made;
                    $set.enable($from, $to);
                }
                when $prefix ~ '-range-step' {
                    my ($from, $to, $step) = $p.value{$prefix ~ '-value'}».made;
                    $set.enable($from, $to, $step);
                }
                when $prefix ~ '-disable' {
                    my $value = $p.value{$prefix~ '-value'}.made;
                    $set.disable($value);
                }
            }
        }
        return $set;
    }

    method TOP($/) {
        my @set = ($/<minutes>.made, $/<hours>.made, $/<doms>.made, $/<months>.made, $/<dows>.made);
        $/.make: @set;
    }
}
