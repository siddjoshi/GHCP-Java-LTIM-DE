
# Prompt: Detect Frameworks (Spring Boot, JUnit) and Generate Upgrade Plans

## Intent / Goal
Analyze a Java repository (Maven or Gradle based) to:
1. Detect frameworks, libraries, and major platform stacks:
   - Spring Boot, Spring Framework, Spring Cloud
   - JUnit 4 / JUnit 5
   - Jakarta EE, Micronaut, Quarkus (if present)
   - Testing frameworks (Mockito, AssertJ)
2. Identify current versions, BOM/platform influences, and actual resolved versions.
3. Compare against the latest LTS or stable releases.
4. Generate a **safe, actionable upgrade plan**:
   - Version-to-version migration steps  
   - Breaking changes  
   - Required code, config, and build updates  
   - Tooling updates (Maven plugin, Gradle plugin, Java toolchain)
5. Output a deterministic structured report (JSON + Markdown).

---

## Inputs (auto-detected unless missing)
- Build tool: Maven or Gradle  
- Java version  
- Framework coordinates: `spring-boot-starter-*`, `org.springframework:*`, `org.junit:*`, `jakarta.*`, etc.  
- BOM / platform declarations  
- Build plugins (compiler, surefire, failsafe, Gradle Java plugin, Spring Boot plugin)

If ambiguity exists, state assumptions explicitly.

---

## Required Repository Scanning
### Detect Frameworks via:
- **POM**: `<dependency>`, `<dependencyManagement>`, parent BOM  
- **Gradle**: `dependencies {}`, `plugins {}`, version catalogs (`libs.versions.toml`)  
- **Source directories**:
  - `import org.springframework...`
  - `import org.junit...`
  - `@SpringBootApplication`, `@Test`, `@ExtendWith`
  - Test folder scanning (`src/test/java`)

### Gather Version Information
- Read declared versions  
- Read plugin versions  
- Read BOM version if used  
- Infer resolved versions from:
  - `mvn dependency:tree`
  - `mvn help:effective-pom`
  - `./gradlew dependencies`
  - `./gradlew dependencyInsight`

---

## Analysis Logic
### 1. Detect Framework Stack
- Spring Boot version → detect major/minor (e.g., 2.7.x, 3.2.x, 3.4.x)
- Spring Framework version if directly declared  
- JUnit version via coordinates:
  - JUnit 4: `"junit:junit"`
  - JUnit 5: `"org.junit.jupiter:*"`

### 2. Determine Upgrade Targets
- Spring Boot:
  - If on **2.x** → recommended target: **3.x LTS**
  - If on older **3.x** → recommend incremental upgrade (e.g., 3.1 → 3.4)
- Spring Framework:
  - 5.x → migrate to 6.x  
- JUnit:
  - JUnit 4 → JUnit 5 upgrade plan  
- Java version compatibility:
  - Spring Boot 3+ requires Java 17+
  - Spring Boot 3.3+ recommends Java 21

### 3. Evaluate Breaking Changes
For each framework generate:
- API removals  
- Package migrations (`javax.*` → `jakarta.*`)  
- Deprecated classes/methods  
- Mandatory configuration file changes  
- Maven/Gradle plugin upgrades required  
- Build tool version constraints (Maven 3.8+ / Gradle 8+)

### 4. Generate Upgrade Plan
A good upgrade plan must include:
- **Pre‑migration prerequisites**
- **Incremental upgrade steps**
- **Code changes required**
- **Test migration** (e.g., JUnit 4 → JUnit 5 annotations mapping)
- **Build changes**
- **Verification steps**
- **Risk level** per step

### 5. Validations Before Completing
- Confirm detected frameworks  
- Confirm latest stable and LTS versions  
- Confirm compatibility with current Java version  
- Ensure planned steps follow semver  
- Include CI impact analysis  
- Produce deterministic JSON output

---

## Output Schema (required)
Produce **both** JSON and Markdown.

### JSON Schema
```json
{
  "frameworks": {
    "springBoot": { "detectedVersion": "", "latestRecommended": "", "upgradePath": [] },
    "springFramework": { "detectedVersion": "", "latestRecommended": "", "upgradePath": [] },
    "junit": { "detectedVersion": "", "migrationNeeded": false, "steps": [] },
    "otherFrameworks": []
  },
  "codeChanges": [],
  "buildChanges": [],
  "breakingChanges": [],
  "javaCompatibility": {
    "currentLevel": "",
    "requiredLevel": "",
    "actions": []
  },
  "recommendedCommands": [],
  "verificationChecklist": []
}
