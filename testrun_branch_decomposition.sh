#!/bin/sh

echo "8x9test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/8x9test.txt $1 

echo "Starting Timing Runs"
echo
echo "Vancouver Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/vanc.txt $1
echo
echo "Vancouver SWSW Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/vancouverSWSW.txt $1
echo
echo "Vancouver SWNW Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/vancouverSWNW.txt $1
echo
echo "Vancouver SWSE Test Set"
./hact_test_branch_decomposition.sh $DATA_DIR/vancouverSWSE.txt $1
echo
echo "Vancouver SWNE Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/vancouverSWNE.txt $1
echo
echo "Vancouver NE Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/vancouverNE.txt $1
echo
echo "Vancouver NW Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/vancouverNW.txt $1
echo
echo "Vancouver SE Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/vancouverSE.txt $1
echo
echo "Vancouver SW Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/vancouverSW.txt $1
echo
echo "Icefields Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/icefield.txt $1
echo

echo "GTOPO TINY Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/gtopo_full_tiny.txt $1
echo "Done"

echo "GTOPO30 UK Tile Test Set"
time ./hact_test_branch_decomposition.sh $DATA_DIR/gtopo30w020n40.txt $1
echo "Done"
