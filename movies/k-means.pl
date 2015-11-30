#!/usr/bin/perl
use strict;
use warnings;
use User;

########### MAIN ######################

# Check for proper number of args
if ($#ARGV + 1 < 1) {
  print "Usage: $0 ratings.csv\n";
  exit;
}

# Open the ratings file
open(my $ratingsFile, '<:encoding(UTF-8)', $ARGV[0])
  or die "Could not open file '$ARGV[0]'";

my @users = [];
my $currentId = 0;

# Loop through the ratings file
while (my $line = <$ratingsFile>) {
  my @values = split(',', $line);
  my $id = $values[0];
  my $movieId = $values[1];
  my $rating = $values[2];

  if ($currentId == $id) {
    $users[$id]->setRating($movieId, $rating);
  }
  else {
    $currentId = $id;
    $users[$id] = new User($id, 1);
    $users[$id]->setRating($movieId, $rating);
  }
}

# Close the ratings file
close($ratingsFile);

my $dist = calcDist($users[12], $users[21]);
print "Distance: $dist\n";


########### FUNCTIONS ##################

# Calculates and returns the distance between 2 users based on their ratings
# Euclidian Distance
sub calcDist {
  # Get and validate arguments
  my ($user1, $user2) = @_;
  if (!defined($user1) || !defined($user2)) {
    die "Not enough args given to calcDist()";
  }

  my $numInCommon = 0;
  my $squaredTotal = 0;
  my $ratings1 = $user1->getRatings();
  keys %$ratings1;
  while(my($movieId, $rating) = each %$ratings1) {
    if ($user2->hasRated($movieId)) {
      $squaredTotal += ($rating - $user2->getRating($movieId)) ** 2;
      $numInCommon++;
    }
  }

  print "In Common: $numInCommon\n";
  return sqrt($squaredTotal);
}
