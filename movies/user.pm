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
  $self->{_cluster} = $cluster if defined($cluster);
  return $self->{_cluster};
}

sub getRating {
  my ($self, $movieId) = @_;
  return $self->{_ratings}->{$movieId} if defined($movieId);
}

sub setRating {
  my ($self, $movieId, $rating) = @_;
  $self->{_ratings}->{$movieId} = $rating if (defined($movieId) && defined($rating));
  return $self->{_ratings}->{$movieId};
}

sub getRatings {
  my ($self) = @_;
  return $self->{_ratings};
}

sub hasRated {
  my ($self, $movieId) = @_;
  return exists $self->{_ratings}->{$movieId} if defined($movieId);
}

1;
