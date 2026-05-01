#!/usr/bin/env bash
raw_target=$({
  echo "session1" | awk '{printf "\033[36m%s\033[0m\n", $0}'
  echo "dir1" | awk '{printf "\033[34m%s\033[0m\n", $0}'
} | awk '!seen[$0]++' | grep session1)

target=$(echo "$raw_target" | perl -pe 's/\e\[[\d;]*m//g')
echo "RAW: $raw_target"
echo "TARGET: $target"
