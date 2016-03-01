package Client::Dispatch;

use strict;
use warnings;
use diagnostics;

use Client::Modules;
use Client::Function;

my %cgi_params = Function::get_cgi_params_from_path_info("function", "one", "two", "three", "four");


my $dispatch_for = {
    showerror          =>   sub { return \&do_sub(       "Function",       "do_invalid_function"      ) },
    createpost         =>   sub { return \&do_sub(       "CreatePost",     "create_post"              ) },
    compose            =>   sub { return \&do_sub(       "Compose",        "show_new_post_form"       ) },
};

sub execute {
    my $function = $cgi_params{function};

    $dispatch_for->{compose}->() if !defined($function) or !$function;

#    $dispatch_for->{post}->($function) unless exists $dispatch_for->{$function} ;

    defined $dispatch_for->{$function}->();
}

sub do_sub {
    my $module = shift;
    my $subroutine = shift;
    eval "require Client::$module" or Page->report_error("user", "Runtime Error (1):", $@);
    my %hash = %cgi_params;
    my $coderef = "$module\:\:$subroutine(\\%hash)"  or Page->report_error("user", "Runtime Error (2):", $@);
    eval "{ &$coderef };" or Page->report_error("user", "Runtime Error (2):", $@) ;
}

1;
