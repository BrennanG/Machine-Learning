#!/usr/bin/perl
use strict;
use warnings;
use User;
use Cluster;

my $K = 3; # Number of clusters

########### MAIN ######################

# Handle arguments
if ($#ARGV + 1 < 1) {
  print "Usage: $0 ratings.csv\n";
  exit;
}
my $ratingsFile = $ARGV[0];

# Create the $users and $clusters array references
my $users = createUsersFromFile($ratingsFile);
my $clusters = createClusters($users);

# Loop through users and put them in their closest clusters
foreach my $user (@$users) {
  my $userId = $user->getId();
  my $closestCluster = $clusters->[0];
  my $closestDist;
  # Compare each cluster's center with user to find the closest
  foreach my $cluster (@$clusters) {
    if ($userId == $cluster->getCenter()->getId()) { next; }

    my $dist = calcDist($user, $cluster->getCenter());
    if (!defined($closestDist) || $dist < $closestDist) {
      $closestCluster = $cluster;
      $closestDist = $dist;
    }
  }
  
  # Set the user's and cluster's fields
  $user->setCluster($closestCluster->getId());
  $closestCluster->addUser($user);
}

# 2 Assign new clusters centers

# 3 Repeat 1 & 2 until nothing is re-labeled



########### FUNCTIONS ##################

# Reads the file corresponding to the given fileName, filling and returning a reference to an array of users (indexed from 1)
sub createUsersFromFile {
  # Handles arguments
  my ($fileName) = @_;
  if (!defined($fileName)) {
    die "Not enough args given to readUsersFromFile()";
  }

  # Open the file
  open(my $file, '<:encoding(UTF-8)', $fileName)
    or die "Could not open file '$fileName'";

  # Loop through the file, filling @users
  my @users = [];
  my $currentId = 0;
  while (my $line = <$file>) {
    # Split valies into scalar values
    my @values = split(',', $line);
    my $id = $values[0];
    my $movieId = $values[1];
    my $rating = $values[2];

    # If the user is not yet in @users, create a new user object and add it
    if ($currentId != $id) {
      $currentId = $id;
      $users[$id-1] = new User($id, -1);
    }

    $users[$id-1]->setRating($movieId, $rating);
  }

  # Close the file and return
  close($ratingsFile);
  return \@users;
}

# Chooses K users randomly to start as cluster centers, then returns the clusters in the form of an array reference
sub createClusters {
  # Handle arguments
  my ($users) = @_;
  if (!defined($users)) {
    die "Not enough args given to createClusters()";
  }

  # Create the @clusters array with random centers
  my @clusters;
  my %takenCenters;
  my $numOfUsers = scalar(@{$users});
  for (my $i = 0; $i < $K; $i++) {
    my $randomUser;
    do { # Don't want to get the same center for 2 different clusters
      $randomUser = $users->[rand($numOfUsers)];
    } while (exists($takenCenters{$randomUser->getId}));

    $takenCenters{$randomUser->getId} = 1;
    $clusters[$i] = new Cluster($randomUser, $i);
  }

  return \@clusters;
}

# Calculates and returns the (Euclidian) distance between 2 users based on their ratings
sub calcDist {
  # Handle arguments
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

  return sqrt($squaredTotal);
}
