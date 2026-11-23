<div align="center">

# Monqiz · منقذ

**A blood donation platform that connects donors, hospitals, and patients.**
منصة تربط المتبرعين بالمستشفيات والمرضى في مكان واحد.

[![.NET](https://img.shields.io/badge/.NET-10.0-512BD4?logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/)
[![ASP.NET Core](https://img.shields.io/badge/ASP.NET%20Core-Web%20API-512BD4?logo=dotnet&logoColor=white)](https://learn.microsoft.com/aspnet/core)
[![EF Core](https://img.shields.io/badge/EF%20Core-10.0-6C2E8C?logo=nuget&logoColor=white)](https://learn.microsoft.com/ef/core/)
[![SQL Server](https://img.shields.io/badge/SQL%20Server-database-CC2927?logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/sql-server)
![Status](https://img.shields.io/badge/status-initial%20setup-orange)

</div>

---

## Table of contents

- [Overview](#overview)
- [Tech stack](#tech-stack)
- [Architecture](#architecture)
- [Project structure](#project-structure)
- [Domain model](#domain-model)
- [Getting started](#getting-started)
- [EF Core workflow](#ef-core-workflow)
- [Configuration](#configuration)
- [Roadmap](#roadmap)
- [Contributing](#contributing)

## Overview

**Monqiz** is a backend for managing blood donation requests. Hospitals publish the blood
types and quantities they need, and donors can find the requests closest to them and accept
them. The domain covers donors and their blood types, hospitals and their locations, donation
requests, and the acceptances that connect the two sides.

> **Status:** early development. The solution structure, domain model, EF Core mappings, the
> initial migration, and the API documentation are in place. Authentication and HTTP endpoints
> are the next milestone.

## Tech stack

| Area            | Choice                                          |
| --------------- | ----------------------------------------------- |
| Runtime         | .NET 10 / C# 14                                 |
| API             | ASP.NET Core Web API                            |
| Data access     | EF Core 10 with SQL Server                      |
| Identity        | ASP.NET Core Identity (`Guid` keys)             |
| API docs        | `Microsoft.AspNetCore.OpenApi` + Scalar         |
| Solution format | `.slnx`                                         |

## Architecture

The solution follows a layered structure: the domain sits at the center, business logic lives in
the services layer, and the infrastructure projects provide the database and HTTP adapters.

```
┌─────────────────────────────────────────────────────────────┐
│  src/Monqiz.Api                      host & composition root│
├─────────────────────────────────────────────────────────────┤
│  Infrastructure/Presentation         HTTP controllers       │
│  Core/Services                       business logic         │
│  Infrastructure/Persistence          EF Core, SQL Server    │
├─────────────────────────────────────────────────────────────┤
│  Core/ServicesAbstraction            service contracts      │
│  Core/Domain                         entities & enums       │
│  Shared                              shared types & DTOs    │
└─────────────────────────────────────────────────────────────┘
```

| Project                            | Responsibility                                           | References                          |
| ---------------------------------- | -------------------------------------------------------- | ----------------------------------- |
| `Core/Domain`                      | Entities, enums, and core business rules                 | —                                   |
| `Core/ServicesAbstraction`         | Service interfaces and contracts                         | `Shared`                            |
| `Core/Services`                    | Business logic implementations                           | `Domain`, `ServicesAbstraction`     |
| `Infrastructure/Persistence`       | `DbContext`, entity configurations, and migrations       | `Domain`                            |
| `Infrastructure/Presentation`      | API controllers                                          | `ServicesAbstraction`               |
| `Shared`                           | Shared types and DTOs                                    | —                                   |
| `src/Monqiz.Api`                   | DI, middleware, configuration, and the application host  | `Services`, `Persistence`, `Presentation` |

Dependencies point inward: infrastructure and services depend on the domain, not the other way
around.

## Project structure

```
monqiz/
├── Core/
│   ├── Domain/
│   │   └── Models/                   # User, Hospital, Request, ...
│   ├── ServicesAbstraction/          # service interfaces
│   └── Services/                     # service implementations
├── Infrastructure/
│   ├── Persistence/
│   │   └── Data/
│   │       ├── Configurations/       # EF Core entity configurations
│   │       ├── Migrations/           # EF Core migrations
│   │       └── MonqizDbContext.cs
│   └── Presentation/                 # API controllers
├── Shared/                           # shared types and DTOs
|   └── Enums/                        # BloodType, Gender, statuses
├── src/
│   └── Monqiz.Api/                   # ASP.NET Core host
│       ├── Program.cs
│       └── appsettings.json
├── Monqiz.slnx
└── README.md
```

## Domain model

```mermaid
erDiagram
    USER ||--o{ REQUEST : creates
    USER ||--o{ REQUEST_ACCEPTANCE : accepts
    USER ||--o{ DONATION_ADDRESS : registers
    HOSPITAL ||--o{ REQUEST : receives
    REQUEST ||--o{ REQUEST_ACCEPTANCE : "accepted through"
    ADDRESS ||--o{ HOSPITAL : locates
    ADDRESS ||--o{ DONATION_ADDRESS : locates

    USER {
        guid Id PK
        string FirstName
        string LastName
        date BirthDate
        date LastDonationDate
        string BloodType
        string Gender
        string Status
    }

    HOSPITAL {
        guid Id PK
        string Name
        string PhoneNumber
        string Email
        string LocationUrl
        guid AddressId FK
    }

    REQUEST {
        guid Id PK
        string BloodType
        int UnitsNeeded
        datetime CreatedAt
        datetime RequiredDate
        string Status
        guid HospitalId FK
        guid CreatorUserId FK
    }

    REQUEST_ACCEPTANCE {
        guid UserId PK, FK
        guid RequestId PK, FK
        string AcceptanceStatus
        datetime CreatedAt
    }

    ADDRESS {
        guid Id PK
        string City
        string Governorate
        string Area
    }

    DONATION_ADDRESS {
        guid AddressId PK, FK
        guid UserId PK, FK
    }
```

**Key rules**

- A `User` is an ASP.NET Core Identity user (`IdentityUser<Guid>`) with a blood type, gender,
  status, and optional last donation date.
- A `Request` belongs to exactly one hospital and has one creator.
- `RequestAcceptance` uses a composite key `(UserId, RequestId)`, so a donor can accept the same
  request only once.
- `DonationAddress` is the many-to-many join between donors and addresses.
- Enum values are persisted as strings, which keeps the database readable.

**Enums**

| Enum             | Values                                                                                       |
| ---------------- | -------------------------------------------------------------------------------------------- |
| `BloodType`      | `Unknown`, `A_Positive`, `A_Negative`, `B_Positive`, `B_Negative`, `AB_Positive`, `AB_Negative`, `O_Positive`, `O_Negative` |
| `Gender`         | `Female`, `Male`                                                                             |
| `UserStatus`     | `Inactive`, `Suspended`, `Active`                                                            |
| `RequestStatus`  | `Pending`, `Approved`, `Fulfilled`, `Cancelled`                                               |
| `DonationStatus` | `Pending`, `Accepted`, `Completed`, `Cancelled`                                               |


## Getting started

### Run the backend locally

**Prerequisites:** the [.NET 10 SDK](https://dotnet.microsoft.com/download) and a local SQL Server
instance (Express and LocalDB both work).

1. **Clone the repository**

   ```bash
   git clone https://github.com/DevHustlers-Community/monqiz.git
   cd monqiz
   ```

2. **Copy the env example** and fill in your own values:

   ```bash
   cp .env.example .env
   ```

   | Variable                               | What to put                                                            |
   | -------------------------------------- | ---------------------------------------------------------------------- |
   | `Jwt__Key`                             | A random secret of at least 32 characters                              |
   | `Otp__Secret`                          | A random **base64** string                                             |
   | `ConnectionStrings__DefaultConnection` | Only if your SQL Server differs from the default in `appsettings.json` |

   Generate a secret with `openssl rand -base64 32`, or in PowerShell:

   ```powershell
   $b = New-Object byte[] 32; [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b); [Convert]::ToBase64String($b)
   ```

   `.env` is git-ignored and nothing sensitive lives in `appsettings*.json`. Keep it that way.

3. **Load the variables** into the terminal you will run the API from. ASP.NET Core reads environment
   variables on its own, but it does not read `.env` files, so load it once per terminal:

   ```bash
   # bash, zsh, Git Bash
   set -a; source .env; set +a
   ```

   ```powershell
   # PowerShell
   Get-Content .env | Where-Object { $_ -match '^\s*[^#\s]' } | ForEach-Object {
     $name, $value = $_ -split '=', 2
     [Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim().Trim('"'), 'Process')
   }
   ```

   Already keep these as user or system environment variables? Skip this step.

4. **Run the API**

   ```bash
   dotnet run --project src/Monqiz.Api --launch-profile http
   ```

   The API listens on `http://localhost:5139` and the Scalar API docs are at
   `http://localhost:5139/scalar/v1`. On startup the app applies pending migrations and seeds the
   database, so there is no need to run `dotnet ef database update` first.

### Seeded data

On startup the app loads the JSON files in `Infrastructure/Persistence/Data/DataSeedFiles/`:

| Data                | Count | Notes                                                                    |
| ------------------- | ----- | ------------------------------------------------------------------------ |
| Users               | 11    | Role `User`, except the **last** entry in `Users.json`, which is `Admin` |
| Addresses           | 10    | Cairo, Giza, Alexandria, Sohag, Assiut, Dakahlia                         |
| Hospitals           | 6     |                                                                          |
| Blood requests      | 8     | `Pending`, `Fulfilled` and `Cancelled`                                   |
| Request acceptances | 10    |                                                                          |

All seeded accounts share the password `P@ssw0rd`. Log in with `POST /api/auth/login` using an email
or an Egyptian phone number, for example `ahmed.hassan@example.com` or `01100000001`.

Seeding runs on every startup but skips any table that already has rows,
so restarting the app never duplicates data. To start from scratch:

```bash
dotnet ef database drop -p Infrastructure/Persistence -s src/Monqiz.Api
```

> **Development only.** The seeded accounts and their shared password are for local testing.
> They will be replaced before the repository goes public.

## EF Core workflow

Run these commands from the repository root:

| Task                        | Command                                                                                                    |
| --------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Add a migration             | `dotnet ef migrations add <Name> -p Infrastructure/Persistence -s src/Monqiz.Api`                          |
| Apply migrations            | `dotnet ef database update -p Infrastructure/Persistence -s src/Monqiz.Api`                                |
| Remove the last migration   | `dotnet ef migrations remove -p Infrastructure/Persistence -s src/Monqiz.Api`                              |
| List migrations             | `dotnet ef migrations list -p Infrastructure/Persistence -s src/Monqiz.Api`                                |
| Check for pending changes   | `dotnet ef migrations has-pending-model-changes -p Infrastructure/Persistence -s src/Monqiz.Api`           |

Keep migrations inside `Infrastructure/Persistence` and use the API project as the startup
project.

## Configuration

| Setting                                               | Location                                                     | Notes                                                  |
| ----------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------ |
| `Jwt:Key`                                             | Environment variable `Jwt__Key`                              | **Required, secret.** Token signing key                |
| `Otp:Secret`                                          | Environment variable `Otp__Secret`                           | **Required, secret.** Base64 secret for one-time codes |
| `ConnectionStrings:DefaultConnection`                 | `appsettings.json` or `ConnectionStrings__DefaultConnection` | SQL Server connection string                           |
| `Jwt:Issuer`, `Jwt:Audience`, `Jwt:DurationInMinutes` | `appsettings.json`                                           | Token claims and lifetime, not secret                  |
| `Logging:LogLevel`                                    | `appsettings.json`                                           | Log levels                                             |
| `AllowedHosts`                                        | `appsettings.json`                                           | Host filtering                                         |

`.env.example` lists every variable with placeholder values. Secrets never go in `appsettings*.json`.

OpenAPI and Scalar are mapped only when `ASPNETCORE_ENVIRONMENT=Development`.

## Roadmap

- [x] Solution skeleton and layer separation
- [x] Domain model and EF Core configurations
- [x] Initial migration
- [x] OpenAPI and Scalar documentation
- [x] Identity registration and authentication (JWT or cookie-based)
- [x] Donor and hospital registration flows
- [x] Donation request endpoints
- [x] Donor matching by blood type and governorate
- [x] Acceptance and donation lifecycle
- [ ] Validation, error handling, and ProblemDetails
- [ ] Integration tests
- [ ] Decouple `Domain` from the EF-specific Identity package

## Contributing

1. Create a branch from the current development branch: `feature/<name>` or `fix/<name>`.
2. Build before you push:

   ```bash
   dotnet build Monqiz.slnx
   ```

3. If you change the model, add a migration and make sure the snapshot is in sync:

   ```bash
   dotnet ef migrations has-pending-model-changes -p Infrastructure/Persistence -s src/Monqiz.Api
   ```

4. Keep pull requests focused and describe the **why**, not just the **what**.