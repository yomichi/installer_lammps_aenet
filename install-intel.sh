set -ue

ROOT_DIR=$(pwd)

AENET_LAMMPS_DIR=$ROOT_DIR/aenet-lammps
LAMMPS_DIR=$ROOT_DIR/lammps
AENET_DIR=$LAMMPS_DIR/lib/aenet/aenet

LOCAL_FCFLAGS="-fPIC -O3 \$(DEBUG)"

cd $AENET_DIR/src/makefiles
sed -i.orig "s/FCFLAGS *=.*/FCFLAGS = ${LOCAL_FCFLAGS}/" Makefile.intel_serial
cd $AENET_DIR/src
make -f makefiles/Makefile.intel_serial lib

cd $LAMMPS_DIR/src
make yes-user-aenet
I_MPI_CXX="icpc" make mode=shared -j2 icc_openmpi
make install-python
