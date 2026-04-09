## Hardened Infrastructure Baseline (Phase 1 Complete)
- **Commit SHA:** df37bc3
- **Audit Date:** 2026-04-09
- **Status:** Verified Stable (April 2026 Registry)
- **Scope:** All active Docker images pinned to immutable tags.

Service Version Registry:

Service Component *=updated	File Path				Current Tag	Hardened Pin (Verified Stable)
* Langfuse Worker		services/langfuse/docker-compose.yaml	:3		:v3.164.0
* Langfuse Server		services/langfuse/docker-compose.yaml	:3		:v3.164.0
* Open WebUI			services/openwebui/docker-compose.yaml	:main		:v0.5.11
* Neo4j				services/neo4j/docker-compose.yaml	:5		:v5.26.24
* Clickhouse			services/clickhouse/docker-compose.yaml	(none)		:26.2.8.15-alpine
* Zep AI			services/zep/docker-compose.yaml	:latest		:1.5.24
* Graphiti			services/zep/docker-compose.yaml	:0.3		:0.3.12
* Redis				services/redis/docker-compose.yaml	:7		:7.4.2-alpine
* Ofelia (Backup)		services/pgbackup/docker-compose.yml	:latest		:v0.3.12
* MinIO				services/minio/docker-compose.yaml	(none)		:RELEASE.2025-10-15T17-29-55Z
* n8n				services/n8n/docker-compose.yaml	:latest		:2.16.0
* Qdrant			services/qdrant/docker-compose.yaml	(none)		:v1.12.1
* Flowise			services/flowise/docker-compose.yaml	(none)		:2.4.1
* Prometheus			services/prometheus/docker-compose.yaml	(none)		:v3.1.0
* Ollama			services/ollama/docker-compose.yaml	:latest		:0.20.4
* Ollama (ROCm)			services/ollama/docker-compose.yaml	:rocm		:0.20.4-rocm
* Dozzle			services/dozzle/docker-compose.yaml	:latest		:v8.11.7
