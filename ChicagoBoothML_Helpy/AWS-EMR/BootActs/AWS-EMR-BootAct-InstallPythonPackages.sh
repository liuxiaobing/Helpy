#!/bin/bash


# enable debugging & set strict error trap
set -x -e


# set environment variables
export HOME=/mnt/home
mkdir $HOME

export SPARK_HOME=/usr/lib/spark

export CUDA_HOME=/mnt/cuda-7.5
mkdir $CUDA_HOME

export TMPDIR=/mnt/tmp
mkdir -p $TMPDIR
#   sudo chmod +t $TMPDIR

export HOMEBREW_TEMP=$TMPDIR

export KERNEL_RELEASE=$(uname -r)
export KERNEL_SOURCE_PATH=/usr/src/kernels/$KERNEL_RELEASE


# change directory to Home folder
cd ~


# enable installation from Fedora repo
echo "[fedora]"                                                                               > ~/fedora.repo
echo "name=fedora"                                                                           >> ~/fedora.repo
echo "mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-23&arch=\$basearch" >> ~/fedora.repo
echo "enabled=0"                                                                             >> ~/fedora.repo
echo "gpgcheck=0"                                                                            >> ~/fedora.repo
sudo mv ~/fedora.repo /etc/yum.repos.d/


# update all packages
sudo yum update -y
# which covers the following essentials
# sudo yum install -y gcc
# sudo yum install -y gcc-c++
# sudo yum install -y gcc-gfortran
# sudo yum install -y patch

# install essential Development Tools
sudo yum groupinstall -y "Development tools"
# which covers the following essentials:
# sudo yum install -y git

# reinstall some compatible kernel source files
sudo yum erase -y kernel-devel
sudo yum install -y kernel-devel-$KERNEL_RELEASE
# sudo yum install -y kernel-headers-$KERNEL_RELEASE


# experimental installations of Fedora packages:
# cd /etc/yum.repos.d
# sudo wget http://linuxsoft.cern.ch/cern/scl/slc6-scl.repo
# sudo yum -y --nogpgcheck install devtoolset-3-gcc
# sudo yum -y --nogpgcheck install devtoolset-3-gcc-c++


# install numerical libraries
# sudo yum -y install atlas-devel
# sudo yum -y install blas-devel
# sudo yum -y install lapack-devel


# install certain other packages
sudo yum install -y boost
sudo yum install -y cairo-devel
sudo yum install -y libjpeg-devel
# sudo yum install -y ncurses-devel


# install LinuxBrew
git clone https://github.com/Homebrew/linuxbrew.git ~/.linuxbrew
export PATH=~/.linuxbrew/bin:~/.linuxbrew/sbin:$PATH:/user/local/include
sudo ln -s $(which gcc) `brew --prefix`/bin/gcc-$(gcc -dumpversion |cut -d. -f1,2)
sudo ln -s $(which g++) `brew --prefix`/bin/g++-$(g++ -dumpversion |cut -d. -f1,2)
sudo ln -s $(which gfortran) `brew --prefix`/bin/gfortran-$(gfortran -dumpversion |cut -d. -f1,2)


# change directory to Temp folder to install NVIDIA driver & CUDA toolkit
cd $TMPDIR

# install NVIDIA driver
# (ref: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using_cluster_computing.html#install-nvidia-driver)
# G2 Instances
# Product Type: GRID
# Product Series: GRID Series
# Product: GRID K520
# Operating System: Linux 64-bit
# Recommended/Beta: Recommended/Certified
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/358.16/NVIDIA-Linux-x86_64-358.16.run
# the following installation issues warnings that prompt a non-zero exit code,
# hence we turn off the strict error trap temporarily and turn it back on again
set +e
sudo sh NVIDIA-Linux-x86_64-358.16.run --silent --kernel-source-path $KERNEL_SOURCE_PATH --tmpdir $TMPDIR
set -e

# install CUDA toolkit
wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run
sudo sh cuda_7.5.18_linux.run --silent --driver --toolkit --toolkitpath $CUDA_HOME --extract $TMPDIR --kernel-source-path $KERNEL_SOURCE_PATH --tmpdir $TMPDIR
sudo sh cuda-linux64-rel-7.5.18-19867135.run --noprompt --prefix $CUDA_HOME --tmpdir $TMPDIR
# add CUDA executables to Path
export PATH=$PATH:$CUDA_HOME/bin
export LD_LIBRARY_PATH=$CUDA_HOME/lib64

# change directory back to Home folder
cd ~


# download PostgreSQL JDBC driver
curl https://jdbc.postgresql.org/download/postgresql-9.4-1205.jdbc42.jar --output PostgreSQL_JDBC.jar


# make Python 2.7 default Python
sudo rm /usr/bin/python
sudo rm /usr/bin/pip
sudo ln -s /usr/bin/python2.7 /usr/bin/python
sudo ln -s /usr/bin/pip-2.7 /usr/bin/pip


