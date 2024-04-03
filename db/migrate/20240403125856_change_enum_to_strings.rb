class ChangeEnumToStrings < ActiveRecord::Migration[7.1]
  ENUMS = [
    {
      table: :agent_roles,
      column: :access_level,
      values: { basic: 0, admin: 1 }
    },
    {
      table: :csv_exports,
      column: :kind,
      values: { users_csv: 0, users_participations_csv: 1 },
    },
    {
      table: :invitations,
      column: :format,
      values: { sms: 0, email: 1, postal: 2 },
    },
    {
      table: :motifs,
      column: :location_type,
      values: { public_office: 0, phone: 1, home: 2 }
    },
    {
      table: :notifications,
      column: :event,
      values: { participation_created: 0, participation_updated: 1, participation_cancelled: 2, participation_reminder: 3 }
    },
    {
      table: :notifications,
      column: :format,
      values: { sms: 0, email: 1, postal: 2 }
    },
    {
      table: :orientations,
      column: :orientation_type,
      values: { social: 0, pro: 1, socio_pro: 2 }
    },
    {
      table: :rdvs,
      column: :created_by,
      values: { agent: 0, user: 1, file_attente: 2, prescripteur: 3 }
    },
    {
      table: :templates,
      column: :model,
      values: { standard: 0, atelier: 1, phone_platform: 2, short: 3, atelier_enfants_ados: 4 }
    },
    {
      table: :users,
      column: :role,
      values: { demandeur: 0, conjoint: 1 }
    },
    {
      table: :users,
      column: :title,
      values: { monsieur: 0, madame: 1 }
    },
    {
      table: :users,
      column: :created_through,
      values: { rdv_insertion: 0, rdv_solidarites: 1 }
    },
    {
      table: :webhook_endpoints,
      column: :signature_type,
      values: { hmac: 0, jwt: 1 }
    },
    {
      table: :rdv_contexts,
      column: :status,
      values: { not_invited: 0, invitation_pending: 1, rdv_pending: 2, rdv_needs_status_update: 3, rdv_noshow: 4, rdv_revoked: 5, rdv_excused: 6, rdv_seen: 7, multiple_rdvs_cancelled: 8, closed: 9 }
    },
    {
      table: :rdvs,
      column: :status,
      values: { unknown: 0, seen: 2, excused: 3, revoked: 4, noshow: 5 }
    },
    {
      table: :participations,
      column: :status,
      values: { unknown: 0, seen: 2, excused: 3, revoked: 4, noshow: 5 }
    }
  ].freeze

  def up
    ENUMS.each do |enum|
      change_column enum[:table], enum[:column], :string

      values = enum[:values].map do |k,v|
        "WHEN '#{v}' THEN '#{k}' "
      end

      execute <<-SQL.squish
        UPDATE #{enum[:table]}
        SET #{enum[:column]} = CASE #{enum[:column]} #{values.join} END
      SQL
    end
  end

  def down
    ENUMS.each do |enum|
      values = enum[:values].map do |k,v|
        "WHEN '#{k}' THEN #{v} "
      end

      execute <<-SQL.squish
        UPDATE #{enum[:table]}
        SET #{enum[:column]} = CASE #{enum[:column]} #{values.join} END
      SQL

      change_column enum[:table], enum[:column], :integer, using: "#{enum[:column]}::integer"
    end
  end
end
