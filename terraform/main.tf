terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.12.2"
    }
  }
}

provider "docker" {
  host = "tcp://localhost:2375"
}

resource "docker_network" "internal" {
  name = "internal"
}

resource "docker_image" "kratos" {
  name = "oryd/kratos:v0.5.5-alpha.1"
}

resource "docker_image" "postgres" {
  name = "postgres:9.6"
}

resource "docker_container" "kratos-postgres" {
  image = docker_image.postgres.latest
  name = "kratos-postgres"
  env = ["POSTGRES_USER=kratos", "POSTGRES_PASSWORD=secret", "POSTGRES_DB=kratos"]
  ports {
    internal = 5432
    external = 5432
  }
  networks_advanced {
    name = docker_network.internal.name
  }
}

resource "docker_container" "kratos-migrate" {
  image = docker_image.kratos.latest
  name  = "kratos-migrate"
  env = ["DSN=postgres://kratos:secret@kratos-postgres:5432/kratos?sslmode=disable&max_conns=20&max_idle_conns=4"]
  command = ["migrate","sql","-e","--yes"]
  rm=true
  networks_advanced {
    name = docker_network.internal.name
  }
  depends_on = [docker_container.kratos-postgres]
}

resource "docker_container" "kratos" {
  image = docker_image.kratos.latest
  name  = "kratos"
  command = ["serve", "-c", "/etc/config/kratos/kratos.yml", "--dev"]
  restart = "unless-stopped"
  networks_advanced {
    name = docker_network.internal.name
  }
  ports {
    internal = 4433
    external = 4433
  }
  depends_on = [docker_container.kratos-migrate]
  upload {
    file = "/etc/config/kratos/identity.schema.json"
    content = jsonencode({
      "$id": "https://schemas.ory.sh/presets/kratos/quickstart/email-password/identity.schema.json",
      "$schema": "http://json-schema.org/draft-07/schema#",
      "title": "Person",
      "type": "object",
      "properties": {
        "traits": {
          "type": "object",
          "properties": {
            "email": {
              "type": "string",
              "format": "email",
              "title": "E-Mail",
              "minLength": 3,
              "ory.sh/kratos": {
                "credentials": {
                  "password": {
                    "identifier": true
                  }
                },
                "verification": {
                  "via": "email"
                },
                "recovery": {
                  "via": "email"
                }
              }
            },
            "name": {
              "type": "object",
              "properties": {
                "first": {
                  "type": "string"
                },
                "last": {
                  "type": "string"
                }
              }
            }
          },
          "required": [
            "email"
          ],
          "additionalProperties": false
        }
      }
    })
  }
  upload {
    file = "/etc/config/kratos/kratos.yml"
    content = yamlencode({
      version:  "v0.5.5-alpha.1"
      dsn: "postgres://kratos:secret@kratos-postgres:5432/kratos?sslmode=disable&max_conns=20&max_idle_conns=4"
      serve: {
        public: {
          base_url: "http://127.0.0.1:4433/"
          cors: {
            enabled: true,
            allowed_origins: [
              "http://127.0.0.1:8080"
            ]
          }
        },
        admin: {
          base_url: "http://kratos:4434"
        }
      }
      selfservice: {
        default_browser_return_url: "http://127.0.0.1:8080/"
        whitelisted_return_urls: [
          "http://127.0.0.1:8080"
        ],
        methods: {
          password: {
            enabled: true
          },
          link: {
            enabled: true
          }
        },
        flows: {
          error: {
            ui_url: "http://127.0.0.1:8080/error"
          },
          settings: {
            ui_url: "http://127.0.0.1:8080/settings",
            privileged_session_max_age: "15m"
          },
          recovery: {
            enabled: true,
            ui_url: "http://127.0.0.1:8080/auth/recovery"
          },
          verification: {
            enabled: true,
            ui_url: "http://127.0.0.1:8080/verify",
            after: {
              default_browser_return_url: "http://127.0.0.1:8080/"
            }
          },
          logout: {
            after: {
              default_browser_return_url: "http://127.0.0.1:8080/"
            }
          },
          login: {
            ui_url: "http://127.0.0.1:8080/auth/login",
            lifespan: "10m"
          },
          registration: {
            ui_url: "http://127.0.0.1:8080/auth/register",
            lifespan: "10m",
            after: {
              oidc: {
                hooks: [
                  {
                    hook: "session"
                  }
                ]
              }
              password: {
                hooks: [
                  {
                    hook: "session"
                  }
                ]
              }
            }
          }
        }
      },
      log: {
        level: "debug",
        format: "text",
        leak_sensitive_values: true,
      }
      secrets: {
        cookie: ["SECURE-COOKIE-SECRET"]
      },
      hashers: {
        argon2: {
          parallelism: 1,
          memory: 131072,
          iterations: 2,
          salt_length: 16,
          key_length: 16
        }
      }
      identity: {
        default_schema_url: "file:///etc/config/kratos/identity.schema.json"
      },
      courier: {
        smtp: {
          connection_uri: "smtps://test:test@mailslurper:1025/?skip_ssl_verify=true"
        }
      }
    })
  }
}

resource "docker_image" "auth-ui" {
  name = "auth-ui"
  //noinspection HCLUnknownBlockType
  build {
    path = "../auth-ui"
    tag = ["auth-ui:dev"]
  }
}

resource "docker_container" "auth-ui" {
  image = docker_image.auth-ui.latest
  name = "auth-ui"
  ports {
    internal = 80
    external = 8080
  }
  networks_advanced {
    name = docker_network.internal.name
  }
}

resource "docker_image" "mailslurper" {
  name = "oryd/mailslurper:latest-smtps"
}

resource "docker_container" "mailslurper" {
  image = docker_image.mailslurper.latest
  name = "mailslurper"
  ports {
    internal = 4436
    external = 4436
  }
  networks_advanced {
    name = docker_network.internal.name
  }
}