FROM ubuntu:18.04

RUN mkdir -p /workdir && chmod 777 /workdir && \
    apt-get update -yqq && \ 
    apt-get install -yqq --no-install-recommends sudo curl git wget && \
    apt-get install -yqq python3 python3-pip && \
    pip3 --no-cache-dir install --upgrade pip setuptools
    #python3-venv python3-all-dev python3-setuptools build-essential python3-wheel && \
    #pip3 --no-cache-dir install pip setuptools && \
#Tensorflow && \
RUN echo "--------------------------------------" && \
    echo "----------- TENSORFLOW ---------------" && \
    echo "--------------------------------------" && \
    pip3 install --no-cache-dir tensorflow keras
#Torch && \
RUN echo "--------------------------------------" && \
    echo "----------- TORCH --------------------" && \
    echo "--------------------------------------" && \
    pip3 install --no-cache-dir torch torchvision
#NodeJS && \
RUN echo "--------------------------------------" && \
    echo "----------- NODEJS Core---------------" && \
    echo "--------------------------------------" && \
    apt-get install -yqq --no-install-recommends nodejs npm && \
    curl https://www.npmjs.com/install.sh | sudo sh && npm install -g n && n 12.13.0 && \
    npm install -g configurable-http-proxy
#Core Python Install
RUN echo "--------------------------------------" && \
    echo "----------- PYTHON Core --------------" && \
    echo "--------------------------------------" && \
    #Fix for Juptyer-Console && \
    pip3 install 'prompt-toolkit==2.0.10' && \
    pip3 install 'six==1.12' && \
    pip3 install --no-cache-dir mypy pylint yapf pytest ipython tornado jupyter nbdime \
                                jupyterlab jupyter-lsp python-language-server[all] jupyterhub && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install jupyterlab-favorites && \
    jupyter labextension install jupyterlab-recents && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
    jupyter labextension install @krassowski/jupyterlab-lsp
#Bash  && \
RUN echo "--------------------------------------" && \
    echo "----------- BASH ---------------------" && \
    echo "--------------------------------------" && \
    pip3 install --no-cache-dir bash_kernel  && \
    python3 -m bash_kernel.install
#Markdown  && \
RUN echo "--------------------------------------" && \
    echo "----------- MARKDOWN -----------------" && \
    echo "--------------------------------------" && \
    pip3 install --no-cache-dir markdown-kernel  && \
    python3 -m markdown_kernel.install
#Python && \
RUN echo "--------------------------------------" && \
    echo "----------- PYTHON -------------------" && \
    echo "--------------------------------------" && \
    pip3 install --no-cache-dir loguru pysnooper numpy scipy pandas pyarrow>=0.14.0 dask[complete] scikit-learn xgboost matplotlib bokeh holoviews[recommended] hvplot tabulate JPype1==0.6.3 JayDeBeApi sqlparse requests[socks] lxml notifiers && \
    jupyter labextension install @pyviz/jupyterlab_pyviz
#Java && \
RUN echo "--------------------------------------" && \
    echo "----- JAVA (Need for beakerx) --------" && \
    echo "--------------------------------------" && \
    apt-get install -yqq openjdk-8-jdk maven gradle
#Beakerx && \
RUN echo "--------------------------------------" && \
    echo "----------- BEAKERX ------------------" && \
    echo "--------------------------------------" && \
    pip3 install --no-cache-dir py4j beakerx && \
    beakerx install && \
    jupyter labextension install beakerx-jupyterlab && \
    #cd /root && \
    #git clone https://github.com/twosigma/beakerx.git && \
    #cd beakerx/beakerx && \ 
    #pip install -r requirements.txt --verbose && \
    #cd .. && \
    #beakerx install && \
    #beakerx_databrowser install && \
#Add-ons && \
    echo "--------------------------------------" && \
    echo "----------- ADDONS -------------------" && \
    echo "--------------------------------------" && \
    pip3 install --no-cache-dir nbgitpuller && \
    jupyter labextension install jupyterlab-drawio
#Julia && \
#RUN echo "--------------------------------------" && \
#    echo "----------- JULIA --------------------" && \
#    echo "--------------------------------------" && \
#    apt-get install -yq julia && \
#    julia -e 'empty!(DEPOT_PATH); push!(DEPOT_PATH, "/usr/share/julia"); using Pkg; Pkg.add("IJulia")'  && \
#    cp -r /root/.local/share/jupyter/kernels/julia-* /usr/local/share/jupyter/kernels/  && \
#    chmod -R +rx /usr/share/julia/  && \
#    chmod -R +rx /usr/local/share/jupyter/kernels/julia-*/  && \
#C++ && \
RUN echo "--------------------------------------" && \
    echo "----------- C++ ----------------------" && \
    echo "--------------------------------------" && \
    apt-get install -yqq libtinfo5 && \
    mkdir -p ~/pre && cd ~/pre && \
    wget https://root.cern.ch/download/cling/cling_2019-12-08_ubuntu18.tar.bz2 && tar jxf cling_2019-12-08_ubuntu18.tar.bz2 && \
    cd cling_2019-12-08_ubuntu18 && cp -r . /usr/. && cd ~ && rm -r pre && \
    cd /usr/share/cling/Jupyter/kernel && pip3 install -e . && \
    jupyter kernelspec install cling-cpp11 && jupyter kernelspec install cling-cpp14 && jupyter kernelspec install cling-cpp17 && jupyter kernelspec install cling-cpp1z
#NodeJS  && \
RUN echo "--------------------------------------" && \
    echo "----------- NodeJS -------------------" && \
    echo "--------------------------------------" && \
    npm install -g --unsafe-perm ijavascript && \
    npm install -g --unsafe-perm itypescript && \
    its --ts-hide-undefined --install=global && \
    ijsinstall --hide-undefined --install=global  && \
    npm cache clean --force clean up
RUN echo "--------------------------------------" && \
    echo "----------- CLEANUP ------------------" && \
    echo "--------------------------------------" && \
    apt-get -y autoclean && apt-get -y autoremove && \
    apt-get -y purge $(dpkg --get-selections | grep deinstall | sed s/deinstall//g) && \
    rm -rf /var/lib/apt/lists/*

ADD settings/jupyter_notebook_config.py /etc/jupyter/
ADD settings/jupyterhub_config.py /etc/jupyterhub/
COPY scripts /scripts

RUN chmod -R 755 /scripts 

ENV M2_HOME=/usr/share/maven
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$PATH:$JAVA_HOME/bin

#EXAMPLES
RUN echo "--------------------------------------" && \
    echo "----------- EXAMPLES -----------------" && \
    echo "--------------------------------------" && \
    mkdir /examples  && cd /examples && \
    cp /usr/share/cling/Jupyter/kernel/cling.ipynb . && \
    mkdir /examples/tensorflow && cd /examples/tensorflow && \
    wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/classification.ipynb && \
    wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/overfit_and_underfit.ipynb && \
    wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/regression.ipynb && \
    wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/save_and_load.ipynb && \
    wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/text_classification.ipynb && \
    wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/text_classification_with_hub.ipynb && \
    cd /examples && \
    git clone https://github.com/twosigma/beakerx.git && \
    cp -R /examples/beakerx/doc/. /examples && \
    rm README.md && \
    rm -R beakerx && \
    mkdir /examples/julia && \
    cd  /examples/julia && \
    wget https://raw.githubusercontent.com/binder-examples/demo-julia/master/demo.ipynb && \
    echo "END"
    
EXPOSE 8000

CMD "/scripts/sys/init.sh"
