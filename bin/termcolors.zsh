#!/bin/env zsh
for i in {0..255}; do print -n -P "%F{$i}"; printf "%3i " "$i"; print -n -P "%f"; if (($i % 16 == 15)); then echo; fi; done
