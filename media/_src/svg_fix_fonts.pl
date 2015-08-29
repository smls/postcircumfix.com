#!/usr/bin/perl
use warnings;
use strict;


my $googleurl = 'http://fonts.googleapis.com/css?family=Raleway:500|Merriweather:400,400italic,700,700italic|Source+Code+Pro';

my %fonts = (
    'Raleway'         => q[Raleway, 'Trebuchet MS', Helvetica, sans-serif],
    'Merriweather'    => q[Merriweather, 'Palatino Linotype', 'Book Antiqua', serif],
    'Source Code Pro' => q['Source Code Pro', 'Lucida Console', Monaco, monospace],
);


my $file = shift(@ARGV) // die "Must pass a file\n";
my $svg = do {
    local $/;
    
    open my $fh, '<', $file or die "Couldn't open file: $!";
    <$fh>
};

my $css;
my $i = 0;

for my $name (sort keys %fonts) {
    my $family = $fonts{$name};
    my $class = "fnt" . $i++;
    my $found;
    
    $svg =~ s{font-family="[^"]*$name[^"]*"}{
        $found++;
        qq[class="$class"]
    }ge;
    
    if ($found) {
        print STDERR " - $found uses of $name\n";
        $css .= ".$class { font-family: $family }\n";
    }
}

if (length $css) {
    my $inc = qq[<link xmlns="http://www.w3.org/1999/xhtml" href='$googleurl' rel='stylesheet' type='text/css' />];
    
    if ($svg =~ m|</defs>|) {
      if ($svg =~ m|</style>|) {
          substr($svg, $-[0], 0) = $css;
          $svg =~ s|(?=</defs>)|$inc\n|;
      }
      else {
          $svg =~ s|(?=</defs>)|$inc\n<style type="text/css">$css</style>|;
      }
    }
    elsif ($svg =~ m|<svg[^>]?>|) {
        substr($svg, $+[0], 0)
            = qq[<defs>\n$inc\n<style type="text/css">$css</style></defs>]
    }
    else { die "Failed to patch SVG." }
}

open my $fh, '>', "$file" or die "Couldn't open file: $!";
print $fh $svg;
