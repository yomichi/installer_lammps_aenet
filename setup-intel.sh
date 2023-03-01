set -e

LAMMPS_VERSION="stable_23Jun2022"
AENET_LAMMPS_VERSION="2022Jul05"
AENET_VERSION="v2.0.4"

ROOT_DIR=$(pwd)

URL=https://github.com/HidekiMori-CIT/aenet-lammps/archive/refs/tags/${AENET_LAMMPS_VERSION}.tar.gz
if [ ! -f aenet-lammps-${AENET_LAMMPS_VERSION}.tar.gz ]; then
    wget ${URL} -O aenet-lammps-${AENET_LAMMPS_VERSION}.tar.gz
fi

URL=https://github.com/lammps/lammps/archive/refs/tags/${LAMMPS_VERSION}.tar.gz
if [ ! -f lammps-${LAMMPS_VERSION}.tar.gz ]; then
    wget ${URL} -O lammps-${LAMMPS_VERSION}.tar.gz
fi

URL=https://github.com/atomisticnet/aenet/archive/refs/tags/${AENET_VERSION}.tar.gz
if [ ! -f aenet-${AENET_VERSION}.tar.gz ]; then
    wget ${URL} -O aenet-${AENET_VERSION}.tar.gz
fi

AENET_LAMMPS_DIR=$ROOT_DIR/aenet-lammps
LAMMPS_DIR=$ROOT_DIR/lammps
AENET_DIR=$LAMMPS_DIR/lib/aenet/aenet

rm -rf $AENET_LAMMPS_DIR
mkdir $AENET_LAMMPS_DIR
tar -xzf aenet-lammps-${AENET_LAMMPS_VERSION}.tar.gz -C $AENET_LAMMPS_DIR --strip-components=1

rm -rf $LAMMPS_DIR
mkdir $LAMMPS_DIR
tar -xzf lammps-${LAMMPS_VERSION}.tar.gz -C $LAMMPS_DIR --strip-components=1

rm -rf $AENET_DIR
mkdir -p $AENET_DIR
tar -xzf aenet-${AENET_VERSION}.tar.gz -C $AENET_DIR --strip-components=1

cp -r $AENET_LAMMPS_DIR/USER-AENET $LAMMPS_DIR/src/
patch -u -p1 -d $AENET_DIR < $AENET_LAMMPS_DIR/aenet/aenet_lammps.patch


LOCAL_FCFLAGS="-O3 --pedantic -fPIC \$(DEBUG)"

cd $AENET_DIR/src/makefiles
sed -i.orig "s/FCFLAGS *=.*/FCFLAGS = ${LOCAL_FCFLAGS}/" Makefile.ifort_serial
cd $AENET_DIR/src
make -f makefiles/Makefile.ifort_serial lib

cd $LAMMPS_DIR/src
make yes-user-aenet
I_MPI_CXX=icpc make mode=shared -j2 icc_openmpi
make install-python
