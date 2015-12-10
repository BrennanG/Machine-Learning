#!/usr/bin/perl
use strict;
use warnings;
use User;
use Cluster;

# Predicts what each user in the ratingsToPredict.csv file would rate the specified movie
# by putting each user into 1 of k clusters

# Output: userId predictedRating

# Arguments:
#   trainingFile.csv
#     -a movie ratings file (without the header line that describes each column)
#     -userIds should be numbered from 1 to n
#     -formatted as follows: userId,movieId,rating,timestamp
#     -this is used as the training data
#   ratingsToPredict.csv
#     -a file with the same format as trainingFile.csv
#     -userIds should also be numbered from 1 to n
#     -the program will output a guess for each of these user's rating of the specified movie
#   movieId
#     -the id of the movie whose rating should be predicted for each user in ratingsToPredict.csv



my $K = 4; # Number of clusters
########### MAIN ######################

# Handle arguments
if ($#ARGV + 1 < 3) {
  print "Usage: $0 trainingFile.csv ratingsToPredict.csv movieId\n";
  exit;
}
my $trainingFile = $ARGV[0];
my $ratingsToPredict = $ARGV[1];
my $movieToPredict = $ARGV[2];

# Create the $users and $clusters array references
my $users = createUsersFromFile($trainingFile);
my $clusters = createClusters($users);

# Adjust the clusters by continually looping until no user changes clusters
adjustClusters($users, $clusters);

my $usersToCheck = createUsersFromFile($ratingsToPredict);
foreach my $userToCheck (@$usersToCheck) {
  my $closest = getClosestCluster($userToCheck, $clusters);
  my $ratingPrediction = $closest->getAverageRatingForMovie($movieToPredict);
  my $id = $userToCheck->getId();
  print "$id $ratingPrediction\n";
}



########### FUNCTIONS ##################

# Reads the file corresponding to the given fileName, filling and returning a reference to an array of users (indexed from 1)
sub createUsersFromFile {
  # Handles arguments
  my ($fileName) = @_;
  if (!defined($fileName)) {
    die "Not enough args given to createUsersFromFile()";
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
  close($file);
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

# Calculates and returns the distance between 2 users based on their ratings
# Euclidian distance weighted by how many movies both users have rated ($numInCommon)
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
  
  if ($numInCommon != 0) { return sqrt($squaredTotal)/$numInCommon; }
  else { return 50; }
}

# Adjusts the clusters by repeatedly putting them in their closest clusters, then readjusting the clusters' centers,
# until no user changes clusters
sub adjustClusters {
  # Handle arguments
  my ($users, $clusters) = @_;
  if (!defined($users) || !defined($clusters)) {
    die "Not enough args given to adjustClusters()";
  }

  # Loop until no user changes clusters
  my $count = 0;
  while (1) {
    # Loop through users and put them in their closest clusters
    my $userChangedClusters = 0;
    foreach my $user (@$users) {
      my $closestCluster = getClosestCluster($user, $clusters);

      # Set the user's and cluster's fields if it changed
      if ($user->getCluster() != $closestCluster->getId()) {
        $user->setCluster($closestCluster->getId());
        $closestCluster->addUser($user);
        $userChangedClusters++;
      }
    }
    
    # Break out if no user changed clusters
    if ($userChangedClusters == 0) { last; }

    # Assign new clusters centers
    foreach my $cluster (@$clusters) {
      my $num = $cluster->getNumOfUsers();
      $cluster->assignNewCenter();
    }

    $count++;
  }
}

# Returns the closest cluster to the given user
sub getClosestCluster {
  my ($user, $clusters) = @_;
  if (!defined($user) || !defined($clusters)) {
    die "Not enough args given to getClosestCluster()";
  }

  my $userId = $user->getId();
  my $closestCluster = $clusters->[0];
  my $closestDist;
  # Compare each cluster's center with user to find the closest
  foreach my $cluster (@$clusters) {
    if ($userId == $cluster->getCenter()->getId()) { next; } # Skip if the user is the center

    my $dist = calcDist($user, $cluster->getCenter());
    if (!defined($closestDist) || $dist < $closestDist) {
      $closestCluster = $cluster;
      $closestDist = $dist;
    }
  }

  return $closestCluster;
}
