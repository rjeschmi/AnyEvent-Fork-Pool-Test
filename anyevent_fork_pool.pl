#!/usr/bin/env perl
use AnyEvent;
use AnyEvent::Fork::Pool;
use lib './lib';

   # use AnyEvent::Fork is not needed

   # all possible parameters shown, with default values
   my $pool = AnyEvent::Fork
      ->new
      ->require ("MyWorker")
      ->AnyEvent::Fork::Pool::run (
           "MyWorker::run", # the worker function

           # pool management
           max        => 4,   # absolute maximum # of processes
           idle       => 0,   # minimum # of idle processes
           load       => 2,   # queue at most this number of jobs per process
           start      => 0.1, # wait this many seconds before starting a new process
           stop       => 10,  # wait this many seconds before stopping an idle process
           on_destroy => (my $finish = AE::cv), # called when object is destroyed

           # parameters passed to AnyEvent::Fork::RPC
           async      => 0,
           on_error   => sub { die "FATAL: $_[0]\n" },
           on_event   => sub { my @ev = @_ },
           serialiser => $AnyEvent::Fork::RPC::STRING_SERIALISER,
        );

   for my $input (1..100) {
      $pool->($input, sub {
        my ($ret) = @_;
         print "MyWorker::run returned $ret\n";
      });
   }

   undef $pool;

   $finish->recv;
