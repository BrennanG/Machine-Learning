#!/usr/bin/perl

package Cluster;

sub new {
  my $class = shift;
  my %params = @_;
  my $self = {
    _center => shift,
    _id     => shift,
    _users  => {},
  };

  bless $self, $class;
  $self->addUser($self->{_center}); # Add the center to _users
  return $self;
}

sub getCenter {
  my ($self) = @_;
  return $self->{_center};
}

sub setCenter {
  my ($self, $center) = @_;
  if (!defined($center)) {
    die "Not enough args given to setCenter()";
  }

  $self->{_center} = $center;
}

sub getId {
  my ($self) = @_;
  return $self->{_id};
}

sub addUser {
  my ($self, $user) = @_;
  if (!defined($user)) {
    die "Not enough args given to addUser()";
  }

  $self->{_users}->{$user->getId()} = $user;
}

sub getUser {
  my ($self, $userId) = @_;
  if (!defined($userId)) {
    die "Not enough args given to getUser()";
  }

  return $self->{_users}->{$userId};
}

sub hasUser {
  my ($self, $user) = @_;
  if (!defined($user)) {
    die "Not enough args given to hasUser()";
  }

  return exists($self->{_users}->{$user->getId()});
}

sub removeUserById {
  my ($self, $userId) = @_;
  if (!defined($userId)) {
    die "Not enough args given to removeUserById()";
  }

  delete($self->{_users}->{$userId});
}

sub removeUserByObject {
  my ($self, $user) = @_;
  if (!defined($user)) {
    die "Not enough args given to removeUserByObject()";
  }

  delete($self->{_users}->{$user->getId()});
}

sub assignNewCenter {
  my ($self) = @_;
  
  my $newCenter = new User(-1, $self->getId());
  my %ratingsHash;
  my %ratingsCount;
  my $users = $self->{_users};
  foreach my $user (values %{$users}) {
    $ratings = $user->getRatings();
    while(my($movieId, $rating) = each %$ratings) {
      if (exists($ratingsHash{$movieId})) {
        $ratingsHash{$movieId} += $rating;
        $ratingsCount{$movieId}++;
      }
      else {
        $ratingsHash{$movieId} = $rating;
        $ratingsCount{$movieId} = 1;
      }
    }
  }

  while(my($movieId, $rating) = each %ratingsHash) {
      $ratingsHash{$movieId} = $ratingsHash{$movieId}/$ratingsCount{$movieId};
  }

  $newCenter->assignNewRatingsHash(\%ratingsHash);
  $self->setCenter($newCenter);
}

sub getAverageRatingForMovie {
  my ($self, $movieId) = @_;
  if (!defined($movieId)) {
    die "Not enough args given to getAverageRatingforMovie()";
  }

  my $sumOfRatings = 0;
  my $count = 0;
  my $users = $self->{_users};
  foreach my $user (values %{$users}) {
    if ($user->hasRated($movieId)) {
      $sumOfRatings += $user->getRating($movieId);
      $count++;
    }
  }

  if ($count == 0) { return 3; } # Best guess for a movie that none of the users have rated is 3
  else { return $sumOfRatings/$count; }
}

sub getNumOfUsers {
  my ($self) = @_;
  my $users = $self->{_users};
  return scalar keys %$users
}

1;











