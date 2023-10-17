# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    "v1/api.json" => {
      openapi: "3.0.1",
      info: {
        title: "API RDV insertion",
        version: "v1",
        description: File.read(Rails.root.join("docs/api/v1/description_api.md"))
      },
      components: {
        securitySchemes: {
          access_token: {
            type: :apiKey,
            name: "access-token",
            in: :header
          },
          uid: {
            type: :apiKey,
            name: "uid",
            in: :header
          },
          client: {
            type: :apiKey,
            name: "client",
            in: :header
          }
        },
        schemas: {
          rdv: {
            type: "object",
            properties: {
              id: { type: "integer" },
              address: { type: "string" },
              agents: {
                type: "array",
                items: { "$ref" => "#/components/schemas/agent" }
              },
              cancelled_at: { type: "string", nullable: true },
              collectif: { type: "boolean" },
              created_by: { type: "string", enum: %w[agent user prescripteur] },
              duration_in_min: { type: "integer" },
              lieu: { "$ref" => "#/components/schemas/lieu" },
              max_participants_count: { type: "integer", nullable: true },
              motif: { "$ref" => "#/components/schemas/motif" },
              organisation: { "$ref" => "#/components/schemas/organisation" },
              starts_at: { type: "string" },
              status: { type: "string", enum: %w[unknown seen excused revoked noshow] },
              users: {
                type: "array",
                items: { "$ref" => "#/components/schemas/user" }
              },
              users_count: { type: "integer" },
              uuid: { type: "string" },
              rdv_solidarites_rdv_id: { type: "integer" }
            },
            required: %w[
              id starts_at duration_in_min cancelled_at address uuid created_by status
              context users_count max_participants_count rdv_solidarites_rdv_id
              agents lieu motif users organisation
            ]
          },
          rdv_with_root: {
            type: "object",
            properties: {
              rdv: { "$ref" => "#/components/schemas/rdv" }
            },
            required: %w[user]
          },
          agents: {
            type: "object",
            properties: {
              agents: {
                type: "array",
                items: { "$ref" => "#/components/schemas/agent" }
              }
            },
            required: %w[agents]
          },
          agent: {
            type: "object",
            properties: {
              id: { type: "integer" },
              email: { type: "string" },
              first_name: { type: "string", nullable: true },
              last_name: { type: "string", nullable: true },
              rdv_solidarites_agent_id: { type: "integer" }
            },
            required: %w[id email first_name last_name rdv_solidarites_agent_i]
          },
          user_with_root: {
            type: "object",
            properties: {
              user: { "$ref" => "#/components/schemas/user" }
            },
            required: %w[user]
          },
          users: {
            type: "object",
            properties: {
              users: {
                type: "array",
                items: { "$ref" => "#/components/schemas/user" }
              }
            },
            required: %w[users]
          },
          user: {
            type: "object",
            nullable: true,
            properties: {
              id: { type: "integer" },
              address: { type: "string", nullable: true },
              affiliation_number: { type: "string", nullable: true },
              bith_date: { type: "string", format: "date", nullable: true },
              bith_name: { type: "string", nullable: true },
              created_at: { type: "string" },
              email: { type: "string", nullable: true },
              first_name: { type: "string" },
              last_name: { type: "string" },
              phone_number: { type: "string", nullable: true },
              department_internal_id: { type: "string", nullable: true },
              rights_opening_date: { type: "string", nullable: true },
              title: { type: "string", enum: %w[monsieur madame] },
              uid: { type: "string", nullable: true },
              role: { type: "string", nullable: true, enum: %w[demandeur conjoint] },
              nir: { type: "string", nullable: true },
              pole_emploi_id: { type: "string", nullable: true },
              carnet_de_bord_carnet_id: { type: "string", nullable: true },
              rdv_solidarites_user_id: { type: "integer" }
            },
            required: %w[
              id uid affiliation_number role created_at department_internal_id
              first_name last_name title address phone_number email birth_date
              rights_opening_date birth_name rdv_solidarites_user_id nir pole_emploi_id
              carnet_de_bord_carnet_id
            ]
          },
          organisation_with_root: {
            type: "object",
            properties: {
              organisation: { "$ref" => "#/components/schemas/organisation" }
            },
            required: %w[organisation]
          },
          organisations: {
            type: "object",
            properties: {
              organisations: {
                type: "array",
                items: { "$ref" => "#/components/schemas/organisation" }
              }
            },
            required: %w[organisations]
          },
          organisation: {
            type: "object",
            properties: {
              id: { type: "integer" },
              email: { type: "string", nullable: true },
              name: { type: "string" },
              phone_number: { type: "string" },
              department_number: { type: "string" },
              rdv_solidarites_organisation_id: { type: "integer" },
              motif_categories: {
                type: "array",
                items: { "$ref" => "#/components/schemas/motif_category" }
              }
            },
            required: %w[id name email phone_number department_number rdv_solidarites_organisation_id motif_categories]
          },
          invitation: {
            type: "object",
            properties: {
              id: { type: "integer" },
              format: { type: "string", enum: %w[sms postal string] },
              sent_at: { type: "string" },
              clicked: { type: "boolean" },
              motif_category: { "$ref" => "#/components/schemas/motif_category" }
            },
            required: %w[id format sent_at clicked rdv_with_referents motif_category]
          },
          # phone_number rdv_solidarites_lieu_id
          lieu: {
            type: "object",
            properties: {
              address: { type: "string" },
              name: { type: "string" },
              phone_number: { type: "string", nullable: true },
              rdv_solidarites_lieu_id: { type: "integer" }
            },
            required: %w[address name phone_number rdv_solidarites_lieu_id]
          },
          motifs: {
            type: "object",
            properties: {
              motifs: {
                type: "array",
                items: { "$ref" => "#/components/schemas/motif" }
              }
            },
            required: %w[motifs]
          },
          #   collectif  follow_up
          motif: {
            type: "object",
            properties: {
              rdv_solidarites_motif_id: { type: "integer" },
              location_type: { type: "string", enum: %w[public_office phone home] },
              name: { type: "string" },
              motif_category: { "$ref" => "#/components/schemas/motif_category" },
              collectif: { type: "boolean" },
              follow_up: { type: "boolean" }
            },
            required: %w[rdv_solidarites_motif_id name collectif location_type follow_up motif_category],
          },
          motif_category: {
            type: "object",
            properties: {
              id: { type: "integer" },
              name: { type: "string" },
              short_name: { type: "string" }
            },
            required: %w[id name short_name]
          },
          errors_unprocessable_entity: {
            type: "object",
            properties: {
              errors: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    error_details: { type: "string" }
                  },
                  required: %w[error_details]
                }
              },
              required: %w[errors]
            }
          },
          error_authentication: {
            type: "object",
            properties: {
              errors: {
                type: "array",
                items: { type: "string" }
              }
            },
            required: %w[errors]
          },
          error_forbidden: {
            type: "object",
            properties: {
              errors: {
                type: "array",
                items: { type: "string" }
              }
            },
            required: %w[errors]
          },
          error_not_found: {
            type: "object",
            properties: {
              not_found: { type: "string" }
            },
            required: %w[not_found]
          }
        }
      },
      tags: [
        {
          name: "Invitation",
          description:
            "Désigne une invitation à prendre rdv.
             Elle est liée à un·e usager·ère, a un format (sms, mail ou postal), une catégorie de motif.
             Elle est unique."
        },
        {
          name: "User",
          description:
            "Désigne le compte unique d'un·e usager·ère.
            Il contient les informations de l'état civil ainsi que des informations
            communes comme le NIR, l'ID interne au département."
        },
        {
          name: "Agent",
          description: "Désigne un·e agent·e. Un·e agent·e est lié·e à une ou plusieurs organisations."
        },
        {
          name: "RDV",
          description:
            "Désigne un rendez-vous.
            Il contient des informations sur le rendez-vous lui-même, le ou les agent·es,
            le ou les usager·ères, le lieu, le motif, l'organisation."
        },
        {
          name: "Motif",
          description:
            "Désigne le motif d'un rendez-vous.
            Il contient des informations telles que le nom du motif, s'il est téléphonique,
            sur place ou à domicile, ainsi que des détails annexes (collectif ou non, catégorie)."
        },
        {
          name: "Organisation",
          description: "Désigne une organisation. Une organisation contient des agent·es."
        }
      ],
      servers: [
        {
          url: "https://www.rdv-insertion-demo.fr",
          description: "Serveur de démo"
        },
        {
          url: "https://www.rdv-insertion.fr",
          description: "Serveur de production"
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :json
end