# install Python packages

# Py4J for Spark
sudo pip install --upgrade Py4J

# Cython
sudo pip install --upgrade Cython

# complete/updated SciPy stack (excl. Nose)
sudo pip install --upgrade iPython[all]
sudo pip install --upgrade MatPlotLib
sudo pip install --upgrade NumPy
sudo pip install --upgrade Pandas
sudo pip install --upgrade SciPy
sudo pip install --upgrade SymPy

# certain popular SkiKits: http://scikits.appspot.com/scikits
sudo pip install --upgrade SciKit-Image
sudo pip install --upgrade SciKit-Learn
sudo pip install --upgrade StatsModels
sudo pip install --upgrade TimeSeries

# advanced visualization tools: Bokeh, GGPlot, GNUPlot, MayaVi & Plotly
sudo pip install --upgrade Bokeh
sudo pip install --upgrade GGPlot
sudo pip install --upgrade GNUPlot-Py --allow-external GNUPlot-Py --allow-unverified GNUPlot-Py

# brew install Expat
# brew install MakeDepend
# brew tap Homebrew/Science
# brew install --python --qt vtk5
# sudo pip install --upgrade MayaVi

sudo pip install --upgrade Plotly

# CUDA/GPU tools, Theano & Deep Learning
# sudo pip install --upgrade PyCUDA
# sudo pip install --upgrade SciKit-CUDA
sudo pip install --upgrade Theano
sudo pip install --upgrade Keras
sudo pip install --upgrade NeuroLab
sudo pip install --upgrade SciKit-NeuralNetwork

# install Geos, Proj, Basemap, Google Maps API & other geospatial libraries
git clone https://github.com/matplotlib/basemap.git
cd basemap/geos-*
export GEOS_DIR=/usr/local
./configure --prefix=$GEOS_DIR
make
sudo make install
cd ..
sudo python setup.py install
cd ..
sudo rm -r basemap

wget http://download.osgeo.org/proj/proj-4.8.0.tar.gz
tar xzf proj-4.8.0.tar.gz
sudo rm proj-4.8.0.tar.gz
cd proj-4.8.0
export PROJ_DIR=/usr/local
./configure --prefix=$PROJ_DIR
make
sudo make install
cd ..
sudo rm -r proj-4.8.0

sudo pip install --upgrade Descartes
sudo pip install --upgrade Google-API-Python-Client
sudo pip install --upgrade GoogleMaps
sudo pip install --upgrade PyProj
sudo pip install --upgrade PySAL

# brew install gdal
# sudo pip install --upgrade Fiona   # depends on GDAL
# sudo pip install --upgrade Cartopy
# sudo pip install --upgrade Kartograph

# network analysis tools: APGL, Cairo, Graph-Tool, GraphViz, NetworkX, Python-iGraph & SNAPPy
sudo pip install --upgrade APGL

# (we skip installing Graph-Tool because it requires GCC C++ 14 compiler)
# wget https://downloads.skewed.de/graph-tool/graph-tool-2.12.tar.bz2
# tar jxf graph-tool-2.12.tar.bz2
# sudo rm graph-tool-2.12.tar.bz2
# cd graph-tool-*
# ./configure
# make
# sudo make install

wget http://cairographics.org/releases/py2cairo-1.10.0.tar.bz2
tar jxf py2cairo-1.10.0.tar.bz2
sudo rm -r py2cairo-1.10.0.tar.bz2
cd py2cairo-1.10.0
./waf configure
./waf build
sudo ./waf install
cd ..
sudo rm -r py2cairo-1.10.0

sudo pip install --upgrade GraphViz
sudo pip install --upgrade NetworkX
sudo pip install --upgrade Python-iGraph
sudo pip install --upgrade SNAPPy

# FindSpark
sudo pip install --upgrade FindSpark

# PySpark_CSV
wget https://raw.githubusercontent.com/seahboonsiew/pyspark-csv/master/pyspark_csv.py

# download .TheanoRC containing Theano configurations
wget https://raw.githubusercontent.com/ChicagoBoothML/Helpy/master/ChicagoBoothML_Helpy/AWS-EMR/BootActs/.theanorc


# launch iPython from Master node
if grep isMaster /mnt/var/lib/info/instance.json | grep true
then
    # create iPython profile
    /usr/local/bin/ipython profile create default
    echo "c = get_config()"                    > $HOME/.ipython/profile_default/ipython_notebook_config.py
    echo "c.NotebookApp.ip = '*'"             >> $HOME/.ipython/profile_default/ipython_notebook_config.py
    echo "c.NotebookApp.open_browser = False" >> $HOME/.ipython/profile_default/ipython_notebook_config.py
    echo "c.NotebookApp.port = 8133"          >> $HOME/.ipython/profile_default/ipython_notebook_config.py

    # launch iPython server
    nohup /usr/local/bin/ipython notebook --no-browser > /mnt/var/log/python_notebook.log &
fi
