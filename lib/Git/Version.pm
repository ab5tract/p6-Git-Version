unit module Git::Version;

my %cached = (
    #              v  .w .x  .y rc? rc c
    '0.99.7a' => [ 0, 99, 7,  1, 0, 0, 0 ],
    '0.99.7b' => [ 0, 99, 7,  2, 0, 0, 0 ],
    '0.99.7c' => [ 0, 99, 7,  3, 0, 0, 0 ],
    '0.99.7d' => [ 0, 99, 7,  4, 0, 0, 0 ],
    '0.99.8a' => [ 0, 99, 8,  1, 0, 0, 0 ],
    '0.99.8b' => [ 0, 99, 8,  2, 0, 0, 0 ],
    '0.99.8c' => [ 0, 99, 8,  3, 0, 0, 0 ],
    '0.99.8d' => [ 0, 99, 8,  4, 0, 0, 0 ],
    '0.99.8e' => [ 0, 99, 8,  5, 0, 0, 0 ],
    '0.99.8f' => [ 0, 99, 8,  6, 0, 0, 0 ],
    '0.99.8g' => [ 0, 99, 8,  7, 0, 0, 0 ],
    '0.99.9a' => [ 0, 99, 9,  1, 0, 0, 0 ],
    '0.99.9b' => [ 0, 99, 9,  2, 0, 0, 0 ],
    '0.99.9c' => [ 0, 99, 9,  3, 0, 0, 0 ],
    '0.99.9d' => [ 0, 99, 9,  4, 0, 0, 0 ],
    '0.99.9e' => [ 0, 99, 9,  5, 0, 0, 0 ],
    '0.99.9f' => [ 0, 99, 9,  6, 0, 0, 0 ],
    '0.99.9g' => [ 0, 99, 9,  7, 0, 0, 0 ],
    '0.99.9h' => [ 0, 99, 9,  8, 0, 0, 0 ],    # 1.0.rc1
    '1.0.rc1' => [ 0, 99, 9,  8, 0, 0, 0 ],
    '0.99.9i' => [ 0, 99, 9,  9, 0, 0, 0 ],    # 1.0.rc2
    '1.0.rc2' => [ 0, 99, 9,  9, 0, 0, 0 ],
    '0.99.9j' => [ 0, 99, 9, 10, 0, 0, 0 ],    # 1.0.rc3
    '1.0.rc3' => [ 0, 99, 9, 10, 0, 0, 0 ],
    '0.99.9k' => [ 0, 99, 9, 11, 0, 0, 0 ],
    '0.99.9l' => [ 0, 99, 9, 12, 0, 0, 0 ],    # 1.0.rc4
    '1.0.rc4' => [ 0, 99, 9, 12, 0, 0, 0 ],
    '0.99.9m' => [ 0, 99, 9, 13, 0, 0, 0 ],    # 1.0.rc5
    '1.0.rc5' => [ 0, 99, 9, 13, 0, 0, 0 ],
    '0.99.9n' => [ 0, 99, 9, 14, 0, 0, 0 ],    # 1.0.rc6
    '1.0.rc6' => [ 0, 99, 9, 14, 0, 0, 0 ],
    '1.0.0a'  => [ 1,  0, 1,  0, 0, 0, 0 ],
    '1.0.0b'  => [ 1,  0, 2,  0, 0, 0, 0 ],
);

sub normalize (Str $v is copy) {
    $v ~~ s:g/^v|^git' 'version' '|\.msysgit.*//;
    $v ~~ tr/-/./;
    $v ~~ s/0rc/0.rc/;
    return %cached{$v} if %cached{$v}:exists;

    # compute the version four parts
    my @v = $v.split('.');
    my @r = ( 0, 0 );
    my $c = 0;

    # commit
    if @v[*-1] eq 'GIT' {
        $c = 1;
        @v.pop;
    }

    if @v[*-1].substr(0,1) eq 'g' {
        $c = @v[*-2];
        @v.pop xx 2;
    }

    # rc
    if @v[*-1].substr(0,2) eq 'rc' {
        @v[*-1] ~~ s/rc//;
        @r = ( -1, @v.pop );
    }
    @v.push( 0 ) xx 4-@v;
    @v.append( @r );
    @v.push( $c );
    @v = @v».Int;

    return %cached{$v} = @v;
}

class Git::Version is Version {
    has $.literal;
    has $.normalized = %cached{$!literal} //= normalize($!literal);

    multi method new( Git::Version $v ) { $v }

    multi method new( Str $v ) { Git::Version.Version::new( normalize($v), $v ); }
}
