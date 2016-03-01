package Compose;

use strict;
use warnings;
use diagnostics;

sub show_new_post_form {
    my $t = Page->new("newpostform");
    $t->display_page("Compose new post");
}

1;
