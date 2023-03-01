set -ue

LAMMPS_VERSION="stable_23Jun2022"
# AENET_LAMMPS_VERSION="2022Jul05"
AENET_LAMMPS_VERSION="master"
AENET_VERSION="v2.0.4"

ROOT_DIR=$(pwd)
AENET_LAMMPS_DIR=$ROOT_DIR/aenet-lammps
LAMMPS_DIR=$ROOT_DIR/lammps
AENET_DIR=$LAMMPS_DIR/lib/aenet/aenet

if [ ${AENET_LAMMPS_VERSION} = "master" ]; then
    AENET_LAMMPS_URL=https://github.com/HidekiMori-CIT/aenet-lammps/archive/refs/heads/master.zip
    if [ ! -f aenet-lammps-${AENET_LAMMPS_VERSION}.zip ]; then
        wget ${AENET_LAMMPS_URL} -O aenet-lammps-${AENET_LAMMPS_VERSION}.zip
    fi  
else
    AENET_LAMMPS_URL=https://github.com/HidekiMori-CIT/aenet-lammps/archive/refs/tags/${AENET_LAMMPS_VERSION}.tar.gz
    if [ ! -f aenet-lammps-${AENET_LAMMPS_VERSION}.tar.gz ]; then
        wget ${URL} -O aenet-lammps-${AENET_LAMMPS_VERSION}.tar.gz
    fi
fi

LAMMPS_URL=https://github.com/lammps/lammps/archive/refs/tags/${LAMMPS_VERSION}.tar.gz
if [ ! -f lammps-${LAMMPS_VERSION}.tar.gz ]; then
    wget ${LAMMPS_URL} -O lammps-${LAMMPS_VERSION}.tar.gz
fi

AENET_URL=https://github.com/atomisticnet/aenet/archive/refs/tags/${AENET_VERSION}.tar.gz
if [ ! -f aenet-${AENET_VERSION}.tar.gz ]; then
    wget ${AENET_URL} -O aenet-${AENET_VERSION}.tar.gz
fi

rm -rf $AENET_LAMMPS_DIR
if [ ${AENET_LAMMPS_VERSION} = "master" ]; then
    unzip aenet-lammps-${AENET_LAMMPS_VERSION}.zip
    mv aenet-lammps-master $AENET_LAMMPS_DIR
else
    mkdir $AENET_LAMMPS_DIR
    tar -xzf aenet-lammps-${AENET_LAMMPS_VERSION}.tar.gz -C $AENET_LAMMPS_DIR --strip-components=1
fi

rm -rf $LAMMPS_DIR
mkdir $LAMMPS_DIR
tar -xzf lammps-${LAMMPS_VERSION}.tar.gz -C $LAMMPS_DIR --strip-components=1

rm -rf $AENET_DIR
mkdir -p $AENET_DIR
tar -xzf aenet-${AENET_VERSION}.tar.gz -C $AENET_DIR --strip-components=1

cp -r $AENET_LAMMPS_DIR/USER-AENET $LAMMPS_DIR/src/
patch -u -p1 -d $AENET_DIR < $AENET_LAMMPS_DIR/aenet/aenet_lammps.patch

cd $LAMMPS_DIR/src
sed -i.orig 's/PYTHON = python/PYTHON = python3/g' Makefile
