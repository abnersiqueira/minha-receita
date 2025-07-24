# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Minha Receita is a Go-based web API for querying Brazilian CNPJ (National Registry of Legal Entities) data from the Federal Revenue Service. It provides ETL capabilities to download, transform, and serve this data through a REST API.

## Common Development Commands

### Building and Running
```bash
# Build the binary
go build -o minha-receita

# Run the API server (default port 8000)
./minha-receita api

# Run with custom port
./minha-receita api -p 8080
```

### Testing
```bash
# Run all tests with race detection
go test --race ./...

# Run tests for a specific package
go test --race ./api/...

# Run a single test
go test --race -run TestSpecificFunction ./package/...
```

### Code Quality
```bash
# Format code
gofmt -w ./

# Run static analysis
staticcheck ./...
```

### Database Setup
```bash
# Start development databases
docker compose up -d postgres mongo

# Start test databases (non-persistent)
docker compose up -d postgres_test mongo_test

# Create database tables
./minha-receita create -u $DATABASE_URL

# Drop database tables
./minha-receita drop -u $DATABASE_URL
```

### Data Processing
```bash
# Download CNPJ data from Federal Revenue
./minha-receita download

# Transform and load data into database
./minha-receita transform

# Generate sample data for testing (10k lines)
./minha-receita sample
./minha-receita transform -d data/sample
```

## Architecture

### CLI Command Structure
The application uses Cobra for CLI commands, with each command in `/cmd/`:
- `api`: Web server for REST API
- `download`: Downloads CNPJ data files
- `transform`: ETL process to load data into databases
- `create/drop`: Database table management
- `sample`: Generates test data samples
- `mirror`: Data mirroring to cloud storage
- `check`: Data validation utilities

### Database Support
The application supports two database backends with implementations in `/db/`:
- PostgreSQL (`/db/postgres/`): Primary SQL database
- MongoDB (`/db/mongodb/`): NoSQL alternative

Database URLs are configured via environment variables:
- Development: `DATABASE_URL`
- Testing: `TEST_POSTGRES_URL`, `TEST_MONGODB_URL`

### ETL Process
The transform package (`/transform/`) implements a multi-stage ETL process:

1. **In-memory lookup tables**: Loads reference data (CNAEs, municipalities, countries, etc.)
2. **Disk-based KV store**: Uses Badger to store company and partner data indexed by CNPJ base
3. **Enrichment**: Reads establishment files and enriches with lookup data
4. **Database load**: Converts to JSON and stores in the configured database

Key data sources:
- `Estabelecimentos*`: Main establishment data (full CNPJ as key)
- `Empresas*`: Company basic data (CNPJ base as key)
- `Socios*`: Partner/shareholder data (CNPJ base as key)
- Tax regime files: `Lucro Real.zip`, `Lucro Presumido.zip`, etc.

### API Structure
The API package (`/api/`) implements HTTP handlers with:
- CNPJ search and retrieval endpoints
- Pagination support for search results
- Optional New Relic monitoring integration
- Host header validation for security

## Testing Strategy

Tests follow Go conventions with `*_test.go` files. The project uses:
- Standard Go testing package
- Separate test database instances (ports 5555 for PostgreSQL, 27117 for MongoDB)
- Test data fixtures in `/testdata/`
- Race detection enabled by default

## Environment Configuration

Create a `.env` file from `.env.sample`. Key variables:
- `DATABASE_URL`: Main database connection
- `TEST_POSTGRES_URL`: PostgreSQL test database
- `TEST_MONGODB_URL`: MongoDB test database
- `NEW_RELIC_LICENSE_KEY`: Optional monitoring
- `ALLOWED_HOST`: Optional host validation
- AWS credentials for mirror functionality

## Key Dependencies

- `spf13/cobra`: CLI framework
- `jackc/pgx/v5`: PostgreSQL driver
- `go.mongodb.org/mongo-driver`: MongoDB driver
- `dgraph-io/badger/v4`: KV store for ETL
- `newrelic/go-agent`: Application monitoring
- `aws/aws-sdk-go`: Cloud storage integration