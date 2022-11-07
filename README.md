# StarknetCC-CTF
Write up of the [StarknetCC-CTF](https://starknet-cc.ctfd.io/) held in Lisbon on November 1st 2022.
Teams of 6 max, 50% must be on-site.

# Overview
You can find all the information we were given on this [PDF](src/StarkNet-CC%20CTF.pdf).

The process to find a flag was this one:
1. Select a challenge
2. Download the `files.zip` file. Once unzipped, it should contain a folder `public` along with the `contracts` and `deploy` folders. `contracts` holds the source code for the deployed smart contracts (that you will need to hack). The `deploy` folder contains a file `chal.py` which specifies: how the contract was deployed (constructor arguments etc) as well as the function `checker` which will be called when you click "get flag" later on.
3. You are given a `nc IP:port` command to run on your shell.
4. Once you connected, you have three choices possible:
  1. Spawn a new instance: You will be given some information such as the private key of the player's address, the player's account contract, the and the exploitable contract's address.
  2. Kill the ongoing instance. Pretty straightforward!
  3. Get flag. When you call this, the function `checker()` gets called. If it returns true, you should see a flag printed on your shell. Simply paste this flag on the starknet-cc challenge pas, and you're all good!

Now let's see what these challenges were about!

## solveme

Let's start with the simplest one. The code is pretty straightforward: we notice that the function `is_solved()` simply returns the value of the storage `solved`. To write into `solved`, just call the function `solve()`. Easy peasy.

An [example js script](example/solveme.js) is provided as an example. We went for the `js` script because none of our computers worked with cairo-lang 0.10.0 / starknet_py v0.5.2.a .

## cairo-intro

![cairo-intro](/screenshots/challenges/cairo-intro.png "cairo-intro")


To solve this one we understand we need to call `solve_challenge()`. To do that, we need to be the owner. The owner storage variable gets modified in the `owner_check` function. The `write` is protected by an `if` condition: to bypass it we need to find a number between `31333333377` and `31333333391` which is divisble by 14. Answer: `31333333388`.

![](/screenshots/cairo-intro.png?raw=true "")

This function isn't external so we can't call it directly. We need to call `increase_balance(amount)` which will in turn call `owner_check`.

`increase_balance` doesn't call `owner_check` with `amount`, it first checks the balance of the caller and calls `owner_check` with `amount + balance`. So we need to first retrieve our balance, and then call `increase_balance` with `31333333388 - current_balance`.

![](/screenshots/cairo-intro2.png?raw=true "")

We can then proceed to call `solve_challenge` and flag :)

## frozen-finance

![frozen-finance](/screenshots/challenges/frozen-finance.png?raw=true "frozen-finance")

The goal is to have a balance of 0.
To do this, we need to call `withdraw()`. Withdraw will only work if the `balance` is higher than `Uint256(46, 7)`. Our balance starts with `50` (see the `constructor()` method), so we need to increase our balance by `7 * 2**128 + 46 - 50 + 1` in order to be able to call withdraw.

![](/screenshots/frozen-finance.png?raw=true "")

To increase our balance we need to call `deposit`. The deposit function first checks that the `.high` part of our deposit is 0 (meaning our deposit can only be as high as 2**128 - 1).
Knowing that, we can compute how many times we will need to call `deposit`: simply divide `7 * 2**128 + 46 - 50 + 1` by `2**128 - 1` -> this gives us `7`.

