<!-- ONYX_METADATA={"link": "https://github.com/onyx-dot-app/onyx/blob/main/deployment/docker_compose/README.md"} -->

# Deploying Onyx using Docker Compose

For general information, please read the instructions in this [README](https://github.com/onyx-dot-app/onyx/blob/main/deployment/README.md).

## Deploy in a system without GPU support

This part is elaborated precisely in this [README](https://github.com/onyx-dot-app/onyx/blob/main/deployment/README.md) in section _Docker Compose_. If you have any questions, please feel free to open an issue or get in touch in slack for support.

## Deploy in a system with GPU support

Running Model servers with GPU support while indexing and querying can result in significant improvements in performance. This is highly recommended if you have access to resources. Currently, Onyx offloads embedding model and tokenizers to the GPU VRAM and the size needed depends on chosen embedding model. For example, the embedding model `nomic-ai/nomic-embed-text-v1` takes up about 1GB of VRAM. That means running this model for inference and embedding pipeline would require roughly 2GB of VRAM.

### Setup

To be able to use NVIDIA runtime, following is mandatory:

- proper setup of NVIDIA driver in host system.
- installation of `nvidia-container-toolkit` for passing GPU runtime to containers

You will find elaborate steps here:

#### Installation of NVIDIA Drivers

Visit the official [NVIDIA drivers page](https://www.nvidia.com/Download/index.aspx) to download and install the proper drivers. Reboot your system once you have done so.

Alternatively, you can choose to install the driver versions via package managers of your choice in UNIX based systems.

#### Installation of `nvidia-container-toolkit`

For GPUs to be accessible to containers, you will need the container toolkit. Please follow [these instructions](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) to install the necessary runtime based on your requirement.

### Launching with GPU

1. To run Onyx with GPU, navigate to `docker_compose` directory and run the following:

   - `docker compose -f docker-compose.gpu-dev.yml -p onyx-stack up -d --pull always --force-recreate` - or run: `docker compose -f docker-compose.gpu-dev.yml -p onyx-stack up -d --build --force-recreate`
     to build from source
   - Downloading images or packages/requirements may take 15+ minutes depending on your internet connection.

2. To shut down the deployment, run:
   - To stop the containers: `docker compose -f docker-compose.gpu-dev.yml -p onyx-stack stop`
   - To delete the containers: `docker compose -f docker-compose.gpu-dev.yml -p onyx-stack down`

## Resource Limits

Onyx services have configurable resource limits to prevent them from consuming excessive system resources. The indexing service (Vespa) is particularly memory-intensive and is now capped at 4GB by default.

### Configuring Resource Limits

You can customize resource limits by setting environment variables in your `.env` file:

```bash
# Indexing Service (Vespa) Limits
VESPA_MEM_LIMIT=4g          # Memory limit (default: 4g)
VESPA_CPU_LIMIT=2           # CPU limit (default: 2)
VESPA_MEM_RESERVATION=2g    # Memory reservation (default: 2g)
VESPA_CPU_RESERVATION=1     # CPU reservation (default: 1)

# Other Services
BACKGROUND_MEM_LIMIT=10g    # Background service memory limit
API_SERVER_MEM_LIMIT=4g     # API server memory limit
POSTGRES_MEM_LIMIT=4g       # Database memory limit
```

### Memory Limits Applied

- **Indexing Service**: Capped at 4GB to prevent excessive RAM usage
- **Background Service**: Limited to 10GB for processing jobs
- **API Server**: Limited to 4GB for handling requests
- **Database**: Limited to 4GB for data operations

These limits ensure stable operation and prevent any single service from consuming all available system resources.
