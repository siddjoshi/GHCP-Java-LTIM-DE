
# Prompt: Analyze Maven/Gradle Projects and Dependencies

## Intent / Goal
Analyze a Java project that uses **Maven** or **Gradle** (including multi-module builds) to:
1. Inventory direct vs transitive dependencies with versions and scopes/configurations.
2. Detect **version conflicts**, **dependency convergence issues**, and **duplicate/evicted** modules.
3. Identify **outdated** dependencies and plugins; propose safe upgrade paths (semver-aware).
4. Flag **risky** dependencies (e.g., known vulnerabilities, end-of-life, unknown licenses).
5. Generate **SBOM** (CycloneDX or SPDX) and optional **SCA** report (Dependency-Check).
6. Recommend **dependency hygiene** fixes: BOM usage, exclusions, Gradle `resolutionStrategy`, version catalogs, constraints, and repository settings.
7. Output a **deterministic report** with upgrade recommendations, risk assessment, and ready-to-run commands.

---

## Context and Assumptions
- The repository root contains one or more of: `pom.xml`, `build.gradle`, `settings.gradle`, `build.gradle.kts`, version catalog `gradle/libs.versions.toml`.
- For **Maven** multi-module builds, parent/aggregator `pom.xml` defines `<modules>`.
- For **Gradle**, `settings.gradle(.kts)` includes `include("moduleA", "moduleB")`.
- Project may use dependency management via **BOM** (Maven `<dependencyManagement>`, Gradle `platform(...)`), and/or **version catalogs** (`libs.versions.toml`).
- The analysis should **not** modify files; only read and recommend. Provide optional patch suggestions as diffs.

---

## Inputs (detect automatically; ask only if missing)
- **Build tool**: Maven or Gradle (infer from files).
- **Java version target** (from `maven-compiler-plugin`, `toolchain`, Gradle `java` toolchain, or `sourceCompatibility`).
- **Modules list** (from Maven `<modules>` or Gradle `settings.gradle`).
- **Repositories** (Maven `<repositories>`, Gradle `repositories {}`).
- **Dependency catalogs** (Maven BOM coordinates, Gradle `platform`, `libs.versions.toml`).
- **Scopes/configurations** (Maven: `compile`, `runtime`, `test`, `plugin`; Gradle: `implementation`, `api`, `runtimeOnly`, `testImplementation`).

If any are ambiguous, state the assumption and annotate the report.

---

## Required Commands & Data Collection (execute where applicable)
### Maven
1. **Dependency Tree (full + scope-specific)**
   - `mvn -q dependency:tree -DoutputFile=target/dependency-tree.txt -DappendOutput=true`
   - For test scope: `mvn -q dependency:tree -Dscope=test`
2. **Version Updates (safe upgrade hints)**
   - `mvn -q versions:display-dependency-updates`
   - `mvn -q versions:display-plugin-updates`
3. **Effective POM (to resolve inheritance/management)**
   - `mvn -q help:effective-pom -Doutput=target/effective-pom.xml`
4. **SBOM (CycloneDX)**
   - If plugin present: `mvn -q cyclonedx:makeAggregateBom`  
   - Else recommend plugin:
     ```xml
     <plugin>
       <groupId>org.cyclonedx</groupId>
       <artifactId>cyclonedx-maven-plugin</artifactId>
       <version>2.8.0</version>
       <executions><execution><phase>verify</phase><goals><goal>makeAggregateBom</goal></goals></execution></executions>
     </plugin>
     ```
5. **SCA (OWASP Dependency-Check)**
   - If plugin present: `mvn -q org.owasp:dependency-check-maven:check`
   - Else recommend plugin:
     ```xml
     <plugin>
       <groupId>org.owasp</groupId>
       <artifactId>dependency-check-maven</artifactId>
       <version>9.0.10</version>
       <configuration><format>JSON</format></configuration>
     </plugin>
     ```

### Gradle (Groovy or Kotlin DSL)
1. **Dependency Trees**
   - Per configuration: `./gradlew dependencies --configuration implementation` (repeat for `api`, `runtimeOnly`, `testImplementation`)
   - All: `./gradlew dependencies --scan` (if build scans enabled)
2. **Outdated Dependencies (ben-manes plugin)**
   - If applied:
     ```gradle
     plugins { id "com.github.ben-manes.versions" version "0.51.0" }
     ```
   - Run: `./gradlew dependencyUpdates -Drevision=release`
3. **Resolved Variants & Conflict Info**
   - `./gradlew -q dependencyInsight --dependency <group:artifact> --configuration implementation`
4. **SBOM (CycloneDX)**
   - Plugin:
     ```gradle
     plugins { id "org.cyclonedx.bom" version "1.8.2" }
     ```
   - Run: `./gradlew cyclonedxBom`
5. **SCA**
   - OWASP plugin:
     ```gradle
     plugins { id "org.owasp.dependencycheck" version "9.0.10" }
     ```
   - Run: `./gradlew dependencyCheckAnalyze`

---

## Analysis Procedure (deterministic)
1. **Detect Build System & Modules**  
   - Identify Maven vs Gradle; enumerate modules (Maven `<modules>`, Gradle `settings.gradle`).
