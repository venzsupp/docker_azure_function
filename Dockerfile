# Stage 1: Build the .NET Azure Function app using the .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file and restore dependencies
COPY ["docker_azure_function.csproj", "."]
RUN dotnet restore "docker_azure_function.csproj"

# Copy the entire project and build it
COPY . /home/site/wwwroot/app
RUN dotnet publish "docker_azure_function.csproj" --configuration Release --output /app/publish

# Stage 2: Use the Azure Functions runtime as the base
FROM mcr.microsoft.com/azure-functions/dotnet-isolated:4-dotnet-isolated8.0 AS base
WORKDIR /home/site/wwwroot/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    curl \
    gnupg2 \
    unixodbc-dev \
    libgssapi-krb5-2
# Install required dependencies
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update

RUN apt-get update && \
    apt-get install -y dotnet-sdk-8.0

# Set environment variables for Azure Functions
ENV AzureWebJobsScriptRoot=/home/site/wwwroot
ENV FUNCTIONS_WORKER_RUNTIME=dotnet-isolated

# Copy the published app from the build stage
COPY --from=build /app/publish .

# Expose Azure Functions default ports
# EXPOSE 80
# EXPOSE 7071

# Start the Azure Functions host
# CMD ["func", "start", "--verbose"]
