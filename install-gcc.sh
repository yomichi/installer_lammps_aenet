set -ue

ROOT_DIR=$(pwd)

AENET_LAMMPS_DIR=$ROOT_DIR/aenet-lammps
LAMMPS_DIR=$ROOT_DIR/lammps
AENET_DIR=$LAMMPS_DIR/lib/aenet/aenet

GFORTRAN_VERSION=$(gfortran -dumpversion | cut -d. -f1)
if [ $GFORTRAN_VERSION -ge 10 ]; then
  LOCAL_FCFLAGS="-fallow-argument-mismatch -fPIC -O3 --pedantic \$(DEBUG)"
else
  LOCAL_FCFLAGS="-fPIC -O3 --pedantic \$(DEBUG)"
fi

cd $AENET_DIR/src/makefiles
sed -i.orig "s/FCFLAGS *=.*/FCFLAGS = ${LOCAL_FCFLAGS}/" Makefile.gfortran_serial
cd $AENET_DIR/src
make -f makefiles/Makefile.gfortran_serial lib

cd $LAMMPS_DIR/src
make yes-user-aenet
make mode=shared -j2 mpi
make install-python
