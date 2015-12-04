#!/usr/bin/perl

package User;

sub new {
  my $class = shift;
  my %params = @_;
  my $self = {
    _id      => shift,
    _cluster => shift,
    _ratings => {},
  };

  bless $self, $class;
  return $self;
}

sub getId {
  my ($self) = @_;
  return $self->{_id};
}

sub getCluster {
  my ($self) = @_;
  return $self->{_cluster};
}

sub setCluster {
  my ($self, $cluster) = @_;
  if (!defined($cluster)) {
    die "Not enough args given to setCluster()";
  }

  $self->{_cluster} = $cluster;
}

sub getRating {
  my ($self, $movieId) = @_;
  if (!defined($movieId)) {
    die "Not enough args given to getRating()";
  }

  return $self->{_ratings}->{$movieId};
}

sub setRating {
  my ($self, $movieId, $rating) = @_;
  if (!defined($movieId) || !defined($rating)) {
    die "Not enough args given to setRating()";
  }

  $self->{_ratings}->{$movieId} = $rating;
}

sub getRatings {
  my ($self) = @_;
  return $self->{_ratings};
}

sub hasRated {
  my ($self, $movieId) = @_;
  if (!defined($movieId)) {
    die "Not enough args given to hasRated()";
  }

  return exists $self->{_ratings}->{$movieId};
}

1;
