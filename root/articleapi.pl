#!/usr/bin/perl -wT
use strict;
$|++;
use lib '../lib';
use lib '../lib/CPAN';
use API::Dispatch;
Dispatch::execute();