2. **Parse Dependency Trees**  
   - Split **direct** vs **transitive**; annotate **scope/configuration**.
   - Detect **convergence** issues (different versions of same GA across modules).
3. **Detect Conflict/Resolution Behavior**
   - Maven: note influence of `<dependencyManagement>` and nearest-wins in tree.
   - Gradle: note **version conflict resolution** (newest wins by default), **platform/BOM alignment**.
4. **Outdated & Upgrade Paths**
   - Use versions reports to propose upgrades:
     - Prefer **BOM/platform** alignments over ad-hoc versions.
     - Respect semver: propose **patch** & **minor** as *low-risk*, **major** only with migration notes.
5. **Risk & License**
   - If SCA/Dependency-Check runs, summarize CVEs by severity and affected modules.
   - If license metadata present (from SBOM or POM), flag **unknown** or **restrictive** licenses.
6. **Hygiene Recommendations**
   - Maven:
     - Centralize versions in `<dependencyManagement>`.
     - Use **BOMs** (e.g., `spring-boot-dependencies`, `jackson-bom`, `micrometer-bom`).
     - Add **exclusions** to remove duplicates/unsafe transitive deps.
     - Keep plugins and compiler toolchains consistent with target Java.
   - Gradle:
     - Use `platform(...)`/`enforcedPlatform(...)` in dependencies or **version catalogs** (`libs.versions.toml`) for alignment.
     - Apply `resolutionStrategy { failOnVersionConflict(); force("group:artifact:version") }` only if necessary, prefer constraints:
       ```gradle
       dependencies {
         constraints {
           implementation("group:artifact:1.2.3")
         }
       }
       ```
     - Prefer **catalog aliases** and `bundles {}` to group commonly used libraries.
7. **SBOM & SCA Outcomes**
   - Produce **CycloneDX** SBOM per module and aggregate.
   - Include a short **vulnerability summary** if SCA is available; otherwise recommend enabling it.
8. **Performance & Build Hygiene Checks**
   - Verify **repository mirrors**, cache settings, and CI build flags.
   - Surface **snapshot** usage; advise replacing with releases unless required.
9. **Generate Deterministic Output (see schema)**
   - One **JSON** block + **human-readable** summary.
   - Include **commands** and optional **patch suggestions** (diffs) for BOM/catalog adoption.

---

## Edge Cases to Handle
- **Multi-module** projects with mixed Maven/Gradle (report per build system).
- **BOM drift**: declared BOM vs actual resolved versions differ.
- **Evictions** in Gradle and **nearest-wins surprises** in Maven trees.
- **Legacy repos** with `compile` scope or deprecated plugins.
- **Private repositories** only accessible via company mirror (note if unreachable).
- **Platform dependencies** (Spring Boot, Quarkus) where direct version overrides are counter-productive.

---

## Output Schema (JSON + Markdown)
Produce **both**:
1) A **JSON** object strictly conforming to the schema below, and  
2) A **Markdown report** for humans with headers and short paragraphs.

### JSON Schema
```json
{
  "project": {
    "buildSystem": "maven|gradle|mixed",
    "javaTarget": "e.g., 17",
    "modules": ["moduleA", "moduleB"]
  },
  "repositories": ["mavenCentral", "companyMirrorUrl", "jcenter(deprecated)"],
  "dependencyInventory": [
    {
      "module": "moduleA",
      "configurationOrScope": "implementation|api|runtimeOnly|testImplementation|compile|runtime|test",
      "direct": [{"group":"g","artifact":"a","version":"x.y.z"}],
      "transitive": [{"group":"g","artifact":"b","version":"x.y.z"}]
    }
  ],
  "conflicts": [
    {
      "ga": "group:artifact",
      "versions": ["1.2.0","1.3.1"],
      "affectedModules": ["moduleA","moduleB"],
      "recommendedFix": "Align via BOM/platform or Gradle constraint"
    }
  ],
  "outdated": [
    {
      "ga": "group:artifact",
      "current": "1.2.0",
      "latestMinorOrPatch": "1.2.7",
      "latestMajor": "2.0.3",
      "riskNotes": "Major introduces breaking changes (Java 21 only)"
    }
  ],
  "securityAndLicense": {
    "sbom": {"format": "CycloneDX", "files": ["bom.xml","bom.json"]},
    "vulnerabilities": [
      {"ga":"g:a","version":"1.2.0","cve":"CVE-XXXX-YYYY","severity":"HIGH","module":"moduleA"}
    ],
    "licenseFlags": [
      {"ga":"g:a","license":"UNKNOWN","module":"moduleB"}
    ]
  },
  "recommendations": {
    "maven": [
      "Add <dependencyManagement> with BOM spring-boot-dependencies 3.4.x",
      "Add exclusions for vulnerable transitive dependency g:a"
    ],
    "gradle": [
      "Adopt version catalog libs.versions.toml",
      "Use enforcedPlatform(...) for Spring alignment"
    ],
    "commands": [
      "mvn versions:display-dependency-updates",
      "./gradlew dependencyUpdates -Drevision=release",
      "mvn cyclonedx:makeAggregateBom",
      "./gradlew cyclonedxBom"
    ],
    "optionalPatches": [
      {"file":"pom.xml","diff":"---\n+ <dependencyManagement>...</dependencyManagement>\n"}
    ]
  }
}
``
