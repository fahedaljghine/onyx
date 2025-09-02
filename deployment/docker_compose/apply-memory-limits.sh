#!/bin/bash

# Script to apply memory limits to Onyx services
# This script will restart the services with the new 4GB memory limit for the indexing service

echo "🔄 Applying memory limits to Onyx services..."
echo "📊 Indexing service will be capped at 4GB RAM"
echo ""

# Function to check if docker-compose is available
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "❌ Error: docker-compose is not installed or not in PATH"
        exit 1
    fi
}

# Function to detect which compose file to use
detect_compose_file() {
    local compose_file=""
    
    if [ -f "docker-compose.yml" ]; then
        compose_file="docker-compose.yml"
    elif [ -f "docker-compose.dev.yml" ]; then
        compose_file="docker-compose.dev.yml"
    elif [ -f "docker-compose.prod.yml" ]; then
        compose_file="docker-compose.prod.yml"
    elif [ -f "docker-compose.gpu-dev.yml" ]; then
        compose_file="docker-compose.gpu-dev.yml"
    else
        echo "❌ Error: No docker-compose file found in current directory"
        echo "Please run this script from the directory containing your docker-compose file"
        exit 1
    fi
    
    echo "📁 Using compose file: $compose_file"
    echo $compose_file
}

# Function to restart services
restart_services() {
    local compose_file=$1
    local project_name=${2:-"onyx-stack"}
    
    echo "🔄 Restarting services with new memory limits..."
    
    # Stop services
    echo "⏹️  Stopping services..."
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$compose_file" -p "$project_name" stop
    else
        docker compose -f "$compose_file" -p "$project_name" stop
    fi
    
    # Start services
    echo "▶️  Starting services with new configuration..."
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$compose_file" -p "$project_name" up -d
    else
        docker compose -f "$compose_file" -p "$project_name" up -d
    fi
    
    echo "✅ Services restarted successfully!"
}

# Function to show current resource usage
show_resource_usage() {
    echo ""
    echo "📊 Current resource usage:"
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$1" -p "${2:-onyx-stack}" ps
    else
        docker compose -f "$1" -p "${2:-onyx-stack}" ps
    fi
    
    echo ""
    echo "💾 Memory usage by container:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
}

# Main execution
main() {
    check_docker_compose
    
    local compose_file=$(detect_compose_file)
    local project_name=${ONYX_PROJECT_NAME:-"onyx-stack"}
    
    echo "🏗️  Project name: $project_name"
    echo ""
    
    # Ask for confirmation
    read -p "Do you want to restart the services to apply the new memory limits? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Operation cancelled"
        exit 0
    fi
    
    restart_services "$compose_file" "$project_name"
    show_resource_usage "$compose_file" "$project_name"
    
    echo ""
    echo "🎉 Memory limits applied successfully!"
    echo "📝 The indexing service is now capped at 4GB RAM"
    echo "🔧 You can customize these limits by setting environment variables:"
    echo "   VESPA_MEM_LIMIT=4g"
    echo "   VESPA_CPU_LIMIT=2"
}

# Run main function
main "$@"
