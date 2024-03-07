#! env perl
use 5.38.0;
use DBD::SQLite;

my $dbname = "rewards.sqlite3";
my $lido_file = "Lido Rewards.csv";

my $dbh = DBI->connect("dbi:SQLite:dbname=$dbname","","");
my $sql = <<EOT;
  INSERT INTO rewards (date, coin, qty, usd_value)
  VALUES (?, ?, ?, ?)
EOT
my $sth = $dbh->prepare($sql);

my %months = (
  Jan => "01", Feb => "02", Mar => "03", Apr => "04", May => "05", Jun => "06",
  Jul => "07", Aug => "08", Sep => "09", Oct => "10", Nov => "11", Dec => "12",
);

my $cnt;
open my $fh, "<:encoding(utf8)", $lido_file or die $!;
while (<$fh>) {
  chomp;
  my @row = split /,/;
  next unless ($row[1] eq "reward");
  my $date = $row[0];
  my $qty = $row[3];
  my @date = split / /, $row[0];
  $date = $date[3] . "-" . $months{$date[1]} . "-" . $date[2];
  my $usd_value = $row[5];
  # say "$date stETH $qty $usd_value";
  $sth->execute($date, "stETH", $qty, $usd_value) or die $!;
  $cnt++;
}
$sth->finish or die $!;
$dbh->disconnect or die $!;

say "Inserted $cnt rows into table rewards."