Oh but wait the function deposit ensures that `deposits` never reaches `MAX_DEPOSITS` which is set to `7`... so it won't work.
Oh but wait! Thanks to [Starknet Explorer](https://github.com/crytic/vscode-starknet-explorer), we can see that `deposits` is never updated... so we don't care about this check!

![](/screenshots/starknet-explorer.png?raw=true "")

Just call `deposit` with `2**128-1` 7 times and then call `withdraw()`. You can then flag! gg

## magic_encoding

![magic-encoding](/screenshots/challenges/magic-encoding.png?raw=true "magic-encoding")

No `.cairo` file here, just a simple `.json` file. Let's try disassembling it with [`thoth`](https://github.com/FuzzingLabs/thoth).

![disassembled code](/screenshots/magic-encoding.png?raw=true "disassembled code")

Interesting! An external function named `test_password`? Looks like it first `xor`'s the password with `12345` and then substracts `19423`. If the result it 0, it writes something somewhere... Let's give it a try?
We're looking for a number `x` that would be equal to `19423` when `xor`'d with `12345`. Well, let's `xor` `19423` with `12345` and we should have our answer... `19423 ^ 12345 == 31718`. To make sure we didn't mess up, let's try `31718 ^ 12345 == 19423`. Ok that's correct.

Let's try calling `test_password` with it? It worked! We can flag :)

## claim-a-punk

![claim-a-punk](/screenshots/challenges/claim-a-punk.png?raw=true "claim-a-punk")

The goal of this challenge is to manage to mint 2 punks on the same address.
The openzeppelin folder is probably here for a reason. However, let's first have a quick look at `claim_a_punk.cairo`.
There are two big functions: `claim` and `transferWhitelistSpot`. I guess the function `tranfserWhitelistSpot` is also here for a particular reason.. let's have a close look at this function.
This file has lots of comments, it makes our life easier, right? But wait... am I seing this right? The comment says `Add "to" to _claimers mapping` but the code is just a repetition of the line just above... ah, those programmers! Too lazy to write the code, they copy/paste and forget to edit...

![](/screenshots/claim-a-punk.png?raw=true "")

Ok well this means the recipient of this function is never added to the `_claimers` mapping. So this also means that... if the player transfers his whitelist spot to a friend, and his friend transfers it back to the player... then the player has effectively been removed from the `_claimers` list. We found it!
Quick recap:
1) Claim a punk with the player's account
2) Create a second account
3) Call `transferWhitelistSpot` with the player's account and transfer it to the second account.
4) Call `transferWhitelistSpot` with the second account and transfer it to the player's account.
5) Claim a second punk with the player's account!
6) Flag! :)

Pro-tip: Dont't forget to set the `maxFee` to 0 when doing a transaction with the second account, otherwise your transaction might fail. Alternatively you can transfer ETH from the player's account to the second account :)

## cairo-bid

![cairo-bid](/screenshots/challenges/cairo-bid.png?raw=true "cairo-bid")

Oooh this one has 4 different `.cairo` files. A lot of code in there... and it follows the good the `namespace` convention to avoid storage clashing. Nice. `bid_interface.cairo` isn't really interesting... `bid_lib.cairo` has a lot of felt <=> Uint256 conversion.. maybe there's something going on with this?
`bid.cairo` is the external functions that act mainly as wrappers around the inner functions from `bid_lib.cairo`. Interesting. How about `utils.cairo`? It holds 3 utility functions: `felt_to_uint256`, `uint256_to_felt` and `assert_251_bit`. This last function should catch your eyes. It asserts that a `felt` is `251` bits... but a felt is at most `251` bits anyways. So... it doesn't actually verify anything? It would be useful if it took a `Uin256` as input... but with a felt it's useless.

![](/screenshots/cairo-bid.png?raw=true "")

So wait if this function is useless, let's look at where it's called, and let's see if we can abuse it? Oh! It's used in the `uint256_to_felt`. So we can basically overflow anything that calls `uint256_to_felt` by giving as input a `Uint256` that is bigger than felt max.

So let's try and call `bid` with... let's say Uint256::MAX? The function `check_if_enough_funds` will not error because it does a `uin256_signed_le` comparison, so the number we passed in will be negative. The function `check_minimal_bid` will not error either because it will call the function `is_le_felt` which will in turn, not trigger any error... We will then have bypassed all the checks and will be able to write in the desired storage variables. Easy flagging!

![](/screenshots/cairo-bid2.png?raw=true "")

![](/screenshots/cairo-bid3.png?raw=true "")

## first-come-first-served

![first-come-first-served](/screenshots/challenges/first-come-first-served.png?raw=true "first-come-first-served")

TODO

## access-denied

![access-denied](/screenshots/challenges/access-denied.png?raw=true "access-denied")

Not much code here. `IAccount.cairo` is simply the interface; and `access_denied.cairo` only has the function `solve`. It will write to the storage variable if we manage to create an invalid signature. It checks the signature by calling `get_public_key` on the Account contract... so actually, simply deploying a new account which returns `0` for the external `get_public_key` method should do the trick?

![](/screenshots/access-denied.png?raw=true "")

