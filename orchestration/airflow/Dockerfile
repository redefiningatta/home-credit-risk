FROM apache/airflow:2.8.0
user root

#enable docker in docker
run apt-get update && \ 
apt-get install -y curl &&\
curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz | tar zxvf - --strip-components=1 -C /usr/bin/ docker/docker && \
chmod +x /usr/bin/docker && \ 
apt-get clean

user airflow

# Install Docker provider for DockerOperator
RUN pip install apache-airflow-providers-docker==3.8.0
