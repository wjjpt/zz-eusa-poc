# zz-eusa-poc

script for query clients to a device using API Meraki-CMX, normalize and inject into kafka topic

# BUILDING

- Build docker image:
  * git clone https://github.com/wjjpt/zz-eusa-poc.git
  * cd src/
  * docker build -t wjjpt/eusapoc .

# EXECUTING

- Execute app using docker image:

`docker run --env KAFKA_BROKER=X.X.X.X --env KAFKA_PORT=9092 --env KAFKA_TOPIC='eusapoc' --env DEVICE='xxx' --env APIKEY='xxx' -ti wjjpt/eusapoc`

