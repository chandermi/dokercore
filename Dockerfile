FROM mcr.microsoft.com/dotnet/framework/sdk:4.8 AS build
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.sln .
COPY dokerprojectcore/*.csproj ./dokerprojectcore/

RUN dotnet restore

# copy everything else and build app
COPY . .
WORKDIR /app/dokerprojectcore
RUN dotnet build


FROM build AS testrunner
WORKDIR /app/tests
ENTRYPOINT ["dotnet", "test", "--logger:trx"]


FROM build AS test
WORKDIR /app/tests
RUN dotnet test


FROM build AS publish
WORKDIR /app/dokerprojectcore
RUN dotnet publish -c Release -o out


FROM mcr.microsoft.com/dotnet/framework/runtime:4.8 AS runtime
WORKDIR /app
COPY --from=publish /app/dokerprojectcore/out ./
ENTRYPOINT ["dokerprojectcore.exe"]