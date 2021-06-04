# Building and deploying Sigma with AI-DSL Ontologoy prototype

1. `git clone https://github.com/singnet/ai-dsl.git` in appropriate location and computer where Sigma is to be deployed;
2. change into `ontology/tools` directory;
3. build docker container by `bash build_docker.sh`
4. deploy docker container by `bash run_docker.sh`
5. go to `localhost:8080/sigma/login.html' and login with usarname:`admin`, password:`admin`;
6. Sigma takes a while to load; after it is loaded, one should be able to see something similar to this:

7. If something does not work, please file bug report with the reference to @kabirkbr
