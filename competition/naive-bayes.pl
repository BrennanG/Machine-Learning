#!/usr/bin/perl
use strict;
use warnings;

# Check for proper number of args
if ($#ARGV + 1 < 1) {
  print "Usage: $0 inputFile outputFile\n";
  exit;
}

# Define Globals
my $ALPHA = 1.5;
my $WORD_COUNT_GOOD = 126035;
my $WORD_COUNT_BAD = 132586;

# Open the input file
open(my $inputFile, '<:encoding(UTF-8)', $ARGV[0])
  or die "Could not open file '$ARGV[0]'";

# Open the output file
open(my $outputFile, '>', $ARGV[1])
  or die "Could not open file '$ARGV[1]'";
print $outputFile "TweetId,Sentiment\n";

# Create the good and bad vectors
my $goodVector = createVector("freq-good.txt");
my $badVector = createVector("freq-bad.txt");

#while(my($word, $freq) = each %$goodHash) {

my $count = 1;

# Loop through the input file
while (my $line = <$inputFile>) {
  chomp($line);
  my @words = split(' ', $line);

  my $goodProb = calcProbability(\@words, $goodVector, $WORD_COUNT_GOOD);
  my $badProb = calcProbability(\@words, $badVector, $WORD_COUNT_BAD);

  if ($goodProb > $badProb) { print $outputFile "$count,P\n"; }
  else { print $outputFile "$count,N\n"; } 

  $count = $count + 1;
}

# Close the files
close($inputFile);
close($outputFile);



#################### FUNCTIONS ###############################

# Creates and returns a vector (in the form of a hash reference) created from the passed file
sub createVector {
  # Handles arguments
  my ($fileName) = @_;
  if (!defined($fileName)) {
    die "Not enough args given to createHash()";
  }

  # Open the file
  open(my $file, '<:encoding(UTF-8)', $fileName)
    or die "Could not open file '$fileName'";

  # Loop through the file, adding words and frequencies to the hash
  my %hash;
  while (my $line = <$file>) {
    chomp($line);
    if ($line =~ /([0-9]+) (.+)$/) {
      $hash{$2} = $1;
    }
  }

  # Close the file and return the hash
  close($file);
  return \%hash;
}

# Calculates the probability of the words being related to the vector
sub calcProbability {
  # Handles arguments
  my ($words, $vector, $totalWords) = @_;
  if (!defined($words) || !defined($vector) || !defined($totalWords)) {
    die "Not enough args given to calcProbability()";
  }

  # Loop through the words, calculating the probability
  my $total = 0;
  my $sizeOfHash = keys(%$vector);
  for my $word (@$words) {
    my $numerator = $ALPHA;
    if (exists $vector->{$word}) {
      $numerator = $numerator + $vector->{$word};
    }

    my $denominator = ($sizeOfHash * $ALPHA) + $totalWords;

    $total = $total + (log($numerator/$denominator)/log(2)); # divide by log(2) to make it a log base 2
  }

  return $total;
}



