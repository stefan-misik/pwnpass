#!/usr/bin/env sh

# Get the password
read_hash()
{
    stty -echo
    trap 'stty echo' EXIT
    eval $1='$(read; printf "%s" "$REPLY" | shasum -a 1 | sed "s/ .*//")'
    stty echo
    trap - EXIT

    echo
}

printf "Password to check: "
read_hash PASS

PASS_SHORT=$(echo "$PASS" | sed "s/^\(.\{5\}\).*$/\1/")
PASS_REST=$(echo "$PASS" | sed "s/^.\{5\}\(.*\)$/\1/")

PWNED=$(curl -s https://api.pwnedpasswords.com/range/$PASS_SHORT | \
    tr -d "\r" | grep -i "$PASS_REST" | \
    sed -n "s/^[^:]*:\([0-9]*\)$/\1/p")

if [ -z "$PWNED" ]
then
    echo "Provided password has not been pwned."
else
    echo "Provided password has been pwned $PWNED times"
fi