Indeed it does! Simple comme bonjour!

## puzzle-box

![puzzle-box](/screenshots/challenges/puzzle-box.png?raw=true "puzzle-box")

## unique-id

![unique-id](/screenshots/challenges/unique-id.png?raw=true "unique-id")

At a first glance, this challenge seams rather tricky. The two files are small, yet finding the mistake requires a sharp eye. Indeed, this is an example of the infamous *storage name clash*. If you look closely, both `proxy.cairo` and `implementation_v1.cairo` define a storage variable called `owners`. "But they're not defined in the same file so they shouldn't interfere with each other" you say? Oh my sweet summer child... Indeed they do!
So we know that when we write in the `owner` storage in `implementation_v1.cairo`, we're actaully writing in `proxy.cairo`'s storage. This is interesting, because the `owner` variable is the one used to... upgrade the contract!!
In `mintNewId`, we write an `Identity` struct in `owners`. Since a struct is nothing but ordered felts, we can write anything we want in `owners` by using the first element of the structure, i.e. `first_name`.

![](/screenshots/unique-id.png?raw=true "")

By calling `mintNewId` with `first_name=1`, we can set `owners[caller_address]` to be equal to 1. In `proxy.cairo`, we can then call `update`, as the only check that is done is a call to see if `owners[caller_address]` is equal to 1. By doing this, we can effectively upgrade the implementation!

![](/screenshots/unique-id2.png?raw=true "")

Ok so let's look at what exactly we need to do (in `chal.py`). The `checker` function checks whether `getIdNumber` returns `31337`. 

Next step is straightforward: write an `implementation_v2.cairo` which simply returns `31337` got `getIdNumber`. An example `.cairo` is provided in [insert link](link).
Once you've upgraded the contract, you can flag! gg!

Pro-tip: this bug is [supposed to have been fixed with cairo-lang 0.10.0](https://github.com/starkware-libs/cairo-lang/releases/tag/v0.10.0). We're not sure exactly why this challenge was in the CTF given that the instructions clearly mentioned we should be using cairo-lang 0.10.0...

## dna

![dna](/screenshots/challenges/dna.png?raw=true "dna")

Only the Ledger chads solved it. We tried brute forcing it but didn't manage to bruteforce in time.

*Courtesy of the Ledger Team*

The dna attack consisted in inverting the function `pedersen(candidate, 317)=target`.

As 317 is a constant, and all candidates being lower than 248 bits, the challenge could be reduced to compute
g^x= target' which is a well known problem: the discrete logarithm problem (DLP). While intractable for large search space,
the number of candidates was only 2^34 (4 candidates per step).

At first glance the exhaustive search can be sped up by starting the search from the following values:
```
branching_values=[
[27644437,35742549198872617291353508656626642567,359334085968622831041960188598043661065388726959079837],#prune 877
[1046527, 16769023, 1073676287],#prune 16127
[87178291199, 479001599, 39916801],#prune 5039
[433494437, 2971215073, 28657, 514229],
[131071, 2147483647, 524287],#prune 8191
[786433, 746497, 995329, 839809],
[9901],#prune all but 333667
]
```
which lead to 1296 points, precompute all possible 2^15 small sums, then brute force over 2^25 values using only point addition (faster than multiplication),
 using cairo-rs and parallelization,
the result can be obtained in one hour.

The greatest speed up is obtained using the `baby-step, giant-step` method, which is a [meet in the middle attack](https://en.wikipedia.org/wiki/Meet-in-the-middle_attack), adapted to
DLP. The idea is to split the search space in two. To simplify, imagine looking for a target sum C, instead of computing 2^34 values, proceed as follow:
- compute 2^17 sum value_i in a subset `A`
- compute 2^17 values in a subset `B` and store the subset `B'`, where `B'_j=(target-value_j)`
- sort both subsets in log(2^17).
- search a collision between `A` and `B'`.
- the solution is the preimage in `A` and `B`.

Note that using the branching values instead of a balanced split improve the computations.
With BS and optimizations, the attack takes less than 10 minutes with a single core python implementation.

(NDLR: blast is a dna search algorithm)

## account-obstruction

![account-obstruction](/screenshots/challenges/account-obstruction.png?raw=true "account-obstruction")

No one managed to solve it :(