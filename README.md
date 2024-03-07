If you hold multiple crypto coins that grant staking rewards, filing your taxes
in the USA is a massive pain in the butt. You can (and I have) thrown lots of money
at crypto tax preparation software websites every year, just to find out that you still
need to spend many hours trying to fix their data integrations / imports. All your
efforts may or may generate usable results for the IRS.

In this repository, I've given up on paying web sites every year, am rolling my own
SQLite database so I can prep a CSV for my tax preparer.

# Schema setup

    sqlite3 rewards.sqlite3
    CREATE TABLE rewards (
        date text,
        coin text,
        qty number,
        usd_value number
    );

# Coins

Each coin is it's own adventure, unfortunately. If you happen to own a Ledger hard wallet
like I do, the dream is that you could just export from Ledger Live and you're done.
For me that only worked for 1 of the 3 coins I care about.

I only care about USD, but you could tweak for whatever currency you care about.

## ADA (Cardano)

Pooltool.io used to export USD (or whatever currency) values at time of each reward.
That was nice. It's currently broken, so we have to cross-reference to a historical dump
of daily ADA/USD prices.

    https://pooltool.io/address/[YOUR ADA WALLET ADDRESS]

Scroll to the bottom, use their "Export Tool" to download a CSV.

    $ sqlite3 rewards.sqlite3
    .import --csv rewards_MYADDR_usd_cointracking.csv raw_ada

Now you've got your wallet data, yay. Load up daily historical ADA/USD data:

https://www.cryptodatadownload.com/cdd/Bitstamp_ADAUSD_d.csv

    .import --csv --skip 1 Bitstamp_ADAUSD_d.csv ada_usd

Now we can create our rewards data:

    INSERT INTO rewards
    SELECT substr(raw_ada.Date, 1, 10), 'ADA', Buy, close * Buy
    FROM raw_ada
    JOIN ada_usd ON substr(raw_ada.Date, 1, 10) = substr(ada_usd.date, 1, 10);

## stETH (Lido staked Ethereum)

Lido runs a website that works great. You can export your reward history, complete with USD
values at time of each reward:

    https://stake.lido.fi/rewards?address=[YOUR stETH WALLET ADDRESS]

Click "Export CSV".

Ugh. That file contains `Wed Mar 06 2024` and we want `2024-03-06`. We'll use a little Perl script
to do our insertion:

    $ perl steth.pl
    Inserted 545 rows into table rewards.

## XTZ (Tezos)

Ledger Live export works great. It tells us the USD value of rewards at the time of each reward.

Settings > Operation history > Save

(Unfortunately this is blank for ADA and stETH. sigh. If it wasn't, we could throw away all the
work we had to do above.)

    .import --csv rewards_MYADDR_usd_cointracking.csv raw_steth


# Reports

    SELECT *
    FROM rewards
    WHERE date >= '2023-01-01'
    AND date <= '2023-12-31'
    ORDER BY date;

