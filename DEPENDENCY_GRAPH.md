# Dependency Graph

## Project Overview
This is a Spring Boot multi-module Gradle project consisting of two modules:
- **common**: A library module with shared business logic
- **search**: A web application module that provides REST APIs

## Module Dependency Graph

```mermaid
graph TD
    A[Root Project: springboot-multi-module] --> B[common module]
    A --> C[search module]
    C --> B
    
    B --> D[spring-boot-starter]
    B --> E[spring-boot-starter-test]
    
    C --> F[spring-boot-starter-actuator]
    C --> G[spring-boot-starter-web]
    C --> H[spring-boot-starter-test]
    
    style A fill:#e1f5ff
    style B fill:#c8e6c9
    style C fill:#c8e6c9
    style D fill:#fff9c4
    style E fill:#fff9c4
    style F fill:#fff9c4
    style G fill:#fff9c4
    style H fill:#fff9c4
```

## Module Dependencies

### Root Project
- **Group**: com
- **Version**: 1.0-SNAPSHOT
- **Java Version**: 21
- **Build Tool**: Gradle

### Common Module
**Purpose**: Shared library module containing business entities and services

**Dependencies**:
- `org.springframework.boot:spring-boot-starter` (implementation)
- `org.springframework.boot:spring-boot-starter-test` (test)
- Spring Boot version: 2.7.18

**Exports**:
- `com.common.Product` - Product entity class
- `com.common.ProductService` - Product service with CRUD operations

**Artifact**: 
- Base Name: `springboot-multi-module-library`
- Version: `0.0.1-SNAPSHOT`

### Search Module
**Purpose**: Web application module providing REST APIs for product search and management

**Dependencies**:
- `org.springframework.boot:spring-boot-starter-actuator` (implementation)
- `org.springframework.boot:spring-boot-starter-web` (implementation)
- `project(':common')` (implementation) - Internal module dependency
- `org.springframework.boot:spring-boot-starter-test` (test)
- Spring Boot version: 2.7.18

**Imports from Common Module**:
- `com.common.Product`
- `com.common.ProductService`

**Artifact**:
- Base Name: `springboot-multi-module-search`
- Version: `0.0.1-SNAPSHOT`

**Main Application**: `com.search.SearchApplication`

## External Library Dependencies

### Spring Boot 2.7.18
The project uses Spring Boot version 2.7.18 with the following starters:

#### spring-boot-starter
Basic Spring Boot starter with core dependencies:
- Spring Core
- Spring Boot
- Spring Boot Autoconfigure
- Logging (Logback)

#### spring-boot-starter-web
Web application support including:
- Spring MVC
- Embedded Tomcat server
- Jackson for JSON processing
- REST API support

#### spring-boot-starter-actuator
Production-ready features:
- Health checks
- Metrics
- Application monitoring endpoints

#### spring-boot-starter-test
Testing support including:
- JUnit
- Spring Test
- Mockito
- AssertJ
- Hamcrest

### Test Dependencies
- JUnit 4.12 (root project)

## Dependency Tree

To view the complete dependency tree for each module, use the following Gradle commands:

```bash
# View dependencies for all modules
./gradlew dependencies

# View dependencies for common module
./gradlew :common:dependencies

# View dependencies for search module
./gradlew :search:dependencies

# Generate HTML dependency report
./gradlew htmlDependencyReport
```

## Transitive Dependencies

### Common Module Transitive Dependencies
Through `spring-boot-starter`:
- spring-core
- spring-context
- spring-beans
- spring-aop
- spring-expression
- logback-classic
- slf4j-api

### Search Module Transitive Dependencies
Through `spring-boot-starter-web`:
- All spring-boot-starter dependencies
- spring-web
- spring-webmvc
- tomcat-embed-core
- tomcat-embed-el
- tomcat-embed-websocket
- jackson-databind
- jackson-core
- jackson-annotations

Through `spring-boot-starter-actuator`:
- micrometer-core
- spring-boot-actuator
- spring-boot-actuator-autoconfigure

## Dependency Management

The project uses Spring Boot's dependency management plugin to manage versions:
- Common module: Uses `io.spring.dependency-management` plugin
- Search module: Uses `org.springframework.boot` plugin with dependency management

This ensures consistent versions across all Spring Boot dependencies without explicitly specifying versions.

## Build Order

When building the project, Gradle automatically determines the correct build order:
1. **common** module is built first (no internal dependencies)
2. **search** module is built second (depends on common)

Build command: `./gradlew build`

## Running the Application

The search module is the runnable application:
```bash
# Build all modules
./gradlew build

# Run the search application
./gradlew :search:bootRun
```

The application runs on port 8100 (configured in search module's application.properties).

## Dependency Graph Generation

To generate detailed dependency reports, use the Gradle tasks defined in the root `build.gradle`:

```bash
# Generate dependency report for all modules
./gradlew generateDependencyGraph

# View the report in build/reports/project/dependencies/
```
