package Posts;

use strict;
use warnings;

use API::CreatePost;

sub posts {
    my $tmp_hash = shift;

    my $page_num = 0;
    my $q = new CGI;
    $page_num = $q->param("page") if $q->param("page");

    my $request_method = $q->request_method();

    if ( $request_method eq "POST" ) {
        CreatePost::create_post();
    }
    Error::report_error("400", "Not found", "Invalid request");  
}

1;


