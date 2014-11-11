#!/bin/bash
ALL_MEMORY=$(sysctl hw.memsize | awk '{print $2}');
ALL_MEMORY=$(($ALL_MEMORY/1048576));
SWAP=$(sysctl vm.swapusage | awk '{print $7}'| sed 's/M//');

FREE_BLOCKS=$(vm_stat | grep free | awk '{ print $3 }' | sed 's/\.//')
INACTIVE_BLOCKS=$(vm_stat | grep inactive | awk '{ print $3 }' | sed 's/\.//')
SPECULATIVE_BLOCKS=$(vm_stat | grep speculative | awk '{ print $3 }' | sed 's/\.//')

FREE=$((($FREE_BLOCKS+SPECULATIVE_BLOCKS)*4096/1048576))
INACTIVE=$(($INACTIVE_BLOCKS*4096/1048576))
TOTAL=$((($FREE+$INACTIVE)))
echo Всего: $ALL_MEMORY MB
echo Свободно:       $FREE MB
echo Своп:   $SWAP MB
