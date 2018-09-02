package Insecure::Demo;
use Dancer2;

# ABSTRACT: demonstration application with security issues

our $VERSION = '0.001';

get '/' => sub {
    template 'index' => { 'title' => 'Insecure::Demo' };
};

true;
